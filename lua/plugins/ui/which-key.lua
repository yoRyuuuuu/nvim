return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = {
        padding = { 2, 3 },
      },
      layout = {
        width = { min = 20 },
        spacing = 4,
      },
      spec = {
        { "<leader>a", group = "AI" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>q", group = "Session" },
        { "<leader>s", group = "Search" },
        { "<leader>u", group = "UI" },
        { "<leader>y", group = "Yank" },
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)

      local function transparent_floats()
        local groups = {
          "NormalFloat",
          "FloatBorder",
          "WhichKeyFloat",
          "WhichKeyBorder",
        }
        for _, g in ipairs(groups) do
          vim.api.nvim_set_hl(0, g, { bg = "NONE" })
        end
      end

      transparent_floats()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = transparent_floats })
    end,
  },
}
