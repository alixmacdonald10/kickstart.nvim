return {
    {
        'mrcjkb/rustaceanvim',
        dependencies = {
            "mfussenegger/nvim-dap"
        },
        version = '^5',
        lazy = false,
        config = function()
            vim.g.rustaceanvim = {
                server = {
                    on_attach = function(client, bufnr)
                        vim.keymap.set('n', '<leader>lo', ':RustLsp openDocs<CR>', { noremap = true, silent = true, desc = 'Open Docs' })
                        vim.keymap.set('n', '<leader>le', ':RustLsp explainError<CR>', { noremap = true, silent = true, desc = 'Explain Error'})
                        vim.keymap.set('n', '<leader>lwr', ':RustLsp reloadWorkspace<CR>', { noremap = true, silent = true, desc = 'Reload Workspace'})
                        vim.keymap.set('n', '<leader>lr', ':RustLsp runnables<CR>', { noremap = true, silent = true, desc = 'Runnables'})
                        vim.keymap.set('n', '<leader>ldb', ':RustLsp debug<CR>', { noremap = true, silent = true, desc = 'Debug'})
                        vim.keymap.set('n', '<leader>ldd', ':lua require("dap").continue()<CR>', { noremap = true, silent = true, desc = 'Debugables' })
                    end,
                    default_settings = {
                        ['rust-analyzer'] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                            },
                            checkOnSave = true,
                            check = {
                                command = "clippy",
                                extraArgs = {"--workspace"},
                                allTargets = true,
                            },
                            diagnostics = {
                                enable = true,
                                experimental = {
                                    enable = true,
                                },
                                -- Make sure no lifetime errors are disabled
                                disabled = {},
                            },
                            -- Enable more detailed inlay hints
                            inlayHints = {
                                lifetimeElisionHints = {
                                    enable = "always",
                                    useParameterNames = true,
                                },
                                reborrowHints = {
                                    enable = "always",
                                },
                            },
                        },
                    },
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
            vim.keymap.set('n', '<leader>lt', ':Neotest<CR>', { noremap = true, silent = true, desc = 'Neotest' })
            vim.keymap.set('n', '<leader>ltr', ':Neotest run<CR>', { noremap = true, silent = true, desc = 'Run Tests'})
            vim.keymap.set('n', '<leader>ltp', ':Neotest output-panel<CR>', { noremap = true, silent = true, desc = 'Test Panel' })
            vim.keymap.set('n', '<leader>lts', ':Neotest summary<CR>', { noremap = true, silent = true, desc = 'Test Summary'})
        end
    },
}
