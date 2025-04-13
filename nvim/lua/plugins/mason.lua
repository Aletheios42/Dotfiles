return {
  -- 1. Mason: gestor de instalación
  { "williamboman/mason.nvim", opts = {} },

  -- 2. Mason + LSP: conexión automática entre mason y lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "clangd" },  -- aquí puedes agregar más
    },
  },

  -- 3. LSPConfig: configuración estándar de LSPs
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").clangd.setup({})
    end,
  },
}

