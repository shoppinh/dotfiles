local passed = 0
local failed = 0

local function test(name, fn)
  local ok_run, err = pcall(fn)
  if ok_run then
    passed = passed + 1
    print("PASS: " .. name)
  else
    failed = failed + 1
    print("FAIL: " .. name)
    print("  " .. tostring(err))
  end
end

local config = require("cursor-agent.config")

test("setup merges defaults", function()
  config.setup({
    polling_interval = 5,
    ui = { border = "single" },
  })

  local opts = config.get()
  assert(opts.polling_interval == 5)
  assert(opts.ui.border == "single")
  assert(opts.base_url == "https://api.cursor.com/v1")
end)

test("api key from env", function()
  vim.env.CURSOR_API_KEY = "test-key"
  config.setup({ api_key = nil })
  assert(config.get_api_key() == "test-key")
  vim.env.CURSOR_API_KEY = nil
end)

test("validation fails without api key", function()
  vim.env.CURSOR_API_KEY = nil
  config.setup({ api_key = nil })
  local ok_run = pcall(config.validate)
  assert(not ok_run, "expected validation error")
end)

test("validation passes with api key", function()
  config.setup({ api_key = "test-key" })
  assert(config.validate())
end)

print(string.format("\nConfig: %d passed, %d failed", passed, failed))
if failed > 0 then
  vim.cmd("cq")
end
