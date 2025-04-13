-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here


-- lua/config/options.lua
vim.opt.syntax = "ON"
-- lua/config/options.lua
vim.opt.filetypeplugin = "ON"
vim.opt.filetypeindent = "ON" -- Opcional: para la indentación automática basada en el tipo de archivo

-- lua/config/options.lua
vim.opt.path:append "**"

-- lua/config/options.lua
vim.opt.wildmenu = true

-- lua/config/options.lua
vim.opt.showcmd = true
