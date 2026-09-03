return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    opts.servers.omnisharp = vim.tbl_deep_extend("force", opts.servers.omnisharp or {}, { enabled = false })
    opts.servers.basedpyright = vim.tbl_deep_extend("force", opts.servers.basedpyright or {}, {
      settings = {
        basedpyright = {
          analysis = {
            diagnosticMode = "openFilesOnly",
          },
        },
      },
    })
    opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls or {}, {
      settings = {
        vtsls = {
          tsserver = {
            maxTsServerMemory = 2048,
          },
        },
      },
    })
    opts.servers.tailwindcss = vim.tbl_deep_extend("force", opts.servers.tailwindcss or {}, {
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname == "" then
          return
        end
        local root_files = {
          "tailwind.config.js",
          "tailwind.config.cjs",
          "tailwind.config.mjs",
          "tailwind.config.ts",
          "postcss.config.js",
          "postcss.config.cjs",
          "postcss.config.mjs",
          "postcss.config.ts",
        }
        local root = vim.fs.root(fname, root_files)
        if not root then
          local pkg_root = vim.fs.root(fname, "package.json")
          if pkg_root then
            local pkg_file = vim.fs.joinpath(pkg_root, "package.json")
            local f = io.open(pkg_file, "r")
            if f then
              local content = f:read("*a")
              f:close()
              if content and content:find('"tailwindcss"') then
                root = pkg_root
              end
            end
          end
        end
        if root then
          on_dir(root)
        end
      end,
    })
  end,
}
