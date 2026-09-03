return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = opts.servers or {}
    opts.servers["*"] = opts.servers["*"] or {}
    opts.servers["*"].capabilities = {
      workspace = {
        didChangeWatchedFiles = {
          dynamicRegistration = false,
        },
      },
    }
    opts.servers.omnisharp = { enabled = false }
    opts.servers.ruff = {
      init_options = {
        settings = {
          lint = {
            enable = false,
          },
        },
      },
    }
    opts.servers.pyright = {
      settings = {
        python = {
          analysis = {
            diagnosticMode = "openFilesOnly",
          },
        },
      },
    }
    opts.servers.basedpyright = {
      settings = {
        basedpyright = {
          analysis = {
            diagnosticMode = "openFilesOnly",
          },
        },
      },
    }
  end,
}


