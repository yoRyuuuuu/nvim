_G.EditFromLazygit = function(file, line, col)
  if type(file) == "table" then
    local payload = file
    file = payload.filename or payload.file or payload[1]
    line = line or payload.line or payload.lnum or payload[2]
    col = col or payload.col or payload.cnum or payload[3]
  end

  if type(file) ~= "string" or file == "" then
    return
  end

  -- Prefer :drop so we reuse an existing buffer if it's already open.
  vim.cmd("silent keepalt drop " .. vim.fn.fnameescape(file))

  local lnum = tonumber(line)
  if lnum ~= nil then
    local cnum = tonumber(col) or 0
    pcall(vim.api.nvim_win_set_cursor, 0, { math.max(lnum, 1), math.max(cnum, 0) })
    vim.cmd("normal! zvzz")
  end
end
