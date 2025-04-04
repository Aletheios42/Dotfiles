-- En lua/plugins/mini-files.lua
return {
  "echasnovski/mini.files",
  version = false,
  keys = {
    {
      "<leader>e",
      function() require("mini.files").open() end,
      desc = "Explorer (mini.files)",
    },
    {
      "<leader>E",
      function() require("mini.files").open(vim.fn.expand("%:p:h")) end,
      desc = "Explorer (current dir)",
    },
  },
  config = function()
    require("mini.files").setup()
  end,
}
