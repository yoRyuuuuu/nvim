return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "main",
    lazy = false,
    config = function()
      local treesitter = require("nvim-treesitter")

      -- Parsers to have available up front. Textobject motions (]f, cif, ...)
      -- silently no-op without a parser, so cover the languages used here.
      treesitter.install({
        "bash",
        "diff",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "hcl",
        "javascript",
        "jsdoc",
        "json",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rust",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "yaml",
      })

      -- In the rewritten main branch, highlighting is provided by Neovim and must be enabled explicitly.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if vim.bo[args.buf].buftype ~= "" then
            return
          end

          local filetype = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(filetype)
          if not lang then
            return
          end

          -- Auto-install a missing parser, then start once it is ready.
          if vim.tbl_contains(require("nvim-treesitter.config").get_installed(), lang) then
            pcall(vim.treesitter.start, args.buf, lang)
          else
            local ok, task = pcall(treesitter.install, { lang })
            if ok and task then
              task:await(vim.schedule_wrap(function()
                if vim.api.nvim_buf_is_valid(args.buf) then
                  pcall(vim.treesitter.start, args.buf, lang)
                end
              end))
            end
          end
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
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local sel = require("nvim-treesitter-textobjects.select").select_textobject
      local mv = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")
      local map = vim.keymap.set

      -- Syntax-aware select: f = function, c = class.
      -- Brackets / quotes / arguments are handled by targets.vim.
      for lhs, obj in pairs({
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      }) do
        map({ "x", "o" }, lhs, function()
          sel(obj, "textobjects")
        end, { desc = "TS " .. obj })
      end

      -- Move to next/prev function, class, parameter without typing counts or symbols.
      map({ "n", "x", "o" }, "]f", function()
        mv.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function start" })
      map({ "n", "x", "o" }, "[f", function()
        mv.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev function start" })
      map({ "n", "x", "o" }, "]c", function()
        mv.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start" })
      map({ "n", "x", "o" }, "[c", function()
        mv.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Prev class start" })
      map({ "n", "x", "o" }, "]a", function()
        mv.goto_next_start("@parameter.inner", "textobjects")
      end, { desc = "Next parameter" })
      map({ "n", "x", "o" }, "[a", function()
        mv.goto_previous_start("@parameter.inner", "textobjects")
      end, { desc = "Prev parameter" })

      -- Reorder arguments without counting.
      map("n", "<leader>na", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap parameter with next" })
      map("n", "<leader>pa", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap parameter with prev" })
    end,
  },
}
