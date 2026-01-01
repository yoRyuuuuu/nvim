return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "go",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre" },
    dependencies = { "nvim-treesitter" },
    opts = {
      max_lines = 4,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects", -- required by nvim-surround
    event = { "BufReadPre" },
    branch = "main",
    dependencies = { "nvim-treesitter" },
  },
}
