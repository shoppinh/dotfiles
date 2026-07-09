return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      omnisharp = { enabled = false },
      ruff = {
        init_options = {
          settings = {
            lint = {
              enable = false,
            },
          },
        },
      },
      pyright = {
        settings = {
          python = {
            analysis = {
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      },
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      },
    },
  },
}


