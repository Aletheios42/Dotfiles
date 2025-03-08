return {
  -- add gruvbox
  { 'wittyjudge/gruvbox-material.nvim' },

  -- Configure LazyVim to load gruvbox
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'gruvbox-material',
    },
  },
}

-- Color azul negro como el de la terminal, no me gusta que sea tan parecido
-- return {
--   {
--     'scottmckendry/cyberdream.nvim',
--     lazy = false,
--     priority = 1000,
--     config = function()
--       require('cyberdream').setup {
--         transparent = true,
--         italic_comments = true,
--         borderless_telescope = false,
--       }
--       vim.cmd [[colorscheme cyberdream]]
--     end,
--   },
-- }
