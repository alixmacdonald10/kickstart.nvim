return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    dashboard = { enabled = true },
    dim = { enabled = true },
    indent = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    statuscolumn = { enabled = true },
    terminal = { enabled = true },
    lazygit = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true } -- Wrap notifications
      }
    }
  },
  keys = {
    -- notifier
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    -- lazygit
    { "<leader>Lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    -- terminal
    {"<leader>tt",  function() Snacks.terminal() end, desc = "Toggle Terminal" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>tL")
        Snacks.toggle.diagnostics():map("<leader>td")
        Snacks.toggle.line_number():map("<leader>tl")
        Snacks.toggle.treesitter():map("<leader>tT")
        Snacks.toggle.inlay_hints():map("<leader>th")
        Snacks.toggle.indent():map("<leader>tg")
        Snacks.toggle.dim():map("<leader>tD")
      end,
    })
  end,
}
