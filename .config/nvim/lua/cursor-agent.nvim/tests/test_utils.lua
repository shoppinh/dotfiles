local passed = 0
local failed = 0

local function eq(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s\n  expected: %s\n  actual:   %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function ok(value, message)
  if not value then
    error(message or "expected truthy value")
  end
end

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

local utils = require("cursor-agent.utils")

test("json roundtrip", function()
  local encoded = assert(utils.json_encode({ hello = "world", n = 1 }))
  local decoded = assert(utils.json_decode(encoded))
  eq(decoded.hello, "world", "decoded hello")
  eq(decoded.n, 1, "decoded n")
end)

test("terminal run statuses", function()
  ok(utils.is_terminal_run_status("FINISHED"))
  ok(utils.is_terminal_run_status("ERROR"))
  ok(not utils.is_terminal_run_status("RUNNING"))
end)

test("retryable statuses", function()
  ok(utils.is_retryable_status(429))
  ok(utils.is_retryable_status(500))
  ok(not utils.is_retryable_status(404))
end)

test("join_url", function()
  eq(utils.join_url("https://api.cursor.com/v1/", "/agents/"), "https://api.cursor.com/v1/agents", "join url")
end)

test("sanitize repos string", function()
  local repos = utils.sanitize_repos("https://github.com/org/repo")
  assert(repos[1].url == "https://github.com/org/repo")
end)

test("sanitize repos array of strings", function()
  local repos = utils.sanitize_repos({
    "https://github.com/org/repo",
  })
  assert(repos[1].url == "https://github.com/org/repo")
end)

test("sanitize repos single object", function()
  local repos = utils.sanitize_repos({
    url = "https://github.com/org/repo",
    startingRef = "main",
  })
  assert(repos[1].url == "https://github.com/org/repo")
  assert(repos[1].startingRef == "main")
end)

test("normalize model params array", function()
  local params = utils.normalize_model_params({
    { id = "fast", value = "false" },
  })
  assert(#params == 1)
  assert(params[1].id == "fast")
  assert(params[1].value == "false")
end)

test("normalize model params map", function()
  local params = utils.normalize_model_params({
    fast = "false",
  })
  assert(#params == 1)
  assert(params[1].id == "fast")
  assert(params[1].value == "false")
end)

test("normalize model params single object", function()
  local params = utils.normalize_model_params({
    id = "fast",
    value = "false",
  })
  assert(#params == 1)
  assert(params[1].id == "fast")
  assert(params[1].value == "false")
end)

print(string.format("\nUtils: %d passed, %d failed", passed, failed))
if failed > 0 then
  vim.cmd("cq")
end
