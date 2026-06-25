---
description: "Microsoft 365 内のメール、会議、Teams、共有ファイル、WorkIQ での所在確認や顧客案件運営情報を扱うときに使う手動参照ルール"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Microsoft WorkIQ Instructions

Microsoft 365 内のメール、会議、Teams、共有ファイルなど、組織内データに閉じた所在確認で使う。製品仕様、制限、API、リリース時期の確認は扱わない。

## When to Use

- 使う: 顧客案件の kickoff 日程、会議体分離、次回スコーピング、録画共有元、開催通知メールを確認するとき。
- 使う: Teams チャット、メール、OneDrive / SharePoint 共有ファイルの所在を確認するとき。
- 使わない: Microsoft / Azure / M365 の仕様、制限、API、GA / Preview / Retirement を確認するとき。

## Core Rules

- M365 に閉じた運営情報は、ローカルファイル探索だけで決め打ちせず `mcp_workiq_ask_work_iq` を併用する。
- WorkIQ の回答が大きい、または話題が広い場合は、日付、会議名、顧客名ごとにクエリを分割する。
- クエリには `5項目以内`、`簡潔に`、`根拠ファイル/会議名も含めて` のように出力粒度を明示する。
- WorkIQ は所在確認に強いが、最終成果物ではローカル議事録、内部メモ、受領資料と突き合わせて確定情報だけを残す。

## Safety

- WorkIQ の返答は private M365 data として扱う。
- 顧客向け成果物や公開資料には、会議 URL、内部メール本文、個人名、未公開ファイル URL をそのまま貼らない。
- 必要な場合は、generation notes や作業メモにだけ根拠を残し、本文では抽象化する。