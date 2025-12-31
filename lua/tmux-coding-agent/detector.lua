-- lua/tmux-coding-agent/detector.lua
-- AI tool detection logic

local M = {}

local config = require('tmux-coding-agent.config')

--- Get command running in a tmux pane by TTY
--- @param pane_tty string Pane TTY device
--- @return string|nil Command line or nil if not found
function M.get_pane_command(pane_tty)
  local ps_output = vim.fn.system(string.format('ps -t %s -o command=', pane_tty))

  for line in ps_output:gmatch('[^\r\n]+') do
    -- Return commands other than shells (zsh, bash, sh)
    if not line:match('^%-?[zb]?sh') and not line:match('^npm') and not line:match('^ps ') then
      return line
    end
  end

  return nil
end

--- Detect AI tool name from command line
--- @param command_line string|nil Command line to check
--- @return string|nil Tool name if detected, nil otherwise
function M.detect_ai_tool(command_line)
  if not command_line then
    return nil
  end

  local ai_tools = config.get_ai_tools()
  for _, tool in ipairs(ai_tools) do
    if command_line:match(tool.pattern) then
      return tool.name
    end
  end

  return nil
end

--- Get all AI tool panes in current tmux session
--- @return table[]|nil List of {index, name, command, tty} or nil on error
--- @return string|nil Error message if failed
function M.get_ai_panes()
  if vim.fn.getenv('TMUX') == vim.NIL then
    return nil, 'Not running inside tmux'
  end

  local panes = vim.fn.system("tmux list-panes -F '#{pane_index}:#{pane_tty}'")
  local current_pane = vim.fn.system("tmux display-message -p '#{pane_index}'"):gsub('\n', '')

  local ai_panes = {}
  for line in panes:gmatch('[^\r\n]+') do
    local pane_idx, pane_tty = line:match('^(%d+):(.+)')
    if pane_idx and pane_idx ~= current_pane then
      local command = M.get_pane_command(pane_tty)
      local detected_tool = M.detect_ai_tool(command)
      if detected_tool then
        table.insert(ai_panes, {
          index = pane_idx,
          name = detected_tool,
          command = command,
          tty = pane_tty,
        })
      end
    end
  end

  if #ai_panes == 0 then
    local tools = config.get_ai_tools()
    local tool_names = {}
    for _, tool in ipairs(tools) do
      table.insert(tool_names, tool.pattern)
    end
    return nil, string.format('No AI tool panes found (%s)', table.concat(tool_names, ', '))
  end

  return ai_panes, nil
end

return M
