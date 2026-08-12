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
}
