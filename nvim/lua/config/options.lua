-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- numeros al lado
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.path:append "**" -- Para que la búsqueda de archivos incluya subdirectorios

vim.opt.wildmenu = true -- Activa el menú desplegable para autocompletar comandos

vim.opt.showcmd = true -- Muestra el comando que estás escribiendo en la parte inferior
