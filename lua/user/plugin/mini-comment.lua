local comment = require('mini.comment')

comment.setup({
    options = {
        -- Actually already in the default config called
        -- with "setup" when there are no arguments, but
        -- specify here anyway in case the default ever
        -- changes for whatever reason
        ignore_blank_line = false,
    },
})

local line_only_whitespace = function(line)
    return line:match('^%s*$') ~= nil
end

local all_lines_only_whitespace = function(start_line, end_line)
    local all_whitespace = true
    for l = start_line, end_line do
        if not line_only_whitespace(vim.fn.getline(l)) then
            all_whitespace = false
            break
        end
    end

    return all_whitespace
end

local comment_blank_lines = function(start_line, end_line)
    for l = start_line, end_line do
        -- Place a placeholder so mini.comment has content to wrap, then reindent
        -- via '==' which uses Tree-sitter/LSP/cindent indentexpr synchronously.
        -- vim.cmd is fully synchronous, so the buffer is correct before toggle_lines runs.
        vim.api.nvim_buf_set_lines(0, l - 1, l, false, { 'x' })
        vim.fn.cursor(l, 1)
        vim.cmd('normal! ==')
    end
    comment.toggle_lines(start_line, end_line)
    for l = start_line, end_line do
        -- Strip the placeholder and any space mini.comment inserts before it
        local commented = vim.fn.getline(l)
        local pos = commented:find('x', 1, true)
        if pos then
            local from = (commented:sub(pos - 1, pos - 1) == ' ') and pos - 1 or pos
            vim.api.nvim_buf_set_text(0, l - 1, from - 1, l - 1, pos, {})
        end
    end
end

local comment_ignoring_blank_lines = function(ignore_blank_line)
    -- Store original operatorfunc and old ignore setting afterwards
    local old_func = vim.go.operatorfunc
    local old_ignore = comment.config.options.ignore_blank_line

    -- Set desired ignore_blank_line option
    comment.config.options.ignore_blank_line = ignore_blank_line

    _G._gC_opfunc = function(motion)
        local start_line_num = vim.fn.line("'[")
        local end_line_num = vim.fn.line("']")

        local all_whitespace = all_lines_only_whitespace(start_line_num, end_line_num)

        if all_whitespace then
            comment_blank_lines(start_line_num, end_line_num)
        else
            comment.operator(motion)
        end

        -- Restore original operatorfunc and old ignore setting afterwards
        comment.config.options.ignore_blank_line = old_ignore
        vim.go.operatorfunc = old_func
        _G._gC_opfunc = nil
    end

    vim.go.operatorfunc = 'v:lua._gC_opfunc'

    -- "ic" mode is operator-pending mode, for some reason normal mode ("n") does
    -- not work here and will just literally insert the keys instead of executing them
    --
    -- Inspired from:
    -- https://www.reddit.com/r/neovim/comments/18w9rwv/trying_to_create_a_custom_text_object/
    vim.api.nvim_feedkeys('g@', 'ic', false)
end

-- Comment while NOT ignoring blank lines with "gc". Matches default functionality from plugin,
-- except for handling of blank lines, which can be commented out by themselves even though the
-- plugin normally detects when range is all whitespace lines and does not do any commenting
vim.keymap.set("n", "gc", function()
    comment_ignoring_blank_lines(false)
end, { noremap = true })

-- Comment while ignoring blank lines with "gC". Single line with "gCC" or "gCc" matches
-- default "gc" and "gcc" behavior for commenting, does not comment blank lines
vim.keymap.set("n", "gC", function()
    comment_ignoring_blank_lines(true)
end, { noremap = true })

vim.keymap.set("n", "gcc", function()
    local line = vim.fn.getline('.')
    local line_num = vim.fn.line('.')

    if line_only_whitespace(line) then
        comment_blank_lines(line_num, line_num)
    else
        comment.toggle_lines(line_num, line_num)
    end
end, { noremap = true })

vim.keymap.set("n", "gcC", "gcc", { remap = true })
vim.keymap.set("n", "gCC", "gcc", { remap = true })
vim.keymap.set("n", "gCc", "gcc", { remap = true })

-- Visual mode: use getpos("v") and getpos(".") to read the live selection anchors
-- instead of '< and '>, which only update after leaving visual mode and can hold
-- stale values. Inspired by the same pattern used in text-case.lua.
-- Only visual-line mode is handled; visual-block commenting is not supported.
local comment_visual_selection = function(ignore_blank_line)
    local vstart = vim.fn.getpos("v")
    local vend = vim.fn.getpos(".")

    local start_line, end_line
    if vstart[2] <= vend[2] then
        start_line = vstart[2]
        end_line = vend[2]
    else
        start_line = vend[2]
        end_line = vstart[2]
    end

    if all_lines_only_whitespace(start_line, end_line) then
        comment_blank_lines(start_line, end_line)
    else
        local old_ignore = comment.config.options.ignore_blank_line

        -- Set desired ignore_blank_line option, and restore afterwards
        comment.config.options.ignore_blank_line = ignore_blank_line
        comment.toggle_lines(start_line, end_line)
        comment.config.options.ignore_blank_line = old_ignore

        -- Use <Esc> to exit visual selection after operation is completed
        local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

        vim.api.nvim_feedkeys(esc, 'm', false)
    end
end

vim.keymap.set('v', 'gc', function() comment_visual_selection(false) end, { noremap = true })
vim.keymap.set('v', 'gC', function() comment_visual_selection(true) end, { noremap = true })

-- Yank-and-comment keymaps work with the built-in Neovim commentstring operator
--
-- Operatorfunc logic taken and modified from this SE comment:
-- https://vi.stackexchange.com/a/37454
local yank_and_comment = function()
    local old_func = vim.go.operatorfunc -- backup previous reference

    -- set a globally callable object/function
    _G.op_func_yanking_and_commenting = function(motion)
        local start_line_num = vim.fn.line("'[")
        local end_line_num = vim.fn.line("']")

        vim.cmd("'[,']y")

        if motion == 'char' then
            -- Charwise commenting does not work too well,
            -- so just do nothing
        else
            -- Move cursor to start of range and use the built-in gcc
            -- operator with a count to toggle comment on all affected lines.
            -- Must use "normal" (not "normal!") because gcc is a mapping in
            -- Neovim 0.10+, and "normal!" bypasses all mappings.
            vim.fn.cursor(start_line_num, 1)
            local count = end_line_num - start_line_num + 1
            vim.cmd(string.format("normal %dgcc", count))
        end

        vim.go.operatorfunc = old_func          -- restore previous opfunc
        _G.op_func_yanking_and_commenting = nil -- deletes itself from global namespace
    end

    vim.go.operatorfunc = 'v:lua.op_func_yanking_and_commenting'

    -- "ic" mode is operator-pending mode, for some reason normal mode ("n") does
    -- not work here and will just literally insert the keys instead of executing them
    --
    -- Inspired from:
    -- https://www.reddit.com/r/neovim/comments/18w9rwv/trying_to_create_a_custom_text_object/
    vim.api.nvim_feedkeys('g@', 'ic', false)
end

-- Yank-and-comment multiple lines with "yc" and single line with "ycc", matches
-- default "gc" and "gcc" behavior for commenting without yanking
vim.keymap.set("n", "yc", function() yank_and_comment() end, { noremap = true })
vim.keymap.set("n", "ycc", "yygcc", { remap = true })
