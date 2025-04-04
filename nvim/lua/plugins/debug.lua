-- En lua/plugins/debug.lua
return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      triggers_nowait = {
        -- Añadir este trigger para ver qué se carga al pulsar <leader>e
        "<leader>e",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    priority = 10000,
    config = function()
      -- Muestra todos los plugins cargados al iniciar
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.defer_fn(function()
            print("Plugins cargados:")
            for name, _ in pairs(require("lazy.core.config").plugins) do
              if name:match("neo%-tree") or name:match("explorer") then
                print("- " .. name)
              end
            end
          end, 100)
        end,
      })
    end,
  }
}
