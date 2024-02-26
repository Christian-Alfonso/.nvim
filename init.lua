if vim.g.vscode then
    -- Neovim is being run as an extension for VSCode
    require("user.vscode")
else
    -- Neovim is being run by itself as standalone
    require("user.nvim")
end
