return {
  {
    'laytan/cloak.nvim',
    opts = {},
    config = function(_, opts)
      require('cloak').setup(opts)
      -- Define the keybind to toggle cloak
      vim.api.nvim_set_keymap('n', '<leader>tc', ':CloakToggle<CR>', { noremap = true, silent = true })
    end,
  },
}
