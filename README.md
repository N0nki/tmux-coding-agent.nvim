# tmux-coding-agent.nvim

Neovim から tmux ペインで動作する AI コーディングアシスタント(Claude Code, Codex, Gemini など)にテキストを送信するプラグイン。

## 機能

- **AI ツール自動検出**: tmux ペインで実行中のプロセスから AI ツールを自動検出
- **柔軟な送信モード**:
  - ビジュアル選択範囲
  - バッファ全体
  - ファイルパス付きバッファ
  - カスタムプロンプト付き送信
- **マルチペイン対応**: 複数の AI ツールペインがある場合は選択可能
- **カスタマイズ可能**: setup() で AI ツールパターンを追加・変更可能

## 必要要件

- Neovim 0.7+
- tmux
- AI ツールが別の tmux ペインで実行中であること

## インストール

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

## 設定

### デフォルト設定

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

### カスタム AI ツールの追加

```lua
require('tmux-coding-agent').setup({
  ai_tools = {
    { name = 'Claude Code', pattern = 'claude' },
    { name = 'Codex', pattern = 'codex' },
    { name = 'Gemini', pattern = 'gemini' },
    { name = 'Aider', pattern = 'aider' },  -- カスタムツール追加
    { name = 'Custom AI', pattern = 'my%-ai' },  -- Lua パターン使用可能
  },
})
```

## 使用方法

### ユーザーコマンド

- `:TmuxSendToAI [tool_name]` - バッファ全体を送信
- `:TmuxSendVisualToAI [tool_name]` - ビジュアル選択範囲を送信
- `:TmuxSendFileToAI [tool_name]` - ファイルパス付きでバッファを送信

`tool_name` はオプションです。指定すると特定の AI ツールにのみ送信します。

### Lua API

```lua
local tmux_ai = require('tmux-coding-agent')

-- バッファ全体を送信
tmux_ai.send_buffer_to_ai()

-- 特定のツールに送信
tmux_ai.send_buffer_to_ai('claude')

-- ビジュアル選択範囲を送信
tmux_ai.send_visual_to_ai()

-- ファイルパス付きで送信
tmux_ai.send_buffer_with_filepath()

-- カスタムプロンプト付きで送信(関数を返す)
local send_with_review = tmux_ai.send_with_prompt('このコードをレビューしてください')
send_with_review()  -- 実行時にバッファを送信

-- ビジュアル選択にプロンプト付きで送信
local send_visual_refactor = tmux_ai.send_visual_with_prompt('このコードをリファクタリングしてください')
send_visual_refactor()
```

### キーマップ例

```lua
local tmux_ai = require('tmux-coding-agent')

-- バッファ全体を送信
vim.keymap.set('n', '<leader>aa', tmux_ai.send_buffer_to_ai, { desc = 'Send buffer to AI' })

-- ビジュアル選択を送信
vim.keymap.set('x', '<leader>aa', tmux_ai.send_visual_to_ai, { desc = 'Send visual to AI' })

-- ファイルパス付きで送信
vim.keymap.set('n', '<leader>af', tmux_ai.send_buffer_with_filepath, { desc = 'Send file to AI' })

-- カスタムプロンプト付き送信
vim.keymap.set('n', '<leader>ar', tmux_ai.send_with_prompt('このコードをレビューしてください'),
  { desc = 'Review code' })
vim.keymap.set('n', '<leader>ae', tmux_ai.send_with_prompt('このコードを説明してください'),
  { desc = 'Explain code' })
vim.keymap.set('x', '<leader>ar', tmux_ai.send_visual_with_prompt('このコードをリファクタリングしてください'),
  { desc = 'Refactor code' })
```

## 動作の仕組み

1. **プロセス検出**: `ps` コマンドで各 tmux ペインの TTY に紐づくプロセスを取得
2. **パターンマッチング**: コマンドラインが設定された AI ツールパターンにマッチするか確認
3. **ペイン選択**:
   - 1つの AI ツールペインのみ → 自動選択
   - 複数の AI ツールペイン → `vim.ui.select` で選択
   - 特定のツール名指定 → そのツールにのみ送信
4. **テキスト送信**: `tmux send-keys -l` でテキストを送信し、Enter を実行

## トラブルシューティング

### AI ツールペインが見つからない

**症状**: `AIツールペインが見つかりません (claude, codex, gemini)` というエラー

**原因**:
- tmux ペインで AI ツールが起動していない
- AI ツールのプロセス名がパターンにマッチしない

**対策**:
1. AI ツールが別の tmux ペインで実行中か確認
2. `ps aux | grep claude` などでプロセス名を確認
3. setup() でカスタムパターンを追加

### tmux 環境外で使用している

**症状**: `tmux環境外では使用できません` というエラー

**対策**: tmux セッション内で Neovim を起動してください

### 選択範囲が空

**症状**: `選択範囲が空です` というエラー

**対策**: ビジュアルモードで範囲を選択してから実行してください

## ライセンス

MIT License - Copyright (c) 2025 n0nki
