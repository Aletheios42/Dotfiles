-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

-- no apila las lineas largas
vim.opt.wrap = false

-- convierte los espacios en tabs
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.clipboard = "unnamedplus"

vim.opt.scrolloff = 999
vim.opt.virtualedit = "block"

-- modo interectivo para los comandos de sustitucioon(Pantallita ocn los cambios)
vim.opt.inccommand = "split"
vim.opt.ignorecase = true

--  para permitir que nvim enseñe por pantalla todos los colores que permita tu terminal
vim.opt.termguicolors = true

vim.g.mapleader = " "


-- Para que la búsqueda de archivos incluya subdirectorios
vim.opt.path:append "**" 
-- Muestra el comando que estás escribiendo en la parte inferior derecha
vim.opt.showcmd = true 

