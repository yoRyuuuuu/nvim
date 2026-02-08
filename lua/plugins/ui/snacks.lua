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

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      dashboard = { enabled = true },
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
      -- Terminal mappings
      { "<leader>tf", function() Snacks.terminal(nil, { win = { position = "float" } }) end, desc = "Terminal (Float Toggle)", },
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
