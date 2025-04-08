return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<leader>tt]],
      direction = 'float',
      float_opts = {
        border = 'curved',
        winblend = 3,
        title_pos = 'center'
      },
    })
    
    -- Create an autocommand to disable spell check in ToggleTerm buffers
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "toggleterm" then
          vim.opt_local.spell = false
        end
      end,
    })
  end,
}
