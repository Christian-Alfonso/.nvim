vim.g.mapleader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")

-- <leader>p can be used to paste lines from Neovim's paste
-- buffer without also cutting the lines being pasted over
-- (preserves whatever you just pasted)
vim.keymap.set("x", "<leader>p", "\"_dP")

-- <leader>y can be used to yank to system clipboard
-- instead of Neovim's local paste buffer
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- <leader>d can be used to delete the current lines
-- without adding it to Neovim's local paste buffer
-- (preserves whatever you already yanked)
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

-- Original version, but "/gI" option doesn't seem to matter when using "%" to select
-- the entire file, so not sure why it would be needed
-- vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>")

-- Rebind increment/decrement number to +/- keys, so that
-- those control key mappings can be used by Tmux instead
vim.keymap.set("n", "+", "<C-a>", { desc = "Increment numbers", noremap = true })
vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement numbers", noremap = true })

-- The remaining keymaps are behavior specific to either
-- the Neovim extension in VSCode or real Neovim
if vim.g.vscode then
    -- VSCode extension

    local vscode = require('vscode-neovim')

    -- DEPRECATED: Remove undo/redo workaround, buffer sync logic in the VSCode Neovim
    -- extension seems to have improved. Leaving the implementation below in case there
    -- is ever a regression or further change in to sync behavior, but the issue seems to not
    -- reproduce anymore. Ignore the below comments for this commented out rebind.
    --
    -- Need to rebind the undo/redo functionality to VSCode's version.
    -- Neovim's version can get out of sync easily during fast key sequences
    -- like "o<Esc>u" with the new line commands that follow this one, because
    -- they use VSCode's commands to fix other issues with the extension

    -- vim.keymap.set("n", "u", function()
    --     for i = vim.v.count1, 1, -1
    --     do
    --         vscode.call('undo')
    --     end
    -- end)

    -- vim.keymap.set("n", "<C-r>", function()
    --     for i = vim.v.count1, 1, -1
    --     do
    --         vscode.call('redo')
    --     end
    -- end)

    -- Allow VSCode to handle opening new line commands, because otherwise both Neovim
    -- and VSCode will try to add autoindents to the same buffer, leading to empty
    -- lines with trailing whitespace
    --
    -- Notes: This rebind cannot be done from VSCode because rebinding any normal character like
    -- 'o' results in not being able to type that character without accidentally triggering the
    -- command (unless careful mode conditions are set, which is impossible to do for every mode
    -- other than normal). Furthermore, the rebind cannot use vim.cmd.normal, as that appears to
    -- cause crashing and repeated character typing loops as if recursively calling the keymap,
    -- so the string returned at the end is necessary to actually enter insert mode afterwards
    vim.keymap.set("n", "o", function()
        if vim.v.count1 == 1 then
            -- Hack behavior for last line specifically because it appears
            -- to prevent the previous insertLineAfter to occur after the
            -- end of the buffer for some reason
            if vim.fn.line('$') == vim.fn.line('.') then
                vscode.action(
                    'runCommands',
                    {
                        args = {
                            commands = {
                                -- Add line after, in the way that "o" usually does
                                'editor.action.insertLineAfter',
                                -- Deleting this new line and insert a line before fixes
                                -- the issue with both indenting and deleting that indent
                                -- upon hitting Escape
                                'editor.action.deleteLines',
                                'editor.action.insertLineBefore',
                                -- Need extra new line for end of file
                                'editor.action.deleteLines',
                                'editor.action.insertLineAfter'
                            }
                        },
                    }
                )
            else
                vscode.action(
                    'runCommands',
                    {
                        args = {
                            commands = {
                                -- Add line after, in the way that "o" usually does
                                'editor.action.insertLineAfter',
                                -- Deleting this new line and insert a line before fixes
                                -- the issue with both indenting and deleting that indent
                                -- upon hitting Escape
                                'editor.action.deleteLines',
                                'editor.action.insertLineBefore',
                            }
                        },
                    }
                )
            end

            return "i"
        else
            -- Let normal "o" command take care of numbered commands,
            -- just don't do anything weird like backspacing or tabbing
            -- to change the indent level, which can sometimes break it
            return "o"
        end
    end, { expr = true })

    vim.keymap.set("n", "O", function()
        if vim.v.count1 == 1 then
            vscode.action(
                'runCommands',
                {
                    args = {
                        commands = {
                            -- Add line before, in the way that "O" usually does
                            'editor.action.insertLineBefore',
                            -- Deleting this new line and insert a line before fixes
                            -- the issue with both indenting and deleting that indent
                            -- upon hitting Escape
                            'editor.action.deleteLines',
                            'editor.action.insertLineBefore'
                        }
                    },
                }
            )

            return "i"
        else
            -- Let normal "O" command take care of numbered commands,
            -- just don't do anything weird like backspacing or tabbing
            -- to change the indent level, which can sometimes break it
            return "O"
        end
    end, { expr = true })

    vim.keymap.set("n", "S", function()
        if vim.v.count1 == 1 then
            -- Hack behavior for last line specifically because it appears
            -- to prevent the previous insertLineBefore to occur after the
            -- end of the buffer for some reason
            if vim.fn.line('$') == vim.fn.line('.') then
                vscode.action(
                    'runCommands',
                    {
                        args = {
                            commands = {
                                -- Strangely, need to add line before and delete it,
                                -- just doing the commands that follow these does not fix
                                -- the deletion of the indent when hitting Escape
                                'editor.action.deleteLines',
                                'editor.action.insertLineBefore',
                                -- Deleting this new line and insert a line before fixes
                                -- the issue with both indenting and deleting that indent
                                -- upon hitting Escape
                                'editor.action.deleteLines',
                                'editor.action.insertLineBefore',
                                -- Need extra new line for end of file
                                'editor.action.deleteLines',
                                'editor.action.insertLineAfter',
                            }
                        },
                    }
                )
            else
                vscode.action(
                    'runCommands',
                    {
                        args = {
                            commands = {
                                -- Strangely, need to add line before and delete it,
                                -- just doing the commands that follow these does not fix
                                -- the deletion of the indent when hitting Escape
                                'editor.action.deleteLines',
                                'editor.action.insertLineBefore',
                                -- Deleting this new line and insert a line before fixes
                                -- the issue with both indenting and deleting that indent
                                -- upon hitting Escape
                                'editor.action.deleteLines',
                                'editor.action.insertLineBefore'
                            }
                        },
                    }
                )
            end

            return "i"
        else
            -- Let normal "S" command take care of numbered commands,
            -- just don't do anything weird like backspacing or tabbing
            -- to change the indent level, which can sometimes break it
            return "S"
        end
    end, { expr = true })

    -- Center viewport when using "n" or "N" to navigate to next/previous thing
    -- with find mode. Need to use VSCode's version because it is not possible
    -- to handle next match and viewport scrolling from Neovim since VSCode
    -- controls the scrolling. Requires using VSCode's find instead of Neovim's
    -- as a consequence.
    vim.keymap.set("n", "n", function()
        vscode.action(
            'runCommands',
            {
                args = {
                    commands = {
                        'editor.action.nextMatchFindAction',
                        'cancelSelection',
                        {
                            command = "vscode-neovim.send",
                            args = "zz"
                        }
                    }
                },
            }
        )
    end)

    vim.keymap.set("n", "N", function()
        vscode.action(
            'runCommands',
            {
                args = {
                    commands = {
                        'editor.action.previousMatchFindAction',
                        'cursorWordLeft',
                        'cancelSelection',
                        {
                            command = "vscode-neovim.send",
                            args = "zz"
                        }
                    }
                },
            }
        )
    end)

    -- Rebind search functionality with "/" and "?" to use VSCode's instead of Neovim's. There
    -- is no option to use Neovim's search this way, unfortunately, as it requires rebinding "n"
    -- and "N" for compatibility, as in the keybinds above
    vim.keymap.set({ "n", "v" }, "/", function()
        vscode.action("actions.find")
    end)

    vim.keymap.set("n", "?", function()
        vscode.action("actions.find")
    end)

    vim.keymap.set("n", "\\", function()
        vscode.action("editor.action.startFindReplaceAction")
    end)

    -- Otherwise, mostly only need to remap leader keybindings, since the
    -- rest can be handled in VSCode's native keybindings
    -- editor (can't rebind leader key to be a layer key like CTRL or SHIFT)
    vim.keymap.set("n", "<leader>n", function()
        vscode.action("editor.action.marker.nextInFiles")
    end)

    vim.keymap.set("n", "<leader>p", function()
        vscode.action("editor.action.marker.prevInFiles")
    end)

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

    -- Center viewport when using "n" or "N" to navigate
    -- to next/previous thing with find mode
    vim.keymap.set("n", "n", "nzzzv")
    vim.keymap.set("n", "N", "Nzzzv")

    -- Set error and quickfix list navigation to <C-n>/<C-p>
    -- and <leader>n/<leader>p respectively
    vim.keymap.set("n", "<C-n>", "<cmd>cnext<CR>zz")
    vim.keymap.set("n", "<C-p>", "<cmd>cprev<CR>zz")
    vim.keymap.set("n", "<leader>n", "<cmd>lnext<CR>zz")
    vim.keymap.set("n", "<leader>p", "<cmd>lprev<CR>zz")

    -- Buffer navigation should also center viewport
    -- to middle of new cursor location
    vim.keymap.set("n", "<C-d>", "<C-d>zz")
    vim.keymap.set("n", "<C-u>", "<C-u>zz")
    vim.keymap.set("n", "<C-f>", "<C-f>zz")
    vim.keymap.set("n", "<C-b>", "<C-b>zz")

    -- Use C-<Arrow> keys for window navigation
    vim.keymap.set("n", "<C-Up>", "<C-w><Up>")
    vim.keymap.set("n", "<C-Down>", "<C-w><Down>")
    vim.keymap.set("n", "<C-Left>", "<C-w><Left>")
    vim.keymap.set("n", "<C-Right>", "<C-w><Right>")

    -- Use S-<Arrow> keys for window resizing
    vim.keymap.set("n", "<S-Up>", "5<C-w>+")
    vim.keymap.set("n", "<S-Down>", "5<C-w>-")
    vim.keymap.set("n", "<S-Right>", "5<C-w>>")
    vim.keymap.set("n", "<S-Left>", "5<C-w><")

    -- Open the float window that gives more information
    -- about the error on the line
    vim.keymap.set("n", "<leader>e", function()
        vim.diagnostic.open_float()
    end)

    -- Format the current buffer using the LSP
    vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format()
    end)

    -- Open Neovim's file explorer, NetRW
    vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
end
