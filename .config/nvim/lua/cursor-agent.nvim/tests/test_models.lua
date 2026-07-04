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

local models = require("cursor-agent.models")
local config = require("cursor-agent.config")

test("normalize string model", function()
  local model = models.normalize("composer-2.5")
  assert(model.id == "composer-2.5")
  assert(model.params == nil)
end)

test("normalize table model", function()
  local model = models.normalize({
    id = "composer-2",
    params = { { id = "fast", value = "true" } },
  })
  assert(model.id == "composer-2")
  assert(#model.params == 1)
end)

test("session overrides config model", function()
  config.setup({ model = "composer-2.5" })
  models.set_selected("claude-4-sonnet-thinking")
  assert(models.get_selected().id == "claude-4-sonnet-thinking")
  models.set_selected(nil)
  assert(models.get_selected().id == "composer-2.5")
end)

test("describe selected default", function()
  config.setup({ model = nil })
  models.set_selected(nil)
  assert(models.describe_selected() == "Cursor default (account/team)")
end)

test("resolve for create prefers opts", function()
  config.setup({ model = "composer-2.5" })
  models.set_selected(nil)
  local resolved = models.resolve_for_create({ model = "gpt-5.4-high" })
  assert(resolved.id == "gpt-5.4-high")
end)

test("coerce drops unsupported params", function()
  local selection = {
    id = "composer-2.5",
    params = { { id = "fast", value = "false" } },
  }
  local catalog_item = {
    id = "composer-2.5",
    displayName = "Composer 2.5",
    variants = {
      { params = {}, isDefault = true },
    },
  }
  local coerced, warning = models.coerce_for_api(selection, catalog_item)
  assert(coerced.id == "composer-2.5")
  assert(coerced.params == nil)
  assert(warning ~= nil)
end)

test("coerce keeps matching variant params", function()
  local selection = {
    id = "composer-2",
    params = { { id = "fast", value = "true" } },
  }
  local catalog_item = {
    id = "composer-2",
    variants = {
      { params = { { id = "fast", value = "true" } }, isDefault = true },
      { params = { { id = "fast", value = "false" } } },
    },
  }
  local coerced, warning = models.coerce_for_api(selection, catalog_item)
  assert(models.params_equal(coerced.params, selection.params))
  assert(warning == nil)
end)

print(string.format("\nModels: %d passed, %d failed", passed, failed))
if failed > 0 then
  vim.cmd("cq")
end
