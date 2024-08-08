-- Este plugin enfoca el area de trabajo
--  pero creo que entra en conflicto con otros porque no parece que fncione
return {
  "folke/twilight.nvim",
  opts = {
    context = 10,
    expand = {
      "function",
      "method",
      "table",
      "if_statement",
      "function_declaration",
      "method_declaration",
      "pair",
    },
  },
}
