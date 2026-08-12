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
        folder = 'daily_notes/',
        date_format = '%Y-%m-%d',
        default_tags = { 'daily-notes' },
      },
      -- Optional, customize how note IDs are generated given an optional title.
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ''
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. '-' .. suffix
      end,
    },
  },
}
