# cursor-agent.nvim

Production-quality Neovim plugin for triggering [Cursor Cloud Agents](https://cursor.com/docs/cloud-agent/api/endpoints) directly from the editor.

Automate daily development workflows: send prompts, poll run status, and display results in a floating window, split buffer, or quickfix list, without leaving Neovim.

## Features

- Idiomatic Lua with modular architecture
- Async HTTP via `vim.system()` and `curl` (non-blocking UI)
- Configurable API key (config or environment variable)
- Retry with exponential backoff on transient failures
- Commands for daily prompts, custom prompts, status, and cancellation
- Auto-detects Git repository context for cloud agents
- Reuses agents across prompts within a session
- Unit tests with mocked API responses

## Requirements

- Neovim 0.10+
- `curl` available on your `PATH`
- A Cursor API key with Cloud Agents API access

## Installation

### lazy.nvim

```lua
{
  "kienmac2k/cursor-agent.nvim",
  config = function()
    require("cursor-agent").setup({
      api_key = os.getenv("CURSOR_API_KEY"),
      prompts = {
        daily = [[
Analyze the current project.
Review git changes.
Suggest next development tasks.
Check for TODOs.
Summarize blockers.
        ]],
      },
    })
  end,
}
```

### packer.nvim

```lua
use {
  "kienmac2k/cursor-agent.nvim",
  config = function()
    require("cursor-agent").setup({
      api_key = os.getenv("CURSOR_API_KEY"),
    })
  end,
}
```

### Manual

```sh
git clone https://github.com/kienmac2k/cursor-agent.nvim ~/.local/share/nvim/site/pack/plugins/start/cursor-agent.nvim
```

Then add `require("cursor-agent").setup({ ... })` to your Neovim config.

## Configuration

```lua
require("cursor-agent").setup({
  -- API key (or set CURSOR_API_KEY env var)
  api_key = "YOUR_CURSOR_API_KEY",
  api_key_env = "CURSOR_API_KEY",

  -- Reuse an existing agent by name or id (bc-...)
  default_agent = "my-agent",
  agent_name = "neovim-session",
  reuse_agent = true,

  -- Model and repository context
  model = { id = "composer-2.5" },
  -- or: model = "composer-2.5"
  repos = {
    { url = "https://github.com/your-org/your-repo", startingRef = "main" },
  },
  auto_detect_repo = true,

  -- Polling and HTTP behavior
  polling_interval = 2,
  max_poll_attempts = 900,
  request_timeout_ms = 60000,
  retry = {
    max_attempts = 4,
    base_delay_ms = 500,
    max_delay_ms = 8000,
  },

  -- UI
  ui = {
    border = "rounded",
    width = 0.8,
    height = 0.8,
    display = "float", -- float | split | quickfix
  },

  -- Prompt templates
  prompts = {
    daily = [[
Analyze the current project.
Review git changes.
Suggest next development tasks.
Check for TODOs.
Summarize blockers.
    ]],
  },

  workOnCurrentBranch = false,
  autoCreatePR = false,
  mode = "agent", -- agent | plan
  log_level = "info",
})
```

### Configuration reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `api_key` | `string?` | `nil` | Cursor API key |
| `api_key_env` | `string` | `CURSOR_API_KEY` | Env var fallback for API key |
| `base_url` | `string` | `https://api.cursor.com/v1` | Cloud Agents API base URL |
| `default_agent` | `string?` | `nil` | Agent name or id to reuse |
| `agent_name` | `string?` | `nil` | Display name for newly created agents |
| `reuse_agent` | `boolean` | `true` | Reuse session agent for follow-up prompts |
| `model` | `string\|table?` | `nil` | Default model (`id` + optional `params`) |
| `favorite_models` | `string[]?` | `nil` | Favorite models shown first in the picker |
| `repos` | `table[]?` | `nil` | Repository configuration |
| `auto_detect_repo` | `boolean` | `true` | Detect repo from current Git directory |
| `polling_interval` | `number` | `2` | Seconds between status polls |
| `max_poll_attempts` | `number` | `900` | Max poll iterations before timeout |
| `request_timeout_ms` | `number` | `60000` | Per-request curl timeout |
| `retry` | `table` | see defaults | Exponential backoff settings |
| `ui` | `table` | see defaults | Result display options |
| `prompts.daily` | `string` | built-in template | Daily workflow prompt |
| `workOnCurrentBranch` | `boolean` | `false` | Push to current branch |
| `autoCreatePR` | `boolean` | `false` | Open PR when run completes |
| `mode` | `string` | `agent` | Initial mode: `agent` or `plan` |
| `log_level` | `string` | `info` | `debug`, `info`, `warn`, `error`, `off` |

## Commands

| Command | Description |
|---------|-------------|
| `:CursorDaily` | Send the configured daily prompt |
| `:CursorAgent <prompt>` | Send a custom prompt |
| `:CursorAgentStart` | Resolve or show the current agent |
| `:CursorAgentStatus` | Show agent and latest run status |
| `:CursorAgentCancel` | Cancel the active run |
| `:CursorAgentModel` | Open interactive model picker |
| `:CursorAgentModel <id>` | Set model by id or alias |
| `:CursorAgentModels` | List all available models |

### Model selection

Models apply when **creating a new agent**. Follow-up prompts on an existing reused agent keep that agent's original model.

**Config default:**

```lua
model = "composer-2.5",
-- or with params:
model = {
  id = "composer-2",
  params = { { id = "fast", value = "true" } },
},
favorite_models = { "composer-2.5", "claude-4-sonnet-thinking" },
```

**Interactive picker:**

```vim
:CursorAgentModel
```

**Set by id:**

```vim
:CursorAgentModel composer-2.5
```

**List available models from the API:**

```vim
:CursorAgentModels
```

Omit `model` (or run `:CursorAgentModel` and choose "Use Cursor default") to let Cursor resolve your account/team default.

`model.params` must be a JSON **array** of `{ id, value }` objects. These config forms are all accepted:

```lua
-- recommended
model = {
  id = "composer-2",
  params = {
    { id = "fast", value = "false" },
  },
}

-- also accepted (normalized automatically)
model = {
  id = "composer-2",
  params = { id = "fast", value = "false" },
}
model = {
  id = "composer-2",
  params = { fast = "false" },
}
```

`repos` must be an array of objects. These are also accepted and normalized automatically:

```lua
repos = "https://github.com/your-org/your-repo"
repos = { url = "https://github.com/your-org/your-repo", startingRef = "main" }
repos = { "https://github.com/your-org/your-repo" }
```

## Example workflows

### Daily standup automation

```vim
:CursorDaily
```

1. Reuses the session agent or creates one (with auto-detected repo if configured)
2. Sends your `prompts.daily` template
3. Polls until the run reaches a terminal state
4. Displays the result in a floating markdown window

### Review current git diff

```vim
:CursorAgent Review current git diff and suggest improvements
```

### Check status without sending a prompt

```vim
:CursorAgentStatus
```

## Architecture

```
lua/cursor-agent/
  init.lua       Entry point and setup()
  config.lua     Defaults, validation, API key resolution
  api.lua        HTTP client, retries, polling
  models.lua     Model catalog, picker, session selection
  commands.lua   User commands and orchestration
  ui.lua         Floating window, split, quickfix rendering
  prompts.lua    Prompt templates and validation
  utils.lua      JSON, logging, git detection, backoff
```

### Module responsibilities

- **config** — merges user options, validates before requests, resolves API key from config or env
- **api** — wraps Cloud Agents API v1 endpoints; injectable `http_request` for tests
- **commands** — session state, command wiring, create/reuse agent flows
- **ui** — result presentation and status formatting
- **prompts** — named prompt templates (`daily`, extensible)
- **utils** — shared helpers (JSON, retry/backoff, git repo detection)

### API endpoints used

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/v1/models` | List available models |
| `POST` | `/v1/agents` | Create agent + initial run |
| `GET` | `/v1/agents` | List agents |
| `GET` | `/v1/agents/{id}` | Get agent metadata |
| `POST` | `/v1/agents/{id}/runs` | Send follow-up prompt |
| `GET` | `/v1/agents/{id}/runs/{runId}` | Poll run status/result |
| `POST` | `/v1/agents/{id}/runs/{runId}/cancel` | Cancel active run |

The client is structured so additional endpoints (artifacts, usage, stream) can be added in `api.lua` without changing command or UI layers.

## Testing

```sh
nvim --headless -u tests/minimal_init.lua -c "lua dofile('tests/run.lua')" -c "qa!"
```

Tests cover configuration validation, utility helpers, and mocked API flows (create agent, poll to completion).

## Error handling

- Missing API key: validation error at `setup()` time
- HTTP/curl failures: user notification with stderr details
- API errors (4xx/5xx): status code and API message surfaced via `vim.notify`
- Transient errors (408, 429, 5xx): automatic retry with exponential backoff
- Agent busy (409): clear message to wait or cancel before retrying
- Poll timeout: informative error after `max_poll_attempts`

## Security notes

- Prefer `CURSOR_API_KEY` environment variable over hardcoding keys in your dotfiles
- API keys are sent only to `api.cursor.com` via Bearer authentication

## License

MIT
