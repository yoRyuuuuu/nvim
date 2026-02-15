return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local required_commands = {
        "gopls",
        "golangci-lint",
        "golangci-lint-langserver",
        "terraform-ls",
        "lua-language-server",
        "stylua",
        "goimports",
      }
      local missing_commands = {}
      for _, cmd in ipairs(required_commands) do
        if vim.fn.executable(cmd) == 0 then
          table.insert(missing_commands, cmd)
        end
      end
      if #missing_commands > 0 then
        vim.schedule(function()
          vim.notify("Missing external tools: " .. table.concat(missing_commands, ", "), vim.log.levels.WARN, {
            title = "Tooling Check",
          })
        end)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok and type(blink.get_lsp_capabilities) == "function" then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      vim.lsp.config("gopls", { capabilities = capabilities })
      vim.lsp.config("golangci_lint_ls", {
        capabilities = capabilities,
        init_options = {
          command = { "golangci-lint", "run", "--output.json.path=stdout", "--show-stats=false" },
        },
      })
      vim.lsp.config("terraformls", { capabilities = capabilities })
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.enable({ "gopls", "golangci_lint_ls", "terraformls", "lua_ls" })

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
          linehl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticErrorLine",
            [vim.diagnostic.severity.WARN] = "DiagnosticWarnLine",
            [vim.diagnostic.severity.HINT] = "DiagnosticHintLine",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfoLine",
          },
        },
      })
    end,
  },
}
