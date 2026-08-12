return {
    {
        'mrcjkb/rustaceanvim',
        dependencies = {
            "mfussenegger/nvim-dap"
        },
        version = '^5', -- Recommended
        lazy = false, -- This plugin is already lazy
        config = function()
            vim.g.rustaceanvim = {
                -- Plugin configuration
                -- tools = {
                -- },
                -- LSP configuration
                server = {
                    on_attach = function(client, bufnr)
                        vim.keymap.set('n', '<leader>lo', ':RustLsp openDocs<CR>', { noremap = true, silent = true })
                        vim.keymap.set('n', '<leader>le', ':RustLsp explainError<CR>', { noremap = true, silent = true })
                        vim.keymap.set('n', '<leader>lwr', ':RustLsp reloadWorkspace<CR>', { noremap = true, silent = true })
                        vim.keymap.set('n', '<leader>lr', ':RustLsp runnables<CR>', { noremap = true, silent = true })
                        vim.keymap.set('n', '<leader>ldb', ':RustLsp debug<CR>', { noremap = true, silent = true })
                        vim.keymap.set('n', '<leader>ldd', ':RustLsp debuggables<CR>', { noremap = true, silent = true })
                    end,
                    default_settings = {
                        -- rust-analyzer language server configuration
                        ['rust-analyzer'] = {
                            cargo = {
                                allFeatures = true, -- Enable all features by default
                            },
                        },
                    },
                },
                -- DAP configuration
                dap = {

                },
            }
        end,
    },
    {
        'saecki/crates.nvim',
        tag = 'stable',
        config = function()
            require('crates').setup()
        end,
    },
    { "rouge8/neotest-rust", },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "rouge8/neotest-rust",
            "mrcjkb/rustaceanvim",
            "nvim-treesitter/nvim-treesitter"
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-rust")
                }
            })
            vim.keymap.set('n', '<leader>lt', ':Neotest<CR>', { noremap = true, silent = true })
            vim.keymap.set('n', '<leader>ltr', ':Neotest run<CR>', { noremap = true, silent = true })
            vim.keymap.set('n', '<leader>ltp', ':Neotest output-panel<CR>', { noremap = true, silent = true })
            vim.keymap.set('n', '<leader>lts', ':Neotest summary<CR>', { noremap = true, silent = true })
        end
    },
}
