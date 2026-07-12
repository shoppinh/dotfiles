-- Kulala (util.rest): repair broken tree-sitter grammar cache and ensure CLI is found.
local grammar_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "kulala.nvim", "tree-sitter-kulala-http")

local function grammar_cache_is_broken()
  local git_dir = vim.fs.joinpath(grammar_dir, ".git")
  if not vim.uv.fs_stat(git_dir) then
    return false
  end
  local remotes = vim.fn.systemlist({ "git", "-C", grammar_dir, "remote" })
  return vim.v.shell_error ~= 0 or #remotes == 0
end

if grammar_cache_is_broken() then
  vim.fn.delete(grammar_dir, "rf")
end

local tree_sitter_cli = vim.fn.exepath("tree-sitter")
if tree_sitter_cli == "" then
  local nvm_cli = vim.fs.joinpath(vim.env.HOME or "", ".nvm", "versions", "node", "v22.19.0", "bin", "tree-sitter")
  if vim.uv.fs_stat(nvm_cli) then
    tree_sitter_cli = nvm_cli
  end
end

return {
  {
    "mistweaverco/kulala.nvim",
    opts = {
      treesitter = {
        enable = true,
        cli_path = tree_sitter_cli ~= "" and tree_sitter_cli or "tree-sitter",
      },
    },
  },
}
