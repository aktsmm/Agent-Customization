---
description: "Microsoft 365 の照会・操作と Scheduler の定期収集で使う。WorkIQ の対話時クラウド優先・定期実行時 CLI 優先、schema確認、読み戻しを扱う"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-10-12 -->

# Microsoft WorkIQ Instructions

メール・予定・Teams・共有ファイル・人や組織、顧客案件の確認と、依頼された下書き・予定等の作成・更新で使う。製品仕様・API仕様・提供時期の調査は扱わない。

## Connection

- 対話時はクラウドHTTP MCPを優先する。
- Copilot Scheduler 等の無人・定期実行の読み取り収集は、最初からローカルCLI／stdio MCPを選ぶ。この定期収集ではクラウドやブラウザへの自動切替を禁止し、要求された原文・一覧等をローカルで取得できなければ未確認として停止する。
- 必要なMCPツールが非公開なら、自然言語の照会には利用可能な `workiq ask` を使える。
- 接続ごとに現在の公開ツールを確認し、選択した接続のツールだけを使う。以下のMCP用ルールをCLI照会のためにクラウドで実行しない。CLIを自動削除しない。

## Queries

- MCPでは所在・原文の探索は `retrieve`、既知エンティティは `fetch`、根拠未提供の統合要約・推論の委譲は `ask`。提供済み資料で足りれば再照会しない。
- 選択したMCPで、不明なパスは `search_paths`、作成・更新・削除・actionの前は `get_schema`。必要なツールがなければ操作は未確認とする。
- 取得は `$select` と少数の `$top` で絞り、独立した既知項目は `fetch` で一括取得してよい。未知の論点は1論点1照会とし、日付・会議・案件、件数上限と根拠を指定する。
- `InefficientFilter` 対策は `$orderby` を外す。`$search` のメールIDが404なら `conversationId` で現在のIDを引き直す。
- 人・組織は現在のPeople／managerで氏名・所属・メール・階層を確認する。過去CCや役職でM1／M2を推測しない。漢字名は過去の実成果物を照合し、根拠がなければ英字のまま。社内呼称とプロフィール表示名を区別する。
- ユーザーの404は `/users?$filter=mail eq '<address>'` でidを引き直す。グループは `/groups?$filter=mail eq '<address>'`。`$filter`値はURLエンコードし、managerは `/users/{id}/manager` で1段ずつたどる。

## Mutations

- 依頼された対象・操作だけを変更する。読み取りの事前承認は書き込み・EULA同意を代替しない。削除等は個別確認が必要。メールは送信せず下書き保存まで。
- 本人・既存状態・重複を確認し、状態を独立確認できなければ変更しない。変更後は返されたIDを選択したMCPの `fetch` で読み戻し、依頼内容と照合する。
- 予定は日時・タイムゾーン・参加者・リマインダー・公開範囲を照合し、UTCは指定タイムゾーンへ換算する。テスト予定の未指定項目は参加者なし・リマインダーなし・非公開・空き時間扱いとし、既存予定を変更しない。

## Evidence

- 生成回答を逐語引用や原文・完全な一覧として扱わず、原文を確認して `retrieve` の引用を保持する。確定事項は受領資料・議事録とも照合する。
- 空振り・限定ページ・期間外・`Expired` は活動0件や未実施の証拠にしない。対象期間・取得範囲・制限・未取得理由を残し、未取得は未確認、過去データは今回の取得成功としない。
- 設定の存在・別接続の成功・作成成功の返答だけで、未検証の操作を完了・送信済みとしない。
- 予定登録と参加・成果、内部作成と対外送付、本人申告と独立確認を区別する。本人が送信を報告したら重複送信を避け、時刻・ヘッダー・承認を推測しない。
- Teamsの全投稿・返信は既知スレッド、channel ID・日時・返信のparentMessageId・本文を照合する。矛盾や網羅性を確認できなければ未確認とする。

## Stop Conditions

- 無人実行で再認証・MFA・EULA同意・拒否が必要なら収集を停止する。認証待ち・同意待ち・権限不足を区別し、未取得理由を通知する。
- 明示的な拒否は別経路・言い換え・再試行で回避しない。対話時のみ、独立した許可対象を上限付きで続行できる。
- 同じ実行経路の別runが追加認証なしに完了するまで、無人運用の復旧は未確認とする。

## Interactive Alternatives

以下は対話時に必要なMCP機能が不在の場合だけ使い、拒否の回避には使わない。

- ファイル取得・保存: 承認済みブラウザでSharePoint RESTの `GetFolderByServerRelativeUrl(...)/Files` または `_api/search/query` を使える。Azure CLIトークンのファイル権限を保証せず、403を無条件に再試行しない。
- ディレクトリ: `az account get-access-token --resource https://graph.microsoft.com` 等の承認済み認証で権限を確認し、Graphのユーザー・manager・グループを照会できる。トークンは表示・保存せず、ファイルの403からディレクトリも不能としない。

## Safety

- WorkIQ の返答は private M365 data として扱う。
- 顧客向け成果物や公開資料には、会議 URL、内部メール本文、個人名、未公開ファイル URL をそのまま貼らない。
- 必要な場合は、generation notes や作業メモにだけ根拠を残し、本文では抽象化する。

公式仕様の更新確認: [クラウドMCP](https://learn.microsoft.com/ja-jp/microsoft-365/copilot/extensibility/work-iq/mcp/overview)、[CLI](https://learn.microsoft.com/ja-jp/microsoft-365/copilot/extensibility/work-iq/cli)。実行時のschema・権限・テナントポリシーを優先する。