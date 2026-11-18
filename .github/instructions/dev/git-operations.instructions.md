---
description: "Git 操作ルール（push 禁止、Conventional Commits、gh CLI）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-11-19 -->

# Git Operations Instructions

## Core Rules

- 明示指示なしの `git push` は禁止（コミットまで可）。同じ repo を自動 push する別プロセス（scheduler の cycle 等）があれば自分の commit も公開されるため、公開させたくない commit は pusher の有無を確認してから作る。
- Git 管理下で、そのワークスペースがコミットを明示的に禁止していなければ、作業がひと段落したタイミングで自分の変更だけを適度にコミットしてよい（都度の許可は不要）。add 前に自分の変更か確認し、他の変更が混在するときは分類して確認する。
- 別 worktree で動く自動実行では、着手前に利用先の checkout・ブランチ・基準コミットを照合する。依頼に反映が含まれる場合は、作業側の保存・コミットを完了とせず、利用先で対象ファイルと反映コミットを検証する。競合や他の未コミット編集があれば上書きせず、未反映として報告する。
- `git push` 前は対象 remote を `git fetch` し、`git rev-list --left-right --count 'HEAD...@{upstream}'` などでahead/behindを再計算する。stale tracking refや記憶上の状態を根拠にpushしない。
- GitHub への接続で SSH が利用可能なときは、HTTPS より SSH を優先する（既存 remote も必要に応じて SSH へ切り替える）。
- ローカル未展開での軽微な操作・変更は `gh api` を優先する（機能・Docs・repo / Issue / PR の調査は GitHub MCP でよい）。
- 成果物に絶対パスを埋め込まない（相対パスで扱う）。
- Playwright MCP はワークスペース直下に `.playwright-mcp/`（console log / snapshot）を生成し、自動 commit などで履歴へ混入する。ブラウザ自動化を使う repo は初回に `.gitignore` へ追加し、追跡済みなら `git rm -r --cached -- .playwright-mcp` で外す（ファイルは残る）。完了前に自分が作った未追跡分は `git clean -n` で確認してから削除する。
- Git hook は `.sample` のままでは実行されない。クローン再現性が必要な場合は、repo 管理下（例: `hooks/pre-commit`）に実体を置き、README で `.git/hooks/` へのコピー手順を案内する。
- 公開同期、repo visibility、`.github` / `.vscode` の公開判断は、実行前に対象と公開範囲を確認し、必要時は `git-publish-policy.instructions.md` を参照する。

## Submodules

- Submodule の内部変更は親から直接コミットせず、子リポジトリで commit・検証した後に、親で更新された gitlink を stage・commit する。親の `git status` が submodule path だけを変更として示すことを確認し、push は各リポジトリで別々に扱う。

## Release Sanity

- release / publish 前に、対象 version が registry に既に存在しないかを確認する。存在する場合は同じ version を再利用せず、HEAD に合わせて patch 以上を上げる。
- release tag を作る前に、その tag が指す commit と現在の HEAD を比較する。既存 tag が HEAD より古いなら tag の付け替えではなく version bump で進める。
- package publish では ignore 設定や packer の想定を信じ切らず、実 tarball の中身を列挙して runtime artifact だけが入っていることを確認する。
- npm package の `files` を使う repo では、必要な runtime artifact を include pattern で明示し、sourcemap などの開発資材が混入しないことを pack 後に確認する。

## Issue-Linked Delivery

- ユーザーが Issue に紐づく release / PR / merge を明示指示した作業は、配布・マージの完了を実物（公開物のバイト照合、merge 済み commit など）で確認してから、その Issue へ結果をコメントし、完了なら閉じる。この指示範囲内の Issue 操作に追加の確認はしない。release 指示のない push / tag / publish は行わず、Issue も閉じない。
- コメントは Issue の言語に合わせ、release / commit / PR へのリンクと、確認できた検証・未検証を分けて書く。未確認を検証済みと書かない。
- 一部のチャネルだけ公開、失敗、未照合、PR 未マージなどの部分状態では閉じない。部分状態と再開条件を報告する。
- 閉じる順序は コメント → `gh issue close --reason completed` とし、投稿後に state とコメント数を読み戻して確認する。PR 作成だけでは完了扱いにしない。

## Conventional Commits

- 形式: `<type>(<scope>): <subject>`
- 主な type: `feat` `fix` `docs` `refactor` `test` `chore`
- subject は命令形・簡潔・文末ピリオドなし。
- 必要なら ` - <user.name>` を末尾に付与してよい。
- PowerShell で `git commit -m` を使う場合、メッセージはシングルクォートで囲む（`(scope)` の括弧がサブ式として評価されるため）。
- 日本語を含む commit message は `-m` に渡さず、UTF-8 ファイルへ書いて `git commit -F <file>` を使う。PowerShell から渡すと cp932 経由で文字化けしたまま保存される。確認は `git log` の表示ではなく、保存されたバイトを UTF-8 として decode して判定する。

## Destructive Operations

- `git filter-repo` / `git rebase -i` / `git reset --hard` 前に未コミット変更を必ず確定する。
- `HEAD.lock` / `couldn't set HEAD` / `unable to unlink` など同じGit更新失敗の対話promptが2回続いたら`n`で停止する。HEAD・status・diff・rebase/merge metadataを確認し、Windowsのfile lockはHandle / Process Explorerで所有processを特定する。未コミット変更を保護するまでrebase、blanket restore、lock削除を続けず、handleを強制closeしない。
- `git restore <file>` / `git checkout -- <file>` は、そのファイル内の無関係な未コミット変更も巻き戻す。restore 後は対象ファイルの diff を再確認し、巻き戻したくない変更（例: 別作業の編集）が消えていないか確認する。
- `git stash` だけに依存しない。
- 別作業や別セッションの変更が同居しうるときは、add 後・commit 前に `git diff --cached --stat` で対象と行数が想定どおりか確認する。単一ファイルの add でも、同じファイルの別作業の変更を巻き込む。pathspec なしの `git commit` は他者が stage 済みの変更も含める。乖離したら `git restore --staged <file>` で戻す。
- 大量の `git status` 出力に対しては、`git add -A` 前に「自分が触ったもの」「別ツール由来（skill 同期、formatter、別 IDE）」「未追跡の一時ファイル」を分類してユーザーに確認する。混在 dirty を一括で commit すると、後で範囲を分離するのが困難になる。
- `GIT_INDEX_FILE` の一時 index で commit する自作 script は、commit 前に一時 index の存在と、staged 削除が依頼パス内だけであることを検証する。index が消えると全ファイル削除の空ツリー commit になる。大量 commit 後は `git ls-tree -r HEAD --name-only` の件数が減っていないか確認する。空ツリーが紛れたら履歴を書き換えず、直前の正常ツリーに後続の版を重ねた tree を `git commit-tree` し、旧値指定の `git update-ref` で進めて修復する。

## Encoding

- 日本語を含むファイルは `UTF-8`（PowerShell では `Get-Content -Raw -Encoding UTF8`）で扱う。
- GitHub API 向け JSON は BOM なし UTF-8 を使う。
- `git show <rev>:<binary-path>` を PowerShell 7 でファイルに保存するときは、`Out-File -Encoding byte` が廃止されているので使わない。`cmd /c "git show <rev>:<path> > `"$tmp`""` にリダイレクトするか、`git cat-file -p <rev>:<path>` を `[System.IO.File]::WriteAllBytes` と組み合わせて raw のまま書き出す。パイプで PowerShell に通すと text 変換されて binary が壊れる。

## gh CLI

- private repo、release、PR/Issue 操作で権限エラーや `Repository not found`（VS Code の同期ボタン含む）が出たら、repo 名を疑う前に `gh auth status` で active account と credential を確認し、必要なら `gh auth switch -u <owner>` で戻す。
- `GITHUB_TOKEN` / `GH_TOKEN` が keyring 認証を上書きしている場合は、そのシェルだけ両変数を `$null` にして再確認してよい。
- GitHub API は成功するのに clone / push が失敗する場合は、Git transport の credential を切り分ける。PR/Issue 確認では `-R <owner>/<repo>` を明示してよい。
- `gh api` は `-f` / `-F` を付けると既定が POST になり、`search/issues` などの GET 専用 endpoint が private repo で 404 になる。読み取りは `-X GET` を明示する（repo 不在や権限不足と誤判定しない）。
- `Resource protected by organization SAML enforcement`（HTTP 403）は microsoft / MicrosoftDocs など SAML 必須 org の未認可で、repo 不在や削除ではない。エラー出力の SSO 認可 URL をユーザーに承認してもらい、別 token や別経路で迂回しない。認可前でも `gh search`（repo 指定なし）は公開項目を返すが、`--repo` 付き検索と `gh api` / `gh issue view` は失敗する。検索結果に出ないことを「クローズ・削除済み」の根拠にせず、個別に取得して 403（未認可）・410（削除）・state で切り分ける。外部起票を数えるときは bot が大量起票する自分の自動化リポを `-- '-user:<自分>'` で除外する（`--limit` に埋もれる）。
- 長いマークダウンを `--body` で直接渡すとシェルの問題が起きやすいので、`--body-file` でファイル経由で渡す。

