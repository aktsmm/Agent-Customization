---
description: "セッションから得られた知見を 00_Ag-SkillBuilder のスキル・エージェントに反映し、公開リポジトリに同期"
---

<!-- syncToGlobal: true -->

# 知見反映 & 同期

セッションで得た知見をスキルリポジトリに反映し、公開リポジトリに同期します。
**環境固有情報・顧客情報は含めないこと。**

## リポジトリパス

| 用途         | パス                                           |
| ------------ | ---------------------------------------------- |
| プライベート | `D:\03_github\00_VSC_tools\00_Ag-SkillBuilder` |
| 公開用       | `D:\03_github\Agent-Skills`                    |

> ⚠️ 別ワークスペースから実行する場合、上記パスが存在するか必ず確認すること。
> 存在しない場合は `gh repo clone aktsmm/Ag-SkillBuilder` などでクローンしてから作業すること。

## 反映先（プライベートリポジトリ内）

| 種別               | パス                    |
| ------------------ | ----------------------- |
| スキル             | `.github/skills/`       |
| エージェント       | `.github/agents/`       |
| インストラクション | `.github/instructions/` |
| プロンプト         | `.github/prompts/`      |

## 公開対象スキル（blacklist 方式）

**SSOT は `Sync-AndPush.ps1` の `$ExcludeSkills` 配列**。
`.github/skills/` 配下のスキルは `$ExcludeSkills` に含まれない限り**すべて自動的に公開対象**となる。

**新しいスキルを非公開にしたい場合は `$ExcludeSkills` に追加する。**
非公開にすべきケース：

1. 外部由来でライセンス未確認
2. 顧客情報・社内情報を含む
3. 開発中で公開品質に達していない

## 手順

1. セッションから汎用的な知見を抽出する
2. 反映先ファイルを特定し、ユーザー承認を得る
3. プライベートリポジトリに反映してコミット＆プッシュ

4. **公開用リポジトリへの同期は必ず `Sync-AndPush.ps1` を使う**（直接コピーは禁止）:
   ```powershell
   cd D:\03_github\00_VSC_tools\00_Ag-SkillBuilder
   .\scripts\Sync-AndPush.ps1 -Message "sync: <変更内容の説明>" -SkipDevPush
   ```

   > ❌ **禁止**: 手動で `Copy-Item ... Agent-Skills\skills\` は使わない（二重ネストの原因）
   > ✅ **正しいコピー先**: `Agent-Skills\` 直下（`skills\` サブフォルダではない）

5. 同期後、公開リポジトリの構造を確認:
   ```powershell
   ls D:\03_github\Agent-Skills | Select-Object Name
   # skills/ フォルダが存在したらバグ → 即削除して git push
   ```
