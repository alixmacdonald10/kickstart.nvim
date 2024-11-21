return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'noice.nvim', -- Assuming noice.nvim is a plugin, adjust as necessary
  },
  opts = {
    options = {
      icons_enabled = true,
      component_separators = '|',
      section_separators = '',
    },
    sections = {
      lualine_a = {
        {
          'buffers',
        },
      },
    },
  },
  version = '^1.0.0', -- optional: specify version if needed
}
