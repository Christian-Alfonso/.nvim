function ColorMyPencils(color)
    local vscode = require('vscode')
    local c = require('vscode.colors').get_colors()
    vscode.setup({
        -- Alternatively set style in setup
        -- style = 'light'

        -- Enable transparent background
        transparent = true,

        -- Enable italic comment
        italic_comments = false,

        -- Disable nvim-tree background color
        disable_nvimtree_bg = true,

        -- Override colors (see ./lua/vscode/colors.lua)
        color_overrides = {
            -- Makes the line numbers completely white
            -- vscLineNumber = '#FFFFFF',
        },

        -- Override highlight groups (see ./lua/vscode/theme.lua)
        group_overrides = {
            -- this supports the same val table as vim.api.nvim_set_hl
            -- use colors from this colorscheme by requiring vscode.colors!
            Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
        }
    })
    vscode.load()

    -- Needed for most themes, "vscode" theme
    -- does not use the "colorscheme" command
    -- color = color or "vscode"
    -- vim.cmd.colorscheme(color)

    -- Some themes require this to make the window
    -- transparent if not supported natively in the theme
    -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
    -- setup must be called before loading
    ColorMyPencils()
}
