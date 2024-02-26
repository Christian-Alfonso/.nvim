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

require("lazy").setup({
    -- Theme plugin, default VSCode color scheme
    {
        "Mofiqul/vscode.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            require("user.theme")
        end
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
        end
    },

    -- Treesitter provides syntax tree highlighting based
    -- on associated language of text file
    {
        'nvim-treesitter/nvim-treesitter',
        init = function()
            require("user.plugin.treesitter")
        end
        -- The following function updates Treesitter automatically,
        -- which can be annoying since Lazy is being called on every
        -- startup of Neovim. Run ":TSUpdate" manually for updates.
        -- config = function()
        --     local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        --     ts_update()
        -- end,
    },

    -- Harpoon allows for marking and quick navigation of
    -- common files in the project folder
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        init = function()
            require("user.plugin.harpoon")
        end
    },

    -- Fugitive gives basic Git integration and utilizes
    -- the built-in text comparison functionality
    {
        'tpope/vim-fugitive',
        init = function()
            require("user.plugin.fugitive")
        end
    },

    -- Undotree allows you to persist file changes for later
    -- undo/redo even after you have closed the editor
    {
        'mbbill/undotree',
        init = function()
            require("user.plugin.undotree")
        end
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
    },
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
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
        end
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
        end
    },
    -- ##############################################################

    -- Gitsigns shows "signs" next to the line numbers to indicate
    -- whether the file has been modified according to Git
    {
        'lewis6991/gitsigns.nvim',
        init = function()
            require("user.plugin.gitsigns")
        end
    },

    -- Comment allows easy commenting/uncommenting of lines of code
    -- based on what language is detected for your text file
    {
        'numToStr/Comment.nvim',
        lazy = false,
        init = function()
            require("user.plugin.comment")
        end
    }
})
