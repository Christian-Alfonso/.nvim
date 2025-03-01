require("user.remap")
require("user.set")
require("user.lazy")

-- Load useful autocommands and theme when using
-- real Neovim and not the VSCode extension
if not vim.g.vscode then
    require("user.theme")

    -- Autocommands upon entering Neovim
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            -- Configure .vimrc local to the config directory
            -- (not currently using a .vimrc, but this seems
            -- to be how one would do it in Neovim)
            -- vim.cmd("set runtimepath^=~/.vim runtimepath+=~/.vim/after")
            -- vim.cmd("let &packpath=&runtimepath")
            -- vim.o.packpath = vim.o.runtimepath
            -- vim.cmd("source .vimrc")

            -- Apply color theme for Neovim
            ColorMyPencils()
            -- Show certain whitespace characters
            vim.cmd("set listchars=tab:↹\\ ,trail:•,extends:>,precedes:<,nbsp:⍽,conceal:?")
            vim.cmd("set list")
            -- Set diff options for Neovim
            -- Set to ignore whitespace changes
            vim.cmd("set diffopt+=iwhite")
            -- Set to enable alignment match lines up to 60
            vim.cmd("set diffopt+=linematch:60")
            -- TEMPORARY: Disable write to ShaDa file because on Windows, there is
            -- a bug where all of the "main.shada.tmp.*" files in nvim-data are filled
            -- and the main.shada file cannot be written. See this bug report:
            -- https://github.com/neovim/neovim/issues/8587
            vim.cmd("set shada=\"NONE\"")
        end,
    })

    -- Autocommands upon leaving Neovim
    vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
            -- Restore cursor to a blinking vertical bar instead
            -- of whatever cursor the current mode has set. Note
            -- that there is no way for Neovim to query the cursor
            -- shape from the terminal to know what it was before
            vim.cmd("set guicursor=a:ver25-blinkwait5-blinkon5-blinkoff5")
        end,
    })

    -- Autocommands upon gaining focus
    vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
            -- Resetting default cursor option on focus fixes an issue
            -- in Windows Terminal where it changes block cursor to the
            -- default line cursor until next mode change
            vim.cmd("set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20")
        end,
    })

    -- Autocommands upon entering new window
    vim.api.nvim_create_autocmd("WinEnter", {
        callback = function()
            ColorMyPencils()
            vim.cmd("set nofen")
            -- Disable folds completely
            vim.cmd("set nofoldenable")
        end,
    })

    -- Autocommands upon leaving current window
    vim.api.nvim_create_autocmd("WinLeave", {
        callback = function()
            ColorMyPencils()
            vim.cmd("set nofen")
        end,
    })

    -- Autocommands upon entering new buffer
    vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            vim.cmd("set statusline=%<%f%h%m%r%=(%l,%c%V)\\ {%b,0x%B}\\ [%{&fileformat}]\\ %P")
        end,
    })

    print("Welcome back to Neovim!")
end
