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
      picker = { enabled = true },
      zen = { enabled = true },
    },
    keys = {
      {
        "<leader>e",
        function()
          Snacks.explorer()
        end,
        desc = "Snacks Explorer",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Snacks LazyGit",
      },
      {
        "<leader>ff",
        smart_files,
        desc = "Search Files",
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = {},
  },
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = {
      use_diagnostic_signs = true,
    },
  },
}
