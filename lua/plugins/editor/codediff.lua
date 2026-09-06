return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  opts = {},
  keys = {
    { "<leader>dd", "<cmd>CodeDiff<cr>", desc = "Changed Files" },
    { "<leader>df", "<cmd>CodeDiff file HEAD<cr>", desc = "Current File vs HEAD" },
    { "<leader>dh", "<cmd>CodeDiff history<cr>", desc = "Commit History" },
  },
}
