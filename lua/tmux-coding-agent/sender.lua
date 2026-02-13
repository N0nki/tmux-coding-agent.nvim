-- lua/tmux-coding-agent/sender.lua
-- Text sending logic

local M = {}

local detector = require('tmux-coding-agent.detector')
local config = require('tmux-coding-agent.config')

--- Notify user with configurable level
local function notify(message, level)
  local notif_config = config.get_notifications()
  if notif_config.enabled then
    vim.notify(message, level or notif_config.level)
  end
end

--- Send text to specific tmux pane
--- @param pane_idx string Pane index
--- @param text string Text to send
--- @param tool_name string Tool name for notification
function M.send_text_to_pane(pane_idx, text, tool_name)
  local escaped_text = text:gsub("'", "'\\''")

  local cmd = string.format("tmux send-keys -t %s -l '%s'", pane_idx, escaped_text)
  vim.fn.system(cmd)

  vim.fn.system(string.format('tmux send-keys -t %s Enter', pane_idx))
end

--- Select target pane from multiple AI panes
local function select_and_send(ai_panes, text, tool_name)
  -- If specific tool name is specified
  if tool_name then
    for _, pane in ipairs(ai_panes) do
      if pane.name:lower():match(tool_name:lower()) or pane.command:lower():match(tool_name:lower()) then
        M.send_text_to_pane(pane.index, text, pane.name)
        return
      end
    end
    notify(string.format('%s pane not found', tool_name), vim.log.levels.WARN)
    return
  end

  -- Auto-select if only one pane
  if #ai_panes == 1 then
    M.send_text_to_pane(ai_panes[1].index, text, ai_panes[1].name)
    return
  end

  -- Select from multiple AI tool panes
  local choices = {}
  -- Add "All" option at the beginning
  table.insert(choices, 'All - Send to all AI tools')
  for i, pane in ipairs(ai_panes) do
    table.insert(choices, string.format('%s (pane %s)', pane.name, pane.index))
  end

  vim.ui.select(choices, {
    prompt = 'Select AI tool to send to:',
  }, function(choice, idx)
    if idx then
      if idx == 1 then
        -- "All" selected: send to all panes
        for _, pane in ipairs(ai_panes) do
          M.send_text_to_pane(pane.index, text, pane.name)
        end
      else
        -- Individual pane selected (adjust index for "All" offset)
        M.send_text_to_pane(ai_panes[idx - 1].index, text, ai_panes[idx - 1].name)
      end
    end
  end)
end

--- Main send function: detect panes and send text
--- @param text string Text to send
--- @param tool_name string|nil Optional specific tool name
function M.send_to_ai(text, tool_name)
  if not text or text == '' then
    notify('Text to send is empty', vim.log.levels.WARN)
    return
  end

  local ai_panes, err = detector.get_ai_panes()
  if err then
    notify(err, vim.log.levels.WARN)
    return
  end

  select_and_send(ai_panes, text, tool_name)
end

return M
