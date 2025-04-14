-- https://github.com/folke/zen-mode.nvim
return
{
  "folke/zen-mode.nvim",
  opts = {
  vim.api.nvim_set_keymap('n', '<leader>z', ':ZenMode<CR>', { noremap = true, silent = true })
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }

}
