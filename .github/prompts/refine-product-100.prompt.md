---
name: "Refine Product 100"
description: "プロダクトを反復実行で最高品質へ近づける。前回サマリーを読み、重複観点を避けて自律的に改善軸を選び、各回で具体改善・検証・記録まで行う。明示 release mode では品質 gate 後に配布と公開状態確認まで進める"
argument-hint: "対象、重点観点、モード（例: current workspace / all / quick / plan / review / release）"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-06-26 -->

# refine product 100

対象プロダクトを何度も実行して最高品質へ近づけるための汎用 prompt。前回サマリーを読み、同じ観点の焼き直しを避け、AI が自律的に今回いちばん効く改善軸を選び、具体改善・検証・記録まで行う。

種別不問: code / docs / slide / runbook / prompt / data / AI asset。

## Non-Negotiables

- 実行可能 mode では、各回で必ず 1 つ以上の具体改善を行う。レビューだけで終わらない。安全に編集できない場合でも `Guard now` として test / docs / checklist / static guard などの成果物を残す。
- 実行可能 mode では、`.git/info/refine-product-state.md` を必ず compact rewrite する。`.git/` が無い場合だけ `Local State: skipped` とし、理由を書く。
- 100% を目指す。検証なし完了、1 件修正で同根放置、Fix now の残件逃げは禁止。
- `Fix now / Guard now / Block` の分類は `Safety + Classification` を SSOT とする。
- `残した観点` に `Fix now` を入れない。残せるのは成果物付きの `Guard now` または確認待ちの `Block` のみ。
- 実機確認が必要でも、機械的代替（test / static guard / manifest consistency / dry-run payload / checklist）を最低 1 つ追加してから止まる。
- 止まる前に次を確認する: 今回の具体改善 / 前回との差分 / 同根 sweep / test or guard / docs sync / cleanup / artifact hygiene / 別軸 review / terminal cleanup / prompt or instruction 側の再発要因。

## Inputs / Modes

- Target: `current workspace` / `all` / `src` / file / folder / product name
- Focus: `feature` / `non-functional` / `UIUX` / `security` / `docs` / `cleanup` / `all`
- Mode: 空欄 / `fix` / `improve` / `quick` / `plan` / `review` / `dry-run` / `release` / `deploy` / `publish`（空欄は default）

| Mode | 動作 |
| --- | --- |
| default / `fix` / `improve` | 前回サマリーから今回の主改善軸を自律選定し、修正・Sweep・検証・state 更新まで行う |
| `quick` | P0/P1 と検証を最優先。P0/P1 の `Fix now` は残さず、関連する最小 Sweep / Guard / Docs / Cleanup は行う |
| `plan` / `review` / `dry-run` | No-Edit。計画または指摘だけ出し、修正・state file 作成/更新はしない |
| `release` / `deploy` / `publish` | default の品質 gate 後、明示された配布対象だけ Release Addendum へ進む |

### Release Intent

- `release` / `deploy` / `publish` mode が明示された場合だけ full release intent と扱う。
- `公開` / `publish` / `Marketplace` などの語だけでは即 publish しない。配布範囲が曖昧なら `Block` または GATE で確認する。
- release mode で対象が software package / VS Code extension / npm package などの単一配布物として特定でき、既存 manifest から package 名と version を決められる場合は、配布対象が明確とみなし、品質 gate 後に commit / tag / push / publish / GitHub Release / verification まで進める。途中で「本当に publish するか」を再確認しない。
- `Release Please` / `リリースして` / `release まで` / `make release` のように release 実行を依頼された場合も、対象 repo と package manifest が一意なら明確な release intent と扱う。`release-prep` / `準備だけ` / `publish しない` / `VSIX だけ` が明示された場合だけ外部公開前に止める。
- release mode で配布対象が複数候補、version 未決定、公開先不明、権限/認証不足、または破壊的履歴操作が必要な場合は、commit / push だけで完了扱いにせず、`Block` または GATE で不足点を確認する。
- `git push` / publish / deploy は、release mode で対象配布が明確な場合、またはユーザーが対象配布を明示した場合のみ実行する。
- release 完了は、配布対象ごとに `VSIX / tag / publish / GitHub Release / verification` が done または blocked と分かれている状態を指す。
- Release でも品質改善 gate は必須。`Fix now` がある状態で配布へ進まない。

## Safety + Classification

安全とは「小さい変更」ではなく、依頼範囲内・可逆・ローカル検証可能・外部公開なし・secret/本番/個人データなし・影響範囲と正しさを説明できること。

| 分類 | 条件 | 必須対応 |
| --- | --- | --- |
| `Fix now` | 依頼範囲内、正しさを説明可能、ローカル検証可能、非破壊的 | 修正・再検証まで実行。残件送り不可 |
| `Guard now` | 本修正は不可だが test / static guard / docs / checklist でリスク低減可能 | 最低 1 つの成果物を追加し、残理由を書く |
| `Block` | 破壊的、外部公開、本番データ、仕様判断、権限不足 | 不足入力、試した代替、次の確認を明記 |

Retry は同一原因 3 回まで。超えたら、試した代替と失敗理由を添えて `Block` に再分類する。

既存の test / lint / build 失敗は、依頼範囲との関係で分類する。依頼範囲内なら `Fix now`、無関係なら `Guard now` として証跡を残し、対象範囲の修正を続ける。原因不明で安全に進めない場合だけ `Block` にする。

## State Intake / Local State / Run Ledger

永続 state file は `.git/info/refine-product-state.md` の 1 つだけ使う。`.github/` 配下の state file や追加の log file は作らない。`Run Ledger` と `Handoff Packet` はチャット出力であり、永続 file ではない。

前回 state は、直近会話の `Run Ledger` / `Handoff Packet`、ユーザー指定の state file、`.git/info/refine-product-state.md` の順に読む。`.git/` が無い場合は代替 file を自動作成せず、チャット state だけで進める。

実行可能 mode（default / quick / release）では、`.git/info/refine-product-state.md` を必ず作成・compact rewrite する。`.git/` が無い場合だけ `Local State: skipped` とし、理由を書く。No-Edit mode（plan / review / dry-run）では作成しない。

state file は append-only にしない。毎回 compact rewrite し、次回判断に効く current snapshot だけを残す。`.git/info/` 配下なので `.gitignore` 変更は不要。

state file の構成は次に限定する: `Current Snapshot` / `Open Items` / `Recent Runs` / `Do Not Repeat` / `Next Focus Candidates` / `Guard or Block`。

肥大化防止: `Recent Runs` は最大 5 件、`Open Items` / `Do Not Repeat` / `Guard or Block` は各最大 10 件、`Next Focus Candidates` は最大 3 件。全体が 200 行または 20KB を超えそうなら、古い run を要約してから上書きする。

state file には raw logs、全文 Findings、terminal 出力、diff、長文 Handoff、secret、個人データ、ローカル絶対パス、一時ログ、未検証の推測を書かない。

入力または直近会話に前回の `Run Ledger` / `Handoff Packet` / `Next Steps` がある場合は最初に読み、各項目を `Closed / Still Open / Reclassified / New` に分類する。無い場合は `baseline` として扱う。

連続実行では、前回の `Open Items` を無視して新観点だけに飛ばない。同時に、前回と同じ観点の焼き直しだけで終わらない。各項目を `閉じた / 継続 / 再分類 / 対象外化` のいずれかに動かし、前回より情報量、検証状態、または成果物が進んだことを `Run Ledger` と local state に残す。

## Autonomous Improvement Planning

この prompt は checklist を上から消化するためではなく、AI が今回いちばん効く改善を計画・実装・検証するために使う。

1. 前回サマリーから `closed / still open / next hypothesis / do-not-repeat` を拾う。
2. 今回は前回と違う主改善軸を 1 つ選ぶ。前回と同じ軸を選ぶのは、新 evidence、未解決 P0/P1、または前回修正の検証不足がある場合だけ。
3. Coverage Matrix は候補地図として使う。すべての小観点を機械的に埋めず、対象と前回履歴から高レバレッジな軸を選ぶ。
4. 実行可能 mode では、選んだ主改善軸から少なくとも 1 つの concrete improvement を完了させる。例: bug fix、UX copy 修正、入力 validation、test 追加、docs 同期、cleanup、guard 追加。
5. 「改善余地なし」と言う前に、別 persona（ユーザー / 運用者 / 保守者 / 監査者 / 次に引き継ぐ AI）で 1 回だけ見直す。
6. それでも安全に編集できない場合だけ、`Block` にし、AI が代替で追加した `Guard now` 成果物を明記する。

## Coverage Matrix

各軸を `Covered / N/A / Open` に分類する。`N/A` は対象外理由を書き、`Open` は `Fix now / Guard now / Block` に分類する。ただし、この表は観点の候補地図であり、AI の自律的な問題発見を縛る上限ではない。小観点に無い問題を見つけた場合は、最も近い軸に置いて直す。

| 軸 | 主要観点 |
| --- | --- |
| 目的・適合 | 対象ユーザー、主要ジョブ、機能要件、受入条件、成功条件、非目的、優先順位、現状とのズレ |
| 機能・状態 | 機能名、用語、ユースケース、境界値、失敗経路、状態遷移、同時実行、冪等性、後方互換 |
| 入力・データ | schema、型、必須/任意、空値、重複、文字コード、locale、時刻、ファイル/URL、外部データ品質 |
| 出力・読まれる面 | 最終 surface、書式、文言、リンク、引用、通知、メール、チャット、CLI、PDF/slide/export、閲覧環境 |
| UI/UX・アクセシビリティ | 視認性、導線、Affordance、Feedback、Recovery、キーボード、スクリーンリーダー、responsive |
| 非機能・運用 | 性能、信頼性、可用性、互換性、保守性、設定、ログ、監視、rollback、コスト、rate limit |
| セキュリティ・安全 | 認証/認可、secret、個人情報、権限、入力検証、injection、依存関係、公開範囲、破壊的操作 |
| 連携・契約 | API 契約、SDK/version、外部サービス、feature flag、migration、error contract、timeout/retry |
| 検証・品質 gate | unit/integration/e2e、lint/typecheck/build、snapshot、dry-run、eval、fixture、artifact/state/exit code 確認 |
| Docs・学習導線 | README、Quick Start、help、runbook、エラーメッセージ、CHANGELOG、機能名/用語統一、設計/運用 docs の同期 |
| AI / 自動化資産 | prompt injection、幻覚防止、根拠、禁止事項、出力形式、不明時、handoff/state、tool scope、決定論処理の script 化 |
| Cleanup・成果物衛生 | dead code、重複、古い資材、一時ファイル、不要 terminal、生成物混入、絶対パス、ローカル依存 |

追加探索では、最低 1 回は次の問いで抜け軸を探す: `ユーザー / 運用者 / 保守者 / 監査者 / 次に引き継ぐ AI` の誰がどこで困るか。

通知、メール、チャット投稿、CLI 出力などは、生成テキストだけでなく最終的に読まれる surface で評価する。

Priority: P0 = 主要機能破壊・データ損失・情報露出 / P1 = 導線混乱・テスト不在・README 不一致 / P2 = 品質改善・文言・dead code。

## Fix Cycle

1. Context: entry points、検証手段、プロジェクト固有 instruction、前回 ledger を読む。
2. Health Check: 現状の test / lint / build / diagnostics が通るか確認。失敗時は baseline failure と修正由来 failure を分け、スクリプト自体の壊れも疑う。
3. Review: Coverage Matrix で gap を出し、各軸を `Covered / N/A / Open` に分類し、`Open` を `Fix now / Guard now / Block` に分類。
4. Implement: 最小差分で修正。既存設計・命名・テストパターンに合わせる。
5. Sweep: 同根原因・同観点の類似 gap を全文検索し、まとめて直す。1 件で満足しない。
6. Test / Guard: 回帰テスト、静的ガード、契約テスト、dry-run、surface snapshot などを追加。
7. Verify: diagnostics → lint → typecheck → test → build。stdout だけでなく artifact / state / process / exit code でも確認。
8. Coverage: 前回と今回の主改善軸が重複していないか確認する。Covered/N/A/Open の未分類軸を残さず、どの mode でも発見済み `Fix now` は未処理で残さない。
9. Docs / Cleanup: README / Quick Start / help / error message / CHANGELOG / 用語を同期し、一時資材・dead code・不要 terminal を片付ける。
10. Close Current Run: `Fix now` が残るなら同じ run 内で閉じる。残すなら `Guard now` / `Block` の条件を満たす。

未解決項目が残る場合は、安全条件を再評価し、`Guard now` / `Block` に再分類してから current run を閉じる。再分類できない `Fix now` が残る場合は未完了として明記し、完了宣言しない。

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
8. commit / push 済みでも tag / publish / GitHub Release が未完なら release は未完了。`Release Status` に未完了箇所を分けて書く。
9. 認証・審査・権限不足で止まる場合は `Block` とし、version / artifact / commit / tag / push / publish 状態を分けて報告。

## Prompt-only Handoff

この prompt は `.prompt.md` 単体で動く前提とする。`handoffs:` frontmatter や custom agent 前提の記述は追加しない。代わりに、チャット文脈で再開できる context-based handoff を出力する。

Next Steps / 新観点 / Block / handoff が 1 件以上ある場合は、`Handoff Packet` と `Handoff Options / Next Action Suggestions` を必ず出す。すべて 0 件なら `Handoff Packet` は省略可。`Run Ledger` は常に出す。

Handoff option は `Plan first` / `Rerun refine` / `AI can continue now` / `User decision` を基本にし、目的・いつ選ぶか・そのまま使える依頼文を含める。

## Output Contract

### No-Edit（plan / review / dry-run）

````markdown
## Plan or Findings
- {計画または指摘。修正はしない}

## Gate
- {次回の実行前に確認すべきこと。なければ none}

## Coverage Matrix Summary
| 軸 | 状態 | 根拠 / 残件 |
| --- | --- | --- |

## Safe-to-Fix 判定
- Fix now / Guard now / Block: {各一覧。No-Edit のため未修正として明記}

## Recommendation
- {削除 / 統合 / 分離 / 移動 / 追加 / 維持 の分類付き改善案}

## Run Ledger
```text
Run Type: baseline|continuation|rerun|release-prep
Prior State Used: local state (.git/info/refine-product-state.md)|user state file|previous Handoff Packet|previous Run Ledger|none
Local State: skipped (no-edit mode)
Primary Axis This Run: {前回と重複しない主改善軸}
Concrete Improvement Target: 次回実行で改善する最小対象: {target}
Closed This Run: none
Still Open: {Findings / 計画由来の open items。Fix now は未修正として明記}
Reclassified: none
New Axis Covered: {今回計画に含めた別軸}
Next Run Focus: {次に実行する 1-3 項目}
```

## Handoff Packet（該当時のみ）
```text
Goal: {次に達成すること}
Current State: {no-edit のため未編集 / 検出済み Findings / 対象ファイル}
Open Items: {Fix now / Guard now / Block / Next Steps}
Prior State Used: {Run Ledger / Handoff Packet / local state (.git/info/refine-product-state.md) / user state file / none}
Recommended Path: {Plan first / Rerun refine / AI can continue now / User decision}
Resume Prompt: {次ターンでそのまま貼れる依頼文}
Do Not: {触らない範囲 / 未確認前提 / 公開・削除禁止など}
```

## Handoff Options / Next Action Suggestions（該当時のみ）
| 候補 | 目的 | いつ選ぶか | そのまま使える依頼文 |
| --- | --- | --- | --- |
````

### Executable（default / quick / release）

````markdown
## Done
- {修正内容。仮説判断した場合は根拠も短く併記}

## Improvement Focus
- Previous Summary Used: {何を読んだか / なければ baseline}
- Primary Axis This Run: {今回の主改善軸。前回との差分も短く書く}
- Concrete Improvement: {この run で完了した具体改善}

## Sweep
- {同根原因・同観点の横展開。なければ「なし」}

## Check
- `{command}`: PASS/FAIL (exit code) {必要なら修正後 PASS}

## Findings
| Priority | 観点 | 内容 | 対応 |
| --- | --- | --- | --- |

## Safe-to-Fix 判定
- Fix now: {0 件であること。残っていれば未完了}
- Guard now: {成果物 / 試したこと / 残す理由 / 次の確認}
- Block: {不足入力 / AI代替 / 今は止める理由 / 次の確認}

## Coverage Sweep
- Coverage Matrix の Covered / N/A / Open サマリ
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
Prior State Used: local state (.git/info/refine-product-state.md)|user state file|previous Handoff Packet|previous Run Ledger|none
Local State: used|updated|skipped ({path or reason})
Primary Axis This Run: {前回と重複しない主改善軸}
Concrete Improvement: {この run で完了した具体改善}
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
Prior State Used: {Run Ledger / Handoff Packet / local state (.git/info/refine-product-state.md) / user state file / none}
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
- 前回サマリーとの差分を踏まえて、今回の主改善軸と `Concrete Improvement Target` または `Concrete Improvement` を明記した。
- Coverage Matrix の各軸を `Covered / N/A / Open` に分類し、`N/A` には理由、`Open` には対応分類がある。
- 発見 gap を `Fix now / Guard now / Block` に分類した。
- 実行可能 mode では、少なくとも 1 つの具体改善または `Guard now` 成果物を完了した。
- 機能名 / 機能要件 / UIUX / docs sync / cleanup / 同観点 sweep のうち、対象に関係するものを見た。
- `Fix now` は修正・再検証まで完了し、残件に入れていない。
- `Guard now` / `Block` には試行内容、AI 代替、次の確認がある。
- Run Ledger に Prior State Used / Closed This Run / Still Open / New Axis Covered / Next Run Focus がある。
- Local State の使用/更新/省略理由を Run Ledger に書いた。
- state file は `.git/info/refine-product-state.md` の 1 つだけで、compact rewrite と上限件数を守った。
- Next Steps / 新観点 / Block / handoff がある場合、Handoff Packet と Handoff Options がある。
- `.prompt.md` 単体運用を維持し、`handoffs:` frontmatter や custom agent 前提の記述を追加していない。
- 一時資材、dev server、task terminal を片付けた。残す場合は理由を書いた。

## Run Boundary

- No-Edit mode（plan / review / dry-run）指定。
- `Fix now` が 0 件で、`Guard now` / `Block` の代替と次確認が記録済み。
- 同一原因の再試行が 3 回超過。
- 安全上ユーザー確認が必要で、非破壊の Guard now を試した。