-- Prefer the default block cursor for Normal mode,
-- provides a visual indicator of which mode is active
-- vim.opt.guicursor = ""

-- Prefer line numbers relative to cursor location, helps
-- with using numbers to jump to a particular line from where
-- the cursor is currently located
vim.opt.nu = true
vim.opt.relativenumber = true

-- Tabs should be configured to 4 spaces in length, and they
-- should insert spaces as opposed to a tab character
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

-- Line wrapping can be visually confusing, although with line numbering, it can be
-- not too difficult to distinguish when the line has wrapped. That being said, prefer
-- to not deal with single lines that visually take up large portions of the buffer
vim.opt.wrap = false

-- Folds are not personally useful; it is too easy to accidentally
-- collapse/uncollapse large folds and lose your place in the buffer
vim.opt.foldenable = false
vim.opt.foldmethod = "manual"
vim.opt.foldlevel = 99

-- Swapfiles can become corrupted and break, at least on Windows.
-- If there is a problem, delete the swapfile (technically, you
-- could lose data, be mindful of that), but do not turn this option
-- off. Yank/paste to clipboard speed is heavily impacted, allegedly
-- due to buffer flush-to-disk problems:
--
-- https://stackoverflow.com/a/27140329
vim.opt.swapfile = true

-- Undodir should be platform agnostic, and the undofile is useful when
-- one needs to quit Neovim for whatever reason and does not want to lose
-- the ability to undo accidental changes they made before exiting
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true

-- Highlight searches when typing them, do not need them to stay highlighted
-- after the search is done, as it can be frustrating to have to clear them
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "100"

-- Space just needs to be the leader key... really struggle with
-- imagining having to relearn a different key for "<leader>" keybinds
vim.g.mapleader = " "
