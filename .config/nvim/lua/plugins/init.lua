local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = vim.fn.system { "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim",
        install_path }
end
vim.cmd [[packadd packer.nvim]]

local ok, packer = pcall(require, "packer")

if not ok then
    return
end

packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float {
                border = "single"
            }
        end,
        prompt_border = "single"
    },
    git = {
        clone_timeout = 600
    },
    auto_clean = true,
    compile_on_sync = false
}

require("packer").startup(function(use)
    ---- Package manager
    use "wbthomason/packer.nvim"

    use "nvim-lua/plenary.nvim"
    use {
        "nvim-treesitter/nvim-treesitter",
        run = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end
    }
    use {
      "nvim-tree/nvim-web-devicons",
      config = require "plugins.config.devicons"
    }

    use {
      -- Search engine
      "nvim-telescope/telescope.nvim",
      requires = { "nvim-lua/plenary.nvim" },
      config = require "plugins.config.telescope"
    }

    use {
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make"
    }

    use { 
      "nvim-telescope/telescope-file-browser.nvim"
    }

    use {
      "nvim-telescope/telescope-ui-select.nvim"
    }

    use "williamboman/mason.nvim"

    use "williamboman/mason-lspconfig.nvim"
    use "neovim/nvim-lspconfig"

    use "mfussenegger/nvim-jdtls"

    use "folke/tokyonight.nvim"

    use {
      "L3MON4D3/LuaSnip",
    }
    use {
        "rafamadriz/friendly-snippets",
    }
    ---- Completion
    use {
      "hrsh7th/nvim-cmp",
      requires = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-nvim-lua",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "hrsh7th/cmp-cmdline",
          "hrsh7th/cmp-nvim-lsp-document-symbol",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",
          "lukas-reineke/cmp-under-comparator", -- Better sort completion items starting with underscore (Python)
      },
      config = require "plugins.config.cmp"
  }
end)
