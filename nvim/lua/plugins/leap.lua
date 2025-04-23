-- https://github.com/ggandor/leap.nvim
return {
  "ggandor/leap.nvim",
  dependencies = {
    "tpope/vim-repeat",
  },
  config = function()
    require('leap').add_default_mappings()
    
    -- Configuración de etiquetas en orden numérico y QWERTY
    require('leap').opts = {
      labels = { 
        'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 
        'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 
        'z', 'x', 'c', 'v', 'b', 'n', 'm'
      },
      safe_labels = {
        'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
        'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'
      },
      highlight_unlabeled_phase_one_targets = true,
    }
  end,
}
