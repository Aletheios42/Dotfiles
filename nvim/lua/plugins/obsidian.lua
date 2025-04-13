return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
  },
  opts = {
    workspaces = {
      {
        name = "SecondBrain",
        path = "/home/aletheios/SecondBrain",
      },
    },

    -- Configuración adaptada a tu estructura
    notes_subdir = "01_Zettelkasten",

    -- Configuración de plantilla por defecto
    note_template_file = "03_Templates/00_Plantilla_notas_atómicas.md",

    -- Configuración de búsqueda con fzf
    finder = "fzf-lua",

    -- Configuración de UI
    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "□", hl_group = "ObsidianTodo" },
        ["x"] = { char = "✓", hl_group = "ObsidianDone" },
      },
    },
  },
  config = function(_, opts)
    -- Seteamos conceallevel directamente al cargar la configuración
    vim.opt.conceallevel = 2

    require("obsidian").setup(opts)

    -- Keymappings básicos
    vim.keymap.set("n", "<leader>on", function()
      vim.cmd("ObsidianNew")
      -- Esperar brevemente para que se cargue la plantilla
      vim.defer_fn(function()
        -- Buscar la posición después del primer separador "- - -"
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local target_line = 0
        local found_first = false

        for i, line in ipairs(lines) do
          if line:match("^%s*%-%s*%-%s*%-") then
            if not found_first then
              found_first = true
            else
              -- Encontramos el segundo separador, posicionamos en la línea anterior
              target_line = i - 1
              break
            end
          end
        end

        if target_line > 0 then
          -- Mover el cursor a la línea objetivo
          vim.api.nvim_win_set_cursor(0, {target_line, 0})
          -- Entrar en modo insertar
          vim.cmd("startinsert")
        end
      end, 100)
    end, { desc = "Nueva nota" })

    -- vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>", { desc = "Insertar plantilla" })
    vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Abrir en Obsidian" })
    vim.keymap.set("n", "<leader>of", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Buscar nota" })
    vim.keymap.set("n", "<leader>og", "<cmd>ObsidianSearch<CR>", { desc = "Búsqueda global" })
    vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Ver backlinks" })

    -- Búsqueda por etiquetas personalizada
    vim.keymap.set("n", "<leader>ot", function()
      local fzf = require('fzf-lua')

      -- Primero, obtenemos todas las etiquetas disponibles con ripgrep
      local handle = io.popen('cd ' .. opts.workspaces[1].path .. ' && rg -o "#[\\w_]+" --no-filename | sort | uniq')
      local tags = {}

      if handle then
        for line in handle:lines() do
          table.insert(tags, line)
        end
        handle:close()
      end

      -- Mostramos la lista de etiquetas con fzf
      fzf.fzf_exec(tags, {
        prompt = "Etiquetas > ",
        actions = {
          ["default"] = function(selected)
            local tag = selected[1]
            -- Ahora buscamos notas con esa etiqueta
            vim.cmd("cd " .. opts.workspaces[1].path)
            fzf.grep({
              search = tag,
              prompt = "Notas con " .. tag .. " > ",
              file_ignore_patterns = {"node_modules"},
              git_icons = false
            })
          end,
        }
      })
    end, { desc = "Buscar por etiquetas" })

    -- Navegación de enlaces
    vim.keymap.set("n", "gf", function()
      if require("obsidian").util.cursor_on_markdown_link() then
        return "<cmd>ObsidianFollowLink<CR>"
      else
        return "gf"
      end
    end, { noremap = false, expr = true })
  end,
}
