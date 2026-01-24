local function lsp_clients()
  return require("lsp-progress").progress({
    format = function(messages)
      local active_clients = vim.lsp.get_clients()
      if #messages > 0 then
        return " LSP:" .. table.concat(messages, " ")
      end
      local client_names = {}
      for _, client in ipairs(active_clients) do
        if client and client.name ~= "" then
          table.insert(client_names, "[" .. client.name .. "]")
        end
      end
      if #client_names == 0 then
        return " LSP: none"
      end
      return " LSP:" .. table.concat(client_names, " ")
    end,
  })
end

-- 🌈 Quotes
local quotes = {
  "Code. Debug. Repeat.",
  "Keep calm and code Go 🐹",
  "No bugs, just features!",
  "Eat, Sleep, Code, Repeat.",
  "Stay curious, keep coding!",
  "Refactor fearlessly 💪",
  "Ship it! 🚀",
}

local current_quote = quotes[math.random(#quotes)]
local fade_level = 200

local function update_fade()
  local color = string.format("#%02x%02x%02x", fade_level, fade_level, fade_level)
  vim.api.nvim_set_hl(0, "QuoteHighlight", { fg = color })
end

local function fade_quote()
  local step = 4
  local increasing = false
  vim.fn.timer_start(50, function()
    fade_level = fade_level + (increasing and step or -step)
    if fade_level <= 80 then
      increasing = true
    end
    if fade_level >= 230 then
      increasing = false
    end
    update_fade()
  end, { ["repeat"] = -1 })
end

-- Change quote every 1 minute
vim.fn.timer_start(60000, function()
  current_quote = quotes[math.random(#quotes)]
end, { ["repeat"] = -1 })

fade_quote()

-- 📁 Current project name
local function project_name()
  local cwd = vim.fn.getcwd()
  return "📁 " .. vim.fn.fnamemodify(cwd, ":t")
end

return {
  {
    "linrongbin16/lsp-progress.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lsp-progress").setup()
    end,
  },
  {
    event = "VeryLazy",
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "linrongbin16/lsp-progress.nvim",
    },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch", icon = "" }, -- Git branch icon
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
          },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " " },
          },
          lsp_clients,
        },
        lualine_c = { project_name },
        lualine_x = {
          function()
            return "%#QuoteHighlight#" .. current_quote
          end,
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
      vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        pattern = "LspProgressStatusUpdated",
        group = "lualine_augroup",
        callback = require("lualine").refresh,
      })
    end,
  },
}
