return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Configure linters
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			-- go = { "ast_grep" },
			cpp = { "cpplint" },
			c = { "cpplint" },
		}

		-- Customize linter configurations
		-- golangci-lint configuration
		lint.linters.golangci_lint = {
			cmd = "golangci-lint",
			args = { "run", "--out-format", "json" },
			stdin = false,
			stream = "both",
			ignore_exitcode = true, -- Prevents errors if golangci-lint finds issues
		}

		-- eslint_d configuration
		lint.linters.eslint_d = {
			cmd = "eslint_d",
			args = { "--format", "json", "--stdin", "--stdin-filename", "$FILENAME" },
			stdin = true,
			ignore_exitcode = true,
		}

		-- pylint configuration
		lint.linters.pylint = {
			cmd = "pylint",
			args = {
				"--output-format=json",
				"--score=no",
				"--msg-template='{line}: {column}: {msg} ({msg_id}:{symbol})'",
			},
			stdin = false,
			ignore_exitcode = true,
		}

		-- cpplint configuration
		lint.linters.cpplint = {
			cmd = "cpplint",
			args = { "--quiet" },
			stdin = false,
			ignore_exitcode = true,
		}

		-- Create lint autogroup
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Setup autocommands for linting
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				-- Protect against invalid buffers
				local bufnr = vim.api.nvim_get_current_buf()
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end

				-- Check if the file type has a configured linter
				local filetype = vim.bo.filetype
				if lint.linters_by_ft[filetype] then
					lint.try_lint()
				end
			end,
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })

		-- Additional keymap to show lint status
		vim.keymap.set("n", "<leader>ls", function()
			local filetype = vim.bo.filetype
			local linters = lint.linters_by_ft[filetype] or {}
			print("Active linters for " .. filetype .. ": " .. table.concat(linters, ", "))
		end, { desc = "Show active linters for current file" })
	end,
}
