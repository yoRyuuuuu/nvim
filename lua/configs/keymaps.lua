-- Copy relative file path for AI
vim.keymap.set("n", "<leader>Y", function()
  local file_path = vim.fn.expand("%:.")
  vim.fn.setreg("+", file_path)
  vim.notify("Copied relative file path: " .. file_path, vim.log.levels.INFO)
end, { desc = "Copy relative file path for AI" })

-- Copy context string for AI (visual mode)
vim.keymap.set("v", "<leader>y", function()
  vim.cmd("normal! y")
  local file_path = vim.fn.expand("%:.")
  local start_line = vim.fn.line("'[")
  local end_line = vim.fn.line("']")
  local context_string = string.format("@%s#L%s-%s", file_path, start_line, end_line)
  vim.fn.setreg('"', "")
  vim.fn.setreg("+", context_string)
  vim.notify("Copied to clipboard: " .. context_string, vim.log.levels.INFO)
end, { desc = "Copy context string for AI" })

-- Clear search highlight
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- LSP rename
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP Rename" })

-- Diagnostic: show full message in a focusable float (scrollable, no early close)
vim.keymap.set("n", "gl", function()
  local bufnr = 0
  local pos = vim.api.nvim_win_get_cursor(0)
  local lnum = pos[1] - 1

  -- Avoid opening an empty float when there are no diagnostics on this line.
  local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
  if not diags or vim.tbl_isempty(diags) then
    vim.notify("No diagnostics", vim.log.levels.INFO)
    return
  end

  local a, b = vim.diagnostic.open_float(bufnr, {
    focus = true,
    scope = "cursor",
    border = "rounded",
    source = "if_many",
    severity_sort = true,
    -- Keep it open while you move/scroll inside the float.
    close_events = { "BufLeave", "InsertEnter", "FocusLost", "CursorMovedI" },
  })

  -- Neovim versions differ in return order; detect the float window reliably.
  local winid = nil
  local float_bufnr = nil
  if type(a) == "number" and vim.api.nvim_win_is_valid(a) then
    winid = a
    float_bufnr = b
  elseif type(b) == "number" and vim.api.nvim_win_is_valid(b) then
    winid = b
    float_bufnr = a
  else
    winid = vim.api.nvim_get_current_win()
    float_bufnr = vim.api.nvim_win_get_buf(winid)
  end

  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.wo[winid].wrap = true
    vim.wo[winid].linebreak = true
  end

  if float_bufnr and type(float_bufnr) == "number" and vim.api.nvim_buf_is_valid(float_bufnr) then
    vim.keymap.set("n", "q", function()
      if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
      end
    end, { buffer = float_bufnr, silent = true, nowait = true })
  end
end, { desc = "Diagnostic (Float Full)" })
