-- PR review helper: checkout a PR and open its diff in codediff.nvim.
-- Used by the octo.nvim snacks picker action (see lua/plugins/editor/octo.lua).
local M = {}

---Run a command synchronously, returning trimmed stdout or nil + stderr on failure.
---@param cmd string[]
---@return string? stdout, string? stderr
local function run(cmd)
  local res = vim.system(cmd, { text = true }):wait()
  if res.code ~= 0 then
    return nil, ((res.stderr or ""):gsub("%s+$", ""))
  end
  return ((res.stdout or ""):gsub("%s+$", "")), nil
end

---Checkout PR `number` and open the branch-point diff in codediff.
---Aborts (with a warning) when the working tree is dirty.
---@param number integer
function M.open(number)
  -- 1. Refuse to switch branches over uncommitted changes.
  local dirty = run { "git", "status", "--porcelain" }
  if dirty == nil then
    vim.notify("git status を実行できませんでした（git リポジトリ内で実行してください）", vim.log.levels.ERROR)
    return
  end
  if dirty ~= "" then
    vim.notify(
      "未コミットの変更があります。stash か commit してから再実行してください。",
      vim.log.levels.WARN
    )
    return
  end

  -- 2. Checkout the PR branch (synchronous).
  local _, err = run { "gh", "pr", "checkout", tostring(number) }
  if err then
    vim.notify("gh pr checkout に失敗しました:\n" .. err, vim.log.levels.ERROR)
    return
  end

  -- 3. Compute the branch point against the default branch.
  local default_ref = run { "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }
  if not default_ref or default_ref == "" then
    default_ref = "origin/HEAD"
  end
  local base = run { "git", "merge-base", "HEAD", default_ref }
  if not base or base == "" then
    vim.notify("merge-base を算出できませんでした。HEAD の差分を表示します。", vim.log.levels.WARN)
    base = "HEAD"
  end

  -- 4. Open the PR-only diff.
  vim.cmd("CodeDiff " .. base)
end

return M
