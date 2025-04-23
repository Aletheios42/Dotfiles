-- https://github.com/mg979/vim-visual-multi
return {
  "mg979/vim-visual-multi",
  branch = "master",
  config = function()
    -- Configuración personalizada para mapeos más estilo Vim
    vim.g.VM_maps = {
      -- Reemplaza Ctrl+n con otra tecla para seleccionar palabra
      ["Find Under"] = "<Leader>m",  -- Usar <Leader>m en vez de Ctrl+n
      
      -- Usar j/k en vez de flechas
      ["Add Cursor Down"] = "j",
      ["Add Cursor Up"] = "k",
      
      -- Navegación entre ocurrencias/cursores
      ["Next"] = "n",      -- Siguiente ocurrencia
      ["Previous"] = "N",  -- Anterior ocurrencia
      ["Skip"] = "q",      -- Saltar ocurrencia actual
      
      -- Selección de cursores
      ["Select All"] = "<Leader>a",  -- Seleccionar todas las ocurrencias
    }
  end,
}
