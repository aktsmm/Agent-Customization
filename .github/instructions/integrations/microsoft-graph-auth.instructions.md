---
description: "Microsoft Graph の委任認証、Azure CLI / Connect-MgGraph、AADSTS65002、管理者承認、Conditional Access、device code、scope 確認を扱うときに使う"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-09-16 -->

# Microsoft Graph Delegated Authentication

Microsoft Graph の委任認証と consent failure の切り分けに使う。Graph API の機能仕様やメール運用ルールは扱わない。

## Authentication

- device code flow は既定で使わない。通常の browser interactive flow を使い、Conditional Access が拒否したら別の device code 経路へ切り替えず停止する。
- 必要な delegated scope だけを要求する。失敗時に `Mail.Send`、application permission、より強い scope へ切り替えない。
- Azure CLI の subscription / tenant login と、対象 Graph scope への consent は別状態として確認する。テナント切り替え成功だけで Graph 権限取得済みと判断しない。

## Failure Routing

- `az login --scope https://graph.microsoft.com/<scope>` が `AADSTS65002` を返した場合、Azure CLI の first-party client と Graph resource 間の preauthorization 不足として扱う。テナント切り替えや同じ login の反復では解決しないため、その client を使う経路を停止する。
- `Connect-MgGraph -Scopes <scope>` の browser interactive flow が管理者承認を要求した場合、tenant consent policy の制約として停止する。必要な app 名、delegated scope、対象 tenant、管理者承認が必要な旨だけを報告する。
- 管理者承認が得られない場合、application permission、別 app、UI automation などへ暗黙に迂回しない。

## Token Safety And Verification

- access token の値や token CLI の生出力を表示・保存しない。
- `Get-MgContext` の account、tenant、scopes、またはメモリ内で decode した JWT の `tid` / `scp` だけを確認する。
- 操作前に account、tenant、要求 scope の存在を確認する。権限上限が重要な場合は、不要な scope が含まれていないことも確認する。
- 認証が完了していなければ、Graph API の変更要求を実行済みと報告しない。