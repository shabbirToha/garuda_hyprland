return {
	{
		"linrongbin16/lsp-progress.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lsp-progress").setup()
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"linrongbin16/lsp-progress.nvim",
		},
		opts = function()
			local function lsp_clients()
				return require("lsp-progress").progress({
					format = function(messages)
						local active_clients = vim.lsp.get_clients()
						if #messages > 0 then
							return " LSP:" .. table.concat(messages, " ")
						end
						local client_names = {}
						for _, client in ipairs(active_clients) do
							if client and client.name ~= "" then
								table.insert(client_names, "[" .. client.name .. "]")
							end
						end
						return #client_names > 0 and " LSP:" .. table.concat(client_names, " ") or " LSP: none"
					end,
				})
			end

			local function project_name()
				return "📁 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
			end

			local mode_map = {
				["n"] = "N",
				["i"] = "I",
				["v"] = "V",
				["V"] = "V",
				[""] = "V",
				["c"] = "C",
				["s"] = "S",
				["S"] = "S",
				[""] = "S",
				["R"] = "R",
				["r"] = "R",
				["!"] = "!",
				["t"] = "T",
			}

			return {
				options = {
					theme = "auto",
					globalstatus = true,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = {
						{
							"mode",
							icon = "",
							fmt = function(str)
								return mode_map[vim.fn.mode()] or str:sub(1, 1)
							end,
						},
					},
					lualine_b = {
						{ "branch", icon = "" },
						{
							"diff",
							symbols = { added = " ", modified = " ", removed = " " },
							colored = true,
							diff_color = {
								added = { fg = "#98be65" },
								modified = { fg = "#51afef" },
								removed = { fg = "#ec5f67" },
							},
							source = function()
								local gitsigns = vim.b.gitsigns_status_dict
								if gitsigns then
									return {
										added = gitsigns.added,
										modified = gitsigns.changed,
										removed = gitsigns.removed,
									}
								end
							end,
						},
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = { error = " ", warn = " ", info = " ", hint = "💡" },
							colored = true,
						},
					},
					lualine_c = {
						{ project_name },
						{
							"filename",
							path = 1,
							symbols = { modified = "📝", readonly = "🔏" },
						},
					},
					lualine_x = {
						{ lsp_clients },
					},
					lualine_y = {
						{ "filetype", colored = true, icon_only = false },
						{ "encoding" },
					},
					lualine_z = {
						{ "progress" },
						{ "location" },
					},
				},
				extensions = { "neo-tree", "lazy", "mason", "trouble" },
			}
		end,
		config = function(_, opts)
			require("lualine").setup(opts)
			vim.api.nvim_create_autocmd("User", {
				pattern = "LspProgressStatusUpdated",
				callback = require("lualine").refresh,
			})
		end,
	},
}
