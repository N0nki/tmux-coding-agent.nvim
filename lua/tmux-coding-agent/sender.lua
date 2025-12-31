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

  notify(string.format('%s (pane %s) にテキストを送信しました', tool_name, pane_idx))
end

--- Select target pane from multiple AI panes
local function select_and_send(ai_panes, text, tool_name)
  -- 特定のツール名が指定されている場合
  if tool_name then
    for _, pane in ipairs(ai_panes) do
      if pane.name:lower():match(tool_name:lower()) or pane.command:lower():match(tool_name:lower()) then
        M.send_text_to_pane(pane.index, text, pane.name)
        return
      end
    end
    notify(string.format('%s ペインが見つかりません', tool_name), vim.log.levels.WARN)
    return
  end

  -- 1つだけの場合は自動選択
  if #ai_panes == 1 then
    M.send_text_to_pane(ai_panes[1].index, text, ai_panes[1].name)
    return
  end

  -- 複数のAIツールペインがある場合は選択
  local choices = {}
  for i, pane in ipairs(ai_panes) do
    table.insert(choices, string.format('%d. %s (pane %s)', i, pane.name, pane.index))
  end

  vim.ui.select(choices, {
    prompt = '送信先のAIツールを選択してください:',
  }, function(choice, idx)
    if idx then
      M.send_text_to_pane(ai_panes[idx].index, text, ai_panes[idx].name)
    end
  end)
end

--- Main send function: detect panes and send text
--- @param text string Text to send
--- @param tool_name string|nil Optional specific tool name
function M.send_to_ai(text, tool_name)
  if not text or text == '' then
    notify('送信するテキストが空です', vim.log.levels.WARN)
    return
  end

  local ai_panes, err = detector.get_ai_panes()
  if err then
    notify(err, vim.log.levels.WARN)
    return
  end

  -- デバッグ情報を表示
  local debug_msg = string.format('検出されたAIツール: %d個', #ai_panes)
  for i, pane in ipairs(ai_panes) do
    debug_msg = debug_msg .. string.format('\n  %d. %s (pane %s)', i, pane.name, pane.index)
  end
  notify(debug_msg, vim.log.levels.INFO)

  select_and_send(ai_panes, text, tool_name)
end

return M
