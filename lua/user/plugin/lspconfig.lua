require("mason").setup()

vim.lsp.enable({ "clangd", "lua_ls", "rust_analyzer", "efm", "pyright" })

local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()

cmp_capabilities.textDocument.completion.completionItem.snippetSupport = false

vim.lsp.config('clangd', {
    filetypes = { 'c', },
    capabilities = cmp_capabilities,
    cmd = {
        "clangd",
        -- Remove argument placeholders during completion
        "--function-arg-placeholders=0",
    },
})

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            completion = {
                -- Only complete function names, no snippets
                callSnippet = "Disable",
                -- Only complete keywords, no snippets
                keywordSnippet = "Disable"
            },
        }
    },
})

vim.lsp.config('rust_analyzer', {
    filetypes = { 'rust', },
})

vim.lsp.config('efm', {
    filetypes = { 'python', 'markdown' },
    init_options = { documentFormatting = true },
    settings = {
        rootMarkers = { ".git/" },
        languages = {
            -- Needed to enable Black for Python formatting, does
            -- not have its own independent server.
            python = {
                { formatCommand = "black --quiet -", formatStdin = true }
            },
            markdown = {
                { formatCommand = "prettier --stdin --stdin-filepath ${INPUT} ${--tab-width:tabWidth} ${--use-tabs:insertSpaces} ${--range-start=charStart} ${--range-start=charEnd}", formatStdin = true }
            }
        }
    }
})
