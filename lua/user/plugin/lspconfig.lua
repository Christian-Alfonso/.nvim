local lsp_zero = require('lsp-zero')
lsp_zero.extend_lspconfig()

lsp_zero.set_sign_icons({
    error = '',
    warn = '',
    hint = '',
    info = ''
})

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({ buffer = bufnr })

    local opts = { buffer = bufnr }

    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.document_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)

    -- This does not seem to be working for some reason, but Neovim should already show
    -- the function signature when typing in Insert mode anyway.
    -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

require('mason-lspconfig').setup({
    ensure_installed = { "clangd", "lua_ls", "rust_analyzer", "efm", "pyright" },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            -- (Optional) Configure lua language server for neovim
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
    }
})

local lsp_config = require("lspconfig")
local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()

cmp_capabilities.textDocument.completion.completionItem.snippetSupport = false

lsp_config.clangd.setup({
    filetypes = { 'c', },
    capabilities = cmp_capabilities,
    cmd = {
        "clangd",
        -- Remove argument placeholders during completion
        "--function-arg-placeholders=0",
    },
})

lsp_config.lua_ls.setup({
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

lsp_config.rust_analyzer.setup({
    filetypes = { 'rust', },
})

lsp_config.efm.setup({
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
