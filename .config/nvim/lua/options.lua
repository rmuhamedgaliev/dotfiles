local options = {
    termguicolors = true,
    mouse = "a",
    undofile = true, -- Save undo history
    expandtab = true,
    shiftwidth = 2,
    tabstop = 2,
    softtabstop = 2,
    scrolloff = 5,
    autoindent = true,
    smartindent = true,
}

for key, value in pairs(options) do
    vim.opt[key] = value
end
