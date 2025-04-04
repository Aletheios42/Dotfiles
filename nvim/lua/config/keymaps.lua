-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


-- Sobrescribir mapeos de LazyVim para el explorador de archivos
-- Eliminar mapeos existentes de neo-tree si existen
vim.keymap.del("n", "<leader>e")
vim.keymap.del("n", "<leader>E")

-- Asignar a mini.files
vim.keymap.set("n", "<leader>e", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0))
end, { desc = "Explorer (current file)" })

vim.keymap.set("n", "<leader>E", function()
  require("mini.files").open(vim.loop.cwd())
end, { desc = "Explorer (root dir)" })
