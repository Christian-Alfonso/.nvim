require('Comment').setup()

-- taken and modified from this SE comment:
-- https://vi.stackexchange.com/a/37454
local yank_and_comment = function()
    local old_func = vim.go.operatorfunc -- backup previous reference

    local api = require('Comment.api')
    local config = require('Comment.config'):get()

    -- set a globally callable object/function
    _G.op_func_yanking_and_commenting = function(motion)
        vim.cmd("'[,']y")

        if motion == 'char' then
            -- Charwise commenting does not work too well,
            -- so just do nothing
        elseif motion == 'line' then
            api.toggle.linewise(motion, config)
        elseif motion == 'block' then
            api.toggle.blockwise(motion, config)
        end

        vim.go.operatorfunc = old_func          -- restore previous opfunc
        _G.op_func_yanking_and_commenting = nil -- deletes itself from global namespace
    end

    vim.go.operatorfunc = 'v:lua.op_func_yanking_and_commenting'

    -- "ic" mode is operator-pending mode, for some reason normal mode ("n") does
    -- not work here and will just literally insert the keys instead of executing them
    --
    -- inspired from:
    -- https://www.reddit.com/r/neovim/comments/18w9rwv/trying_to_create_a_custom_text_object/
    vim.api.nvim_feedkeys('g@', 'ic', false)
end

vim.keymap.set("n", "yc", function() yank_and_comment() end, { noremap = true })
vim.keymap.set("n", "ycc", "yygcc", { remap = true })
