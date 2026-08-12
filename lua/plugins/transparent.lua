return {
  {
    'xiyaowong/transparent.nvim',
    opts = {},
    config = function(_, opts)
      require('transparent').setup(opts)
      vim.keymap.set('n', '<leader>tv', ':TransparentToggle<CR>', { noremap = true, silent = true, desc = 'Toggle Transparency' })
    end,
  },
}
