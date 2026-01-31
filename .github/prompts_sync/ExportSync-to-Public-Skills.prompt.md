---
description: ".ghc_template のスキル・プロンプト・エージェントを Public Skills と グローバル設定に同期"
---

# 同期タスク

## 1. Public Skills への同期

**ターゲット:** `D:\03_github\00_VSC_tools\00_Ag-SkillBuilder`

`.github/skills/` 配下のスキルを上記リポジトリに robocopy `/MIR` で同期。
環境固有情報・顧客情報が入らないよう注意。

## 2. グローバル設定への同期

**ターゲット:** `%APPDATA%\Code\User\prompts\`

以下のディレクトリを **すべて prompts フォルダに** 同期：

| ソース | 同期対象 |
|--------|----------|
| `.github/prompts_sync/*.prompt.md` | プロンプト |
| `.github/agents_sync/*.agent.md` | エージェント |

```powershell
$globalPrompts = "$env:APPDATA\Code\User\prompts"
Copy-Item ".github\prompts_sync\*" $globalPrompts -Force
Copy-Item ".github\agents_sync\*.agent.md" $globalPrompts -Force
```

## 3. Instructions への同期（任意）

```powershell
robocopy ".github\instructions_sync" "$env:APPDATA\Code\User\instructions" /MIR
```

## 完了確認

両方の同期完了後、結果サマリーを表示。
