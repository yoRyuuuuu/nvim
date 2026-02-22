return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local eslint_config_files = {
        "eslint.config.js",
        "eslint.config.cjs",
        "eslint.config.mjs",
        "eslint.config.ts",
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
      }

      local function find_eslint_root(path)
        local found = vim.fs.find(eslint_config_files, {
          path = path,
          upward = true,
          type = "file",
        })
        if #found == 0 then
          return nil
        end
        return vim.fs.dirname(found[1])
      end

      local required_commands = {
        "gopls",
        "golangci-lint",
        "golangci-lint-langserver",
        "goimports",
        "typescript-language-server",
        "vscode-eslint-language-server",
        "lua-language-server",
        "stylua",
        "terraform-ls",
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
      vim.lsp.config("terraformls", {
        capabilities = capabilities,
        on_attach = function(client)
          -- terraform-ls semantic tokens can conflict with Tree-sitter highlighting.
          client.server_capabilities.semanticTokensProvider = nil
        end,
      })
      vim.lsp.config("ts_ls", { capabilities = capabilities })
      vim.lsp.config("eslint", {
        capabilities = capabilities,
        root_dir = function(buf, on_dir)
          local bufname = type(buf) == "number" and vim.api.nvim_buf_get_name(buf) or buf
          if not bufname or bufname == "" then
            return nil
          end

          local dirname = vim.fs.dirname(bufname)
          if not dirname then
            return nil
          end

          local root = find_eslint_root(dirname)
          if on_dir then
            if root then
              on_dir(root)
            end
            return nil
          end

          return root
        end,
      })
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

      vim.lsp.enable({ "gopls", "golangci_lint_ls", "terraformls", "ts_ls", "eslint", "lua_ls" })

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
