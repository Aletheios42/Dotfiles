-- Este plugin te permite renombrar archivos, y variables lo tengo mapeado:
--  vim.api.nvim_set_keymap('n', '<leader>rn', ':IncRename ', { noremap = true, silent = true })
return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  config = true,
}
