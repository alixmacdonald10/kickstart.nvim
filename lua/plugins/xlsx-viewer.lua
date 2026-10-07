return {
  'beargruug/xls-viewer.nvim',
  config = function()
    require('xls-viewer').setup({
      python_cmd = './.venv/bin/python',
    })
  end
}
