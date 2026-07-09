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
    },
  },
}

