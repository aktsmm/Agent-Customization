---
name: "cleanup-old-chat-sessions"
description: "Use when: 現在の workspace にある古い未ピン留めのローカル VS Code チャットセッションを、少数は GUI、大量時は承認付き offline cleanup で安全に削除する"
argument-hint: "[保持日数] [--dry-run]（省略時: 5日・apply、承認は着手時に1回）"
agent: "agent"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-08-04 -->

# 古いチャットセッションを安全に削除

現在の workspace に属するローカル VS Code チャットセッションから、保持期間を過ぎ、かつピン留めされていないものだけを削除する。セッションのアーカイブは削除と別操作なので、この prompt では実行しない。

## 引数と実行モード

- 保持日数は引数の正の整数を使い、省略時は `5` 日とする。
- 明示呼び出しを削除承認とみなし、mode 省略時は apply する。`--apply` は互換 alias として同じ扱いにする。
- `--dry-run` がある場合だけ、候補と検証方法を報告して変更せず停止する。
- apply でも read-only preflight は必須。承認は着手時の 1 回にまとめる。実行開始時に offline mode になり得ること（VS Code の close / restart、backup・quarantine 後の local DB 変更、cloud deletion は未確認）を提示して承認を取り、以降は mode 判定やフェーズ移行で再確認しない。
- 引数が曖昧、または `archive` を求めている場合は削除せず確認する。
- cutoff は apply 直前の時刻から保持日数を引き、`lastMessageDate <= cutoff` を「古い」と判定する。

## 対象と正本

- 対象は現在の workspace に対応する `workspaceStorage` のみ。VS Code が公開する user-data location を優先し、取得できない場合だけ platform の storage root 候補を列挙して `workspace.json` の folder URI と現在の workspace を照合する。固定パスや別 workspace の storage を使わない。
- セッション一覧の正本は対象 `state.vscdb` の `chat.ChatSessionStore.index`。ファイルの更新日時を年齢判定に使わない。
- ピン留め状態の正本は同じ DB の `agentSessions.state.cache`。`vscode-chat-session://local/` resource の base64 session ID を構造的に復元し、`pinned: true` の ID を必ず除外する。cache の読取・JSON parse・resource 復元・schema 検証のいずれかに失敗した場合は pin 状態不明として削除を停止する。正常に全件解析できた空の pin set は許容する。
- `archived: true` はピン留めを意味せず、表示から隠す状態であって永続保護ではない。未ピン留めならアーカイブ済みセッションも候補になり得る。
- 検索・要約用の session store は pin 状態や VS Code の削除実体の正本ではないため、候補判定や削除に使わない。
- `github.copilot.sessionSync.*` は検索用 session store / cloud mapping の操作であり、local chat history 削除の代用にしない。

## 安全な判定

最初に read-only で次を集計し、apply では削除直前にも再計算する。

- workspace に属する local session ID、title、`lastMessageDate`、`isEmpty`、`hasPendingEdits`
- cutoff 以下の候補、pin により除外した ID、external session、現在アクティブな session、保留中編集の session
- active session は現在の Copilot chat session resource と、Chat editor で開いている session resource から exact ID を取得する。どちらかの取得可否が不明なら削除全体を停止する。
- 削除対象は「local」「古い」「未ピン留め」「非アクティブ」「保留中編集なし」の全条件を満たすものだけ
- `isEmpty` は報告用の属性であり、年齢条件を免除しない。
- 候補を `file-backed`（`.jsonl` / `.json` の片方以上あり）と `stale-index`（両方なし）に分類する。片方だけある状態は不整合ではなく、実在する representation だけを扱う。

現在の会話と保留中編集の session は削除対象から除外する。pin 状態不明、候補 scope 不明、JSON/schema 破損がある場合は削除全体を停止する。apply では変更前に候補数、title 集約、除外件数、全 ID/title を含む候補 manifest をチャットに提示するが、そこで停止しない。

## 経路選択

- 候補が `1–5` 件、`stale-index` が `0` 件、全候補を GUI row と一意照合でき、visible GUI 操作が可能なら **GUI mode** を使う。
- 候補が `6` 件以上、`stale-index` が `1` 件以上、または GUI の一意照合・操作が不成立なら **offline mode** を提案する。件数だけを理由に GUI mode を強行しない。
- `5` 件は、native confirmation と削除後の index 再読を最大5回に抑え、仮想リストの広範囲走査を避ける運用上限とする。
- 候補 `0` 件は no-op。`--dry-run` は選択予定の mode と、その理由も報告する。
- offline mode の影響は着手時の承認で提示済みとして扱い、mode 確定時に再確認せず進む。着手時の承認が得られていない場合だけ停止する。

## GUI mode

1. Agent Sessions の対象 row から VS Code 標準の `Delete...` action を実行する。この action が session object / selection context を受けて内部状態を更新する経路だけを使う。
2. 現在の agent が row を選択して context action を実行できる visible GUI 操作経路を持つか確認する。agent 自身で操作できない場合は exact 候補を提示してユーザーの GUI 操作を待ち、keyboard sequence や raw command 呼び出しで代用しない。
3. GUI mode では window の close / reload / restart、renderer 終了、`state.vscdb` や session file の直接変更を行わない。
4. `agentSession.delete` に raw ID / URI / keybinding args を渡せると推測しない。`workbench.action.chat.clearHistory` は保持期間や保護条件を無視して全件削除するため使わない。
5. 削除前に候補を GUI row と照合する。title、表示日時、provider など GUI で確認できる属性の組み合わせが一意でない候補、GUI に表示されない候補、scope を確認できない候補が1件でもあれば、何も削除せず offline mode の承認へ切り替える。
6. native action 自体は pin / active session を削除から保護しない。各削除の直前に index、pin cache、active resource を再読し、同じ ID が local・古い・未ピン留め・非アクティブ・保留中編集なしを保つ場合だけ、対象 row を1件 `Delete...` する。
7. native confirmation が1件を示すことを確認して承認し、操作後に index を再読する。想定した ID だけが消え、pin / active / pending-edit session が残ることを確認してから次へ進む。
8. キャンセル、候補変化、想定外 ID の消失、検証不能が起きたら残りを削除せず停止する。
9. workspace 外、global storage、debug logs、他 provider resource は触らない。native action の cloud deletion は best effort で失敗が表面化しない場合があるため、正式な同期状態を別途確認できない限り未確認と報告する。

## Offline mode

1. 承認後に `workbench.action.files.saveAll` を実行し、VS Code から独立した durable one-shot helper を OS temp に作る。helper、manifest、status、backup、quarantine の path を確定し、window close で agent turn が切れるため artifact path と再開手順をチャットへ提示してから window close を開始する。
2. helper は対象 workspace の window にだけ通常の close を送る。複数 workspace が同じ main process を共有するため、process 単位で visible window を列挙して一括 close せず、待機条件も main process の終了ではなく対象 window の消滅と `state.vscdb` の unlock で判定する。ユーザーが VS Code 標準確認で「はい」を選んだ後、対象 renderer の終了を待つ。強制 kill は使わない。終了しなければ変更せず停止する。
3. window 停止後に `workspace.json` の folder URI と現在の workspace を再照合し、`state.vscdb` と pin cache を再読する。workspace binding 不一致、preflight と exact candidate ID 集合が変化、pin 追加、candidate の active / pending-edit 化、schema 破損があれば変更せず再起動する。
4. SQLite backup を作成し、file-backed session を quarantine へ移動してから、transaction で exact index entries だけを削除する。`stale-index` は index entry だけを削除する。VS Code は同じフォルダの `state.vscdb.backup` から workspace storage を復元するため、`state.vscdb` だけを変更すると次の起動で全件戻る。同じ index 削除を `state.vscdb.backup` にも適用するか、その backup を quarantine へ退避して VS Code に再生成させる。
5. mutation の途中で失敗した場合は DB backup と quarantine file を復元する。rollback の各結果を status に残し、復元不能が1件でもあれば自動 cleanup せず報告する。
6. offline 検証で削除 ID が index / session files から消え、保護対象が残ることを確認してから同じ workspace を再起動する。再起動後に DB を再読し、削除 ID が復活していないことを確認する。復活していたら追加削除せず、quarantine を戻して rollback し、offline mode 失敗として復活の供給元とともに報告する。
7. 手順6と検証節にある再起動後の DB / Agent Sessions view 確認が両方成功した後だけ、backup、quarantine、manifest、status、helper を削除する。失敗時は復旧に必要な artifact を残し、その場所と次の操作を報告する。
8. offline mode は local history のみを変更する。cloud sync は未確認と報告し、cloud mapping を推測で直接変更しない。

## 検証

削除後は次を実行してから完了にする。

- index と session files を再読し、削除した ID が両方から消えたことを確認する。
- 「local・古い・未ピン留め・非アクティブ・保留中編集なし」を満たす候補が 0 件であること、除外した pin / active / pending-edit session が残ることを確認する。
- GUI mode は Agent Sessions view を refresh し、削除対象の specific title / 表示日時が残っていないことを確認する。window reload / restart は行わない。
- offline mode は再起動前後の DB 検証と、再起動後の Agent Sessions view の双方で削除対象が復活していないことを確認する。
- UI と index の結果が一致しない場合は追加削除せず、削除済み ID と不一致内容を報告する。

## 最終報告

次を簡潔に報告する。

- mode（dry-run / apply）、workspace、cutoff、候補数、file-backed / stale-index 内訳、pin 除外数、実削除数
- 選択 mode と理由、GUI mode は再起動なし、offline mode は承認・再起動・rollback status、cloud sync の確認可否
- 検証結果、保持した保護対象、残るリスク