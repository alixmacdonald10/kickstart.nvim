return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<leader>tt]],
      direction = 'vertical',
      size = 75,
      persist_size = true
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
