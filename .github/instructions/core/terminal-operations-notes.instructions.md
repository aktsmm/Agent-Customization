---
description: "ターミナル操作の低頻度トラブルシュートメモ。VSCE 拡張機能 publish (vsce publish / VSCE_PAT / VSIX) 、Chrome Web Store publish (CWS)、CDP、stale token、stdout capture、Edge profile、SPA dialog などを必要時に参照する"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Terminal Operations Notes

ターミナル操作の低頻度・具体的なハマりどころを置く手動参照メモ。日常の PowerShell 実行規約や安全操作は扱わない。

## Shell Recovery

- 同じ read-only 検証や確認コマンドが共有 shell で 2 回以上飲まれたり、`>>` が続く場合は、その shell での再試行を打ち切り、read-only な subagent や別の非共有実行経路へ切り替えてよい。
- `rg` 導入直後のシェルで `rg` が見つからない場合は、ターミナル再起動か、`$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')` で PATH を再読込してよい。
- read-only な audit / sync / verify で長い quoted payload や here-string が見えている場合は、共有 shell の復旧待ちを前提にせず、最初から一時 script、clean な one-shot shell、または read-only subagent を選んでよい。

## Output and Completion

- `run_in_terminal` の sync 実行が `Command produced no output` を返したり、async 実行が prompt 復帰前に idle した場合も、直ちに失敗扱いにせず expected artifact を先に確認する。artifact が生成済みなら render/capture 問題として扱い、未生成なら dedicated terminal や短い follow-up command で観測を補強する。
- 長い `npm` / `node` / test suite で stdout capture が不安定な場合は、`cmd /c "... && echo OK"` や `Write-Output "name-exit=$LASTEXITCODE"` のような success marker を付け、末尾の marker か exit code を正本にする。`> $null` や `Select-Object -Last N` を使う場合も marker か exit code の確認を省略しない。
- PowerShell script を編集した後は、`[scriptblock]::Create((Get-Content -Raw -Encoding UTF8 <file>))` で構文確認してから実行する。

## Credentials and Environment

- token 依存 CLI で Process と User の環境変数が食い違うときは、手順書で「環境変数を更新してから再実行」と繰り返すより、repo 側に Process 値を先に検証し、失効・不一致なら User 環境変数へ自動 fallback する wrapper script / npm script を追加する方を優先する。例: `VSCE_PAT` を使う `vsce verify-pat` / `vsce publish`。
- Azure CLI で `az account set` が対象 subscription を見失っても、対象 tenant の ARM token が取れる場合は、追加ログインより `az account get-access-token --tenant <tenantId>` + REST 経路を優先する。token 本体は保存・表示しない。
- wrapper が無い既存 workflow を一時的に回す場合でも、stale な Process 値を前提にしない。同じコマンド実行内で `[System.Environment]::GetEnvironmentVariable('<NAME>','User')` を読み直して明示引数や `$env:` に渡す。

## Extension Publish (VSCE / CWS)

拡張機能 publish（VS Code Marketplace `vsce publish`、Chrome Web Store CWS publish）で踏むハマりどころ。

### 共通 Gate

- publish 前の gate（lint / test / build / package / verify-pat / publish）は、shared shell に長い `;` 連結で流さず、**dedicated terminal で 1 コマンドずつ** 実行する。途中の 1 ステップ失敗が後続出力に埋もれると原因追跡が難しくなる。
- 同じ SaaS 管理画面（Azure DevOps PAT 設定、Chrome Web Store Dashboard、GCP Console）を操作するコマンドは、競合を避けるため直列実行を優先する。

### VSCE 固有

- `vsce verify-pat` が PASS でも `vsce publish` が `PAT expired` で落ちる場合、Azure DevOps PAT の Expiration が発行当日 (`Custom defined` 既定) の定番ケースを疑う。`1 year` に伸ばし、`Marketplace > Manage` スコープを含めて再発行する。
- VS Code 起動済みシェルでは `$env:VSCE_PAT` は起動時 env を継ぐ。User scope を更新しただけでは Process に反映されず、`[System.Environment]::GetEnvironmentVariable('VSCE_PAT','User')` で読み直して `-p $pat` に渡すと通る。
- VSIX 生成は拡張 directory へ移動してから `vsce package --out <file.vsix>` で出力する。`--packagePath` や末尾引数で directory を渡す運用は失敗しやすい。
- VS Code 拡張の local 修正版を実機確認するとき、`Developer: Reload Window` だけでは workspace の未インストール変更は読まれず、既に入っている Marketplace / VSIX 版を再読込するだけのことがある。`code --install-extension <generated.vsix> --force` で入れ直してから reload するか、Extension Development Host (`F5`) を使う。
- `vsce publish` 直後は `vsce show --json` や Marketplace page のバージョン表示が stale なことがある。publish 成功出力、remote tag、GitHub Release、Marketplace page の更新時刻など別経路の証跡を先に確認し、stale 表示だけで再 publish や追加 version bump しない。

### CWS 固有

- Chrome Web Store API の Refresh Token はテストモードで 7 日間有効。期限切れで publish が落ちたら OAuth 同意画面から再取得する。
- `CWS_CLIENT_ID` / `CWS_CLIENT_SECRET` は User scope 環境変数が正本。`.env.submit` を repo に commit しない（`.gitignore` で除外）。

## Browser and CDP

- 既存ブラウザの認証状態を使う CDP 起動では、認証が特定プロファイルに紐づく場合 `--profile-directory=<known profile>` を優先し、場当たり的な `--user-data-dir` 新設は避ける。別ログイン状態と大量キャッシュを生みやすい。
- Edge が既に CDP ポート付きで起動済み（例: `--remote-debugging-port=9222 --profile-directory=Default`）のとき、別プロファイルが必要なら同じ user-data-dir の Edge をポート指定なしで起動する（`msedge.exe --profile-directory="Profile 2" <url>`）。新ウィンドウが同一プロセスに合流し、既存 CDP ポートで両方のプロファイルタブにアクセスできる。全 Edge を `Stop-Process` する必要はない。
- CDP `Page.navigate` はハッシュベース SPA（`#/path`）のルート遷移に無効（SPA ルーターが反応しない）。`Runtime.evaluate` で `location.href='<hash-url>'` を代入するか、in-page のリンク click を使う。
- 未保存変更がある SPA を CDP でリロード / 再ナビすると native の `beforeunload` 確認ダイアログが出て `Runtime.evaluate` がブロックされる。`accept:true` で閉じると再リロードから連鎖ダイアログを生み、さらにそのダイアログを開いた CDP セッションが閉じると別接続から `Page.handleJavaScriptDialog` が効かないことがある。dirty な SPA ではリロードを避け、overlay は Escape / Cancel で閉じてクリーン状態を保ったまま操作する。孤児化したら 1 回だけユーザーに手動 Cancel を依頼する。