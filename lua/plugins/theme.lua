-- return {
--   'catppuccin/nvim',
--   priority = 1000, -- Make sure to load this before all the other start plugins.
--   init = function()
--     vim.cmd.colorscheme 'catppuccin-mocha'
--     vim.cmd.hi 'Comment gui=none'
--   end,
-- }
return {
  'neanias/everforest',
  lazy = false,
  priority = 1000,
  config = function()
    vim.g.everforest_background = 'medium' -- 'hard', 'medium', 'soft'
    vim.g.everforest_better_performance = 1

    vim.cmd.colorscheme 'everforest'
  end,
}
