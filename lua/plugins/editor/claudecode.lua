-- Claude Code IDE integration. Claude Code runs in its own Herdr App pane
-- (so Herdr can track its state) and connects here with `/ide`.
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  -- Load at startup so the WebSocket server is up before `/ide` looks for it.
  event = "VeryLazy",
  opts = {
    terminal = { provider = "none" },
  },
  keys = {
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
    },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
