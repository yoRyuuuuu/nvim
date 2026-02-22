return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lsp_policy = {
        max_filesize_bytes = 1024 * 1024,
        excluded_dir_names = {
          [".git"] = true,
          [".next"] = true,
          [".terraform"] = true,
          ["build"] = true,
          ["coverage"] = true,
          ["dist"] = true,
          ["node_modules"] = true,
          ["target"] = true,
          ["vendor"] = true,
        },
      }

      local server_root_markers = {
        gopls = { "go.work", "go.mod" },
        golangci_lint_ls = { "go.work", "go.mod" },
        terraformls = { ".terraform", ".git" },
        ts_ls = { "tsconfig.json", "jsconfig.json", "package.json" },
        lua_ls = { ".luarc.json", ".luarc.jsonc", "stylua.toml", ".git" },
      }

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

      local function normalize_path(path)
        if not path or path == "" then
          return nil
        end

        local normalized = vim.fs.normalize(path)
        if normalized == "" or normalized:match("^%w+://") then
          return nil
        end

        return normalized
      end

      local function resolve_buf_path(buf)
        local bufname
        if type(buf) == "number" then
          if not vim.api.nvim_buf_is_valid(buf) then
            return nil
          end
          if vim.bo[buf].buftype ~= "" then
            return nil
          end
          bufname = vim.api.nvim_buf_get_name(buf)
        else
          bufname = buf
        end

        return normalize_path(bufname)
      end

      local function is_excluded_path(path)
        local normalized = path:gsub("\\", "/")
        for dir_name, _ in pairs(lsp_policy.excluded_dir_names) do
          local suffix = "/" .. dir_name
          if normalized:find(suffix .. "/", 1, true) or normalized:sub(-#suffix) == suffix then
            return true
          end
        end
        return false
      end

      local function is_lsp_target(buf, path)
        local file_path = normalize_path(path) or resolve_buf_path(buf)
        if not file_path then
          return false
        end
        if vim.fn.filereadable(file_path) == 0 then
          return false
        end
        if is_excluded_path(file_path) then
          return false
        end

        local stat = vim.uv.fs_stat(file_path)
        if not stat or stat.type ~= "file" then
          return false
        end
        if stat.size and stat.size > lsp_policy.max_filesize_bytes then
          return false
        end

        return true
      end

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

      local function find_marked_root(path, markers)
        local file_path = normalize_path(path)
        if not file_path then
          return nil
        end

        local dirname = vim.fs.dirname(file_path)
        if not dirname then
          return nil
        end

        local found = vim.fs.find(markers, {
          path = dirname,
          upward = true,
        })
        if #found == 0 then
          return nil
        end

        return vim.fs.dirname(found[1])
      end

      local function build_root_dir(markers)
        return function(buf, on_dir)
          local file_path = resolve_buf_path(buf)
          if not is_lsp_target(buf, file_path) then
            return nil
          end

          local root = find_marked_root(file_path, markers)
          if on_dir then
            if root then
              on_dir(root)
            end
            return nil
          end

          return root
        end
      end

      local function disable_formatting_capabilities(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      local required_tool_commands = {
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
      local missing_tool_commands = {}
      for _, command_name in ipairs(required_tool_commands) do
        if vim.fn.executable(command_name) == 0 then
          table.insert(missing_tool_commands, command_name)
        end
      end
      if #missing_tool_commands > 0 then
        vim.schedule(function()
          vim.notify("Missing external tools: " .. table.concat(missing_tool_commands, ", "), vim.log.levels.WARN, {
            title = "Tooling Check",
          })
        end)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok and type(blink.get_lsp_capabilities) == "function" then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      local lsp_servers = {
        gopls = {
          root_dir = build_root_dir(server_root_markers.gopls),
          on_attach = function(client)
            -- Prefer Tree-sitter highlights over gopls semantic tokens.
            client.server_capabilities.semanticTokensProvider = nil
          end,
        },
        golangci_lint_ls = {
          root_dir = build_root_dir(server_root_markers.golangci_lint_ls),
          init_options = {
            command = { "golangci-lint", "run", "--output.json.path=stdout", "--show-stats=false" },
          },
        },
        terraformls = {
          root_dir = build_root_dir(server_root_markers.terraformls),
          on_attach = function(client)
            -- terraform-ls semantic tokens can conflict with Tree-sitter highlighting.
            client.server_capabilities.semanticTokensProvider = nil
          end,
        },
        ts_ls = {
          root_dir = build_root_dir(server_root_markers.ts_ls),
          on_attach = function(client)
            disable_formatting_capabilities(client)
          end,
        },
        eslint = {
          on_attach = function(_, bufnr)
            -- If eslint attaches, disable ts_ls formatting for this buffer to avoid conflicts.
            local ts_clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ts_ls" })
            for _, ts_client in ipairs(ts_clients) do
              disable_formatting_capabilities(ts_client)
            end
          end,
          root_dir = function(buf, on_dir)
            local file_path = resolve_buf_path(buf)
            if not is_lsp_target(buf, file_path) then
              return nil
            end

            local dirname = vim.fs.dirname(file_path)
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
        },
        lua_ls = {
          root_dir = build_root_dir(server_root_markers.lua_ls),
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      }

      local server_names = vim.tbl_keys(lsp_servers)
      table.sort(server_names)
      for _, server_name in ipairs(server_names) do
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          single_file_support = false,
        }, lsp_servers[server_name])
        vim.lsp.config(server_name, server_opts)
      end
      vim.lsp.enable(server_names)

      vim.diagnostic.config({
        update_in_insert = false,
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
