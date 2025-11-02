vim.g.mapleader = " "

-- Holding Shift while using j/k for up/down movement in
-- visual mode will allow the block of code to be moved in
-- that direction, even matches indent level of new scope
--
-- This functionality has been replaced using mini-move,
-- since that respects counts and Normal/Visual differences
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Joining lines will try to keep viewport in place
vim.keymap.set("n", "_", "mzJ`z")

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
--
-- Commented out because this functionality has proved not particularly useful in most
-- situations where find and replace would be necessary
-- vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
-- vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>")

-- Insert on the first non-whitespace character of each line
vim.keymap.set("n", "<leader>i", function()

end)

-- Append to the end of each line, without padding each line
vim.keymap.set("v", "<leader>a", function()
    local vstart = vim.fn.getpos("v")
    local vend = vim.fn.getpos(".")

    local line_start
    local line_end

    if vstart[2] < vend[2] then
        line_start = vstart[2]
        line_end = vend[2]
    else
        line_start = vend[2]
        line_end = vstart[2]
    end

    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    local ctrl_v = vim.api.nvim_replace_termcodes("<C-v>", true, false, true)

    -- local col_nav

    -- if first_whitespace_col > 1 then
    --     col_nav = (first_whitespace_col - 1) .. 'l'
    -- else
    --     col_nav = ''
    -- end

    vim.api.nvim_feedkeys(
        esc ..
        line_start ..
        -- 'G0' .. col_nav .. ctrl_v .. line_end .. 'GI',
        'GA',
        'm',
        false)

    local last_inserted_text = vim.fn.getreg('.')

    local lines = vim.api.nvim_buf_get_lines(0, line_start, line_end, false)

    for i, line in ipairs(lines) do
        -- line_len = vim.fn.strlen(line)
        -- if line_len < longest_line_len then
        lines[i] = line .. last_inserted_text
        -- end
    end

    vim.api.nvim_buf_set_lines(0, line_start, line_end, true, lines)
end)

local find_longest_line_index_and_length = function(start_line_num, end_line_num)
    local lines = vim.api.nvim_buf_get_lines(0, start_line_num - 1, end_line_num, false)

    local longest_line_num = start_line_num
    local longest_line_len = 0

    for i, line in ipairs(lines) do
        local len = vim.fn.strlen(line)
        if len > longest_line_len then
            longest_line_num = start_line_num + i - 1
            longest_line_len = len
        end
    end

    return longest_line_num, longest_line_len
end

-- Insert (l)eading characters all in the same column, right before the
-- first non-whitespace character on the line with the closest non-whitespace
-- character to column 1 (left side of buffer), including empty lines
vim.keymap.set("v", "<leader>l", function()
    local vstart = vim.fn.getpos("v")
    local vend = vim.fn.getpos(".")

    local line_start
    local line_end

    if vstart[2] < vend[2] then
        line_start = vstart[2]
        line_end = vend[2]
    else
        line_start = vend[2]
        line_end = vstart[2]
    end

    local _, longest_line_len = find_longest_line_index_and_length(line_start, line_end)

    local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)

    first_whitespace_col = longest_line_len

    for _, line in ipairs(lines) do
        line_len = vim.fn.strlen(line)

        -- Only consider non-empty lines
        if line_len > 0 then
            -- Find first non-whitespace character
            local col = string.find(line, "%S")
            if col < first_whitespace_col then
                first_whitespace_col = col -- Lua uses 1-based indexing
            end

            -- There cannot be any column before 1
            -- so if we found a column with a character
            -- at 1, we can just break, no need to keep
            -- looking at the rest of the lines
            if col == 1 then
                first_whitespace_col = 1
                break
            end
        end
    end

    for i, line in ipairs(lines) do
        line_len = vim.fn.strlen(line)

        print(line_len)
        if line_len == 0 then
            lines[i] = string.rep(" ", first_whitespace_col - 1)
        end
    end

    vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, true, lines)

    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    local ctrl_v = vim.api.nvim_replace_termcodes("<C-v>", true, false, true)

    local col_nav

    if first_whitespace_col > 1 then
        col_nav = (first_whitespace_col - 1) .. 'l'
    else
        col_nav = ''
    end

    vim.api.nvim_feedkeys(
        esc ..
        line_start ..
        'G0' .. col_nav .. ctrl_v .. line_end .. 'GI',
        'm',
        false)
end)

local pad_lines_to_longest_with_spaces = function(start_line_num, end_line_num)
    local _, longest_line_len = find_longest_line_index_and_length(start_line_num, end_line_num)

    local lines = vim.api.nvim_buf_get_lines(0, start_line_num - 1, end_line_num, false)

    for i, line in ipairs(lines) do
        line_len = vim.fn.strlen(line)
        if line_len < longest_line_len then
            lines[i] = line .. string.rep(" ", longest_line_len - line_len)
        end
    end

    vim.api.nvim_buf_set_lines(0, start_line_num - 1, end_line_num, true, lines)
end

-- Append (t)railing characters all in the same column, right after the
-- last character of the longest line, including empty lines
vim.keymap.set("v", "<leader>t", function()
    local vstart = vim.fn.getpos("v")
    local vend = vim.fn.getpos(".")

    local line_start
    local line_end

    if vstart[2] < vend[2] then
        line_start = vstart[2]
        line_end = vend[2]
    else
        line_start = vend[2]
        line_end = vstart[2]
    end

    pad_lines_to_longest_with_spaces(line_start, line_end)

    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    local ctrl_v = vim.api.nvim_replace_termcodes("<C-v>", true, false, true)

    vim.api.nvim_feedkeys(esc .. line_start .. 'G$' .. ctrl_v .. line_end .. 'GA', 'm', false)
end)


vim.keymap.set("v", "<leader>w", function()
    local curpos = vim.fn.getpos("v")
    vim.cmd("'<,'>s/\\s\\+$//e")
    vim.fn.setpos(".", curpos)

    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

    vim.api.nvim_feedkeys(esc .. '0', 'm', false)
end)

-- Rebind increment/decrement number to +/- keys, so that
-- those control key mappings can be used by Tmux instead
vim.keymap.set("n", "+", "<C-a>", { desc = "Increment numbers", noremap = true })
vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement numbers", noremap = true })

-- <leader>b can be used to get a visual selection of the entire current buffer
vim.keymap.set("n", "<leader>b", "ggVG")

-- Buffer navigation should also center viewport
-- to middle of new cursor location
vim.keymap.set({ "n", "v" }, "<C-d>", "36jzz")
vim.keymap.set({ "n", "v" }, "<C-u>", "36kzz")
vim.keymap.set({ "n", "v" }, "<C-f>", "43jzz")
vim.keymap.set({ "n", "v" }, "<C-b>", "43kzz")

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

    -- Center viewport using the built-in "revealLine" VSCode command from the exposed API:
    -- https://github.com/vscode-neovim/vscode-neovim/issues/1909#issuecomment-2362783237
    -- https://code.visualstudio.com/api/references/commands#commands
    vim.keymap.set({ "n", "v" }, "zz", function()
        local curline = vim.fn.line(".")
        vscode.call("revealLine", { args = { lineNumber = curline, at = "center" } })
    end)

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
        vim.g.callback_ready = false

        vscode.action(
            'runCommands',
            {
                args = {
                    commands = {
                        'editor.action.nextMatchFindAction',
                        'cancelSelection',
                    }
                },
                callback = function() vim.g.callback_ready = true end
            }
        )

        if vim.wait(10000, function() return vim.g.callback_ready end) then
            -- Calling for VSCode to evaluate the current line number
            vscode.eval("return vscode.window.activeTextEditor.selection.active.line")

            -- Grab the current line number now that the previous call has been evaluated,
            -- as now it will be accurate (could also just add one to the value returned
            -- by that previous VSCode eval call).
            local curline = vim.fn.line(".")
            vscode.call("revealLine", { args = { lineNumber = curline, at = "center" } })
        end
    end)

    vim.keymap.set("n", "N", function()
        vim.g.callback_ready = false

        vscode.action(
            'runCommands',
            {
                args = {
                    commands = {
                        'editor.action.previousMatchFindAction',
                        'cursorWordLeft',
                        'cancelSelection',
                    }
                },
                callback = function() vim.g.callback_ready = true end
            }
        )

        if vim.wait(10000, function() return vim.g.callback_ready end) then
            -- Calling for VSCode to evaluate the current line number
            vscode.eval("return vscode.window.activeTextEditor.selection.active.line")

            -- Grab the current line number now that the previous call has been evaluated,
            -- as now it will be accurate (could also just add one to the value returned
            -- by that previous VSCode eval call).
            local curline = vim.fn.line(".")
            vscode.call("revealLine", { args = { lineNumber = curline, at = "center" } })
        end
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

    vim.keymap.set("n", "<leader>w", function()
        vscode.action("editor.action.trimTrailingWhitespace")
    end)

    vim.keymap.set("v", "<leader>w", function()
        print("THIS")
        -- local curpos = vim.fn.getpos("v")
        vim.cmd("'<,'>s/\\s\\+$//e")
        -- vim.fn.setpos(".", curpos)
    end)

    vim.keymap.set("n", "<leader>e", function()
        vscode.action("editor.action.showHover")
    end)

    vim.keymap.set("n", "<leader>f", function()
        vscode.action("editor.action.formatDocument")
    end)

    vim.keymap.set("n", "<leader>c", function()
        vscode.action("editor.action.quickFix")
    end)

    vim.keymap.set("n", "<leader>s", function()
        vscode.action("workbench.action.showAllSymbols")
    end)

    vim.keymap.set("n", "<leader>r", function()
        vscode.action("editor.action.referenceSearch.trigger")
    end)

    vim.keymap.set("n", "<leader>q", function()
        vscode.action("editor.action.rename")
    end)

    vim.keymap.set("n", "<leader>pv", function()
        vscode.action("workbench.view.explorer")
    end)

    -- Replicate specific plugin functionality using VSCode equivalents

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

    vim.keymap.set('v', '<leader>ps', function()
        vscode.action("workbench.action.findInFiles")
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
    -- Open up Git source control interface
    vim.keymap.set("n", "<leader>gs", function()
        vscode.action("workbench.view.scm")
    end);

    -------------
    -- Harpoon --
    -------------
    -- Add file to quick menu navigation
    -- (in VSCode, keeps the file open in the editor)
    vim.keymap.set("n", "<leader>ha", function()
        vscode.action("workbench.action.keepEditor")
    end);

    -- Open quick menu navigation with current file list
    -- (in VSCode, navigates to open editors list)
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

    -- Center viewport when using <C-o>/<C-i> to navigate
    -- to next/previous location in code
    vim.keymap.set("n", "<C-o>", "<C-o>zz")
    vim.keymap.set("n", "<C-i>", "<C-i>zz")

    -- Set error and quickfix list navigation to <C-n>/<C-p>
    -- and <leader>n/<leader>p respectively
    vim.keymap.set("n", "<C-n>", "<cmd>cnext<CR>zz")
    vim.keymap.set("n", "<C-p>", "<cmd>cprev<CR>zz")
    vim.keymap.set("n", "<leader>n", "<cmd>lnext<CR>zz")
    vim.keymap.set("n", "<leader>p", "<cmd>lprev<CR>zz")

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

    -- Remove trailing whitespace in buffer
    --
    -- taken from:
    -- https://vi.stackexchange.com/a/41388
    vim.keymap.set("n", "<leader>w", function()
        print("THAT")
        local curpos = vim.fn.getpos(".")
        vim.cmd("%s/\\s\\+$//eg")
        vim.fn.setpos(".", curpos)
    end)

    vim.keymap.set("v", "<leader>w", function()
        local curpos = vim.fn.getpos("v")
        vim.cmd("'<,'>s/\\s\\+$//eg")
        vim.fn.setpos(".", curpos)

        local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

        vim.api.nvim_feedkeys(esc .. '0', 'm', false)
    end)

    -- Open the float window that gives more information
    -- about the error on the line
    vim.keymap.set("n", "<leader>e", function()
        vim.diagnostic.open_float()
    end)

    -- Go to symbol definition for the current buffer
    vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
    end)

    -- Go to symbol declaration for the current buffer
    vim.keymap.set("n", "gD", function()
        vim.lsp.buf.declaration()
    end)

    -- Format the current buffer using the LSP
    vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format()
    end)

    -- Get code actions for symbol under cursor
    vim.keymap.set("n", "<leader>c", function()
        vim.lsp.buf.code_action()
    end)

    -- Get all document symbols for current buffer
    vim.keymap.set("n", "<leader>s", function()
        vim.lsp.buf.document_symbol()
    end)

    -- Get all references to symbol under cursor
    vim.keymap.set("n", "<leader>r", function()
        vim.lsp.buf.references()
    end)

    -- Rename all references to symbol under cursor
    vim.keymap.set("n", "<leader>q", function()
        vim.lsp.buf.rename()
    end)

    -- Open Neovim's file explorer, NetRW
    vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
end
