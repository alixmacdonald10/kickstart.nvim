return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {

        },
        config = function(_, opts)
            require('render-markdown').setup(opts)
            -- Define the keybind to toggle markdown 
            vim.keymap.set('n', '<leader>tm', ':RenderMarkdown toggle<CR>', { noremap = true, silent = true, desc = 'Toggle Markdown Render' })
        end,
    },
    {
        "toppair/peek.nvim",
        event = { "VeryLazy" },
        build = "deno task --quiet build:fast",
        config = function()

            local peek = require("peek")
            peek.setup({
                auto_load = true,         -- whether to automatically load preview when
                -- entering another markdown buffer
                close_on_bdelete = true,  -- close preview window on buffer delete
                syntax = true,            -- enable syntax highlighting, affects performance
                theme = 'dark',           -- 'dark' or 'light'
                update_on_change = true,
                app = 'browser',          -- 'webview', 'browser', string or a table of strings
                filetype = { 'markdown' },-- list of filetypes to recognize as markdown
                -- relevant if update_on_change is true
                throttle_at = 200000,     -- start throttling when file exceeds this
                -- amount of bytes in size
                throttle_time = 'auto',   -- minimum amount of time in milliseconds
                -- that has to pass before starting new render
            })
            local toggle = function()
                if peek.is_open() then
                    print('opened')
                    peek.close()
                else
                    print('closed')
                    peek.open()
                end
            end

            vim.keymap.set('n', '<leader>tp', toggle, { noremap = true, silent = true, desc = 'Toggle Markdown Preview' })
        end,
    },
    -- {
    --     '3rd/image.nvim',
    --     opts = {
    --         backend = "kitty",
    --         markdown = {
    --             enabled = true,
    --             clear_in_insert_mode = true,
    --             download_remote_images = true,
    --             only_render_image_at_cursor = true,
    --             floating_windows = false,
    --             filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
    --         },
    --         neorg = {
    --             enabled = true,
    --             filetypes = { "norg" },
    --         },
    --         typst = {
    --             enabled = true,
    --             filetypes = { "typst" },
    --         },
    --     window_overlap_clear_enabled = true,
    --     }
    -- },
}
