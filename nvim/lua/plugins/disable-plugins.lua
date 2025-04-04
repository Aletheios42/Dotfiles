-- En lua/plugins/kill-neotree.lua
return {
  -- Desactivar neo-tree de todas las formas posibles
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  -- Desactivar también posibles formas alternativas
  { "neo-tree",                    enabled = false },
  { "neo-tree.nvim",               enabled = false },

  -- Sobreescribir la configuración de LazyVim para quitar los keymaps
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      -- Desactivar la sección explorer completa
      if opts.ui and opts.ui.explorer then
        opts.ui.explorer = nil
      end

      -- Eliminar keymaps
      if opts.keymaps then
        opts.keymaps["<leader>e"] = false
        opts.keymaps["<leader>E"] = false
        opts.keymaps["<leader>fe"] = false
        opts.keymaps["<leader>fE"] = false
      end

      -- Desactivar plugins de LazyVim
      if not opts.plugins then
        opts.plugins = {}
      end

      if not opts.plugins.disabled then
        opts.plugins.disabled = {}
      end

      table.insert(opts.plugins.disabled, "neo-tree.nvim")

      return opts
    end,
  },
}
