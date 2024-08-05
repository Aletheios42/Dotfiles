
local local_plugins = {
    {
        "vim-apm", dir = "~/personal/vim-apm",
        config = function()
            --[[
            local apm = require("vim-apm")

            apm:setup({})
            vim.keymap.set("n", "<leader>apm", function() apm:toggle_monitor() end)
            --]]
        end
    },
    {
        "vim-with-me", dir = "~/personal/vim-with-me",
        config = function() end
    },
}

return local_plugins

