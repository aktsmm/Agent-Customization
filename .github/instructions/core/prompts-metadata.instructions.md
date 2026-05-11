---
description: "VS Code User Data の prompts/instructions/agents/SKILL を編集・新規作成するときに使う metadata ルールと保存先の既定スコープ。`description` / `applyTo` / `name` / HTML メタ / `syncToGlobal` / personal default の SSOT"
applyTo: "**/*.prompt.md,**/*.instructions.md,**/*.agent.md,**/SKILL.md"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# グローバル（APPDATA）プロンプトのメタデータ・保存先運用

%APPDATA%/Code/User/prompts/ 配下の `*.prompt.md` / `*.agent.md` / `*.instructions.md` を編集・新規作成するときの metadata ルールと保存先の既定スコープ。

workspace 固有の `.github/instructions/**/*.instructions.md`、`.github/copilot-instructions.md`、`AGENTS.md` にはこの instruction を持ち込まない。

## Personal Scope Defaults

- 個人用の VS Code カスタマイズを作る依頼では、明示的な指定がなければ personal scope を第一候補にする
- prompts / instructions / agents は VS Code User Data の `%APPDATA%/Code/User/prompts/` を優先する
- skills は personal skill の公式保存先（例: `~/.copilot/skills/`、`~/.claude/skills/`、`~/.agents/skills/`）を使う
- `.github/copilot-instructions.md`、`AGENTS.md`、workspace 配下の `.instructions.md` は personal metadata ルールの対象として扱わない
- GitHub Copilot CLI の always-on instruction は `$HOME/.copilot/copilot-instructions.md` が公式の推奨保存先。`~/.copilot/instructions/` は CLI がデフォルトで自動ロードする場所としては公式に明記されていないため、CLI 側に追加ディレクトリを読ませたい場合は `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` 環境変数で明示する
- VS Code Chat の personal instructions は User Data prompts フォルダーまたは `~/.copilot/instructions/` に置く（どちらを読むかは `chat.instructionsFilesLocations` で制御される）
- 保存先の確認が必要でも、質問は最小限にとどめる
- 単純なひな型作成では、まず最小構成で作ってから不足分だけ確認する

## Content Size and Granularity

中身の量・粒度・always-on の扱い・具体例の最小化は `context-management.instructions.md` を SSOT とする。ここでは frontmatter / 保存先 / sync ポリシーだけ扱う。

## YAML Frontmatter

VS Code が認識する `description` / `applyTo` / `name` は、HTML コメントではなく **YAML frontmatter** に書く。

### `.instructions.md`

- 常時またはファイル条件で自動適用したい場合は `applyTo` を必ず書く
- UI 表示や semantic matching に使わせたい説明は `description` に書く
- 手動添付・参照専用にしたい場合だけ `applyTo` を省略してよい

### `.prompt.md` / `.agent.md`

- slash command / agent picker の説明は YAML `description` に書く
- 必要に応じて `name` / `argument-hint` / `tools` / `model` などを YAML に書く

### `SKILL.md`

- `name` と `description` は必須
- `name` はフォルダ名と一致させる
- `description` には「何をするか」と「いつ使うか」を両方書く
- 手動でも使う skill では `argument-hint` を書く
- `user-invocable` は原則として明示し、通常は `true` にする
- `user-invocable: false` は `/` メニューに出したくない background skill のときだけ使う
- `disable-model-invocation: true` は手動専用 skill のときだけ使う

## HTML Metadata

以下のメタ情報ブロックは YAML frontmatter の直後に置き、削除・改変しない（プレフィックス安定性・同期/運用のため）。
HTML コメントは同期・運用向けであり、VS Code の `description` としては扱われない。

- `syncToGlobal: true`（または省略）
- `author: ...`
- `repository: ...`
- `license: ...`
- `copyright: ...`

## `syncToGlobal` Rules

- 汎用的で、他環境に持っていっても安全に動く
- 環境固有の値を含まない（例: Tenant/Subscription ID、Publisher、個人アカウント、ローカルの絶対パスなどに依存しない）
- シークレット/認証情報を含まない（例: API Key、Token、Password、Connection String を書かない）

次のいずれかに該当する場合は **`syncToGlobal: true` を書かない**。

- 環境固有の値を含む
- シークレット/認証情報を含む
- 顧客情報・社内情報など外部共有禁止の情報を含む

## Secret Handling

- 新規作成時は secret / 個人情報 / 環境固有値を直接書かずプレースホルダ化してよい
  - 例: `AZURE_TENANT_ID=<set-in-env>` / `GITHUB_TOKEN=<set-in-env>`
  - 参照が必要な場合は「環境変数/設定で渡す」旨を本文に書く（値は書かない）
- すでに secret / 個人情報 / 環境固有値を含むファイルは、値をそのまま残してもよいが、以下を必ず満たす
  - `syncToGlobal: true` を付けない
  - 同期フローで疑わしいファイルはユーザーに警告を出し、同期対象になっていないことを確認する
  - 必要に応じて `.github/.sync-ignore` にファイル名を追加し、複数層で公開を防ぐ
  - 値の削除やマスク化をユーザーに強制しない（手元参照として保つ価値があるため）
- 同期フローの責務は同期 prompt（例: `sync-user-customizations-to-github`）側にあり、この instruction は「同期しない設定になっていること」のチェックを同期 prompt に要求する

## Minimal Templates

### 同期 OK

```
---
description: "いつ・何に使う instruction か"
applyTo: "**"
---

<!-- syncToGlobal: true -->
<!-- author: ... -->
<!-- repository: ... -->
<!-- license: ... -->
<!-- copyright: ... -->
```

### 同期 NG

```
---
description: "ローカル専用の用途説明"
---

<!-- author: ... -->
<!-- repository: ... -->
<!-- license: ... -->
<!-- copyright: ... -->
```

### `SKILL.md`

```yaml
---
name: skill-name
description: "What it does. Use when [trigger conditions]."
argument-hint: "対象ファイル、URL、依頼内容など"
user-invocable: true
---
```
