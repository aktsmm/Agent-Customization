---
applyTo: "**"
---

<!-- description: Edge CDP（Chrome DevTools Protocol）接続のパターンと注意事項 -->

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Edge CDP Connection Instructions

既存の Edge ブラウザに CDP（Chrome DevTools Protocol）で接続して操作する際のルールです。

## 1. Edge の起動フラグ

Edge をリモートデバッグ対応で起動するには以下のフラグが**両方**必要:

```
--remote-debugging-port=9223
--remote-allow-origins=*
```

- `--remote-allow-origins=*` がないと WebSocket 接続時に **403 Forbidden** になる
- `--restore-last-session` を付けるとタブが復元される

```powershell
Start-Process 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' `
  -ArgumentList '--remote-debugging-port=9223', '--remote-allow-origins=*', '--restore-last-session'
```

## 2. 接続方法: websocket-client を使う

**Playwright の `connect_over_cdp` は Edge 拡張の Service Worker で assertion エラーが発生するため非推奨。**
`websocket-client` パッケージで直接 CDP WebSocket に接続するのが安定。

```python
import json, websocket, urllib.request

# タブ一覧取得
tabs = json.loads(urllib.request.urlopen('http://localhost:9223/json').read())
page_tabs = [t for t in tabs if t.get('type') == 'page']

# 対象タブに接続
ws = websocket.create_connection(
    target_tab['webSocketDebuggerUrl'],
    timeout=60,
    suppress_origin=True  # Origin ヘッダーを送らない
)
```

### CDP ドメイン有効化

コマンド実行前に必要なドメインを有効化する:

```python
cdp(ws, 'Page.enable')
cdp(ws, 'Runtime.enable')
```

### イベントドレイン

管理センター等の SPA はイベントが大量に流れるため、コマンド応答を受信する際は **id でフィルタ** し、タイムアウトを適切に設定する:

```python
def cdp(ws, method, params=None, timeout=30):
    msg_id = next_id()
    ws.send(json.dumps({'id': msg_id, 'method': method, 'params': params or {}}))
    end = time.time() + timeout
    while time.time() < end:
        ws.settimeout(max(1, end - time.time()))
        try:
            msg = json.loads(ws.recv())
            if msg.get('id') == msg_id:
                return msg
        except websocket.WebSocketTimeoutException:
            continue
    return None
```

## 3. SPA ナビゲーション

M365 管理センター (`admin.cloud.microsoft`) 等の SPA は `Page.navigate` だとページリロードが発生してセッションが切れる。
**`window.location.hash` を変更** して SPA 内遷移する:

```python
cdp(ws, 'Runtime.evaluate', {
    'expression': 'window.location.hash = "#/licenses"',
    'returnByValue': True
})
time.sleep(10)  # SPA の描画待ち
```

## 4. スクリーンショット・テキスト取得

```python
# スクリーンショット
resp = cdp(ws, 'Page.captureScreenshot', {'format': 'png'})
img = base64.b64decode(resp['result']['data'])

# ページテキスト
resp = cdp(ws, 'Runtime.evaluate', {
    'expression': 'document.body.innerText.substring(0, 10000)',
    'returnByValue': True
})
text = resp['result']['result']['value']
```

## 5. Angular/Material の仮想スクロール + モーダル操作パターン

ESXP Week View（Angular + Material）のように virtual scroll で行が随時 DOM 生成/破棄される UI でのクリック自動化。

- **「スクロール → 行検出 → クリック → フォーム出現待機」を単一 async eval_js に統合**: 複数の `Runtime.evaluate` に分割すると境界で要素参照が破棄され、`el.click()` が無反応になる
- **クリック対象は祖先探索**: 対象テキストを持つ最深ノード自身は click ハンドラを持たないことが多い。`getComputedStyle(p).cursor === 'pointer'` を 2-8 世代上まで遡って `candidates` に積み、priority で選ぶ
- **モーダル連鎖操作は毎回開き直し**: Cancel/Close 後の SPA 状態を追うより、`force_close_all_overlays` → `open_tile` → `switch_tab` で既知状態から再開する方が冪等で安定
- **モーダル内コンテンツの日付/週依存性は自動化前に必ず検証**: 「別の日付に切り替えて内容が変わるか」を先に確認。変わらないなら週移動ループは不要

## 6. Windows コンソールから Python + 絵文字出力

Windows PowerShell で Python スクリプトが絵文字・日本語を出力する場合、以下の 3 点セットで `UnicodeEncodeError: cp932` を防ぐ:

```powershell
chcp 65001 | Out-Null
$env:PYTHONIOENCODING="utf-8"
```

```python
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() != "utf-8":
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
```

## 7. よくあるエラーと対処

| エラー | 原因 | 対処 |
|--------|------|------|
| 403 Forbidden on WebSocket | `--remote-allow-origins` フラグなし | Edge を再起動してフラグ追加 |
| Playwright assertion error (Service Worker) | Edge 拡張の SW target を処理できない | websocket-client で直接接続 |
| Runtime.evaluate タイムアウト | ドメイン未有効化 or イベント過多 | `Runtime.enable` + イベントドレイン |
| Page.navigate 後セッション切れ | SPA のフルリロード | `window.location.hash` で遷移 |
| `suppress_origin=True` 必要 | websocket-client が Origin を付与 | 接続時に指定 |
| `el.click()` 無反応（virtual scroll UI） | eval_js 境界で要素参照が破棄 | スクロール+click を単一 async eval_js に統合 |
| 深いネスト UI でクリック不発 | textNode 自身に click ハンドラなし | 祖先を `cursor: pointer` で探索 |
| モーダル連鎖操作の 2 件目以降で失敗 | Cancel 後の SPA 状態が不安定 | 毎回モーダルを開き直して既知状態から開始 |
| `UnicodeEncodeError: cp932` | Windows デフォルトの cp932 エンコーディング | `chcp 65001` + `PYTHONIOENCODING=utf-8` + `sys.stdout.reconfigure` |
