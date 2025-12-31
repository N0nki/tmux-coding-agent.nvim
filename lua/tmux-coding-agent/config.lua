-- lua/tmux-coding-agent/config.lua
-- Configuration management

local M = {}

--- Default configuration
--- @class TmuxCodingAgent.Config
--- @field ai_tools table[] List of AI tool patterns (name, pattern)
--- @field notifications table Notification settings
M.defaults = {
  ai_tools = {
    { name = 'Claude Code', pattern = 'claude' },
    { name = 'Codex', pattern = 'codex' },
    { name = 'Gemini', pattern = 'gemini' },
  },
  notifications = {
    enabled = true,
    level = vim.log.levels.INFO,
  },
}

--- Current configuration (merged defaults + user)
--- @type TmuxCodingAgent.Config
M.options = vim.deepcopy(M.defaults)

--- Setup configuration with user options
--- @param user_opts table User configuration
function M.setup(user_opts)
  M.options = vim.tbl_deep_extend('force', M.defaults, user_opts)
  M.validate()
end

--- Validate current configuration
function M.validate()
  if type(M.options.ai_tools) ~= 'table' then
    error('tmux-coding-agent: ai_tools must be a table')
  end

  for i, tool in ipairs(M.options.ai_tools) do
    if not tool.name or not tool.pattern then
      error(string.format('tmux-coding-agent: ai_tools[%d] missing name or pattern', i))
    end
  end
end

--- Get AI tools list
--- @return table[] List of AI tool configurations
function M.get_ai_tools()
  return M.options.ai_tools
end

--- Get notification settings
--- @return table Notification configuration
function M.get_notifications()
  return M.options.notifications
end

return M
