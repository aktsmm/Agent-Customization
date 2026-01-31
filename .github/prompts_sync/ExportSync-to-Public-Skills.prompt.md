---
description: "セッションから得られた知見を 00_Ag-SkillBuilder`のスキル・エージェントに反映し、公開リポジトリに同期"
---

# 知見反映 & 同期

## Phase 1: 知見の抽出

このセッションでSKILL 向けの汎用的な得られた知見・学びを特定してください：

- 新しいパターン・ベストプラクティス
- 失敗から学んだアンチパターン
- ツール使用のコツ・注意点

ただし、環境固有情報、顧客情報は含めないでください。

## Phase 2: 反映先の特定

**反映先リポジトリ:** `D:\03_github\00_VSC_tools\00_Ag-SkillBuilder`（プライベート）

以下のディレクトリから知見を反映すべきファイルを特定：

| 種別               | パス                    | 反映対象                         |
| ------------------ | ----------------------- | -------------------------------- |
| スキル             | `.github/skills/`       | 設計原則、チェックリスト、ガイド |
| エージェント       | `.github/agents/`       | 行動指針、制約条件               |
| インストラクション | `.github/instructions/` | ドメイン別ルール                 |
| プロンプト         | `.github/prompts/`      | 再利用可能なワークフロー         |

## Phase 3: ユーザー確認

反映予定の内容を提示し、**ユーザーの承認を得てから**次に進む：

```
📝 反映予定:
- [ファイルパス]: [反映内容の要約]
- [ファイルパス]: [反映内容の要約]

この内容で反映してよいですか？ (y/n)
```

## Phase 4: 知見の反映

特定したファイルに知見を追記・更新：

- 環境固有情報・顧客情報は含めない
- 汎用的な形で記述
- 既存の構造・フォーマットに従う

## Phase 5: コミット & プッシュ（プライベート）

`00_Ag-SkillBuilder` で反映したファイルを Git にコミット＆プッシュ：

1. `Set-Location "D:\03_github\00_VSC_tools\00_Ag-SkillBuilder"`
2. 未保存ファイルを保存
3. `git status` で変更確認
4. 日本語でわかりやすいコミットメッセージを作成
5. `git add . && git commit && git push`

## Phase 6: 公開用リポジトリへの同期

スキルを公開用リポジトリにコピー：

**公開用リポジトリ:** `D:\03_github\Agent-Skills`

```powershell
$source = "D:\03_github\00_VSC_tools\00_Ag-SkillBuilder\.github\skills"
$target = "D:\03_github\Agent-Skills\skills"
if (Test-Path $source) { Copy-Item "$source\*" $target -Recurse -Force }
```

公開用リポジトリでもコミット＆プッシュ：

1. `Set-Location "D:\03_github\Agent-Skills"`
2. 未保存ファイルを保存
3. `git status` で変更確認
4. 日本語でわかりやすいコミットメッセージを作成
5. `git add . && git commit && git push`

## 完了確認

- 反映した知見のサマリーを表示
- コミット＆プッシュ結果を確認
