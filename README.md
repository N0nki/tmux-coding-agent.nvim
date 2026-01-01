# tmux-coding-agent.nvim

A Neovim plugin for sending text to AI coding assistants (Claude Code, Codex, Gemini, etc.) running in tmux panes.

## Features

- **Auto-detect AI tools**: Automatically detect AI tools in tmux panes via process inspection
- **Flexible send modes**:
  - Visual selection
  - Entire buffer
  - Buffer with filepath
  - Custom prompt with code
- **Multi-pane support**: Select from multiple AI tool panes when available
- **Customizable**: Add or modify AI tool patterns via setup()

## Requirements

- Neovim 0.7+
- tmux
- AI tool running in a separate tmux pane

## Installation

### lazy.nvim

```lua
{
  'n0nki/tmux-coding-agent.nvim',
  config = function()
    require('tmux-coding-agent').setup({
      ai_tools = {
        { name = 'Claude Code', pattern = 'claude' },
        { name = 'Codex', pattern = 'codex' },
        { name = 'Gemini', pattern = 'gemini' },
      },
    })
  end,
}
```

## Configuration

### Default settings

```lua
require('tmux-coding-agent').setup({
  ai_tools = {
    { name = 'Claude Code', pattern = 'claude' },
    { name = 'Codex', pattern = 'codex' },
    { name = 'Gemini', pattern = 'gemini' },
  },
  notifications = {
    enabled = true,
    level = vim.log.levels.INFO,
  },
})
```

### Adding custom AI tools

```lua
require('tmux-coding-agent').setup({
  ai_tools = {
    { name = 'Claude Code', pattern = 'claude' },
    { name = 'Codex', pattern = 'codex' },
    { name = 'Gemini', pattern = 'gemini' },
    { name = 'Aider', pattern = 'aider' },  -- Add custom tool
    { name = 'Custom AI', pattern = 'my%-ai' },  -- Lua pattern supported
  },
})
```

## Usage

### User commands

- `:TmuxSendToAI [tool_name]` - Send entire buffer
- `:TmuxSendVisualToAI [tool_name]` - Send visual selection
- `:TmuxSendFileToAI [tool_name]` - Send buffer with filepath

`tool_name` is optional. If specified, sends only to the specific AI tool.

### Lua API

```lua
local tmux_ai = require('tmux-coding-agent')

-- Send entire buffer
tmux_ai.send_buffer_to_ai()

-- Send to specific tool
tmux_ai.send_buffer_to_ai('claude')

-- Send visual selection
tmux_ai.send_visual_to_ai()

-- Send with filepath
tmux_ai.send_buffer_with_filepath()

-- Send with custom prompt (returns a function)
local send_with_review = tmux_ai.send_with_prompt('Please review this code')
send_with_review()  -- Execute to send buffer

-- Send visual selection with prompt
local send_visual_refactor = tmux_ai.send_visual_with_prompt('Please refactor this code')
send_visual_refactor()
```

### Keymap examples

```lua
local tmux_ai = require('tmux-coding-agent')

-- Send entire buffer
vim.keymap.set('n', '<leader>aa', tmux_ai.send_buffer_to_ai, { desc = 'Send buffer to AI' })

-- Send visual selection
vim.keymap.set('x', '<leader>aa', tmux_ai.send_visual_to_ai, { desc = 'Send visual to AI' })

-- Send with filepath
vim.keymap.set('n', '<leader>af', tmux_ai.send_buffer_with_filepath, { desc = 'Send file to AI' })

-- Send with custom prompts
vim.keymap.set('n', '<leader>ar', tmux_ai.send_with_prompt('Please review this code'),
  { desc = 'Review code' })
vim.keymap.set('n', '<leader>ae', tmux_ai.send_with_prompt('Please explain this code'),
  { desc = 'Explain code' })
vim.keymap.set('x', '<leader>ar', tmux_ai.send_visual_with_prompt('Please refactor this code'),
  { desc = 'Refactor code' })
```

## How it works

1. **Process detection**: Uses `ps` command to get processes for each tmux pane's TTY
2. **Pattern matching**: Checks if command line matches configured AI tool patterns
3. **Pane selection**:
   - Single AI tool pane → Auto-select
   - Multiple AI tool panes → `vim.ui.select` for selection
   - Specific tool name → Send only to that tool
4. **Text sending**: Sends text via `tmux send-keys -l` and executes Enter

## Troubleshooting

### No AI tool panes found

**Symptom**: Error message `No AI tool panes found (claude, codex, gemini)`

**Causes**:

- AI tool is not running in a tmux pane
- AI tool's process name doesn't match patterns

**Solutions**:

1. Verify AI tool is running in a separate tmux pane
2. Check process name with `ps aux | grep claude`
3. Add custom pattern in setup()

### Not running inside tmux

**Symptom**: Error message `Not running inside tmux`

**Solution**: Launch Neovim inside a tmux session

### Selection is empty

**Symptom**: Error message `Selection is empty`

**Solution**: Select text in visual mode before executing

## License

MIT License - Copyright (c) 2025 n0nki
