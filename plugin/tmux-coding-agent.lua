-- plugin/tmux-coding-agent.lua
-- Entry point and user command definitions

if vim.g.loaded_tmux_coding_agent then
  return
end
vim.g.loaded_tmux_coding_agent = 1

local agent = require('tmux-coding-agent')

-- :TmuxSendToAI [tool_name]
vim.api.nvim_create_user_command('TmuxSendToAI', function(opts)
  agent.send_buffer_to_ai(opts.args ~= '' and opts.args or nil)
end, {
  nargs = '?',
  desc = 'Send buffer to AI tool in tmux pane',
})

-- :TmuxSendVisualToAI [tool_name]
vim.api.nvim_create_user_command('TmuxSendVisualToAI', function(opts)
  agent.send_visual_to_ai(opts.args ~= '' and opts.args or nil)
end, {
  range = true,
  nargs = '?',
  desc = 'Send visual selection to AI tool in tmux pane',
})

-- :TmuxSendFileToAI [tool_name]
vim.api.nvim_create_user_command('TmuxSendFileToAI', function(opts)
  agent.send_buffer_with_filepath(opts.args ~= '' and opts.args or nil)
end, {
  nargs = '?',
  desc = 'Send buffer with filepath to AI tool',
})
