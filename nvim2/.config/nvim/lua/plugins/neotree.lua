--  Es el tree de la derecha, lo tengo mapeado:
-- Abre el árbol de archivos en el panel derecho
----keymap.set("n", "<leader>e", "<Cmd>Neotree toggle<CR>", { desc = "Toggle NeoTree" })

-- Navega dentro del árbol de archivos
-----keymap.set("n", "<leader>r", "<Cmd>Neotree reveal<CR>", { desc = "Reveal in NeoTree" })

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "right",
      mappings = {
        ["Y"] = "none",
        -- Agregar el mapeo 'b' para abrir archivos en un nuevo buffer
        ["b"] = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id() -- Obtiene la ruta completa del archivo

          -- Abre el archivo en un nuevo buffer
          vim.cmd("badd " .. filepath)
          vim.cmd("buffer " .. filepath) -- Cambia al buffer recién añadido
        end,
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_by_name = {
          ".git",
          ".DS_Store",
        },
        always_show = {
          ".env",
        },
      },
    },
  },
}

-- return {
--   "nvim-neo-tree/neo-tree.nvim",
--   opts = {
--     window = {
--       position = "right",
--       mappings = {
--         ["Y"] = "none",
--       },
--     },
--     filesystem = {
--       filtered_items = {
--         hide_dotfiles = false,
--         hide_by_name = {
--           ".git",
--           ".DS_Store",
--         },
--         always_show = {
--           ".env",
--         },
--       },
--     },
--   },
-- }
