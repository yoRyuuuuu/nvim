return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "main",
    lazy = false,
    config = function()
      -- In the rewritten main branch, highlighting is provided by Neovim and must be enabled explicitly.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if vim.bo[args.buf].buftype ~= "" then
            return
          end
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      max_lines = 4,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPre" },
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
