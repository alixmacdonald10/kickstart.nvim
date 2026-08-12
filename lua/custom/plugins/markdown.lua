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
}
