---
name: "visualize-as-infographic"
description: "会話セッションの内容や指定トピックを、X / SNS 投稿向けのカラフルなインフォグラフィック図（HTML→PNG）に複数パターンで起こす。Use when: セッションを図示, インフォグラフィック, フロー図を画像化, X 投稿用の図, infographic, visualize session, ポスター画像作成"
argument-hint: "図示する対象（省略時は直近セッションの要点）、用途（X投稿/スライド等）、パターン数や比率の希望があれば"
agent: "agent"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->

# visualize as infographic

会話セッションの要点（または指定トピック / ファイル / skill）を、**SNS で映えるカラフルなインフォグラフィック図**に起こす。自己完結 HTML を作り、Playwright で PNG 化して複数パターン出力する。

## 入力

- 対象: 引数があればそれ。無ければ **直近セッションの要点**を要約して図の素材にする。
- 用途: 既定は X 投稿用。指定があれば比率・枚数を合わせる。
- 不明点が成果物を大きく変える場合のみ 1 回だけ確認し、それ以外は推測して進める。

## 出力方針

- **2〜3 パターン**作る。型を変える: 例）①横型ステップフロー（16:9, 1200×675）②循環/ループ図（正方形 1200×1200）③一覧+ハイライトパネル（1080×760）。
- 比率は用途で選ぶ: X は 16:9 / 正方形、ブログ OGP は 1200×630。指定があればそれに合わせる。
- 1 パターン = **独立した HTML 1 ファイル**にする（複数を 1 HTML に詰めると要素参照ズレ・見切れが起きる）。
- 保存先は `output/<topic>-diagrams/`。PNG は `<topic>-<pattern>.png`。

## デザイン規約（映え重視）

- ダーク背景（`#0b1020`〜`#0f172a` 系）+ シアン/パープル/ピンクのグラデーション。
- 日本語フォントは Noto Sans JP（Google Fonts を `@import`）。見出し 900、本文 400〜500。
- 角丸カード、絵文字アイコン、番号バッジ、矢印で流れを示す。1 枚で完結し文字は詰め込みすぎない。
- **署名・アカウント名は既定で入れない**。skill 名やライセンス表記は、ユーザーが明示したときだけ端に小さく入れる。

## レンダリング手順（Gotchas 込み）

1. HTML を作る。`html,body` に**ポスター実寸の width/height** を指定し `overflow:hidden`。
2. `file://` は Playwright でブロックされる → 出力フォルダで `python -m http.server <port>` を起動して配信する。
3. ブラウザの viewport をポスター実寸に `browser_resize` し、各 HTML を開いて **`fullPage` でスクショ**する（要素単位 ref はズレやすい。viewport=実寸 + fullPage が安定）。ブラウザ操作 MCP が無効化されている場合は、Python Playwright (`sync_api`) で代替する: `new_page(viewport={w,h}, device_scale_factor=2)` → `page.goto(url, wait_until="load")` → `fullPage` スクショ。Python Playwright は `Path("x.html").resolve().as_uri()` で **`file://` を直接開ける**ので、その場合 http サーバーは不要。`networkidle` は Google Fonts 待ちで不安定なことがあるので `load` + 撮影前 wait を使う。uv 管理 venv は `uv pip install playwright --python .venv\Scripts\python.exe` 後に `python -m playwright install chromium`。`run_in_terminal` が `cd` を落とすことがあるので URL とスクリプトは絶対パスで渡す。
4. フォント描画のため撮影前に 1〜1.5 秒待つ。
5. 生成 PNG は `view_image` で**必ず目視確認**し、見切れ・崩れがあれば実寸かレイアウトを直して撮り直す。番号バッジ（①②…）やステップ順がある図は、**表示順が DOM 順と一致しているか**を必ず見る。CSS grid の `grid-column` / `grid-row` 固定配置は、DOM 順を無視してセルを飛ばし、番号が乱れる原因になりやすい（色や強調だけ付けたいセルに位置固定を併用しない）。
6. 完了後: HTTP サーバーを停止し、ワークスペース直下に出た PNG は出力フォルダへ移動。編集元 HTML は残す。

## 完了報告

- 各 PNG をパス付きで提示し、サイズ・型・用途（X メイン / 2枚組 等）を表で示す。
- どれを投稿に使うと良いかの推奨を 1 つ添える。

## やらないこと

- 文字だけのスライド化（図示が目的）。1 枚に情報を詰め込みすぎない。
- 実在しない数値・引用の捏造。素材はセッション/対象の事実に限定する。
