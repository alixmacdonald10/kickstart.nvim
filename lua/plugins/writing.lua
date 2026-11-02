return {
  { 'rhysd/vim-grammarous' },
  {
    'chomosuke/typst-preview.nvim',
    lazy = true,
    ft = 'typst',
    version = '1.*',
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
  {
    'epwalsh/obsidian.nvim',
    version = '*',
    lazy = false,
    -- ft = 'markdown',
    event = {
      --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
      --   -- refer to `:h file-pattern` for more examples
      'BufReadPre '
        .. vim.fn.expand '~'
        .. '/vaults/*/*.md',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      workspaces = {
        { name = 'software', path = '~/vaults/vault-software' },
        {
          name = 'writing',
          path = '~/vaults/vault-writing',
        },
      },
      mappings = {
        -- Toggle check-boxes.
        ['<leader>ch'] = {
          action = function()
            return require('obsidian').util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
      },
      templates = {
        folder = 'templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
      },
      daily_notes = {
        folder = 'daily/',
        date_format = '%Y-%m-%d',
        default_tags = { 'daily-notes' },
      },
    },
  },
}
