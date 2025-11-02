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
                    ["<C-k>"] = lga_actions.quote_prompt(),
                    ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                    -- freeze the current list and start a fuzzy search in the frozen list
                    ["<C-space>"] = actions.to_fuzzy_refine,
                },
            },
            -- ... also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec
            -- layout_config = { mirror=true }, -- mirror preview pane
        },
    },
    pickers = {
        find_files = {
            hidden = true,
        },
    },
}

-- For some reason, the "load_extension" calls have to happen after
-- the "setup" call for telescope. See here for more information:
-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/71#issuecomment-1798119642

-- Load extension for live grep args to enable file search
telescope.load_extension('live_grep_args')

local builtin = require('telescope.builtin')
local conf = require('telescope.config').values

-- Search through "project files" (pf)
vim.keymap.set('n', '<leader>pf', builtin.find_files)

-- Search through "(p)roject source (c)ontrol" (pc)
vim.keymap.set('n', '<leader>pc', builtin.git_files)

-- Search for keyword without grep, simple "project search" (ps)
vim.keymap.set('n', '<leader>ps', function()
    builtin.live_grep({
        vimgrep_arguments = table.insert(conf.vimgrep_arguments, '--fixed-strings'),
        prompt_title = "Search",
        prompt_prefix = "🔍 "
    })
end)

vim.keymap.set('v', '<leader>ps', function()
    -- Get existing content from register 'v'
    local old_vreg = vim.fn.getreg('v')

    -- Store visual selection in register 'v'
    vim.cmd.normal('\"vy')

    -- Get new content from register 'v'
    local new_vreg = vim.fn.getreg('v')

    builtin.live_grep({
        default_text = new_vreg,
        vimgrep_arguments = table.insert(conf.vimgrep_arguments, '--fixed-strings'),
        prompt_title = "Search (" .. new_vreg .. ")",
        prompt_prefix = "🔍 "
    })

    -- Restore existing content back in register 'v'
    -- (schedule to happen after search to avoid
    -- clobbering of the input from register "v")
    vim.schedule(function() vim.fn.setreg('v', old_vreg) end)
end)

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

-- Search for keyword with grep, "project grep" (pg)
vim.keymap.set('n', '<leader>pg', builtin.live_grep)

-- "Project resume" (pr) last search
vim.keymap.set('n', '<leader>pr', builtin.resume)

-- Search for keyword with "project live grep" (plg)
vim.keymap.set('n', '<leader>plg', telescope.extensions.live_grep_args.live_grep_args)

-- Search through "project objects" (po)
vim.keymap.set('n', '<leader>po', builtin.treesitter)

-- Search through "project LSP references" (plr)
-- using the word under the cursor
vim.keymap.set('n', '<leader>plr', builtin.lsp_references)

local lga_shortcuts = require("telescope-live-grep-args.shortcuts")

-- Search for word under cursor with grep (p*)
vim.keymap.set('n', '<leader>p*', lga_shortcuts.grep_word_under_cursor)

-- Search for visual selection with "project live grep" (plg)
vim.keymap.set('v', '<leader>plg', lga_shortcuts.grep_visual_selection)

-- Load extension for textcase to enable interactive textcase option search
telescope.load_extension('textcase')

-- Search for textcase options for a given word or visual selection
vim.keymap.set('n', 'gaq', '<cmd>TextCaseOpenTelescope<CR>', { desc = "Telescope for Textcase" })
vim.keymap.set('v', 'gaq', "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope for Textcase" })
