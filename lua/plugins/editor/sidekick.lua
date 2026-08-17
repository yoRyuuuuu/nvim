return {
  "folke/sidekick.nvim",
  opts = {
    nes = { enabled = false },
    cli = {
      win = {
        keys = {
          -- prefer emacs-style keys
          buffers = false, -- <c-b>
          files = false, -- <c-f>
          prompt = false, -- <c-p>
        },
      },
      mux = { backend = "tmux", enabled = false },
      tools = {
        codex = { cmd = { "codex" } },
        -- Hide TMUX so Claude Code emits a plain OSC 52 instead of the
        -- tmux DCS passthrough form, which nvim's terminal cannot parse
        -- and leaks into the buffer as literal `52;c;<base64>` text.
        claude = { env = { TMUX = false } },
      },
    },
  },
  keys = {
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle()
      end,
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").select()
      end,
      desc = "Sidekick Select CLI",
    },
    {
      "<leader>ad",
      function()
        require("sidekick.cli").close()
      end,
      desc = "Detach a CLI Session",
    },
    {
      "<leader>at",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>af",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "Send File",
    },
    {
      "<leader>av",
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      mode = { "x" },
      desc = "Send Visual Selection",
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
  },
}
