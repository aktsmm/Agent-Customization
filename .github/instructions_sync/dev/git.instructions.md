---
applyTo: "**"
---

<!-- description: Git 操作ルール（Conventional Commits、Push 禁止、gh CLI、LICENSE 規約） -->

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Git Instructions

このプロジェクトでは **Conventional Commits** に従ったコミットメッセージを必須とします。
エージェントがコミットを作成する際は、以下のルールを厳守してください。

## 基本ルール

- **明示的な指示がない限り `git push` は禁止**。コミットまでは可、プッシュはユーザーの明示的な許可を得てから行うこと。
- **ローカルでリポジトリを開いていない場合は `gh api` を使う**。ファイルの作成・更新・削除などの軽い操作でわざわざクローンしない。`gh api repos/{owner}/{repo}/contents/{path}` で直接操作すること。
- **ワークスペース内のファイルパスは相対パスで記述する**。`agent.md` や設定ファイルなどに絶対パス（`C:\Users\...` 等）を埋め込まない。別PC・別環境での再利用性を保つため、ワークスペースルートからの相対パスを使うこと。
- **`gh issue comment` 等の `gh` CLI で `--body` に変数を渡す場合、変数定義と実行を同一の `run_in_terminal` 呼び出しにまとめること**。分割すると変数が引き継がれず、空文字や前回の値で重複投稿される。ヒアストリング（`@"..."@`）を使う場合は特に注意。

## フォーマット

```text
<type>(<scope>): <subject>

<body>

<footer>
```

## 1. Type (必須)

変更の種類を表す以下のいずれかのプレフィックスを使用してください。

- **feat**: 新機能 (A new feature)
- **fix**: バグ修正 (A bug fix)
- **docs**: ドキュメントのみの変更 (Documentation only changes)
- **style**: コードの動作に影響しない変更 (空白、フォーマット、セミコロン欠落など)
- **refactor**: バグ修正も機能追加も行わないコード変更 (A code change that neither fixes a bug nor adds a feature)
- **perf**: パフォーマンスを向上させるコード変更 (A code change that improves performance)
- **test**: テストの追加や既存テストの修正 (Adding missing tests or correcting existing tests)
- **chore**: ビルドプロセスやドキュメント生成などの補助ツールやライブラリの変更 (Changes to the build process or auxiliary tools)

## 2. Scope (任意)

変更の影響範囲を示す名詞を括弧内に記述します。
例: `feat(auth): add login logic`, `fix(api): handle timeout error`

## 3. Subject (必須)

変更内容の簡潔な説明。

- **命令形**を使用する (例: "add" ではなく "added" や "adds" は避ける。日本語の場合は「〜を追加」「〜を修正」と言い切る)
- 文末にピリオド `.` を付けない
- 英字の場合は先頭を小文字にする (固有名詞を除く)

### ユーザー名の付与（任意）

チーム開発やログ追跡のため、コミット者名を付与する場合：

```text
<type>(<scope>): <subject> - <user.name>
```

例: `feat(auth): ログイン機能を追加 - <user.name>`（`git config user.name` の値を使用）

## 4. Body (任意)

変更の動機や、以前の挙動との違いなどを詳細に記述します。

## 5. Footer (任意)

- **Breaking Changes**: 互換性のない変更がある場合は `BREAKING CHANGE:` で始める。
- **Issue References**: 関連する Issue 番号を記述する (例: `Closes #123`)

## エージェントへの指示

- 複数の論理的な変更を含む場合は、可能な限りコミットを分割してください。
- コミットメッセージは、変更内容を正確に反映させてください。「修正」のような曖昧な表現は避けてください。

## 破壊的 Git 操作の注意

- `git filter-repo`, `git rebase -i`, `git reset --hard` を実行する前に、**未コミットの変更を必ずコミット**してください。
- これらの操作はワーキングツリーをリセットするため、未コミット変更は不可逆に消失します。
- `git stash` では不十分です（`filter-repo` は stash も影響を受ける場合がある）。

## 公開リポジトリのデフォルト（aktsmm）

- **公開 GitHub リポジトリを新規作成する場合、基本は CC BY-NC-SA 4.0 の LICENSE を入れる**（英語＋日本語併記＋補足条項5項）。既存の標準テキストは下記を正としてコピーする。
  - 標準 LICENSE（適用済みの実体）:
    - https://github.com/aktsmm/gh-copilot-multi-agent-mission-board/blob/master/LICENSE
  - テンプレ（新規リポジトリ作成時にコピー用）:
    - https://github.com/aktsmm/ghc_template/blob/master/LICENSE
  - 補足条項の構成（5項）:
    1. Microsoft 社員例外（業務範囲内で商用利用OK）
    2. AI/ML 学習用途の禁止
    3. コレクション/集約リポへの再配布禁止
    4. クレジット表記フォーマット
    5. 商用ライセンス（商用利用は要連絡、個人学習は歓迎）
  - 例外: `Agent-Skills`（スキル単位のライセンス運用）と `ghc_template`（テンプレ用途）は別扱い

- **文字化け防止**: PowerShell で LICENSE 等の日本語を含むテキストを扱う場合は、読み込みを `Get-Content -Raw -Encoding UTF8` とし、GitHub API に投げる JSON も BOM なし UTF-8 で書き出す。

- **公開リポジトリの `.gitignore` には、原則として以下を追加してコミット対象から除外**（`ghc_template` と `Agent-Skills` を除く）。
  - `/research/`
  - `/.github/skills/`
  - `/output_sessions/`
  - テンプレ（コピー用）:
    - https://github.com/aktsmm/ghc_template/blob/master/templates/gitignore-public.txt
