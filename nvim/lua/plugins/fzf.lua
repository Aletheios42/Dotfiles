return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    
    -- Configuración básica
    fzf.setup({
      -- Opciones globales aquí si las necesitas
    })
    
    -- Keymappings
    local map = vim.keymap.set
    -- Búsqueda de archivos
    map("n", "<leader>ff", fzf.files, { desc = "Find files" })
    map("n", "<leader>fg", fzf.git_files, { desc = "Find git files" })
    map("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
    map("n", "<leader>fo", fzf.oldfiles, { desc = "Find recently opened files" })
    
    -- Búsqueda de texto
    map("n", "<leader>fw", fzf.grep_cword, { desc = "Find word under cursor" })
    map("n", "<leader>fl", fzf.live_grep, { desc = "Live grep" })
    map("n", "<leader>fs", fzf.grep_project, { desc = "Search in project" })
    
    -- Git
    map("n", "<leader>gc", fzf.git_commits, { desc = "Git commits" })
    map("n", "<leader>gb", fzf.git_branches, { desc = "Git branches" })
    
    -- LSP
    map("n", "<leader>lr", fzf.lsp_references, { desc = "LSP references" })
    map("n", "<leader>ld", fzf.lsp_definitions, { desc = "LSP definitions" })
    map("n", "<leader>lt", fzf.lsp_typedefs, { desc = "LSP type definitions" })
    map("n", "<leader>ls", fzf.lsp_document_symbols, { desc = "LSP document symbols" })
  end,
}
