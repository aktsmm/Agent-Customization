---
applyTo: "**"
---

<!-- description: PowerPoint COM 編集の原則・レビュー基準・デザイン規約 -->

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# PowerPoint Editing Instructions

PowerPoint を COM Automation で編集する際のルールとデザイン基準です。

## 1. COM Automation の基本

- ファイルが開いている場合は必ず **COM Automation**（python win32com）を使う。python-pptx はロックエラーになる
- COM はスライド **1-indexed**、python-pptx は 0-indexed
- 日本語テキストは Python スクリプト + `python -X utf8` で実行（PowerShell のスマートクォート問題を回避）
- 色は **BGR形式**: `#0078D4` → `0xD47800`
- `Font.Bold = -1`（msoTrue）。`$true` ではない
- **日本語フォント置換は `Font.Name` だけでは不十分**: 和文表示は `NameFarEast` が優先されることがある。フォント統一時は `Name` / `NameAscii` / `NameFarEast` / `NameComplexScript` をまとめて設定する
- **スライドマスター / レイアウトも更新する**: 本文シェイプだけ更新しても `SlideMaster` / `CustomLayouts` に旧フォントが残ると、プレースホルダーの再編集や新規入力で見た目が旧フォントへ戻ることがある
- 新しいファイルを作るのではなく、**既存ファイルを直接編集**すること（ユーザーはファイルが増えるのを嫌がる）
- 編集後は `pres.Save()` で上書き保存
- **OneDrive 保存リトライ**: `pres.Save()` が OneDrive 同期と衝突してエラーになることがある。`time.sleep(2)` 後にリトライで解決する
- 段落区切りは `\r`（chr(13)）を使う。`\n` は段落として認識されない場合がある
- **テキスト追記は `InsertAfter()` を使う**: `TextRange.Text = "..."` による全文上書きはフォーマット（太字・色・サイズ）が全て消失するため禁止。段落を追加する場合は `Paragraphs(n).InsertAfter(chr(13) + "new text")` を使い、追加テキスト末尾にも `chr(13)` を付けて次段落との結合を防ぐ
- **参照URLの単一リンクは Shape レベルを優先**: 参考欄のように TextBox 全体が 1 URL を指す場合は `Shape.ActionSettings(1).Hyperlink.Address` と `(2)` を使う。文字単位リンクより安定し、クリック領域も明確
- **複数URLは 1 URL 1 TextBox に分ける**: 1 つの TextBox に複数 URL を入れるとクリック付与・監査が不安定になりやすい。確実に clickable にしたいときは URL ごとに Shape を分ける
- PowerShell 7+ (.NET Core/5+) では `[Marshal]::GetActiveObject` が削除されている。開いている PPTX への COM 接続は Python `win32com.client.GetActiveObject("PowerPoint.Application")` を使うこと

## 2. 箇条書きの統一

- テキストに手動記号（■●→・等）がある場合、`Bullet.Type = 0`（ppBulletNone）に統一する
- 自動箇条書きの非標準 Character が手動記号と共存すると二重箇条書きになるため、`Bullet.Type = 0` に戻す
- 編集完了後に全スライド一括で `Bullet.Type = 0` を監査すると安全

## 3. レビュー時の注意

- 非表示スライドを必ず確認する
- 各表示スライドのノートに導入・目的があるかを見る
- 画像主体のスライドはテキスト量だけで薄いと判断しない
- 構成が概念 → 基礎 → 応用 → 実践になっているか確認する
- スライド移動・挿入後は番号とセクション構成を再確認する
- フォント差し替え後は overflow を全スライドで監査する

## 4. デザイン基準

- 本文 16pt 以上、RefURL・注釈は 13pt 以上
- ■ 見出しは通常 #0078D4 の青で統一
- 本文は黒、ナビゲーションは灰、URL は青 + ハイパーリンクに統一
- 追加スライド後はタイトルスタイルを多数派に揃える

## 5. 参照URL（RefURL）の配置ルール

- 位置は右下、Shape 名は `RefURL`
- フォントは Calibri + BIZ UDPGothic、13pt 以上
- `ページタイトル | URL` または 2 行表示で、必ずタイトルと URL の両方を見せる
- 単一URLなら Shape レベルリンクを優先する
- 完了前に HTTP 到達確認と表示タイトル整合確認を行う

## 6. セクション管理

- `SectionProperties.AddBeforeSlide(slideIndex, name)` で追加する
- 複数日ワークショップは `Day1:` `Day2:` で区別する
- セクション表紙追加後は境界を再設定する
- 大きく再構成した場合はセクション全再構築が安全
