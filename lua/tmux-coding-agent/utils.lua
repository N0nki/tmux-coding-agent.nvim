-- lua/tmux-coding-agent/utils.lua
-- Text extraction utilities

local M = {}

--- Get visual selection text
--- @return string|nil Selected text or nil on error
function M.get_visual_selection()
  -- Exit visual mode to update '< and '> marks
  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  if start_pos[2] == 0 or end_pos[2] == 0 then
    vim.notify('Failed to get visual selection', vim.log.levels.WARN)
    return nil
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local start_row = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3]

  local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

  if not lines or #lines == 0 then
    vim.notify('Selection is empty', vim.log.levels.WARN)
    return nil
  end

  return table.concat(lines, '\n')
end

--- Get entire buffer content
--- @return string Buffer content as single string
function M.get_buffer_content()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, '\n')
end

return M
