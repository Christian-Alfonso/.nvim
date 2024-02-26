-- Here is where you configure the autocompletion settings.
local lsp_zero = require('lsp-zero')
lsp_zero.extend_cmp()

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
