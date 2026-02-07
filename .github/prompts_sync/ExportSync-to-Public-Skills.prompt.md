---
description: "セッションから得られた知見を 00_Ag-SkillBuilder のスキル・エージェントに反映し、公開リポジトリに同期"
---

<!-- syncToGlobal: true -->

# 知見反映 & 同期

セッションで得た知見をスキルリポジトリに反映し、公開リポジトリに同期します。
**環境固有情報・顧客情報は含めないこと。**

## リポジトリ

| 用途         | パス                                           |
| ------------ | ---------------------------------------------- |
| プライベート | `D:\03_github\00_VSC_tools\00_Ag-SkillBuilder` |
| 公開用       | `D:\03_github\Agent-Skills`                    |

## 反映先

| 種別               | パス                    |
| ------------------ | ----------------------- |
| スキル             | `.github/skills/`       |
| エージェント       | `.github/agents/`       |
| インストラクション | `.github/instructions/` |
| プロンプト         | `.github/prompts/`      |

## 手順

1. セッションから汎用的な知見を抽出
2. 反映先ファイルを特定し、ユーザー承認を得る
3. プライベートリポジトリに反映してコミット＆プッシュ
4. 公開用リポジトリにコピー＆コミット＆プッシュ:
   ```powershell
   Copy-Item "D:\03_github\00_VSC_tools\00_Ag-SkillBuilder\.github\skills\*" "D:\03_github\Agent-Skills\skills" -Recurse -Force
   ```
