local golangci_config_files = {
  ".golangci.yml",
  ".golangci.yaml",
  ".golangci.toml",
  ".golangci.json",
}

local function find_golangci_config(path)
  local found = vim.fs.find(golangci_config_files, {
    path = path,
    upward = true,
    type = "file",
  })
  return found[1]
end

return {
  "stevearc/conform.nvim",
  keys = {
    {
      "<leader>lf",
      function()
        require("conform").format({ lsp_fallback = true })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    formatters = {
      ["golangci-lint"] = {
        cwd = function(_, ctx)
          local config_path = find_golangci_config(ctx.dirname)
          if config_path then
            return vim.fs.dirname(config_path)
          end
          return nil
        end,
      },
    },
    formatters_by_ft = {
      lua = { "stylua" },
      go = function(bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname == "" then
          return { "goimports" }
        end
        local dirname = vim.fs.dirname(bufname)
        if dirname and find_golangci_config(dirname) then
          return { "golangci-lint" }
        end
        return { "goimports" }
      end,
    },
  },
}
