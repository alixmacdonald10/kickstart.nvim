return {
  -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    -- NOTE: Must be loaded before dependants. `config = true` is deliberately absent:
    -- `mason.setup()` is called explicitly below, and calling it twice re-appends the
    -- default registries, which logs "Ignoring duplicate registry entry" every startup.
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },

    -- Allows extra capabilities provided by nvim-cmp
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    -- Brief aside: **What is LSP?**
    --
    -- LSP is an initialism you've probably heard, but might not understand what it is.
    --
    -- LSP stands for Language Server Protocol. It's a protocol that helps editors
    -- and language tooling communicate in a standardized fashion.
    --
    -- In general, you have a "server" which is some tool built to understand a particular
    -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
    -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
    -- processes that communicate with some "client" - in this case, Neovim!
    --
    -- LSP provides Neovim with features like:
    --  - Go to definition
    --  - Find references
    --  - Autocompletion
    --  - Symbol Search
    --  - and more!
    --
    -- Thus, Language Servers are external tools that must be installed separately from
    -- Neovim. This is where `mason` and related plugins come into play.
    --
    -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
    -- and elegantly composed help section, `:help lsp-vs-treesitter`

    --  This function gets run when an LSP attaches to a particular buffer.
    --    That is to say, every time a new file is opened that is associated with
    --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    --    function will be executed to configure the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- NOTE: Remember that Lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- Find references for the word under your cursor.
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>lD', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>lds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>la', vim.lsp.buf.code_action, '[Lsp] code [A]ction', { 'n', 'x' })

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- NOTE: inlay hints are toggled with `<leader>th` by `Snacks.toggle.inlay_hints()`
        -- in lua/plugins/snacks.lua. A buffer-local mapping here would be shadowed by it
        -- anyway (snacks maps at startup), so it lives in one place only.
      end,
    })

    -- Diagnostic display.
    --
    -- NOTE: Neovim defaults both `virtual_text` and `virtual_lines` to false, so
    -- without this diagnostics only appear as a gutter sign plus an underline --
    -- the message itself is never rendered next to the code.
    local diagnostic_signs = true
    if vim.g.have_nerd_font then
      local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
      diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      diagnostic_signs = { text = diagnostic_signs }
    end

    -- Compact '●' text at the end of every diagnostic line *except* the one the
    -- cursor is on -- that line gets the full, untruncated message rendered
    -- below it instead, so the common case needs no keypress.
    --
    -- `source = 'if_many'` matters for Python, where ruff (lint) and ty (types)
    -- both attach to the same buffer and an unattributed message is ambiguous.
    local virt_text = { prefix = '●', source = 'if_many', spacing = 2, current_line = false }
    local virt_lines = { current_line = true }

    vim.diagnostic.config {
      signs = diagnostic_signs,
      underline = true,
      severity_sort = true,
      update_in_insert = false,
      virtual_text = virt_text,
      virtual_lines = virt_lines,
      float = { source = 'if_many', border = 'rounded' },
    }

    -- Expand to full-width lines under *every* diagnostic, not just the cursor's.
    -- NOTE: `<leader>tv` is already TransparentToggle (lua/plugins/transparent.lua).
    vim.keymap.set('n', '<leader>tV', function()
      local current = vim.diagnostic.config().virtual_lines
      local expanded = type(current) ~= 'table' or current.current_line ~= true
      vim.diagnostic.config {
        virtual_lines = expanded and virt_lines or true,
        virtual_text = expanded and virt_text or false,
      }
    end, { desc = 'Toggle diagnostic [V]irtual lines' })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    --  NOTE: every key here must be a real config name shipped by nvim-lspconfig
    --  (see `lsp/*.lua` in that plugin, or `:help lspconfig-all`). Formatters,
    --  linters and scanners are *not* language servers -- those belong in
    --  `tools` below, which is what gets handed to mason-tool-installer.
    local servers = {
      -- rust_analyzer = {},  # NOTE: rust-analyzer is managed via rustup

      -- ruff owns lint, style and import rules; `ty` (see `external_servers`
      -- below) owns types. Formatting goes through conform
      -- (`ruff_organize_imports`, `ruff_format` in lua/plugins/conform.lua), so
      -- the server's own formatter is never asked for.
      --
      -- NOTE: ruff takes its configuration through `init_options`, not `settings`.
      -- Nesting it under `settings` (as this used to) sends it as a
      -- workspace/didChangeConfiguration payload that ruff ignores.
      ruff = {
        -- ruff's hover only explains `noqa` codes. Leaving it on means every
        -- hover in a Python buffer returns two results and `ty`'s type
        -- information -- the one that's actually useful -- is no longer
        -- guaranteed to be first.
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      },
      sqlls = {},
      marksman = {},

      -- NOTE: terraformls is deliberately absent. It claims the same `terraform`
      -- filetype as tofu_ls, so both would attach and index the workspace twice.
      --
      -- `root_markers` includes `.git`, so in a repo that also builds Rust the
      -- indexer walks `target/`. That walk goes to stderr, and Neovim records LSP
      -- stderr at ERROR unconditionally -- which is what grew lsp.log to 282MB.
      tofu_ls = {
        init_options = {
          indexing = {
            ignoreDirectoryNames = { 'target', 'node_modules', 'dist', '.venv' },
          },
        },
      },

      helm_ls = {},
      dockerls = {},
      docker_compose_language_service = {},
      tinymist = {},
      tflint = {},

      lemminx = {}, --xml
      taplo = {}, --toml
      jsonls = {},
      yamlls = {},
      texlab = {},
      -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
      --
      -- Some languages (like typescript) have entire language plugins that can be useful:
      --    https://github.com/pmizio/typescript-tools.nvim
      --
      -- But for many setups, the LSP (`ts_ls`) will work just fine
      -- ts_ls = {},
      --

      lua_ls = {
        -- cmd = {...},
        -- filetypes = { ...},
        -- capabilities = {},
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },
    }

    -- Servers whose binary does not come from Mason. `uvx` fetches and caches
    -- `ty` on demand, so there is no Mason package to keep in sync and we always
    -- run the current release. Cost: the very first attach in a fresh uv cache
    -- pays for the download, and it needs network that once.
    --
    -- `/usr/bin` is prepended to PATH in init.lua and `uvx` lives at
    -- /usr/bin/uvx, so this `cmd` resolves from inside Neovim as-is.
    local external_servers = {
      ty = { cmd = { 'uvx', 'ty', 'server' } },
    }

    -- Ensure the servers and tools above are installed
    --  To check the current status of installed tools and/or manually install
    --  other tools, you can run
    --    :Mason
    --
    --  You can press `g?` for help in this menu.
    require('mason').setup()

    -- Formatters, linters and scanners. These are plain Mason packages -- they are
    -- not language servers and must never appear in `servers` above.
    local tools = {
      'stylua', -- Used to format Lua code
      -- NOTE: no black -- Python formatting is ruff's (`ruff_organize_imports`,
      -- `ruff_format` in lua/plugins/conform.lua). Adding black back would give
      -- conform two formatters fighting over the same buffer.
      'buf', -- proto fmt
      'prettierd',
      'hadolint',
      'tfsec',
      'trivy',
      'yamlfix',
      'yamllint',
    }

    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, tools)
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    -- NOTE: mason-lspconfig v2 removed `setup { handlers = ... }`; it now only
    -- accepts `ensure_installed` and `automatic_enable`. Server configuration goes
    -- through Neovim's own `vim.lsp.config()`, which merges on top of the defaults
    -- that nvim-lspconfig ships in its `lsp/` directory.
    vim.lsp.config('*', { capabilities = capabilities })
    -- `tbl_extend('error', ...)` is deliberate: it raises if a name is ever added
    -- to both tables rather than silently letting one win.
    for name, config in pairs(vim.tbl_extend('error', servers, external_servers)) do
      if next(config) ~= nil then
        vim.lsp.config(name, config)
      end
    end

    require('mason-lspconfig').setup {
      -- mason-tool-installer owns installation, so nothing to install here.
      ensure_installed = {},
      -- Enable exactly the servers configured above, and nothing else Mason
      -- happens to have installed. rust_analyzer is deliberately absent -- it is
      -- managed by rustaceanvim (see lua/plugins/rust.lua).
      automatic_enable = vim.tbl_keys(servers),
    }

    -- `automatic_enable` above only covers servers Mason installed, so anything
    -- in `external_servers` has to be enabled by hand.
    vim.lsp.enable(vim.tbl_keys(external_servers))
  end,
}
