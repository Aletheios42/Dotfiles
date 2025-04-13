
-- lua/config/commands.lua
vim.api.nvim_create_user_command('BufOnly', '%bd | e# | bd#', { bang = true })
