return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter", -- configured in treesitter.lua with main branch
      {
        "fredrikaverpil/neotest-golang",
        version = "*", -- Optional, but recommended; track releases
        build = function()
          vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait() -- Optional, but recommended
        end,
      },
    },
    config = function()
      local config = {
        runner = "gotestsum", -- Optional, but recommended
      }

      ---@diagnostic disable-next-line: missing-fields
      require("neotest").setup({
        adapters = {
          require("neotest-golang")(config),
        },
      })

      -- :TestFile
      vim.api.nvim_create_user_command("TestFile", function()
        require("neotest").run.run(vim.fn.expand("%"))
      end, {})

      -- :TestNearest
      vim.api.nvim_create_user_command("TestNearest", function()
        require("neotest").run.run()
      end, {})

      -- :TestSummary
      vim.api.nvim_create_user_command("TestSummary", function()
        require("neotest").summary.toggle()
      end, {})

      -- :TestOutput
      vim.api.nvim_create_user_command("TestOutput", function()
        require("neotest").output.open({ enter = true })
      end, {})

      -- :TestAll
      vim.api.nvim_create_user_command("TestAll", function()
        require("neotest").run.run(vim.fn.getcwd())
      end, {})
    end,
  },
}
