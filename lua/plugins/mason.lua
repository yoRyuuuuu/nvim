return {
  {
    {
      "mason-org/mason.nvim",
      opts = {},
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "gopls",
        "golangci-lint",
        "terraform",
        "terraform-ls",
        "tflint",
        "lua-language-server",
      },
    },
  },
}
