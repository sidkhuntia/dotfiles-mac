return {
	"akinsho/bufferline.nvim",
	-- cmd = {
	-- 	"BufferLineCloseOthers",
	-- 	"BufferLineCloseLeft",
	-- 	"BufferLineCloseRight",
	-- },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	opts = {
		options = {
			mode = "tabs",
			--      separator_style = "slope",
			diagonstics = "nvim_lsp",
			-- hover = {
			-- 	enabled = true,
			-- 	delay = 150,
			-- 	reveal = { "close" },
			-- },
			indicator = {
				style = "underline",
			},
		},
	},
	-- 	keys = {
	-- 		{ "<leader>co", "<cmd>BufferLineCloseOthers<cr>", desc = "Close all other visible buffers" },
	-- 		{ "<leader>cl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all visible buffers to the left of current" },
	-- 		{ "<leader>cr", "<cmd>BufferLineCloseRight<cr>", desc = "Close all visible buffers to the right of current" },
	-- 	},
}
