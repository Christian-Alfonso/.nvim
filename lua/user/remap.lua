vim.g.mapleader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Only needed to get out of visual block
-- mode for <C-c> users with parity to what
-- Esc does after typing, allows for multiline
-- editing with <C-c> instead of cancelling out
vim.keymap.set("i", "<C-c>", "<Esc>")

-- No one likes to repeat the last recorded register,
-- so let's just make it a no-op
vim.keymap.set("n", "Q", "<nop>")

-- Do not need the open new terminal functionality,
-- but uncomment for this shortcut
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !wt -w 0 nt<CR>")

vim.keymap.set("n", "<C-n>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-p>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>n", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>p", "<cmd>lprev<CR>zz")

-- Original version, but "/gI" option doesn't seem to matter when using "%" to select
-- the entire file, so not sure why it would be needed
-- vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>")

vim.keymap.set('v', '/', function()
    -- Get existing content from register 'v'
    local old_vreg = vim.fn.getreg('v')

    -- Store visual selection in register 'v'
    vim.cmd.normal('\"vy')

    -- Get <C-r> as a special key to feed into "feedkeys"
    local ctrl_r = vim.api.nvim_replace_termcodes("<C-r>", true, false, true)

    -- Feed "/<C-r><C-r>v" to get the content of the 'v' register'
    vim.api.nvim_feedkeys("/" .. ctrl_r .. ctrl_r .. "v", 'm', false)

    -- Restore existing content back in register 'v'
    -- (schedule to happen after "feedkeys" to avoid
    -- clobbering of the input from register "v")
    vim.schedule(function() vim.fn.setreg('v', old_vreg) end)
end)

-- The remaining keymaps are behavior specific to either
-- the Neovim extension in VSCode or real Neovim
if vim.g.vscode then
    -- VSCode extension - only need to remap leader
    -- keybindings, since the rest can be handled in
    -- VSCode's native keybindings editor (can't rebind
    -- leader key to be a layer key like CTRL or SHIFT)
    local vscode = require('vscode-neovim')

    vim.keymap.set("n", "<leader>e", function()
        vscode.action("editor.action.showHover")
    end)

    vim.keymap.set("n", "<leader>f", function()
        vscode.action("editor.action.formatDocument")
    end)

    vim.keymap.set("n", "<leader>pv", function()
        vscode.action("workbench.view.explorer")
    end)

    -- Replicate plugin functionality using VSCode equivalents

    ---------------
    -- Telescope --
    ---------------
    -- Search through "project files" (pf)
    vim.keymap.set('n', '<leader>pf', function()
        vscode.action("workbench.action.quickOpen")
    end)
    -- Search for keyword with "project search" (ps)
    vim.keymap.set('n', '<leader>ps', function()
        vscode.action("workbench.action.findInFiles")
        -- Uncomment to use a native Vim input prompt for grep
        -- vscode.action("workbench.action.findInFiles", {
        --     args = { query = vim.fn.input("Grep > ") },
        -- })
    end)
    -- "Project resume" (pr) last search
    -- (VSCode only does search resume, so this is
    -- the same as "project search" or "ps")
    vim.keymap.set('n', '<leader>pr', function()
        vscode.action("workbench.action.findInFiles")
    end)
    -- Search through "project objects" (po)
    vim.keymap.set('n', '<leader>po', function()
        vscode.action("workbench.action.gotoSymbol")
    end)
    -- Search for keyword under cursor in project (p*)
    vim.keymap.set('n', '<leader>p*', function()
        local word = vim.fn.expand("<cword>")
        vscode.action("workbench.action.findInFiles", {
            args = { query = word },
        })
    end)

    --------------
    -- Fugitive --
    --------------
    vim.keymap.set("n", "<leader>gs", function()
        vscode.action("workbench.view.scm")
    end);

    -------------
    -- Harpoon --
    -------------
    vim.keymap.set("n", "<leader>ha", function()
        vscode.action("workbench.action.keepEditor")
    end);
    vim.keymap.set("n", "<leader>he", function()
        vscode.action("workbench.files.action.focusOpenEditorsView")
    end);
else
    -- ordinary Neovim

    vim.keymap.set("n", "<C-d>", "<C-d>zz")
    vim.keymap.set("n", "<C-u>", "<C-u>zz")
    vim.keymap.set("n", "<C-f>", "<C-f>zz")
    vim.keymap.set("n", "<C-b>", "<C-b>zz")

    vim.keymap.set("n", "<C-Up>", "<C-w><Up>")
    vim.keymap.set("n", "<C-Down>", "<C-w><Down>")
    vim.keymap.set("n", "<C-Left>", "<C-w><Left>")
    vim.keymap.set("n", "<C-Right>", "<C-w><Right>")

    vim.keymap.set("n", "<leader>e", function()
        vim.diagnostic.open_float()
    end)

    vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format()
    end)

    vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
end
