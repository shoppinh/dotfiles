local api = require("cursor-agent.api")
local config = require("cursor-agent.config")
local ui = require("cursor-agent.ui")

local M = {}

---@class CursorAgentModelSelection
---@field id string
---@field params? table[]

local session = {
  model = nil,
}

local cache = {
  items = nil,
  fetched_at = 0,
}

local CACHE_TTL_SEC = 300

---@param model string|table|nil
---@return CursorAgentModelSelection|nil
function M.normalize(model)
  if model == nil then
    return nil
  end

  if type(model) == "string" then
    if model == "" then
      return nil
    end
    return { id = model }
  end

  if type(model) == "table" and model.id then
    return {
      id = model.id,
      params = require("cursor-agent.utils").normalize_model_params(model.params),
    }
  end

  return nil
end

---@return CursorAgentModelSelection|nil
function M.get_selected()
  if session.model then
    return vim.deepcopy(session.model)
  end

  return M.normalize(config.get().model)
end

---@param model string|table|nil
function M.set_selected(model)
  session.model = M.normalize(model)
end

---@return string
function M.describe_selected()
  local selected = M.get_selected()
  if not selected then
    return "Cursor default (account/team)"
  end

  if not selected.params or #selected.params == 0 then
    return selected.id
  end

  local param_bits = {}
  for _, param in ipairs(selected.params) do
    param_bits[#param_bits + 1] = string.format("%s=%s", param.id, tostring(param.value))
  end

  return string.format("%s (%s)", selected.id, table.concat(param_bits, ", "))
end

---@param item table
---@return string
function M.format_model_item(item)
  local label = item.displayName or item.id
  if item.description and item.description ~= "" then
    label = label .. " — " .. item.description
  end
  return label
end

---@param variant table
---@param model table
---@return string
function M.format_variant_item(variant, model)
  local label = variant.displayName or model.displayName or model.id
  if variant.description and variant.description ~= "" then
    label = label .. " — " .. variant.description
  end
  if variant.isDefault then
    label = label .. " [default]"
  end
  return label
end

---@param model table
---@param variant? table
---@return CursorAgentModelSelection
function M.to_selection(model, variant)
  if variant and variant.params and #variant.params > 0 then
    return {
      id = model.id,
      params = variant.params,
    }
  end

  return { id = model.id }
end

---@param params_a table[]|nil
---@param params_b table[]|nil
---@return boolean
function M.params_equal(params_a, params_b)
  params_a = params_a or {}
  params_b = params_b or {}

  if #params_a ~= #params_b then
    return false
  end

  for index, param in ipairs(params_a) do
    local other = params_b[index]
    if not other or tostring(param.id) ~= tostring(other.id) then
      return false
    end
    if tostring(param.value) ~= tostring(other.value) then
      return false
    end
  end

  return true
end

---@param items table[]
---@param model_id string
---@return table|nil
function M.find_in_catalog(items, model_id)
  for _, item in ipairs(items) do
    if item.id == model_id then
      return item
    end
    for _, alias in ipairs(item.aliases or {}) do
      if alias == model_id then
        return item
      end
    end
  end
  return nil
end

---@param selection CursorAgentModelSelection
---@param catalog_item table|nil
---@return CursorAgentModelSelection
---@return string|nil warning
function M.coerce_for_api(selection, catalog_item)
  if not selection.params or #selection.params == 0 then
    return selection, nil
  end

  if not catalog_item then
    return { id = selection.id }, string.format(
      "unknown model '%s'; dropped unsupported params",
      selection.id
    )
  end

  local variants = catalog_item.variants or {}
  local parameters = catalog_item.parameters or {}

  if #variants == 0 and #parameters == 0 then
    return { id = selection.id }, string.format(
      "model '%s' does not accept params; dropped params",
      selection.id
    )
  end

  for _, variant in ipairs(variants) do
    if M.params_equal(selection.params, variant.params or {}) then
      return selection, nil
    end
  end

  for _, variant in ipairs(variants) do
    if variant.isDefault then
      return M.to_selection(catalog_item, variant), string.format(
        "invalid params for '%s'; using default variant",
        selection.id
      )
    end
  end

  return { id = selection.id }, string.format(
    "invalid params for '%s'; dropped params",
    selection.id
  )
end

---@param client CursorAgentApiClient
---@param opts? table
---@param done fun(err?: string, model?: CursorAgentModelSelection, warning?: string)
function M.prepare_for_create(client, opts, done)
  local selection = M.resolve_for_create(opts)
  if not selection then
    done(nil, nil, nil)
    return
  end

  if not selection.params or #selection.params == 0 then
    done(nil, selection, nil)
    return
  end

  M.fetch(client, false, function(err, items)
    if err then
      done(err, selection, nil)
      return
    end

    local catalog_item = M.find_in_catalog(items, selection.id)
    local coerced, warning = M.coerce_for_api(selection, catalog_item)
    done(nil, coerced, warning)
  end)
end

---@param items table[]
---@return table[]
local function sort_models(items)
  local favorites = config.get().favorite_models or {}
  local favorite_rank = {}
  for idx, model_id in ipairs(favorites) do
    favorite_rank[model_id] = idx
  end

  table.sort(items, function(a, b)
    local a_rank = favorite_rank[a.id] or 9999
    local b_rank = favorite_rank[b.id] or 9999
    if a_rank ~= b_rank then
      return a_rank < b_rank
    end
    return (a.displayName or a.id) < (b.displayName or b.id)
  end)

  return items
end

---@param client CursorAgentApiClient
---@param force? boolean
---@param done fun(err?: string, items?: table[])
function M.fetch(client, force, done)
  local now = vim.loop.now() / 1000
  if not force and cache.items and (now - cache.fetched_at) < CACHE_TTL_SEC then
    done(nil, vim.deepcopy(cache.items))
    return
  end

  api.list_models(client, function(err, data)
    if err then
      done(err, nil)
      return
    end

    local items = sort_models(data.items or {})
    cache.items = items
    cache.fetched_at = now
    done(nil, vim.deepcopy(items))
  end)
end

---@param model table
---@param done fun(selection?: CursorAgentModelSelection)
local function pick_variant(model, done)
  local variants = model.variants or {}
  if #variants <= 1 then
    done(M.to_selection(model, variants[1]))
    return
  end

  local entries = {}
  for _, variant in ipairs(variants) do
    entries[#entries + 1] = {
      variant = variant,
      label = M.format_variant_item(variant, model),
    }
  end

  ui.select_from_list("Select model variant", entries, function(entry)
    return entry.label
  end, function(entry)
    if not entry then
      done(nil)
      return
    end
    done(M.to_selection(model, entry.variant))
  end)
end

---@param done fun(selection?: CursorAgentModelSelection)
function M.pick(done)
  local ok, err = pcall(config.validate)
  if not ok then
    ui.notify(err, "error")
    done(nil)
    return
  end

  local client = api.new()
  M.fetch(client, false, function(fetch_err, items)
    if fetch_err then
      ui.notify(fetch_err, "error")
      done(nil)
      return
    end

    if #items == 0 then
      ui.notify("No models returned by the API", "warn")
      done(nil)
      return
    end

    local entries = {}
    for _, model in ipairs(items) do
      entries[#entries + 1] = {
        model = model,
        label = M.format_model_item(model),
      }
    end

    entries[#entries + 1] = {
      model = nil,
      label = "Use Cursor default (account/team)",
    }

    ui.select_from_list("Select Cursor model", entries, function(entry)
      return entry.label
    end, function(entry)
      if not entry then
        done(nil)
        return
      end

      if not entry.model then
        done(nil)
        return
      end

      pick_variant(entry.model, done)
    end)
  end)
end

---@param model_id string
---@param done fun(selection?: CursorAgentModelSelection)
function M.set_by_id(model_id, done)
  local normalized = M.normalize(model_id)
  if not normalized then
    ui.notify("Model id is required", "error")
    if done then
      done(nil)
    end
    return
  end

  local ok, err = pcall(config.validate)
  if not ok then
    ui.notify(err, "error")
    if done then
      done(nil)
    end
    return
  end

  local client = api.new()
  M.fetch(client, false, function(fetch_err, items)
    if fetch_err then
      ui.notify(fetch_err, "error")
      if done then
        done(nil)
      end
      return
    end

    for _, model in ipairs(items) do
      if model.id == normalized.id then
        local variants = model.variants or {}
        if #variants == 1 then
          local selection = M.to_selection(model, variants[1])
          M.set_selected(selection)
          if done then
            done(selection)
          end
          return
        end

        for _, variant in ipairs(variants) do
          if variant.isDefault then
            local selection = M.to_selection(model, variant)
            M.set_selected(selection)
            if done then
              done(selection)
            end
            return
          end
        end

        M.set_selected({ id = model.id })
        if done then
          done({ id = model.id })
        end
        return
      end

      for _, alias in ipairs(model.aliases or {}) do
        if alias == normalized.id then
          M.set_selected({ id = model.id })
          if done then
            done({ id = model.id })
          end
          return
        end
      end
    end

    M.set_selected(normalized)
    if done then
      done(normalized)
    end
  end)
end

---@param opts? table
---@return CursorAgentModelSelection|nil
function M.resolve_for_create(opts)
  if opts and opts.model then
    return M.normalize(opts.model)
  end
  return M.get_selected()
end

---@param done fun(content: string)
function M.show_catalog(done)
  local ok, err = pcall(config.validate)
  if not ok then
    ui.notify(err, "error")
    return
  end

  local client = api.new()
  M.fetch(client, true, function(fetch_err, items)
    if fetch_err then
      ui.notify(fetch_err, "error")
      return
    end

    local lines = {
      "# Available Cursor Models",
      "",
      string.format("Current selection: **%s**", M.describe_selected()),
      "",
    }

    for _, model in ipairs(items) do
      lines[#lines + 1] = string.format("## %s (`%s`)", model.displayName or model.id, model.id)
      if model.description then
        lines[#lines + 1] = model.description
      end
      if model.aliases and #model.aliases > 0 then
        lines[#lines + 1] = "- Aliases: " .. table.concat(model.aliases, ", ")
      end
      if model.variants and #model.variants > 0 then
        lines[#lines + 1] = "- Variants:"
        for _, variant in ipairs(model.variants) do
          local suffix = variant.isDefault and " [default]" or ""
          lines[#lines + 1] = "  - " .. (variant.displayName or model.id) .. suffix
        end
      end
      lines[#lines + 1] = ""
    end

    ui.show_result("Cursor Models", table.concat(lines, "\n"))
    if done then
      done(table.concat(lines, "\n"))
    end
  end)
end

return M
