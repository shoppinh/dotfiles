-- Example lazy.nvim configuration for cursor-agent.nvim
return {
  "kienmac2k/cursor-agent.nvim",
  config = function()
    require("cursor-agent").setup({
      api_key = os.getenv("CURSOR_API_KEY"),
      model = "composer-2.5",
      favorite_models = {
        "composer-2.5",
        "claude-4-sonnet-thinking",
      },
      default_agent = "my-agent",
      polling_interval = 2,
      ui = {
        border = "rounded",
        width = 0.8,
        height = 0.8,
        display = "float",
      },
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
