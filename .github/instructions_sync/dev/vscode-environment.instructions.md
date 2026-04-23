---
---

<!-- author: aktsmm -->

# VS Code 環境情報

## ファイルパス

### チャット画像の保存先

- GitHub Copilot Chat に貼り付けた画像は以下に保存される:
  - `%APPDATA%\Code\User\workspaceStorage\vscode-chat-images\`
- ファイル名形式: `image-{timestamp}.png`
- チャットで画像を参照する際はこのパスを使用する
- 必要に応じて、ワークスペース内に用途に合ったファイル名でコピーして使用してよい

### グローバル Prompts / Agents / Instructions

- `%APPDATA%\Code\User\prompts\` 配下に配置
- ワークスペース固有のものは各リポの `.github/prompts/` に配置

## 拡張機能ストレージ

- `%APPDATA%\Code\User\globalStorage\` — グローバル拡張機能データ
- `%APPDATA%\Code\User\workspaceStorage\` — ワークスペース別データ

## GitHub CLI 認証

- VS Code ターミナルで `gh` を使って private repo にアクセスする際、`Could not resolve to a Repository` や scope 不足が出たら、repo 名や remote を疑う前に `gh auth status` で active credential を確認する
- `GITHUB_TOKEN` / `GH_TOKEN` 環境変数が設定されていると、keyring に保存された高権限認証より優先されることがある
- そのシェルだけ保存済み認証を使いたい場合は、`$env:GITHUB_TOKEN=$null; $env:GH_TOKEN=$null` を設定してから `gh` を再実行してよい
- private repo の PR/Issue 確認で認証が怪しいときは、`gh pr list -R <owner>/<repo> ...` のように `-R` を明示して切り分けてよい

## Web検索のフォールバック

- Brave などの Web 検索ツールが同一タスク内で 3 回以上連続してエラーになった場合は、Web 検索不能と決めつけず、代替手段を試す
- フォールバック手段として `copilot -p "{クエリ}" --allow-all-tools --allow-all-urls --available-tools web_search --silent` を優先して使用してよい
- URL 列挙が目的のときは、プロンプト内で「URL のみを 1 行 1 件で返す」「説明文や番号は出さない」「必要なら件数を明示する」と指示する
- CLI 出力に前置き文が混ざることがあるため、機械処理に使うときは URL 行のみ抽出して扱う

## CLI 検索ツール

- Windows 環境で高速な全文検索が必要な場合は、`Select-String` より `ripgrep` (`rg`) を優先してよい
- 未導入なら `winget install --id BurntSushi.ripgrep.MSVC --scope user --accept-source-agreements --accept-package-agreements` でユーザースコープに導入してよい
- 導入直後のシェルで `rg` が見つからない場合は、ターミナルを再起動するか、`$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')` で PATH を再読込してよい
- PowerShell で `rg` の日本語出力が文字化けする場合は、`[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)` と `$OutputEncoding = [Console]::OutputEncoding` を先に設定してよい
