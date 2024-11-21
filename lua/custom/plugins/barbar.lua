return {
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },
  init = function()
    vim.g.barbar_auto_setup = false

    local map = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }

    -- Move to previous/next
    map('n', '<leader>bn', '<Cmd>BufferNext<CR>', opts)
    map('n', '<leader>bp', '<Cmd>BufferPrevious<CR>', opts)
    map('n', '<leader>bc', '<Cmd>BufferClose<CR>', opts)
  end,
  opts = {
    -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
    animation = true,
  },
  version = '^1.0.0', -- optional: only update when a new 1.x version is released
}
