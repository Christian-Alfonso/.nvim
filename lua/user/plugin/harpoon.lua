local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>he", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- Navigate Harpoon list using the same navigation keys
--
-- Can specify ({ ui_nav_wrap = true }) to either "next" or "prev"
-- to make navigation wrap around from last to first or vice versa
vim.keymap.set("n", "<C-l>", function() harpoon:list():next({ ui_nav_wrap = true }) end)
vim.keymap.set("n", "<C-h>", function() harpoon:list():prev({ ui_nav_wrap = true }) end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():select(harpoon:list():length()) end)
