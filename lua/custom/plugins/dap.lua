-- # CUSTOM DAP CONFIG
--   custom dap configurations per project can be stored in a .vscode/launch.json in the root of your project. This is then ran using the :lua require("dap").continue() or the custom key binding defined in the rustaceanvim plugin 
--
--   An example config is shown below:
--              {
--                "version": "0.2.0",
--     "            configurations": [
              --                      {
--             "name": "Cargo Run QObserver",
--             "type": "codelldb",
--             "request": "launch",
--             "program": "${workspaceFolder}/target/debug/qobserver",
--             "args": [
--                 "--remote-secrets-provider=azure-key-vault:name=vqadmintst,resource-group=rg-qerent-infra-testing-uks-1"
--             ],
--             "cwd": "${workspaceFolder}",
--             "preLaunchTask": "cargo build",
--             "sourceLanguages": ["rust"],
--             "env": {}
--         }
--     ]
--   }
--

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<leader>dq',
      function()
          local dap = require('dap')
          local dapui = require('dapui')
          dap.disconnect()
          dap.stop()
          dapui.close()
      end,
      desc = 'Debug: Quit',
    },
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>tb',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>dr',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    
    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {}

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close


    if not dap.adapters then dap.adapters = {} end
    dap.adapters["probe-rs-debug"] = {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fn.expand "$HOME/.cargo/bin/probe-rs",
        args = { "dap-server", "--port", "${port}" },
      },
    }
    -- Connect the probe-rs-debug with rust files. Configuration of the debugger is done via project_folder/.vscode/launch.json
    require("dap.ext.vscode").type_to_filetypes["probe-rs-debug"] = { "rust" }
    -- Set up of handlers for RTT and probe-rs messages.
    -- In addition to nvim-dap-ui I write messages to a probe-rs.log in project folder
    -- If RTT is enabled, probe-rs sends an event after init of a channel. This has to be confirmed or otherwise probe-rs wont sent the rtt data.
    dap.listeners.before["event_probe-rs-rtt-channel-config"]["plugins.nvim-dap-probe-rs"] = function(session, body)
      local utils = require "dap.utils"
      utils.notify(
        string.format('probe-rs: Opening RTT channel %d with name "%s"!', body.channelNumber, body.channelName)
      )
      local file = io.open("probe-rs.log", "a")
      if file then
        file:write(
          string.format(
            '%s: Opening RTT channel %d with name "%s"!\n',
            os.date "%Y-%m-%d-T%H:%M:%S",
            body.channelNumber,
            body.channelName
          )
        )
      end
      if file then file:close() end
      session:request("rttWindowOpened", { body.channelNumber, true })
    end
    -- After confirming RTT window is open, we will get rtt-data-events.
    -- I print them to the dap-repl, which is one way and not separated.
    -- If you have better ideas, let me know.
    dap.listeners.before["event_probe-rs-rtt-data"]["plugins.nvim-dap-probe-rs"] = function(_, body)
      local message =
        string.format("%s: RTT-Channel %d - Message: %s", os.date "%Y-%m-%d-T%H:%M:%S", body.channelNumber, body.data)
      local repl = require "dap.repl"
      repl.append(message)
      local file = io.open("probe-rs.log", "a")
      if file then file:write(message) end
      if file then file:close() end
    end
    -- Probe-rs can send messages, which are handled with this listener.
    dap.listeners.before["event_probe-rs-show-message"]["plugins.nvim-dap-probe-rs"] = function(_, body)
      local message = string.format("%s: probe-rs message: %s", os.date "%Y-%m-%d-T%H:%M:%S", body.message)
      local repl = require "dap.repl"
      repl.append(message)
      local file = io.open("probe-rs.log", "a")
      if file then file:write(message) end
      if file then file:close() end
    end

  end,
  },
}

  
