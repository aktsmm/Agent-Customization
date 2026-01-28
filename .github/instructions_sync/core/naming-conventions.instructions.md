# Naming Conventions

リポジトリ内のファイル・フォルダ・変数の命名規則を定義します。

## ファイル命名規則

### プロンプトファイル (`.prompt.md`)

**形式**: `<動詞>-<対象>[-<補足>].prompt.md`

**良い例:**

- `git-commit.prompt.md` - 動詞-対象で明確
- `git-commit-push.prompt.md` - 動詞-対象-補足
- `create-workflow.prompt.md` - 動詞-対象
- `review-agents-and-instructions.prompt.md` - 動詞-複数対象
- `export-session-log.prompt.md` - 動詞-対象-補足

**避けるべき例:**

- `gc_Commit.prompt.md` - アンダースコア混在、頭字語不明
- `gpull.prompt.md` - 頭字語のみ
- `doStuff.prompt.md` - camelCase不可

### インストラクションファイル (`.instructions.md`)

**形式**: `<対象>[-<補足>].instructions.md`

**例:**

- `git.instructions.md` - 対象のみ
- `terminal.instructions.md` - 対象のみ
- `microsoft-docs.instructions.md` - 対象-補足
- `naming-conventions.instructions.md` - 対象-補足

### エージェントファイル (`.agent.md`)

**形式**: `<役割>[-<補足>].agent.md`

**例:**

- `orchestrator.agent.md` - 役割のみ
- `sync-to-global.agent.md` - 役割-補足
- `sample.agent.md` - テンプレート用

## 一般原則

### 推奨

- **ケバブケース**: `my-file-name.md` （単語をハイフンで区切る）
- **小文字**: すべて小文字を使用
- **英語**: ファイル名は英語で記述
- **簡潔さ**: 3-5単語以内に抑える
- **説明的**: 内容が分かる名前にする

### 禁止

- `snake_case` - アンダースコアは使わない
- `camelCase` - キャメルケースは使わない
- `PascalCase` - パスカルケースは使わない
- 日本語 - ファイル名に日本語を含めない
- 頭字語のみ - `gc.md`, `gcp.md` など意味不明な短縮は避ける
- スペース - `my file.md` はNG、`my-file.md` にする

## フォルダ命名規則

- **ケバブケース**: `prompts_sync`, `instructions_sync` など
- **複数形**: 複数のファイルを含む場合は複数形 (`prompts`, `agents`)
- **単数形**: 単一の概念を表す場合は単数形 (`core`, `dev`)

## 変数・関数命名規則（コード内）

### PowerShell

```powershell
# 推奨: PascalCase (関数)
function Copy-PromptFiles { }

# 推奨: camelCase (変数)
$sourceDir = "..."
$targetFiles = @()
```

### Python

```python
# 推奨: snake_case (関数・変数)
def copy_prompt_files():
    source_dir = "..."
    target_files = []

# 推奨: PascalCase (クラス)
class PromptManager:
    pass
```

### JavaScript/TypeScript

```javascript
// 推奨: camelCase (関数・変数)
function copyPromptFiles() {
  const sourceDir = "...";
  const targetFiles = [];
}

// 推奨: PascalCase (クラス)
class PromptManager {}
```

## 例外

以下のファイルは慣例に従い命名規則の例外とします：

- `README.md` - プロジェクトルートの説明ファイル
- `LICENSE` - ライセンスファイル
- `AGENTS.md` - エージェント一覧（全大文字OK）
- `.gitignore`, `.editorconfig` - 設定ファイル
