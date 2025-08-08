return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      -- Define cursor colors using Catppuccin's palette
      local cursor_normal = "#F38BA8"  -- Pink
      local cursor_insert = "#A6E3A1"  -- Green
      local cursor_visual = "#FAB387"  -- Peach
      local cursor_replace = "#F9E2AF" -- Yellow

      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
        },
        integrations = {
          nvimtree = true,
          telescope = true,
          treesitter = true,
          cmp = true,
          gitsigns = true,
          neotree = true,
        },
        custom_highlights = function(colors)
          return {
            -- Make windows transparent
            NormalFloat = { bg = "none" },
            FloatBorder = { bg = "none" },
            NormalNC = { bg = "none" },
            WinBarNC = { bg = "none" },
            WinBar = { bg = "none" },
            WinSeparator = { bg = "none" },
            NeoTreeNormal = { bg = "none" },
            NeoTreeNormalNC = { bg = "none" },
            NvimTreeNormal = { bg = "none" },
            NvimTreeNormalNC = { bg = "none" },
            
            -- Define cursor highlight groups with bright colors
            MyCursorNormal = { fg = "#FFFFFF", bg = cursor_normal },
            MyCursorInsert = { fg = "#000000", bg = cursor_insert },
            MyCursorVisual = { fg = "#000000", bg = cursor_visual },
            MyCursorReplace = { fg = "#000000", bg = cursor_replace },
            
            -- Enhance cursor line visibility
            CursorLine = { bg = "#313244" },
            CursorColumn = { bg = "#313244" },
            CursorLineNr = { fg = cursor_normal, bold = true },
          }
        end,
      })
      
      -- Enable cursor line
      vim.opt.cursorline = true
      
      -- Set cursor shapes and highlight groups for different modes
      vim.opt.guicursor = table.concat({
        "n-v-c:block-MyCursorNormal",
        "i-ci-ve:ver25-MyCursorInsert",
        "r-cr:hor20-MyCursorReplace",
        "o:hor50-MyCursorNormal",
        "a:blinkwait700-blinkoff400-blinkon250",
        "sm:block-blinkwait175-blinkoff150-blinkon175",
      }, ",")
      
      -- Mode-specific cursor line numbers
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*",
        callback = function()
          local mode = vim.fn.mode()
          if mode == "i" then
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = cursor_insert, bold = true })
          elseif mode == "v" or mode == "V" then
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = cursor_visual, bold = true })
          elseif mode == "R" then
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = cursor_replace, bold = true })
          else
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = cursor_normal, bold = true })
          end
        end,
      })
      
      vim.cmd([[colorscheme catppuccin]])
    end,
  },
}
