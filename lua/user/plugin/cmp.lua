--TODO: Determine if this plugin config is even needed anymore after removal of LSP Zero

local cmp = require('cmp')
local cmp_mappings = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
})

cmp.setup({
    mapping = cmp_mappings,
    sources = {
        { name = 'nvim_lsp' },
    }
})
