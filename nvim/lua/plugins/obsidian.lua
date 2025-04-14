-- nvim/lua/plugins/obsidian.lua
return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
  },
  opts = {
    workspaces = {
      {
        name = "SecondBrain",
        path = vim.fn.expand("$SECONDBRAIN"),
      },
    },
    notes_subdir = "01_Zettelkasten",
    note_template_file = vim.fn.expand("$SECONDBRAIN") .. "/03_Templates/00_Plantilla_notas_atómicas.md",
    finder = "fzf-lua",
    disable_frontmatter = true,

    -- Añadir estas opciones para personalizar la creación de notas
    new_notes_location = "notes_subdir",
    templates = {
      subdir = "03_Templates",
      date_format = "%Y-%m-%d",
      substitutions = {}
    },

    -- Asegurar que no está usando ID para nombrar archivos
    use_advanced_uri = false,

    -- Desactivar YAML completamente
    yaml_parser = "none",

    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "□", hl_group = "ObsidianTodo" },
        ["x"] = { char = "✓", hl_group = "ObsidianDone" },
      },
    },

    -- Función personalizada para seguir URLs
    follow_url_func = function(url)
      -- Determinar si la URL es local o externa
      if url:match("^https?://") then
        -- URL externa: abrir con xdg-open (Linux), open (macOS), o start (Windows)
        vim.fn.jobstart({"xdg-open", url}, {detach = true})
      else
        -- URL local: usar Obsidian o Neovim para abrir
        -- Si es un archivo de markdown, abrir en Neovim
        if url:match("%.md$") then
          vim.cmd("edit " .. url)
        else
          -- Para otros archivos locales, usar xdg-open
          vim.fn.jobstart({"xdg-open", url}, {detach = true})
        end
      end
    end,

    -- Activar debug para ver errores
    debug = true,
  },
  config = function(_, opts)
    vim.opt.conceallevel = 2

    -- Configurar obsidian.nvim
    require("obsidian").setup(opts)

    -- Función personalizada para crear notas con plantilla
    local function create_note_with_template()
      -- Solicitar nombre de nota
      vim.ui.input({prompt = "Nombre de la nota: "}, function(input)
        if not input or input == "" then return end

        -- Definir la ruta base de Zettelkasten usando la variable de entorno
        local zettelkasten_path = vim.fn.expand("$SECONDBRAIN") .. "/01_Zettelkasten/"
        local filename = input .. ".md"
        local full_path = zettelkasten_path .. filename

        -- Crear buffer (no listado para que no aparezca en :ls por defecto)
        local bufnr = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_buf_set_name(bufnr, full_path)
        vim.api.nvim_set_current_buf(bufnr)

        -- Leer contenido de la plantilla
        local template_path = vim.fn.expand("$SECONDBRAIN") .. "/03_Templates/00_Plantilla_notas_atómicas.md"
        local file = io.open(template_path, "r")

        if not file then
          print("Error: No se pudo abrir la plantilla en " .. template_path)
          return
        end

        local content = file:read("*all")
        file:close()

        -- Insertar plantilla en el buffer
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))

        -- Guardar la nota directamente en la ruta correcta
        vim.cmd("write! " .. full_path)

        -- Posicionar cursor en la posición deseada
        vim.defer_fn(function()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local target_line = 0
          local found_first = false

          for i, line in ipairs(lines) do
            if line:match("^%s*%-%s*%-%s*%-") then
              if not found_first then
                found_first = true
              else
                target_line = i - 1
                break
              end
            end
          end

          if target_line > 0 then
            vim.api.nvim_win_set_cursor(0, {target_line, 0})
            vim.cmd("startinsert")
          end
        end, 100)
      end)
    end

    -- Reemplazar el keymapping original con la función personalizada
    vim.keymap.set("n", "<leader>on", create_note_with_template, { desc = "Nueva nota con plantilla" })
    vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Abrir en Obsidian" })
    vim.keymap.set("n", "<leader>of", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Buscar nota" })
    vim.keymap.set("n", "<leader>og", "<cmd>ObsidianSearch<CR>", { desc = "Búsqueda global" })
    vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Ver backlinks" })
    
    -- Añadir keymapping específico para seguir enlaces bajo el cursor
    vim.keymap.set("n", "gx", "<cmd>ObsidianFollowLink<CR>", { desc = "Seguir enlace bajo el cursor" })

    -- Búsqueda por etiquetas personalizada (solo primeras dos líneas) - Busca en todo SecondBrain
    vim.keymap.set("n", "<leader>ot", function()
      local fzf = require('fzf-lua')
      local workspace_path = opts.workspaces[1].path
      local command = [[
        rg --files --hidden --follow "$(echo ']] .. workspace_path .. [[')" -g '*.md' | while IFS= read -r -d $'\n' file; do
          head -n 2 "$file" | rg -o '#[[:word:]_]+' --no-filename
        done | sort | uniq
      ]]
      local handle = io.popen(command)
      local tags = {}
      if handle then
        for line in handle:lines() do
          table.insert(tags, line)
        end
        handle:close()
      end

      fzf.fzf_exec(tags, {
        prompt = "Etiquetas > ",
        actions = {
          ["default"] = function(selected)
            local tag = selected[1]
            vim.cmd("cd " .. workspace_path)
            fzf.grep({
              search = tag,
              prompt = "Notas con " .. tag .. " > ",
              file_ignore_patterns = {"node_modules"},
              git_icons = false
            })
          end,
        }
      })
    end, { desc = "Buscar por etiquetas (primeras líneas) - Todo SecondBrain" })
  end
}
