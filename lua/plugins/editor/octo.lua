return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
  opts = {
    picker = "snacks",
    picker_config = {
      snacks = {
        actions = {
          -- Enter on a PR: checkout and open its diff in codediff.nvim.
          -- No comment/review/approve mappings are wired up (scope: read diffs only).
          pull_requests = {
            {
              name = "review_with_codediff",
              lhs = "<cr>",
              desc = "Checkout PR and open in codediff",
              fn = function(picker, item)
                picker:close()
                require("configs.pr_review").open(item.number)
              end,
            },
          },
        },
      },
    },
  },
  keys = {
    { "<leader>dp", "<cmd>Octo pr list<cr>", desc = "Review PR (codediff)" },
  },
}
