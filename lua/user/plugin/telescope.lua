local telescope = require('telescope')
local actions = require('telescope.actions')
local lga_actions = require('telescope-live-grep-args.actions')

telescope.setup {
    defaults = {
        -- Uncomment to mirror preview pane
        -- layout_config = { mirror = true },
        -- Uncomment to remove border from windows
        -- border = true,
        -- borderchars = {
        --     prompt = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        --     results = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        --     preview = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        -- },
        mappings = {
            i = {
                ["<Up>"] = actions.cycle_history_prev,
                ["<Down>"] = actions.cycle_history_next,
            },
        },
    },
    extensions = {
        live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = {         -- extend mappings
                i = {
                    ["<C-k>"] = lga_actions.quote_prompt,
                    ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                },
            },
            -- ... also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec

            -- Uncomment to mirror preview pane
            -- layout_config = { mirror = true },
        },
    },
}

-- For some reason, the "load_extension" call has to happen after
-- the "setup" call for telescope. See here for more information:
-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/71#issuecomment-1798119642
telescope.load_extension('live_grep_args')

local builtin = require('telescope.builtin')

-- Search through "project files" (pf)
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
-- Search through "project Git" (pg)
vim.keymap.set('n', '<leader>pg', builtin.git_files, {})
-- Search for keyword with "project search" (ps)
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
-- Uncomment to use a native Vim input prompt for grep
-- vim.keymap.set('n', '<leader>ps', function()
--     local query = vim.fn.input("Grep > ")
--
--     if query == '' then
--         return
--     end
--
--     builtin.grep_string({ search = query });
--
--     -- Get <Esc> as a special key to feed into "feedkeys"
--     local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
--
--     vim.api.nvim_feedkeys(esc, 'm', false)
-- end)
-- "Project resume" (pr) last search
vim.keymap.set('n', '<leader>pr', builtin.resume, {})
vim.keymap.set('n', '<leader>plg', telescope.extensions.live_grep_args.live_grep_args, {})
-- Search through "project objects" (po)
vim.keymap.set('n', '<leader>po', builtin.treesitter, {})
-- Search through "project references" (pr)
-- using the word under the cursor
vim.keymap.set('n', '<leader>plr', builtin.lsp_references, {})

local lga_shortcuts = require("telescope-live-grep-args.shortcuts")

vim.keymap.set('n', '<leader>p*', lga_shortcuts.grep_word_under_cursor, {})
vim.keymap.set('v', '<leader>plg', lga_shortcuts.grep_visual_selection, {})
