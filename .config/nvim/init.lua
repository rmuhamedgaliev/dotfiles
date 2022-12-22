require "options"
require "plugins"

vim.cmd[[colorscheme tokyonight]]

require("mason").setup()
require("mason-lspconfig").setup()
