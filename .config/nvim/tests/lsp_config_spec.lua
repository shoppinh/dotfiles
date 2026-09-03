local spec = dofile(".config/nvim/lua/plugins/lsp.lua")

local opts = {
  servers = {
    ["*"] = {
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
          },
        },
      },
    },
    pyright = {
      enabled = false,
    },
    basedpyright = {
      enabled = true,
    },
    ruff = {
      enabled = true,
      init_options = {
        settings = {},
      },
    },
    omnisharp = {
      enabled = true,
    },
  },
}

spec.opts(nil, opts)

assert(opts.servers.pyright.enabled == false)
assert(opts.servers.basedpyright.enabled == true)
assert(opts.servers.ruff.enabled == true)
assert(opts.servers.ruff.init_options.settings.lint == nil)
assert(opts.servers.omnisharp.enabled == false)
assert(opts.servers["*"].capabilities.workspace.fileOperations.didRename == true)
assert(opts.servers["*"].capabilities.workspace.didChangeWatchedFiles == nil)
assert(opts.servers.vtsls.settings.vtsls.tsserver.maxTsServerMemory == 2048)
assert(type(opts.servers.tailwindcss.root_dir) == "function")

local lazy_file = assert(io.open(".config/nvim/lua/config/lazy.lua", "r"))
local lazy_config = lazy_file:read("*a")
lazy_file:close()

assert(not lazy_config:find("lazyvim.plugins.extras.lang.typescript.vtsls", 1, true))
