---
name: "Refine Product 100"
description: "プロダクトを機能・非機能・UI/UX で徹底レビューし、修正・テスト・同観点スイープ・ドキュメント整備・不要物削除まで自律実行。Run Ledger / Handoff Packet で反復改善を継続。明示 release mode では品質 gate 後に配布準備まで進める"
argument-hint: "対象、重点観点、モード（例: current workspace / all / standard / auto / quick / release）"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- updated: 2026-05-31 -->

# refine product 100

対象プロダクトを機能・非機能・UI/UX・ドキュメント・cleanup まで徹底レビューし、安全に直せる gap を閉じ切るための汎用 prompt。

種別不問: code / docs / slide / runbook / prompt / data / AI asset。

## Non-Negotiables

- 100% を目指す。検証なし完了、1 件修正で同根放置、Fix now の残件逃げは禁止。
- `Fix now / Guard now / Block` の分類は `Safety + Classification` を SSOT とする。
- `残した観点` に `Fix now` を入れない。残せるのは成果物付きの `Guard now` または確認待ちの `Block` のみ。
- 実機確認が必要でも、機械的代替（test / static guard / manifest consistency / dry-run payload / checklist）を最低 1 つ追加してから止まる。
- 止まる前に次を確認する: Fix gap / 同根 sweep / test or guard / docs sync / cleanup / artifact hygiene / 別軸 review / terminal cleanup / prompt or instruction 側の再発要因。

## Inputs / Modes

- Target: `current workspace` / `src` / file / folder / product name
- Focus: `feature` / `non-functional` / `UIUX` / `security` / `docs` / `cleanup` / `all`
- Mode: `plan only` / `review only` / `confirm` / `standard` / `auto` / `quick` / `release`（空欄は `standard`）

| Mode | 動作 |
| --- | --- |
| `plan only` | 計画だけ。編集しない |
| `review only` | 指摘だけ。編集しない |
| `confirm` | 計画と GATE を出してから編集 |
| `standard` | high-confidence gap を 1 サイクル閉じ + Sweep。追加 gap は最大 1 件、残りは Next Steps |
| `auto` | 確認なしに安全な `Fix now` を閉じる。最大 3 cycle で区切り、残りは Ledger / Handoff に渡す |
| `quick` | P0/P1 と検証だけ。Sweep / Docs / Cleanup は「なし」で省略可 |
| `release` | `standard` 相当の品質 gate 後、明示された配布対象だけ Release Addendum へ進む |

### Release Intent

- `release` mode が明示された場合だけ full release intent と扱う。
- `公開` / `publish` / `Marketplace` などの語だけでは即 publish しない。`confirm` 相当で配布範囲を確認する。
- `git push` / publish / deploy は、ユーザーが release mode と対象配布を明示した場合のみ実行する。
- Release でも品質改善ループは必須。`Fix now` がある状態で配布へ進まない。

## Safety + Classification

安全とは「小さい変更」ではなく、依頼範囲内・可逆・ローカル検証可能・外部公開なし・secret/本番/個人データなし・影響範囲と正しさを説明できること。

| 分類 | 条件 | 必須対応 |
| --- | --- | --- |
| `Fix now` | 依頼範囲内、正しさを説明可能、ローカル検証可能、非破壊的 | 修正・再検証まで実行。残件送り不可 |
| `Guard now` | 本修正は不可だが test / static guard / docs / checklist でリスク低減可能 | 最低 1 つの成果物を追加し、残理由を書く |
| `Block` | 破壊的、外部公開、本番データ、仕様判断、権限不足 | 不足入力、試した代替、次の確認を明記 |

Retry は同一原因 3 回まで。超えたら `Block` に再分類する。

## State Intake / Run Ledger

`.github/refine-product.md` があれば前回 state を反映する。存在しなければ作らない。

入力または直近会話に前回の `Run Ledger` / `Handoff Packet` / `Next Steps` がある場合は最初に読み、各項目を `Closed / Still Open / Reclassified / New` に分類する。無い場合は `baseline` として扱う。

連続実行では、前回の `Open Items` を無視して新観点だけに飛ばない。各項目を `閉じた / 継続 / 再分類 / 対象外化` のいずれかに動かし、前回より情報量または検証状態が進んだことを `Run Ledger` に残す。

## Review Rubric

| カテゴリ | 主要観点 |
| --- | --- |
| 機能 | ユースケース、境界値、失敗経路、状態遷移、後方互換 |
| 非機能 | 性能、信頼性、セキュリティ、互換性、保守性 |
| UI/UX | 視認性、導線、Affordance、Feedback、Recovery |
| その他 | アクセシビリティ、エラー復旧、テストカバレッジ、ドキュメント |
| 自動化資産 | prompt / template / quick action / canned response の根拠、禁止事項、出力形式、不明時の扱い |

通知、メール、チャット投稿、CLI 出力などは、生成テキストだけでなく最終的に読まれる surface で評価する。

Priority: P0 = 主要機能破壊・データ損失・情報露出 / P1 = 導線混乱・テスト不在・README 不一致 / P2 = 品質改善・文言・dead code。

## Fix Cycle

1. Context: entry points、検証手段、プロジェクト固有 instruction、前回 ledger を読む。
2. Health Check: 現状の test / lint / build / diagnostics が通るか確認。失敗時はスクリプト自体の壊れも疑う。
3. Review: Review Rubric で gap を出し、`Fix now / Guard now / Block` に分類。
4. Implement: 最小差分で修正。既存設計・命名・テストパターンに合わせる。
5. Sweep: 同根原因を全文検索し、まとめて直す。1 件で満足しない。
6. Test / Guard: 回帰テスト、静的ガード、契約テスト、dry-run、surface snapshot などを追加。
7. Verify: diagnostics → lint → typecheck → test → build。stdout だけでなく artifact / state / process / exit code でも確認。
8. Coverage: `standard` は追加 1 件まで、`auto` は最大 3 cycle まで全観点を再スイープ。
9. Docs / Cleanup: README / Quick Start / help / error message / CHANGELOG / 用語を同期し、一時資材・dead code・不要 terminal を片付ける。
10. Repeat or Stop: `Fix now` が残るなら継続。残すなら `Guard now` / `Block` の条件を満たす。

`auto` で 3 cycle 後も `Fix now` が残る場合は current run を閉じ、Run Ledger と Handoff Packet で次 run に渡す。

Subagent は、大規模 repo / 複数観点 Sweep / 長いログ解析で read-only 調査に限定して使う。使わない場合は理由を最終報告に残す。

## Meta Improvement Scope

prompt / instruction / skill / hook / reusable script 自体に再発要因がある場合のみ扱う。主タスクの修正と検証後、同じスコープで安全な最小変更だけ反映する。別系統の大整理、public/private sync、他資産への波及編集は明示依頼がない限り Next Steps に積む。

## Release Addendum

`release` mode かつ配布対象が明示されたソフトウェア配布物だけに適用する。ドキュメント等は skip。

1. 対象 version が既に公開済みでないか確認。既存なら patch 以上を上げる。
2. package metadata / lockfile / version display / CHANGELOG / release notes を同期。
3. typecheck / lint / unit / integration / dependency audit を実行。Fix now 可能な audit は直す。
4. build / pack を実行し、artifact の存在・サイズ・更新時刻を正本にする。
5. pack 中身を列挙し、src / test / .github / .vscode / sourcemap / 内部資料の混入を確認。
6. Commit → push → publish → GitHub Release は、ユーザーの明示 release 指示がある場合だけ実行。
7. publish 後は registry / Marketplace / Git tag / GitHub Release など別経路で裏取り。stale 表示だけで再 publish しない。
8. 認証・審査・権限不足で止まる場合は `Block` とし、version / artifact / commit / tag / push / publish 状態を分けて報告。

## Prompt-only Handoff

この prompt は `.prompt.md` 単体で動く前提とする。`handoffs:` frontmatter や custom agent 前提の記述は追加しない。代わりに、チャット文脈で再開できる context-based handoff を出力する。

Next Steps / 新観点 / Block / handoff が 1 件以上ある場合は、`Handoff Packet` と `Handoff Options / Next Action Suggestions` を必ず出す。すべて 0 件なら `Handoff Packet` は省略可。`Run Ledger` は常に出す。

Handoff option は `Plan first` / `Rerun refine` / `AI can continue now` / `User decision` を基本にし、目的・いつ選ぶか・そのまま使える依頼文を含める。

すべての mode で、Next Steps / 新観点 / Block / handoff が 1 件以上ある場合は、mode 固有の出力に続けて `Handoff Packet` と `Handoff Options / Next Action Suggestions` を追加する。

## Output Contract

### Plan Only

````markdown
## Plan
- {実行計画}

## Gate
- {編集前に確認すべきこと}

## Run Ledger
```text
Run Type: baseline|continuation|rerun|release-prep
Prior State Used: .github/refine-product.md|previous Handoff Packet|previous Run Ledger|none
Closed This Run: none
Still Open: {計画上の open items}
Reclassified: none
New Axis Covered: {今回計画に含めた別軸}
Next Run Focus: {次に実行する 1-3 項目}
```
````

### Review Only

````markdown
## Findings
| Marker | Priority | QP | 観点 | 内容 | 対応 |
| --- | --- | --- | --- | --- | --- |

## Safe-to-Fix 判定
- Fix now / Guard now / Block: {各一覧}

## Recommendation
- {削除 / 統合 / 分離 / 移動 / 追加 / 維持 の分類付き改善案}

## Run Ledger
```text
Run Type: baseline|continuation|rerun
Prior State Used: .github/refine-product.md|previous Handoff Packet|previous Run Ledger|none
Closed This Run: none
Still Open: {Findings 由来の open items。Fix now は未修正として明記}
Reclassified: {分類変更。なければ none}
New Axis Covered: {今回追加で見た別軸}
Next Run Focus: {次に見る 1-3 項目}
```

## Handoff Packet（該当時のみ）
```text
Goal: {次に達成すること}
Current State: {review only のため未編集 / 検出済み Findings / 対象ファイル}
Open Items: {Fix now / Guard now / Block / Next Steps}
Prior State Used: {Run Ledger / Handoff Packet / .github/refine-product.md / none}
Recommended Path: {Plan first / Rerun refine / AI can continue now / User decision}
Resume Prompt: {次ターンでそのまま貼れる依頼文}
Do Not: {触らない範囲 / 未確認前提 / 公開・削除禁止など}
```

## Handoff Options / Next Action Suggestions（該当時のみ）
| 候補 | 目的 | いつ選ぶか | そのまま使える依頼文 |
| --- | --- | --- | --- |
````

### Standard / Auto / Quick / Release

````markdown
## Done
- {修正内容。仮説判断した場合は根拠も短く併記}

## Sweep
- {同根の横展開。なければ「なし」}

## Check
- `{command}`: PASS/FAIL (exit code) {必要なら修正後 PASS}

## Findings
| Marker | Priority | QP | 観点 | 内容 | 対応 |
| --- | --- | --- | --- | --- | --- |

## Safe-to-Fix 判定
- Fix now: {0 件であること。残っていれば未完了}
- Guard now: {成果物 / 試したこと / 残す理由 / 次の確認}
- Block: {不足入力 / AI代替 / 今は止める理由 / 次の確認}

## Coverage Sweep
- 再確認した観点 / 追加で直したもの / 残した観点 / Subagent 使用有無

## Documentation / Cleanup（該当時のみ）

## Meta Improvements（該当時のみ）

## Release Status（release mode のみ）
- Version: {before -> after}
- Artifact: {path / size / timestamp / checksum if available}
- Commit / Tag / Push / Publish / GitHub Release: {done / skipped / blocked}
- Registry or Marketplace verification: {source / result / stale risk}

## 100% Pass 判定

## Next Steps（優先度順、[AI] / [User] 担当付き）

## Run Ledger
```text
Run Type: baseline|continuation|rerun|release-prep
Prior State Used: .github/refine-product.md|previous Handoff Packet|previous Run Ledger|none
Closed This Run: {閉じた項目と検証結果}
Still Open: {Guard now / Block / Next Steps。Fix now は不可}
Reclassified: {分類変更した項目と理由。なければ none}
New Axis Covered: {今回追加で見た別軸}
Next Run Focus: {次回最初に見る 1-3 項目}
```

## Handoff Packet（該当時のみ）
```text
Goal: {次に達成すること}
Current State: {完了済み変更 / 検証結果 / 成果物 / 対象ファイル}
Open Items: {Guard now / Block / Next Steps。Fix now は不可}
Prior State Used: {Run Ledger / Handoff Packet / .github/refine-product.md / none}
Recommended Path: {Plan first / Rerun refine / AI can continue now / User decision}
Resume Prompt: {次ターンでそのまま貼れる依頼文}
Do Not: {触らない範囲 / 未確認前提 / 公開・削除禁止など}
```

## Handoff Options / Next Action Suggestions（該当時のみ）
| 候補 | 目的 | いつ選ぶか | そのまま使える依頼文 |
| --- | --- | --- | --- |
````

## Final Self-Check

- 前回出力があれば取り込み、Closed / Still Open / Reclassified / New に分類した。
- 発見 gap を `Fix now / Guard now / Block` に分類した。
- `Fix now` は修正・再検証まで完了し、残件に入れていない。
- `Guard now` / `Block` には試行内容、AI 代替、次の確認がある。
- Run Ledger に Prior State Used / Closed This Run / Still Open / New Axis Covered / Next Run Focus がある。
- Next Steps / 新観点 / Block / handoff がある場合、Handoff Packet と Handoff Options がある。
- `.prompt.md` 単体運用を維持し、`handoffs:` frontmatter や custom agent 前提の記述を追加していない。
- 一時資材、dev server、task terminal を片付けた。残す場合は理由を書いた。

## Stop Conditions

- `plan only` / `review only` 指定。
- `confirm` mode の GATE でユーザーが終了を選んだ。
- `Fix now` が 0 件で、`Guard now` / `Block` の代替と次確認が記録済み。
- `auto` で 3 cycle 後も `Fix now` が残り、Run Ledger と Handoff Packet で継続可能にした。
- 同一原因の再試行が 3 回超過。
- 安全上ユーザー確認が必要で、非破壊の Guard now を試した。