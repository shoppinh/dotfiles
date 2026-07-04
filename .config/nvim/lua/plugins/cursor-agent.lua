return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/cursor-agent.nvim",
    name = "cursor-agent.nvim",
    config = function()
      require("cursor-agent").setup({
        api_key = os.getenv("CURSOR_API_KEY"),
        model = {
          id = "composer-2.5",
        },
      })
    end,
  },
}
