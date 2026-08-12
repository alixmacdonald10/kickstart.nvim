return {
  {
    'catppuccin/nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    -- init = function()
    --   vim.cmd.colorscheme 'kanagawa-wave'
    -- end,
  },
}
