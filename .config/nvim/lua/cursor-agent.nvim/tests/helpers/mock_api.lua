local M = {}

local responses = {}
local call_log = {}

function M.reset()
  responses = {}
  call_log = {}
end

---@param method string
---@param path_pattern string
---@param response table
---@param status? number
function M.stub(method, path_pattern, response, status)
  responses[#responses + 1] = {
    method = method:upper(),
    path_pattern = path_pattern,
    response = response,
    status = status or 200,
  }
end

function M.get_call_log()
  return call_log
end

---@param client table
function M.attach(client)
  client.http_request = function(method, path, body, done)
    call_log[#call_log + 1] = {
      method = method:upper(),
      path = path,
      body = body,
    }

    for _, stub in ipairs(responses) do
      if stub.method == method:upper() and path:match(stub.path_pattern) then
        if stub.status >= 200 and stub.status < 300 then
          done(nil, stub.response, stub.status)
        else
          done("mock API error", stub.response, stub.status)
        end
        return
      end
    end

    done("no mock response for " .. method .. " " .. path, nil, 404)
  end
end

return M
