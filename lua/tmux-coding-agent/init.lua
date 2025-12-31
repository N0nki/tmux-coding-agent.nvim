-- lua/tmux-coding-agent/init.lua
-- Public API

local M = {}

local config = require('tmux-coding-agent.config')
local sender = require('tmux-coding-agent.sender')
local utils = require('tmux-coding-agent.utils')

--- Setup function called by users in their config
--- @param opts table|nil User configuration options
function M.setup(opts)
  config.setup(opts or {})
end

--- Send visual selection to AI tool
--- @param tool_name string|nil Optional specific tool name
function M.send_visual_to_ai(tool_name)
  local text = utils.get_visual_selection()
  if not text then
    return
  end
  sender.send_to_ai(text, tool_name)
end

--- Send entire buffer to AI tool
--- @param tool_name string|nil Optional specific tool name
function M.send_buffer_to_ai(tool_name)
  local text = utils.get_buffer_content()
  sender.send_to_ai(text, tool_name)
end

--- Send buffer with filepath context
--- @param tool_name string|nil Optional specific tool name
function M.send_buffer_with_filepath(tool_name)
  local filepath = vim.fn.expand('%:p')
  local content = utils.get_buffer_content()
  local text = string.format('File: %s\n\n```\n%s\n```', filepath, content)
  sender.send_to_ai(text, tool_name)
end

--- Create a function that sends buffer with custom prompt
--- @param prompt string Custom prompt text
--- @param tool_name string|nil Optional specific tool name
--- @return function Function that sends buffer with prompt
function M.send_with_prompt(prompt, tool_name)
  return function()
    local content = utils.get_buffer_content()
    local text = string.format('%s\n\n```\n%s\n```', prompt, content)
    sender.send_to_ai(text, tool_name)
  end
end

--- Create a function that sends visual selection with custom prompt
--- @param prompt string Custom prompt text
--- @param tool_name string|nil Optional specific tool name
--- @return function Function that sends selection with prompt
function M.send_visual_with_prompt(prompt, tool_name)
  return function()
    local text = utils.get_visual_selection()
    if not text then
      return
    end
    local full_text = string.format('%s\n\n```\n%s\n```', prompt, text)
    sender.send_to_ai(full_text, tool_name)
  end
end

return M
