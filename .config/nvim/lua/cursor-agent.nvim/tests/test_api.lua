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

local api = require("cursor-agent.api")
local config = require("cursor-agent.config")
local mock_api = require("tests.helpers.mock_api")

config.setup({ api_key = "test-key", polling_interval = 0.01, max_poll_attempts = 5 })

test("create_agent posts prompt", function()
  mock_api.reset()
  mock_api.stub("POST", "/agents$", {
    agent = { id = "bc-1", name = "Test", status = "ACTIVE" },
    run = { id = "run-1", agentId = "bc-1", status = "CREATING" },
  })

  local client = api.new()
  mock_api.attach(client)

  local done = false
  api.create_agent(client, "hello", {}, function(err, data)
    assert(not err, err)
    assert(data.agent.id == "bc-1")
    assert(data.run.id == "run-1")
    done = true
  end)

  vim.wait(1000, function()
    return done
  end)

  assert(done, "callback not called")
  local call = mock_api.get_call_log()[1]
  assert(call.body.prompt.text == "hello")
  assert(call.body.model == nil)
  assert(#mock_api.get_call_log() == 1)
end)

test("create_agent sanitizes string repos", function()
  mock_api.reset()
  mock_api.stub("POST", "/agents$", {
    agent = { id = "bc-1", name = "Test", status = "ACTIVE" },
    run = { id = "run-1", agentId = "bc-1", status = "CREATING" },
  })

  config.setup({
    api_key = "test-key",
    repos = {
      "https://github.com/org/repo",
    },
    auto_detect_repo = false,
  })

  local client = api.new()
  mock_api.attach(client)

  local done = false
  api.create_agent(client, "hello", {}, function(err)
    assert(not err, err)
    done = true
  end)

  vim.wait(1000, function()
    return done
  end)

  local call = mock_api.get_call_log()[1]
  assert(type(call.body.repos) == "table")
  assert(type(call.body.repos[1]) == "table")
  assert(call.body.repos[1].url == "https://github.com/org/repo")
end)

test("create_agent encodes model object", function()
  mock_api.reset()
  mock_api.stub("POST", "/agents$", {
    agent = { id = "bc-1", name = "Test", status = "ACTIVE" },
    run = { id = "run-1", agentId = "bc-1", status = "CREATING" },
  })

  config.setup({
    api_key = "test-key",
    model = {
      id = "composer-2.5",
      params = { id = "fast", value = "false" },
    },
    auto_detect_repo = false,
  })

  local client = api.new()
  mock_api.attach(client)

  local done = false
  api.create_agent(client, "hello", {}, function(err)
    assert(not err, err)
    done = true
  end)

  vim.wait(1000, function()
    return done
  end)

  local call = mock_api.get_call_log()[1]
  assert(type(call.body.model) == "table")
  assert(call.body.model.id == "composer-2.5")
  assert(type(call.body.model.params) == "table")
  assert(call.body.model.params[1].id == "fast")
  assert(call.body.model.params[1].value == "false")
end)

test("poll_run completes on FINISHED", function()
  mock_api.reset()
  config.setup({ api_key = "test-key", polling_interval = 0.01, max_poll_attempts = 5 })
  local statuses = { "RUNNING", "FINISHED" }
  local idx = 0

  local client = api.new()
  client.http_request = function(method, path, body, done)
    if method == "GET" and path:match("/runs/run%-1$") then
      idx = idx + 1
      local status = statuses[idx] or "FINISHED"
      done(nil, {
        id = "run-1",
        agentId = "bc-1",
        status = status,
        result = status == "FINISHED" and "done" or nil,
      }, 200)
      return
    end
    done("unexpected request", nil, 500)
  end

  local done = false
  api.poll_run(client, "bc-1", "run-1", nil, function(err, run)
    assert(not err, err)
    assert(run.status == "FINISHED")
    assert(run.result == "done")
    done = true
  end)

  vim.wait(2000, function()
    return done
  end)

  assert(done, "poll callback not called")
end)

print(string.format("\nAPI: %d passed, %d failed", passed, failed))
if failed > 0 then
  vim.cmd("cq")
end
