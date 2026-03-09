return {
	"akinsho/bufferline.nvim",
	enabled = true,
	opts = {
		options = {
			-- Existing
			numbers = "ordinal",
			color_icons = true,
			separator_style = "thick", -- "slant", "thick", "thin", etc.
			diagnostics = "nvim_lsp",
			diagnostics_update_in_insert = false,

			-- Added
			themable = true,

			indicator = {
				icon = "  ",
				style = "icon",
			},

			show_buffer_close_icons = true,
			show_close_icon = true, -- changed from false since you wanted it added

			buffer_close_icon = "",
			close_icon = "",
			modified_icon = "",
		},
	},
}
