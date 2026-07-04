return {
  -- messages, cmdline and the popupmenu
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })

      opts.presets.lsp_doc_border = true
    end,
  },

  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 5000,
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      dashboard = {
        preset = {
          header = [[
   ███████╗██╗  ██╗ ██████╗ ██████╗ ██████╗ ██╗███╗   ██╗██╗  ██╗
   ██╔════╝██║  ██║██╔═══██╗██╔══██╗██╔══██╗██║████╗  ██║██║  ██║
   ███████╗███████║██║   ██║██████╔╝██████╔╝██║██╔██╗ ██║███████║
   ╚════██║██╔══██║██║   ██║██╔═══╝ ██╔═══╝ ██║██║╚██╗██║██╔══██║
   ███████║██║  ██║╚██████╔╝██║     ██║     ██║██║ ╚████║██║  ██║
   ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝

   ]],
        },
      },
    },
  },

  -- buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
    },
    opts = {
      options = {
        mode = "tabs",
        -- separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },

  -- filename
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local function hl_color(group, attr)
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        if not ok or not hl[attr] then
          return nil
        end
        return string.format("#%06x", hl[attr])
      end

      local function incline_highlight()
        return {
          InclineNormal = {
            guibg = hl_color("Visual", "bg") or hl_color("String", "fg"),
            guifg = hl_color("Normal", "fg"),
          },
          InclineNormalNC = {
            guibg = hl_color("Normal", "bg"),
            guifg = hl_color("Comment", "fg"),
          },
        }
      end

      local function setup()
        require("incline").setup({
          highlight = {
            groups = incline_highlight(),
          },
          window = { margin = { vertical = 0, horizontal = 1 } },
          hide = {
            cursorline = true,
          },
          render = function(props)
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
            if vim.bo[props.buf].modified then
              filename = "[+] " .. filename
            end

            local icon, color = require("nvim-web-devicons").get_icon_color(filename)
            return { { icon, guifg = color }, { " " }, { filename } }
          end,
        })
      end

      setup()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = setup,
      })
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local LazyVim = require("lazyvim.util")
      opts.sections.lualine_c[4] = {
        LazyVim.lualine.pretty_path({
          length = 0,
          relative = "cwd",
          modified_hl = "MatchParen",
          directory_hl = "",
          filename_hl = "Bold",
          modified_sign = "",
          readonly_icon = " 󰌾 ",
        }),
      }
    end,
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = {
        gitsigns = true,
        tmux = true,
        kitty = { enabled = false, font = "+2" },
      },
    },
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
  },
}
