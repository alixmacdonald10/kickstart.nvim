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
            vim.api.nvim_set_keymap('n', '<leader>tm', ':RenderMarkdown toggle<CR>', { noremap = true, silent = true })
        end,
    },
    
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
        '3rd/image.nvim',
        opts = {
            backend = "kitty",
            markdown = {
                enabled = true,
                clear_in_insert_mode = false,
                download_remote_images = true,
                only_render_image_at_cursor = true,
                floating_windows = false,
                filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
            },
        },
    },
    -- {
    --     "3rd/diagram.nvim",
    --     dependencies = {
    --         "3rd/image.nvim",
    --     },
    --     opts = {},
    --     config = function(_, opts)
    --         require('diagram').setup(opts)
    --     end,
    -- },
}
