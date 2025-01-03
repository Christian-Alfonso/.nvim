local textcase = require("textcase")

textcase.setup({
    -- Do not want default keymappings, this would included the LSP enabled textcase mappings, see
    -- commented out block below about why these mappings are problematic
    default_keymappings_enabled = false,
})

-- Mappings for changing case of current word
vim.keymap.set('n', 'gau', function() textcase.current_word('to_upper_case') end, {})
vim.keymap.set('n', 'gal', function() textcase.current_word('to_lower_case') end, {})
vim.keymap.set('n', 'gas', function() textcase.current_word('to_snake_case') end, {})
vim.keymap.set('n', 'gad', function() textcase.current_word('to_dash_case') end, {})
vim.keymap.set('n', 'gan', function() textcase.current_word('to_constant_case') end, {})
vim.keymap.set('n', 'ga.', function() textcase.current_word('to_dot_case') end, {})
vim.keymap.set('n', 'ga,', function() textcase.current_word('to_comma_case') end, {})
vim.keymap.set('n', 'gaa', function() textcase.current_word('to_phrase_case') end, {})
vim.keymap.set('n', 'gac', function() textcase.current_word('to_camel_case') end, {})
vim.keymap.set('n', 'gap', function() textcase.current_word('to_pascal_case') end, {})
vim.keymap.set('n', 'gat', function() textcase.current_word('to_title_case') end, {})
vim.keymap.set('n', 'gaf', function() textcase.current_word('to_path_case') end, {})

-- Uncomment to enable renaming every instance of word in entire workspace with text case change
-- through the LSP. It is as potentially destructive as it sounds, will open buffers for all files
-- containing instances and give you the option to write them all. USE AT OWN RISK
-- vim.keymap.set('n', 'gaU', function() textcase.lsp_rename('to_upper_case') end, {})
-- vim.keymap.set('n', 'gaL', function() textcase.lsp_rename('to_lower_case') end, {})
-- vim.keymap.set('n', 'gaS', function() textcase.lsp_rename('to_snake_case') end, {})
-- vim.keymap.set('n', 'gaD', function() textcase.lsp_rename('to_dash_case') end, {})
-- vim.keymap.set('n', 'gaN', function() textcase.lsp_rename('to_constant_case') end, {})
-- vim.keymap.set('n', 'ga.', function() textcase.lsp_rename('to_dot_case') end, {})
-- vim.keymap.set('n', 'ga,', function() textcase.lsp_rename('to_comma_case') end, {})
-- vim.keymap.set('n', 'gaA', function() textcase.lsp_rename('to_phrase_case') end, {})
-- vim.keymap.set('n', 'gaC', function() textcase.lsp_rename('to_camel_case') end, {})
-- vim.keymap.set('n', 'gaP', function() textcase.lsp_rename('to_pascal_case') end, {})
-- vim.keymap.set('n', 'gaT', function() textcase.lsp_rename('to_title_case') end, {})
-- vim.keymap.set('n', 'gaF', function() textcase.lsp_rename('to_path_case') end, {})

-- Mappings for change case operations on a given motion
vim.keymap.set('n', 'gou', function() textcase.operator('to_upper_case') end, {})
vim.keymap.set('n', 'gol', function() textcase.operator('to_lower_case') end, {})
vim.keymap.set('n', 'gos', function() textcase.operator('to_snake_case') end, {})
vim.keymap.set('n', 'god', function() textcase.operator('to_dash_case') end, {})
vim.keymap.set('n', 'gon', function() textcase.operator('to_constant_case') end, {})
vim.keymap.set('n', 'go.', function() textcase.operator('to_dot_case') end, {})
vim.keymap.set('n', 'go,', function() textcase.operator('to_comma_case') end, {})
vim.keymap.set('n', 'goa', function() textcase.operator('to_phrase_case') end, {})
vim.keymap.set('n', 'goc', function() textcase.operator('to_camel_case') end, {})
vim.keymap.set('n', 'gop', function() textcase.operator('to_pascal_case') end, {})
vim.keymap.set('n', 'got', function() textcase.operator('to_title_case') end, {})
vim.keymap.set('n', 'gof', function() textcase.operator('to_path_case') end, {})

-- Applies a textcase API function to a given visual selection. The general 
-- handling for all visual mode possibilities inspired by these posts:
-- https://www.reddit.com/r/neovim/comments/1b1sv3a/function_to_get_visually_selected_text/
-- https://www.reddit.com/r/neovim/comments/vu9atg/how_do_i_get_the_text_selected_in_visual_mode/
-- https://www.reddit.com/r/neovim/comments/p4u4zy/comment/hbsph93/
local apply_textcase_function_to_visual_selection = function(textcase_function)
    if vim.fn.mode() == 'v' then
        -- Regular visual mode
        local vstart = vim.fn.getpos("v")
        local vend = vim.fn.getpos(".")

        local pos_start
        local pos_end

        if vstart[2] < vend[2] or (vstart[2] == vend[2] and vstart[3] <= vend[3]) then
            pos_start = vstart
            pos_end = vend
        else
            pos_start = vend
            pos_end = vstart
        end

        local region = vim.fn.getregion(pos_start, pos_end, { type = vim.fn.mode() })

        for i, v in pairs(region) do
            region[i] = textcase_function(v)
        end

        vim.api.nvim_buf_set_text(0, pos_start[2] - 1, pos_start[3] - 1, pos_end[2] - 1, pos_end[3], region)
    elseif vim.fn.mode() == 'V' then
        -- Visual line mode
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

        -- Alternatively, use api.nvim_buf_get_lines
        local lines = vim.fn.getline(line_start, line_end)

        for i, v in pairs(lines) do
            lines[i] = textcase_function(v)
        end

        vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, true, lines)
    elseif vim.fn.mode() == '\22' then
        -- Visual block mode
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

        local col_start
        local col_end

        if vstart[3] < vend[3] then
            col_start = vstart[3]
            col_end = vend[3]
        else
            col_start = vend[3]
            col_end = vstart[3]
        end

        local line

        for i = line_start, line_end do
            line = vim.api.nvim_buf_get_text(0, i - 1, math.min(col_start - 1, col_end), i - 1,
                math.max(col_start - 1, col_end), {})[1]

            vim.api.nvim_buf_set_text(0, i - 1, math.min(col_start - 1, col_end), i - 1,
                math.max(col_end - 1, col_end), { textcase_function(line) })
        end
    end
end

-- Mappings for change case operations on a given visual selection
vim.keymap.set('v', 'gau', function() apply_textcase_function_to_visual_selection(textcase.api.to_upper_case) end)
vim.keymap.set('v', 'gal', function() apply_textcase_function_to_visual_selection(textcase.api.to_lower_case) end)
vim.keymap.set('v', 'gas', function() apply_textcase_function_to_visual_selection(textcase.api.to_snake_case) end, {})
vim.keymap.set('v', 'gad', function() apply_textcase_function_to_visual_selection(textcase.api.to_dash_case) end, {})
vim.keymap.set('v', 'gan', function() apply_textcase_function_to_visual_selection(textcase.api.to_constant_case) end, {})
vim.keymap.set('v', 'ga.', function() apply_textcase_function_to_visual_selection(textcase.api.to_dot_case) end, {})
vim.keymap.set('v', 'ga,', function() apply_textcase_function_to_visual_selection(textcase.api.to_comma_case) end, {})
vim.keymap.set('v', 'gaa', function() apply_textcase_function_to_visual_selection(textcase.api.to_phrase_case) end, {})
vim.keymap.set('v', 'gac', function() apply_textcase_function_to_visual_selection(textcase.api.to_camel_case) end, {})
vim.keymap.set('v', 'gap', function() apply_textcase_function_to_visual_selection(textcase.api.to_pascal_case) end, {})
vim.keymap.set('v', 'gat', function() apply_textcase_function_to_visual_selection(textcase.api.to_title_case) end, {})
vim.keymap.set('v', 'gaf', function() apply_textcase_function_to_visual_selection(textcase.api.to_path_case) end, {})
