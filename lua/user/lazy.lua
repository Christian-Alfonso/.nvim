-- Bootstrap Lazy if it does not already exist
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Lazy will handle which plugins need to be loaded for normal
-- Neovim and the VSCode plugin through the "cond" property for
-- each one, but to update plugins, Lazy still needs to be used
-- through normal Neovim, as it cannot be accessed in VSCode
require("lazy").setup({
    rocks = {
        -- None of the plugins here use luarocks, so
        -- disable it completely, otherwise Lazy errors
        enabled = false,
    },
    spec = {
        -- Theme plugin, default VSCode color scheme
        {
            "Mofiqul/vscode.nvim",
            lazy = false,
            priority = 1000,
            init = function()
                require("user.theme")
            end,
            cond = not vim.g.vscode,
            opts = {
                rocks = {
                    enabled = false,
                }
            }
        },

        -- Telescope allows for searching by filename
        -- and text in project folder
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.5',
            -- or                              , branch = '0.1.x',
            dependencies = {
                'nvim-lua/plenary.nvim',
                'nvim-telescope/telescope-live-grep-args.nvim',
            },
            init = function()
                require("user.plugin.telescope")
            end,
            cond = not vim.g.vscode,
        },

        -- Treesitter provides syntax tree highlighting based
        -- on associated language of text file
        {
            'nvim-treesitter/nvim-treesitter',
            init = function()
                require("user.plugin.treesitter")
            end,
            -- The following function updates Treesitter automatically,
            -- which can be annoying since Lazy is being called on every
            -- startup of Neovim. Run ":TSUpdate" manually for updates.
            -- config = function()
            --     local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            --     ts_update()
            -- end,
            cond = not vim.g.vscode,
        },

        -- Harpoon allows for marking and quick navigation of
        -- common files in the project folder
        {
            'ThePrimeagen/harpoon',
            branch = 'harpoon2',
            dependencies = { 'nvim-lua/plenary.nvim' },
            init = function()
                require("user.plugin.harpoon")
            end,
            cond = not vim.g.vscode,
        },

        -- Fugitive gives basic Git integration and utilizes
        -- the built-in text comparison functionality
        {
            'tpope/vim-fugitive',
            init = function()
                require("user.plugin.fugitive")
            end,
            cond = not vim.g.vscode,
        },

        -- Undotree allows you to persist file changes for later
        -- undo/redo even after you have closed the editor
        {
            'mbbill/undotree',
            init = function()
                require("user.plugin.undotree")
            end,
            cond = not vim.g.vscode,
        },

        -- LSP Zero uses all of the following includes for installing
        -- and managing the Language Server Protocols (LSPs) that you
        -- want to use for your text file of a certain language
        -- ##############################################################
        {
            'VonHeikemen/lsp-zero.nvim',
            branch = 'v3.x',
            lazy = true,
            config = false,
            init = function()
                require("user.plugin.lsp-zero")
            end,
            cond = not vim.g.vscode,
        },
        {
            'williamboman/mason.nvim',
            lazy = false,
            config = true,
            cond = not vim.g.vscode,
        },

        -- Autocompletion
        {
            'hrsh7th/nvim-cmp',
            event = 'InsertEnter',
            dependencies = {
                { 'L3MON4D3/LuaSnip' },
            },
            config = function()
                require("user.plugin.cmp")
            end,
            cond = not vim.g.vscode,
        },

        -- LSP
        {
            'neovim/nvim-lspconfig',
            cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
            event = { 'BufReadPre', 'BufNewFile' },
            dependencies = {
                { 'hrsh7th/cmp-nvim-lsp' },
                { 'williamboman/mason-lspconfig.nvim' },
            },
            config = function()
                require("user.plugin.lspconfig")
            end,
            cond = not vim.g.vscode,
        },
        -- ##############################################################

        -- Gitsigns shows "signs" next to the line numbers to indicate
        -- whether the file has been modified according to Git
        {
            'lewis6991/gitsigns.nvim',
            init = function()
                require("user.plugin.gitsigns")
            end,
            cond = not vim.g.vscode,
        },

        -- Comment allows easy commenting/uncommenting of lines of code
        -- based on what language is detected for your text file
        {
            'numToStr/Comment.nvim',
            lazy = false,
            init = function()
                require("user.plugin.comment")
            end,
            cond = not vim.g.vscode,
        },

        -------------------------------
        -- VSCode compatible plugins --
        -------------------------------

        -- Surround allows easy surrounding of text with common paired characters like
        -- ", ', (, [, {, etc. Since it is text only, it is compatible with VSCode.
        {
            "kylechui/nvim-surround",
            version = "*", -- Use for stability; omit to use `main` branch for the latest features
            event = "VeryLazy",
            config = function()
                require("nvim-surround").setup({
                    -- Configuration here, or leave empty to use defaults
                })
            end
        },

        -- Textcase allows easy switching between different casing styles (Pascal to underscored,
        -- hypenated to Camel, etc.) to prevent the need to manually edit the entire word.
        {
            "johmsalas/text-case.nvim",
            dependencies = { "nvim-telescope/telescope.nvim" },
            init = function()
                require("user.plugin.text-case")
            end,
            cmd = {
                -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
                "Subs",
                "TextCaseOpenTelescope",
                "TextCaseOpenTelescopeQuickChange",
                "TextCaseOpenTelescopeLSPChange",
                "TextCaseStartReplacingCommand",
            },
            -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
            -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
            -- available after the first executing of it or after a keymap of text-case.nvim has been used.
            lazy = false,
        },

        -- Mini-move from the Mini-nvim collection of plugins allows for moving lines in a way that handles
        -- the complexity of using counts and Normal/Visual mode differences in the line motions.
        {
            "nvim-mini/mini.move",
            init = function()
                require("user.plugin.mini-move")
            end,
            version = "*"
        },
    },
})
