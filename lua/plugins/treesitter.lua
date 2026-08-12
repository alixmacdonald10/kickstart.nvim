-- Tree-sitter parsers + queries.
--
-- NOTE: this uses the `main` branch, which is a full, incompatible rewrite of the
-- plugin. The old `master` branch supports Neovim 0.10/0.11 only and is the source
-- of the `treesitter.lua:197: attempt to call method 'range' (a nil value)`
-- highlighter crashes on this Neovim (0.13-dev).
--
-- `main` has no `nvim-treesitter.configs` module: there is no `ensure_installed`,
-- no `auto_install`, and no `highlight`/`indent` option tables. Highlighting and
-- indentation are Neovim features that the config turns on itself, below.
--
-- Requires `tree-sitter-cli` >= 0.26.1 on PATH (`sudo pacman -S tree-sitter-cli`),
-- plus `tar`, `curl` and a C compiler.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  -- The plugin does not support lazy-loading.
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require 'nvim-treesitter'

    ts.setup {}

    local langs = {
      'bash',
      'python',
      'rust',
      'terraform',
      'dockerfile',
      'toml',
      'diff',
      'html',
      'xml',
      'lua',
      'make',
      'just',
      'luadoc',
      'markdown',
      'markdown_inline',
      'regex',
      'query',
      'vim',
      'vimdoc',
      -- NOTE: no `jsonc` -- the `main` branch dropped it; jsonc buffers use the
      -- `json` parser (`vim.treesitter.language.register` is not needed, the
      -- plugin already maps the filetype).
      'json',
      'proto',
    }

    -- Every parser is compiled by the `tree-sitter` CLI. Without it each language
    -- fails with `ENOENT: 'tree-sitter'`, and since `install` runs on every startup
    -- that is one error notification per language, every time. Fail once, loudly,
    -- instead. Installing is otherwise asynchronous and a no-op for parsers already
    -- present, so it is safe to call unconditionally.
    if vim.fn.executable 'tree-sitter' == 1 then
      ts.install(langs)
    else
      vim.notify(
        'nvim-treesitter: `tree-sitter` CLI not found, skipping parser install.\n'
          .. 'Install it (`sudo pacman -S tree-sitter-cli`), then run `:TSUpdate`.',
        vim.log.levels.WARN
      )
    end

    -- `main` replaces `auto_install` with nothing, so highlighting starts only for
    -- filetypes whose parser is already installed. Add languages to the list above
    -- rather than expecting them to appear on demand.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('kickstart-treesitter-start', { clear = true }),
      callback = function(event)
        local lang = vim.treesitter.language.get_lang(event.match)
        if not lang or not pcall(vim.treesitter.start, event.buf, lang) then
          return
        end
        -- Tree-sitter indentation is provided by this plugin and is still marked
        -- experimental upstream. Note the quoting -- it is load-bearing.
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
