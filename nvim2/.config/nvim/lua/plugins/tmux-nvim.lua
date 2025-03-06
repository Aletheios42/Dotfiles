-- Para la integracion con tmux por ejemplo tabulaciones o resize
return {
  {
    "aserowy/tmux.nvim",
    config = function()
      return require("tmux").setup({
        resize = {
          enable_default_keybindings = false,
        },
      })
    end,
  },
}
