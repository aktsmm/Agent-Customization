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

## 適用範囲

- ここでは YAML frontmatter、HTML metadata、`syncToGlobal`、保存先の既定だけを扱う
- 読み込み経路や配置戦略そのものは `copilot-loading.instructions.md` を正本にする
- `.github/copilot-instructions.md`、`AGENTS.md`、workspace 配下の `.instructions.md` にはこの rule を持ち込まない

## Personal Scope Defaults

- 個人用の VS Code カスタマイズは、明示指定がなければ `%APPDATA%/Code/User/prompts/` を第一候補にする
- skills は personal skill の公式保存先を使う
- 単純なひな型作成では、最小構成で作ってから不足分だけ確認する

## YAML Frontmatter

VS Code が認識する `description` / `applyTo` / `name` は、HTML コメントではなく **YAML frontmatter** に書く。

### `.instructions.md`

- 常時またはファイル条件で自動適用したい場合は `applyTo` を必ず書く
- UI 表示や semantic matching に使わせたい説明は `description` に書く
- 手動添付・参照専用にしたい場合だけ `applyTo` を省略してよい

### `.prompt.md` / `.agent.md`

- slash command / agent picker の説明は YAML `description` に書く
- 必要に応じて `name` / `argument-hint` / `tools` / `model` などを YAML に書く
- `model` は現在環境で exact display name を確認した場合だけ書く。テンプレートや例では実在名を固定せず、placeholder か省略を使う

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

- 次をすべて満たすときだけ `syncToGlobal: true` を付ける
  - 汎用的で、他環境に持っていっても安全に動く
  - 環境固有値に依存しない
  - シークレットや認証情報を含まない
- 上記を満たさない file には `syncToGlobal: true` を付けない

## Secret Handling

- 新規作成時は secret / 個人情報 / 環境固有値を直接書かずプレースホルダ化してよい
  - 例: `AZURE_TENANT_ID=<set-in-env>` / `GITHUB_TOKEN=<set-in-env>`
  - 参照が必要な場合は「環境変数/設定で渡す」旨を本文に書く（値は書かない）
- 既存 file に secret / 個人情報 / 環境固有値がある場合でも、少なくとも `syncToGlobal: true` は付けない
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
