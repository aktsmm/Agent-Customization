---
description: "Git 操作ルール（コミット規約、Push 禁止）"
---

<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Git 操作ルール

- **明示的な指示がない限り `git push` は禁止**。コミットまでは可、プッシュはユーザーの明示的な許可を得てから行うこと。
- コミットメッセージは Conventional Commits 形式（`feat:`, `fix:`, `docs:`, `chore:` 等）で記述する。

- **ローカルでリポジトリを開いていない場合は gh api を使う**。ファイルの作成・更新・削除などの軽い操作でわざわざクローンしない。gh api repos/{owner}/{repo}/contents/{path} で直接操作すること。

- **ワークスペース内のファイルパスは相対パスで記述する**。`agent.md` や設定ファイルなどに絶対パス（`C:\Users\...` 等）を埋め込まない。別PC・別環境での再利用性を保つため、ワークスペースルートからの相対パスを使うこと。

- **`gh issue comment` 等の `gh` CLI で `--body` に変数を渡す場合、変数定義と実行を同一の `run_in_terminal` 呼び出しにまとめること**。分割すると変数が引き継がれず、空文字や前回の値で重複投稿される。ヒアストリング（`@"..."@`）を使う場合は特に注意。

## 公開リポジトリのデフォルト（aktsmm）

- **公開 GitHub リポジトリを新規作成する場合、基本は CC BY-NC-SA 4.0 の LICENSE を入れる**（英語＋日本語併記＋補足条項5項）。既存の標準テキストは下記を正としてコピーする。
  - 標準 LICENSE（適用済みの実体）:
    - https://github.com/aktsmm/gh-copilot-multi-agent-mission-board/blob/master/LICENSE
  - テンプレ（新規リポジトリ作成時にコピー用）:
    - https://github.com/aktsmm/ghc_template/blob/master/templates/LICENSE_PUBLIC.md
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
