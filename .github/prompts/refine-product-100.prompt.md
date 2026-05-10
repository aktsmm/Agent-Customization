---
name: "Refine Product 100"
description: "プロダクトを機能・非機能・UI/UX で徹底レビューし、修正・テスト・同観点スイープ・ドキュメント整備・不要物削除まで自律実行。妥協なく 100% パスを目指す汎用プロンプト。リリース指示があれば最後に配布まで進める"
argument-hint: "対象、重点観点、モード（例: current workspace / all / auto / quick / release）"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- updated: 2026-05-11 -->

# Refine Product 100

機能・非機能・UI/UX の観点で対象プロダクトを徹底レビューし、修正・テスト・同観点スイープ・ドキュメント整備・不要物削除まで自律実行する。**妥協しない**。100% の出力と言えるところまで押し込む。

プロダクト種別を問わず使える汎用プロンプト（コード / ドキュメント / スライド / 運用手順 / プロンプト / データ・AI 等）。種別固有の観点はユーザー入力と既存成果物から自分で推定する。

## Prime Directive — 100% or 明確な停止理由

最初から 100% を目指す。次は禁止。

- 「次にやるべきこと」を案内するだけで終わる
- 「人間に確認してもらう」で止まる
- 「自分の権限ではここまで」で軽く撤退する
- 95% で満足する
- 検証せず完了扱い
- 1 件直して同根原因の他箇所を放置する
- 失敗した検証を直さず完了扱いにする

止まる前に必ず自問する。**1 つでも yes ならまだ止まらない**。

1. まだ自分の権限で安全に直せる high-confidence な gap が残っていないか
2. 同じ根本原因で他にも修正できる箇所が残っていないか（**全文検索・grep でスイープしたか**）
3. まだ追加できる回帰防止テスト・静的ガードがないか
4. README・ヘルプ・設定説明・エラー文・サンプルが古い/不一致のまま残っていないか
5. 不要ファイル・dead code・未使用依存・検証用一時資材が残っていないか
6. 配布対象なら、配布物 payload に不要物が混入していないか
7. UI/UX・アクセシビリティ・エラー復旧・テスト・ドキュメント・運用性など、最初の修正観点以外に見落とした別軸の gap が残っていないか
8. 検証・調査で開いた terminal / task / dev server / watch / browser / emulator / local API などの実行セッションが不要に残っていないか

実機 UI 確認・人間判断・外部実値が必須でローカルで閉じない場合でも、**機械的代替（回帰テスト・静的ガード・チェックリスト）を最低 1 つ追加してから**止まる。

## Inputs / Modes

- Target: ${input:target:対象（例: current workspace / src / 特定モジュール）}
- Focus: ${input:focus:重点観点（例: 機能 / 非機能 / UIUX / security / docs / cleanup / all）}
- Mode: ${input:mode:plan only / review only / confirm / standard / auto / quick。空欄は standard}

| Mode | 動作 |
| --- | --- |
| `plan only` | 計画だけ。編集しない |
| `review only` | 指摘だけ。編集しない |
| `confirm` | 計画と GATE を出してから編集 |
| `standard` / 空欄 | GATE 省略。主要な high-confidence gap を 1 サイクル閉じ、検証・必要な docs/cleanup・Focused Coverage Sweep まで自律実行。追加 gap は最大 1 件まで修正し、残りは Next Steps |
| `auto` / `自動` | Full auto。安全に直せる high-confidence gap が尽きるまで複数サイクルで修正・検証・Sweep・docs/cleanup・Final Coverage Sweep を繰り返す |
| `quick` | P0/P1 と検証だけに集中。最小差分で修正し、Final Response は Done / Check / Next Steps に圧縮（Sweep / Documentation / Cleanup は実施するが「なし」と明記して省略可） |

ユーザー指示に「リリース」「release」「公開」が含まれる場合、対象がソフトウェア配布物なら §Release Loop を実行するか 1 回だけ確認する。対象がドキュメント・スライド・教材・運用手順などの場合は、§Release Loop ではなく成果物の最終チェックと共有・配置手順を Next Steps に書く。

## Safety Constraints

- 対象はユーザーが所有・編集してよいワークスペース内のコード・ドキュメント・設定・成果物に限定
- secret / token / 個人情報を出力・保存・ログ化しない
- `git push` / publish / deploy / public sync は §Release Loop または明示指示時のみ
- 破壊的操作・データ削除・外部公開は事前確認なしに行わない
- ファイル削除は **明らかに不要なもの**（git ignored 対象 / 検証用一時資材 / 削除済み機能の dead code）に限る。迷うものは削除せず Next Steps に残す
- ユーザー作業環境固有のファイル（LICENSE / CONTRIBUTING / 既存設計資料）は触らない
- **今回の依頼に含まれない範囲（新規設定追加・無関係なリファクタ・無関係ファイルの cleanup・既存仕様変更）を勝手に始めない**。価値があれば Next Steps に積む
- **仕様判断を勝手に変えない**。既存の動作・設定名・marker・install target 等の変更は、ユーザー指示か `.github/refine-product.md` の Plan 上に明示記述があるときだけ

## Safe-to-Fix Gate

gap を見つけたら、逃げずに `Fix now` / `Guard now` / `Block` のどれかへ分類する。

安全とは「小さい変更」ではなく、**所有ワークスペース内・依頼範囲内・可逆・ローカル検証可能・外部公開なし・secret/本番/個人データ/破壊的操作なし・影響範囲と正しさを説明できる**ことを指す。根本原因を直すために必要なら複数ファイルを変更してよい。ただし、影響範囲を限定し、関連テスト・lint・typecheck・静的ガードで検証する。

- `Fix now`: 依頼範囲内、必要十分な差分、既存仕様・README・テスト・命名から正しさを説明できる、ローカル検証できる、破壊的/不可逆/外部公開/secret/本番データ/広い設計判断を含まない
- `Guard now`: 実値・実機・人間判断が必要で本修正はできないが、回帰テスト・静的ガード・チェックリスト・エラー文・docs など機械的代替でリスクを下げられる
- `Block`: destructive 操作、外部公開、本番/クラウド/決済/個人データ/secret、公開 API・install target・互換性の大きな変更、仕様トレードオフ、ユーザー判断がないと正しさを説明できない変更

`Block` は完了逃げに使わない。必ず「不足している入力」「AI 代替を試した内容」「次に必要な確認」を Findings または Next Steps に残す。`100% pass complete` は、発見した gap をすべて `Fix now` 済み、`Guard now` 済み、または根拠付き `Block` に分類した状態を指す。

破壊的変更が最善に見える場合でも auto で実行しない。代わりに、互換 shim、feature flag 既定 off、deprecation warning、dry-run、backup/migration 手順、静的ガード、docs など非破壊の `Guard now` を先に試す。本当に破壊的変更が必要なら `Block` として、目的・影響範囲・代替不可の理由・具体コマンド/差分案・rollback・検証計画・ユーザーに必要な判断を短く提示する。

`Fix now` / `Guard now` にしたものは、**修正 → 検証 → 失敗原因の読解 → 再修正 → 再検証**を通す。検証が失敗している間は完了扱いにしない。同一原因の同じ修正ループは最大 3 回まで再試行し、3 回を超えたら原因・試した対処・不足情報を `Block` として記録する。別原因の失敗が見つかった場合は新しい gap として再分類し、安全に直せるなら続けて直す。

## Workflow

### 1. Context

プロジェクト種別と成果物形式（コード / ドキュメント / スライド / 運用手順 / プロンプト / データ・AI 等）を推定し、entry points・既存検証手段・プロジェクト固有 instruction（例: `.github/copilot-instructions.md` / `AGENTS.md` / README / 設計資料 / runbook）を読む。情報不足は仮説を明記して進む。

**連続実行ラチェット**: state 用に使うファイルは最大 1 つ、`.github/refine-product.md` のみ。既に存在する場合だけ先に読み、前回の `Next Focus` / `Known Gaps` を今回の重点に優先反映する。存在しなければ前回 state はなしとして進め、勝手に state ファイルを作らない。**前回と同じ観点だけにせず、最低 1 件は別軸を含める**。同観点を継続するなら理由を Findings に明記する。

**自律性原則**: 不明点があっても、Safety Constraints、ユーザー指示、既存 Plan / instruction の範囲内で進められる場合は質問で止まらず、既存コード・テスト・ドキュメントから high-confidence な仮説を置いて実装・検証する。判断根拠は最終報告の `Done` または `Findings.対応` 欄に短く記録する（例: 「設定名 X は既存の Y 系命名に合わせた」）。曖昧で破壊的・不可逆な選択は仮説で進めず、Next Steps に積む。

### 1.5. Subagent Delegation（該当時は原則使用）

大きな repo、未知領域が広い調査、複数観点の Coverage Sweep、長いログ/テスト失敗解析では、コンテキスト節約のため**原則サブエージェントを使う**。使わない場合は、対象が小さい / 既に必要文脈が十分 / サブエージェントが利用不可 / 追加呼び出しの方が遅い、などの理由を最終報告の `Coverage Sweep` または `Safe-to-Fix 判定` に短く残す。原則は read-only 調査に限定し、main agent が最終判断・編集・検証責任を持つ。依頼は「対象範囲、観点、編集禁止、返すべき形式（file path / risk / Fix now・Guard now・Block 推奨 / 検証案）」を明確にする。secret、外部公開、破壊的操作、ユーザー判断が必要な設計決定はサブエージェントへ実行させない。

### 2. Verification Pipeline Health Check

対象種別に応じた検証エントリポイントが**現状で実際に PASS するか**確認する。コードなら test / lint / typecheck、ドキュメントなら link check / 用語一貫性、スライドなら export / レイアウト、運用手順なら dry-run / 冪等性、プロンプトなら代表入力ケース等。失敗したら、検証対象ではなくスクリプト自体の壊れも疑う。新規追加検証は必ず既存パイプラインから呼ばれるよう配線する。

### 3. 全観点レビュー

機能面・非機能面・UI/UX を**同時に**見て、🔴🟡🟢 マーカー付きで指摘を出す。

各指摘は、可能なら `QP-*`（検証可能な品質プロパティ）として扱う。根拠は `意図/仕様/README/観測挙動 -> 期待性質 -> 対象面 -> 修正/テスト -> 検証結果` の短い証拠連鎖で確認し、証拠が薄いものは推測で断定しない。

| カテゴリ | 主要観点 |
| --- | --- |
| 機能 | 主要ユースケース、境界値、失敗経路、状態遷移、データ整合性、後方互換性 |
| 非機能 | 性能、信頼性（timeout/retry/cancel/競合/解放）、セキュリティ/プライバシー、互換性、保守性、可観測性 |
| UI/UX | 視認性、情報階層、導線、説明順序、Affordance、Feedback、Recovery、Consistency、Trust |
| アクセシビリティ | キーボード、フォーカス、ラベル、コントラスト、セマンティクス、読み上げ |
| エラー/復旧 | 原因表示、次の行動、再試行可否、取り消し、部分失敗 |
| テスト | 重要仕様・境界・異常・回復のカバレッジ、ランナー健全性 |
| ドキュメント | README、設定説明、トラブルシュート、サンプル、用語一貫性 |

優先度: 🔴 P0 (主要機能破壊・データ損失・重大 UX ブロック・情報露出) / 🟡 P1 (主要導線の混乱・重要仕様のテスト不在・README 不一致) / 🟢 P2 (品質改善・文言・一貫性・dead code)

### 4. GATE（confirm モードのみ）

`all fix` / `P0,P1` / `1,3,5` / `plan only`。auto / quick では省略。

### 5. Implement → Sweep → Verify → Repeat

各指摘について:

1. **Implement**: 最小差分で修正。既存設計・命名・テストパターンに合わせる
2. **Sweep**: 同じ根本原因で直せる箇所を全文検索・型検索・grep で必ず洗い出してまとめて直す。**1 件直して満足は禁止**。スイープ結果は最終報告の Sweep セクションに必ず書く（該当なしなら「なし」と明記）
3. **Test**: 回帰防止テストを追加。実機/外部依存で閉じない箇所は機械的代替テスト（manifest 整合・文言同期・契約テスト・静的ガード）を追加
4. **Verify**: IDE diagnostics → lint → typecheck → 検証パイプライン健全性 → unit → integration → build → 手動確認手順 の順
5. **Repeat**: 検証失敗は必ず原因を読み、`Fix now` / `Guard now` / `Block` に再分類する。安全に直せる問題は修正して関連検証を再実行し、失敗したまま完了扱いにしない。同一原因の同じ修正ループは最大 3 回まで。テスト期待値が実コードと乖離して失敗した場合、ユーザー指示・既存仕様・README・既存テスト・後方互換性を確認し、実装が正しいと説明できる場合のみ期待値を更新する。理由は `Done` または `Findings.対応` 欄に短く記録する

実行ルール: 既存 scripts/CI を優先、ターミナルは非対話・単発・timeout 付き、watch/dev server は起動しない、汚染ターミナルは復旧せず新セッションへ切替。検証・調査で開いた terminal は、結果を確認したら原則閉じる。常駐が必要な terminal だけ残し、最終報告に理由と停止方法を書く。

### 5.5. Coverage Sweep（standard / auto 必須）

standard / auto では、最初の修正と検証が通った後に必ずもう一度、機能 / 非機能 / UI/UX / アクセシビリティ / エラー復旧 / セキュリティ / 性能 / 互換性 / データ整合性 / テスト / ドキュメント / 運用性 / cleanup / release readiness を再スイープする。standard は追加で安全に直せる high-confidence gap を最大 1 件まで §5 に戻って修正・検証し、残りは Next Steps に分ける。auto は安全に直せる high-confidence gap が尽きるまで §5 に戻る。実環境や人間判断が必要なものは、AI 代替を検討した上で Next Steps に残す。quick では P0/P1 と今回の Focus に限定してよい。

### 6. Documentation Sweep

修正に応じて以下を**必ず同期**する。コード変更後の README 同期忘れは典型的 P1 gap。

- README / Quick Start / 機能一覧 / インストール手順 / 設定説明
- ヘルプ文 / エラーメッセージ / nls 文言 / コマンド説明
- CHANGELOG（Unreleased セクション）
- サンプル・トラブルシュート・既知の制限
- 用語の一貫性（同概念の別名混在を全文確認）

### 7. Cleanup

明らかに不要なものは削除する。判断に迷うものは削除せず Next Steps に残す。**削除可**: git ignored 対象の一時ファイル / 検証用に追加した一時 task / 削除済み機能の dead code / 参照されていない asset。**削除不可**: 用途不明の top-level ファイル / 他リポジトリから参照されうるもの / ユーザー未コミット作業。

検証作業で追加した一時 VS Code task や scratch ファイルは、コミット前に必ず HEAD 状態へ戻す。使い終わった terminal / task / dev server / watch / browser / emulator / local API は停止・kill し、残す必要があるものだけ理由を最終報告へ書く。

### 8. Release Loop（ソフトウェア配布物がある場合のみ。明示指示 or 配布対象シグナル + ユーザー同意時）

対象がドキュメント・スライド・教材・運用手順などの場合は本セクションは skip。代わりに「成果物の最終チェック → 配布先（共有 drive / wiki / portal）への配置 → 関係者通知」を Next Steps に書く。

ユーザー指示に「リリース」「release」「公開」がない場合は、配布対象シグナルを検出したら最後に「`/refine-product-100` の品質改善は完了。続けて配布まで進めますか？」と**1 回だけ**短く確認する。指示なし or 「いいえ」なら終了。

実行する場合の手順:

1. **公開前重複確認**: 対象 version が既に公開されていないか確認（既存ならパッチを上げる）
2. **Version sync**: package メタ / lockfile / バージョン表示文字列 / CHANGELOG / release notes を**同時更新**
3. **必須テスト**: typecheck / lint / unit / integration / 依存脆弱性監査
4. **Production build**
5. **配布物作成**: 配布形態に応じた pack コマンド（vsix package / npm pack / python -m build / docker build / etc.）
6. **配布物 Hygiene Check（最重要）**: 配布物の中身を**必ず列挙**して、開発資材（src / test / scripts / .github / .vscode / lockfile / sourcemap / 一時ログ / 内部設計資料）が混入していないことを目視確認。混入していたら **publish せず**、ignore 設定（`.vscodeignore` / `package.json files` / `MANIFEST.in` / `.dockerignore` 等）を**修正してから再パッケージ**。ignore 修正自体を commit に含める（再発防止）
7. **メタデータ反映**: 配布物の SHA256 とサイズを release notes に反映
8. **Commit**: `[Release] vX.Y.Z - <要約>`
9. **Push**
10. **Publish**（duplicate-safe オプションを使う。`already published` は事前確認の不備として扱い version を上げ直す）
11. **GitHub Release 作成**（該当する場合、`--target` は full SHA）
12. **公開状態を別経路で裏取り**（API 応答だけでは信用しない）
13. **後片付け**: 検証用一時資材を削除

### 9. State Update（任意・単一ファイル）

state 用に使うファイルは `.github/refine-product.md` のみ。既に存在する場合のみ、`<!-- START:prompt-state:refine-product -->` ブロックに今回の Run Meta / Carry Over / Quality Ledger / Next Focus / Learnings Delta を上書き記録してよい。`Next Focus` には**前回と異なる観点を最低 1 件**含める。存在しなければ作成しない。継続改善ログが必要なら、最終報告の Next Steps に「`.github/refine-product.md` を作成するか確認」として提案する。

## Final Response Format

```markdown
## Done
- {修正内容を箇条書き。自律性原則で仮説判断した場合は根拠も短く併記}

## Sweep（同根原因の横展開）
- {他に直したもの。なければ「なし」}

## Check
各検証コマンドと pass/fail (exit code) を 1 行ずつ列挙。失敗したものは「→ 修正後 PASS」も併記。失敗したまま完了扱いにしない。

例:
- `npm test`: PASS (exit 0)
- `node scripts/test-foo.js`: FAIL (exit 1) → 期待値修正後 PASS (exit 0)
- `npm run build`: PASS (exit 0)

## Findings
| Marker | Priority | QP | 観点 | 内容 | 対応 |
| --- | --- | --- | --- | --- | --- |

## Safe-to-Fix 判定
- Fix now: {今回直した gap。なければ「なし」}
- Guard now: {機械的代替でリスクを下げた gap。なければ「なし」}
- Block: {安全に直せない gap と不足入力。なければ「なし」}

## Coverage Sweep
- 再確認した観点: {機能 / 非機能 / UIUX / a11y / error / security / performance / compatibility / data / tests / docs / operability / cleanup / release など}
- 追加で見つけて直したもの: {一覧、なければ「なし」}
- 残した観点: {AI 代替を検討した上で残したもの。なければ「なし」}
- Subagent: {使った場合は用途と結果。使わなかった場合は理由}

## Documentation / Cleanup（該当時のみ）
- 同期した docs / 削除した不要物 / 残った検証用ノイズ
- Terminal cleanup: {閉じた terminal / 停止した常駐プロセス / 残したものと理由。なければ「なし」}

## 100% Pass 判定
- {100% pass complete / Needs user confirmation / Needs real-env validation / Failed after 3 retries}

## Next Steps（優先度順 P1→P3、各件に [AI] / [User] 担当）

`[User]` と書く前に、**AI 代替（機械的回帰テスト・静的ガード・チェックリスト）で閉じられないか必ず検討**する。閉じられるなら `[AI]` にする。

### 確認
- {確認タスク} `~3d`

### 新観点（最大 3 件、前回と同観点だけにしない）
1. **P1** `[AI / User]` {観点}: {具体タスク} `~Nd`
2. **P2** `[AI / User]` {観点}: {具体タスク} `~Nd`
3. **P3** `[AI / User]` {観点}: {具体タスク} `~Nd`

### 再発防止
- {1 件}

## Release Suggestion（配布対象シグナル検出時のみ）
- 検出根拠 / 提案: {続けてリリースしますか？ はい / いいえ / 既に指示済みのため自動実行}
```

`Sweep` / `Check` / `Findings` / `Safe-to-Fix 判定` / `Coverage Sweep` / `Next Steps` は省略しない。該当なしは「なし」と明記。`Documentation / Cleanup` は該当時のみ書く。`quick` モードでは Sweep / Coverage Sweep / Documentation / Cleanup を「なし」明記で省略可。

## Self-Check（最終報告前に 1 回）

- Sweep 実施済み（または「なし」の根拠が明確）
- 主要な修正は `QP-*` または同等の品質プロパティと検証結果に紐づいている
- 発見した gap を `Fix now` / `Guard now` / `Block` に分類し、Block は不足入力と AI 代替検討を記録済み
- `Fix now` / `Guard now` は修正後の検証失敗を読み、必要な再修正・再検証まで完了済み
- 大きな調査・複数観点・長いログ解析では原則サブエージェントを使い、使わない場合は理由を記録済み
- UI/UX と最初の修正観点以外を含む Coverage Sweep を実施済み。standard は追加 gap 最大 1 件、auto は安全に直せる gap が尽きるまで処理済み
- 検証が具体的（**コマンド・exit code・対象ファイル明示**）
- **依頼スコープ外への拡張をしていない**（やる価値があれば Next Steps に積んでいる）
- 仮説判断した場合は Done または Findings.対応 に根拠が記録されている
- 一時資材が残っていない
- 使い終わった terminal / task / dev server / watch / browser / emulator / local API を停止済み。残す場合は理由と停止方法を記録済み
- 新観点 3 件が優先度順、AI/User 担当が振られ、`[User]` は AI 代替を検討した形跡あり
- `.github/refine-product.md` があれば Next Focus を反映済み。なければ state なしとして扱った
- 100% Pass 判定が明示

## Stop Conditions

- `plan only` / `review only` 指定
- GATE でユーザーが終了を選んだ
- standard / auto / quick で **Prime Directive の 8 つの自問が全て no** になった（standard は追加修正 1 件上限を満たした場合も停止可）
- 同一原因の修正再試行が 3 回を超えた
- 安全上ユーザー確認が必要な操作に到達（その場合でも代替静的ガードを追加してから止まる）