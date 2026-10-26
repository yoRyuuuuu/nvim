local function smart_files()
  local picker = require("snacks").picker
  local root = require("snacks.git").get_root()
  local sources = require("snacks.picker.config.sources")

  local files = root == nil and sources.files
    or vim.tbl_deep_extend("force", sources.git_files, {
      untracked = true,
      cwd = vim.uv.cwd(),
    })

  picker({
    multi = { "buffers", "recent", files },
    format = "file",
    matcher = { frecency = true, sort_empty = true },
    filter = { cwd = true },
    transform = "unique_file",
  })
end

local function git_worktrees()
  local root = require("snacks.git").get_root(vim.uv.cwd())
  if root == nil then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local out = vim.system({ "git", "worktree", "list", "--porcelain" }, { cwd = root, text = true }):wait()
  if out.code ~= 0 then
    vim.notify("git worktree list failed: " .. (out.stderr or ""), vim.log.levels.ERROR)
    return
  end

  local items = {}
  for block in (out.stdout .. "\n"):gmatch("(.-)\n\n") do
    local item = {}
    for line in block:gmatch("[^\n]+") do
      local key, value = line:match("^(%S+)%s?(.*)$")
      if key == "worktree" then
        item.cwd = value
      elseif key == "HEAD" then
        item.commit = value
      elseif key == "branch" then
        item.branch = value:gsub("^refs/heads/", "")
      elseif key == "detached" then
        item.detached = true
      elseif key == "bare" or key == "prunable" then
        item.skip = true
      end
    end
    if item.cwd and not item.skip then
      item.current = vim.fs.normalize(item.cwd) == vim.fs.normalize(root)
      item.label = item.branch or (item.commit or ""):sub(1, 7)
      item.text = item.label .. " " .. item.cwd
      items[#items + 1] = item
    end
  end

  Snacks.picker.pick({
    title = "Git Worktrees",
    items = items,
    preview = "git_log",
    -- fancy では git_log プレビューの行ハイライトが無効になる
    previewers = { diff = { style = "syntax" } },
    format = function(item)
      local a = Snacks.picker.util.align
      return {
        item.current and { a("", 2), "SnacksPickerGitBranchCurrent" } or { a("", 2) },
        {
          a(item.label, 30, { truncate = true }),
          item.detached and "SnacksPickerGitDetached" or "SnacksPickerGitBranch",
        },
        { " " },
        { vim.fn.fnamemodify(item.cwd, ":~"), "SnacksPickerDir" },
      }
    end,
    on_show = function(picker)
      for i, item in ipairs(picker:items()) do
        if item.current then
          picker.list:view(i)
          Snacks.picker.actions.list_scroll_center(picker)
          break
        end
      end
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.cmd.cd(item.cwd)
        vim.notify("cd " .. vim.fn.fnamemodify(item.cwd, ":~"), vim.log.levels.INFO)
      end
    end,
  })
end

local function dashboard_lines(title, path)
  return {
    { text = title, align = "center" },
    { text = { { vim.fn.fnamemodify(path, ":~"), hl = "SnacksDashboardFile" } }, align = "center", padding = 2 },
  }
end

local function dashboard_worktree()
  local cwd = vim.uv.cwd()
  local root = require("snacks.git").get_root(cwd)
  if root == nil then
    return dashboard_lines({ { "Not a git repository", hl = "SnacksDashboardDesc" } }, cwd)
  end

  local out = vim
    .system(
      { "git", "rev-parse", "--path-format=absolute", "--abbrev-ref", "HEAD", "--git-dir", "--git-common-dir" },
      { cwd = root, text = true }
    )
    :wait()
  if out.code ~= 0 then
    return nil
  end

  local head, git_dir, common_dir = unpack(vim.split(vim.trim(out.stdout), "\n"))
  if head == "HEAD" then
    head =
      vim.trim(vim.system({ "git", "rev-parse", "--short", "HEAD" }, { cwd = root, text = true }):wait().stdout or "")
  end
  local kind = "worktree"
  if git_dir == common_dir then
    local linked = vim.uv.fs_scandir(common_dir .. "/worktrees")
    kind = linked and vim.uv.fs_scandir_next(linked) and "main" or "no worktrees"
  end
  return dashboard_lines(
    { { head, hl = "SnacksDashboardKey" }, { "  (" .. kind .. ")", hl = "SnacksDashboardDesc" } },
    root
  )
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
      vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("snacks_dashboard_worktree", { clear = true }),
        callback = function()
          Snacks.dashboard.update()
        end,
      })
    end,
    ---@type snacks.Config
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          -- stylua: ignore
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          },
        },
        sections = {
          { section = "header" },
          dashboard_worktree,
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      explorer = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      lazygit = {
        enabled = true,
        win = {
          backdrop = false,
          wo = {
            winhighlight = "Normal:Normal,NormalFloat:Normal,FloatBorder:Normal",
          },
        },
      },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      picker = {
        enabled = true,
        actions = {
          sidekick_send = function(...)
            local ok, sidekick = pcall(require, "sidekick.cli.picker.snacks")
            if ok and type(sidekick.send) == "function" then
              return sidekick.send(...)
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
            },
            -- Works around a snacks.nvim/Neovim redraw race with the
            -- right-aligned result-count extmark that transposes typed
            -- characters at EOL when virtualedit=none (upstream:
            -- https://github.com/folke/snacks.nvim/issues/2810).
            wo = {
              virtualedit = "all",
            },
          },
        },
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["E"] = { { "confirm", "close" } },
                },
              },
            },
          },
        },
      },
      terminal = { enabled = true },
      rename = { enabled = true },
      zen = { enabled = true },
    },
    -- stylua: ignore start
    keys = {
      -- Explorer (AstroNvim: <leader>e)
      { "<leader>e", function() Snacks.explorer() end, desc = "Explorer", },
      -- Picker mappings (AstroNvim-style)
      { "<leader>f<CR>", function() Snacks.picker.resume() end, desc = "Resume", },
      { "<leader>f'", function() Snacks.picker.marks() end, desc = "Marks", },
      { "<leader>fa", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config Files", },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers", },
      { "<leader>fc", function() Snacks.picker.grep_word() end, desc = "Word at Cursor", mode = { "n", "x" }, },
      { "<leader>fC", function() Snacks.picker.commands() end, desc = "Commands", },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files", },
      { "<leader>fF", function() Snacks.picker.files({ hidden = true, follow = true }) end, desc = "Find Files (hidden)", },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Git Files", },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Tags", },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps", },
      { "<leader>fl", function() Snacks.picker.lines() end, desc = "Lines", },
      { "<leader>fm", function() Snacks.picker.man() end, desc = "Man Pages", },
      { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notifications", },
      { "<leader>fo", function() Snacks.picker.recent() end, desc = "Old Files", },
      { "<leader>fO", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Old Files (cwd)", },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects", },
      { '<leader>fr', function() Snacks.picker.registers() end, desc = "Registers", },
      { "<leader>fs", smart_files, desc = "Smart (buffers,recent,files)", },
      { "<leader>ft", function() Snacks.picker.colorschemes() end, desc = "Colorschemes", },
      { "<leader>fu", function() Snacks.picker.undo() end, desc = "Undo History", },
      { "<leader>fw", function() Snacks.picker.grep() end, desc = "Live Grep", },
      { "<leader>fW", function() Snacks.picker.grep({ hidden = true, follow = true }) end, desc = "Live Grep (hidden)", },
      -- Git mappings (AstroNvim-style)
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches", },
      { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Commits (repo)", },
      { "<leader>gC", function() Snacks.picker.git_log_file() end, desc = "Git Commits (file)", },
      { "<leader>go", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" }, },
      { "<leader>gt", function() Snacks.picker.git_status() end, desc = "Git Status", },
      { "<leader>gT", function() Snacks.picker.git_stash() end, desc = "Git Stash", },
      { "<leader>gw", git_worktrees, desc = "Git Worktrees", },
      -- Terminal mappings
      { "<leader>tf", function() Snacks.terminal(nil, { win = { position = "float", border = "rounded" } }) end, desc = "Terminal (Float Toggle)", },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "LazyGit", },
      -- LSP picker mappings (Astrojvim-style)
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration", },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation", },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References", },
      { "gT", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition", },
      { "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols", },
      { "<leader>lG", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols", },
      -- General/UI mappings (AstroNvim-style)
      { "<leader>R", function() Snacks.rename.rename_file() end, desc = "Rename Current File", },
      { "<leader>uD", function() Snacks.notifier.hide() end, desc = "Dismiss Notifications", },
      { "<leader>uZ", function() Snacks.zen() end, desc = "Toggle Zen Mode", },
      -- Extra useful pickers (kept Astro-style)
      { "<leader>lD", function() Snacks.picker.diagnostics() end, desc = "Diagnostics", },
      { "<leader>fT", function() Snacks.picker.todo_comments() end, desc = "Todo", },
      { "<leader>fX", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme", },
      -- Keep these as-is (useful + non-conflicting)
      { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming", },
      { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing", },
    },
    -- stylua: ignore end
  },
}
