-- Archivo: ~/.config/nvim/lua/plugins/init.lua
return {
  -- Otros plugins
  {
    "lervag/vimtex",
    lazy = false, -- Asegúrate de que no se cargue de forma perezosa
    config = function()
      vim.g.vimtex_view_method = "zathura"
    end,
  },
  -- Otros plugins
}
