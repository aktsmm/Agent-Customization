---
name: "Refine Product 100"
description: "プロダクトを機能・非機能・UI/UX で徹底レビューし、修正・テスト・同観点スイープ・ドキュメント整備・不要物削除まで自律実行。妥協なく 100% パスを目指す汎用プロンプト。リリース指示があれば品質 gate 後に配布まで進める"
argument-hint: "対象、重点観点、モード（例: current workspace / all / auto / quick / release）"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- updated: 2026-05-11 -->

# refine product 100

機能・非機能・UI/UX の観点で対象プロダクトを徹底レビューし、修正・テスト・同観点スイープ・ドキュメント整備・不要物削除まで自律実行する。**妥協しない**。100% の出力と言えるところまで押し込む。

種別不問の汎用プロンプト（コード / ドキュメント / スライド / 運用手順 / プロンプト / データ・AI 等）。

## Prime Directive

最初から 100% を目指す。「案内だけで終わる」「95% で満足」「検証せず完了」「1 件直して同根を放置」は禁止。

止まる前の自問（**1 つでも yes ならまだ止まらない**）:
1. 安全に直せる gap が残っていないか
2. 同根原因で他に修正できる箇所がないか（grep スイープしたか）
3. 回帰防止テスト・静的ガードを追加できないか
4. README・ヘルプ・設定説明が古い/不一致のまま残っていないか
5. 不要ファイル・dead code・検証用一時資材が残っていないか
6. 配布物に不要物が混入していないか
7. 最初の修正観点以外に別軸の gap が残っていないか
8. 不要な terminal / task / dev server が残っていないか

実機確認が必須でも、**機械的代替を最低 1 つ追加してから** 止まる。

## Inputs / Modes

- Target: 対象（current workspace / src / 特定モジュール）
- Focus: 重点観点（機能 / 非機能 / UIUX / security / docs / cleanup / all）
- Mode: plan only / review only / confirm / standard / auto / quick（空欄は standard）

| Mode | 動作 |
| --- | --- |
| `plan only` | 計画だけ。編集しない |
| `review only` | 指摘だけ。編集しない |
| `confirm` | 計画と GATE を出してから編集 |
| `standard` | high-confidence gap を 1 サイクル閉じ + Sweep。追加 gap は最大 1 件、残りは Next Steps |
| `auto` | 安全に直せる gap が尽きるまで複数サイクル |
| `quick` | P0/P1 と検証だけ。Sweep / Docs / Cleanup は「なし」で省略可 |
| `release` | `auto` の品質改善ループを完了後、ソフトウェア配布物なら Version sync → test/audit/build/pack/hygiene → commit → push → publish → GitHub Release → 裏取り → cleanup まで進める |

Release intent:

- `Release`, `release`, `リリース`, `公開`, `publish`, `PushPublish`, `Marketplace`, `マケプレ` が入力に含まれる場合は full release intent と扱う。
- 明示 Release intent がある場合、確認不能を理由に local prep へ縮退しない。
- Release intent は品質改善ループをスキップしない。§5 と §5.5 を通過してから §8 に進む。
- ただし secret / 本番データ / 破壊的履歴改変 / credentials 不足 / 外部サービス認証失敗 / duplicate version などの Block は記録し、非破壊の Guard now を先に試す。
- ドキュメント等は最終チェック + 配置手順を Next Steps に書く。

## Safety Constraints

- ワークスペース内のユーザー所有物に限定
- secret / token / 個人情報を出力・保存しない
- `git push` / publish / deploy は §Release Loop または明示 Release intent がある場合のみ実行する。明示 Release intent がある場合は full release 完了を期待値とする
- 破壊的操作・データ削除・外部公開は事前確認なし不可
- 依頼範囲外（新規設定追加・無関係リファクタ・仕様変更）は勝手に始めず Next Steps に積む

## Safe-to-Fix Gate

安全とは「小さい変更」ではなく、**依頼範囲内・可逆・ローカル検証可能・外部公開なし・secret/本番/個人データなし・影響範囲と正しさを説明できる**こと。

| 分類 | 条件 |
| --- | --- |
| `Fix now` | 依頼範囲内、正しさを説明可能、ローカル検証可能、非破壊的 |
| `Guard now` | 本修正は不可だが、回帰テスト・静的ガード・docs 等の機械的代替でリスク低減可能 |
| `Block` | 破壊的 / 外部公開 / 本番データ / 仕様判断が必要 → 不足入力 + AI 代替検討を記録 |

`Block` は完了逃げに使わない。不足入力・AI 代替を試した内容・次の確認を必ず残す。破壊的変更が最善に見えても auto で実行しない。互換 shim / feature flag off / deprecation warning / dry-run / backup 手順 / 静的ガードなど非破壊 `Guard now` を先に試す。

修正 → 検証 → 失敗原因読解 → 再修正のループは同一原因で最大 3 回。超えたら Block。

## Workflow

### 1. Context

種別推定、entry points・検証手段・プロジェクト固有 instruction を読む。`.github/refine-product.md` があれば前回 state を反映。

**連続実行ラチェット**: 前回と同じ観点だけにせず、**最低 1 件は別軸を含める**。同観点継続なら理由を Findings に明記。

**自律性原則**: Safety Constraints・ユーザー指示・既存 instruction の範囲内で進められる場合は質問で止まらず、既存コード・テスト・ドキュメントから high-confidence な仮説を置いて実装・検証する。判断根拠は Done または Findings.対応に記録。曖昧で破壊的・不可逆な選択は Next Steps に積む。

**サブエージェント委任**: 大規模 repo / 複数観点 Sweep / 長いログ解析では read-only 調査に限定して原則使用。依頼は「対象範囲、観点、編集禁止、返す形式」を明確に。secret・外部公開・破壊的操作は委任しない。使わない場合は理由を最終報告に残す。

### 2. Verification Health Check

検証パイプラインが現状 PASS するか確認。失敗したらスクリプト自体の壊れも疑う。

### 3. 全観点レビュー

🔴🟡🟢 マーカー付きで指摘。

| カテゴリ | 主要観点 |
| --- | --- |
| 機能 | ユースケース、境界値、失敗経路、状態遷移、後方互換 |
| 非機能 | 性能、信頼性、セキュリティ、互換性、保守性 |
| UI/UX | 視認性、導線、Affordance、Feedback、Recovery |
| その他 | アクセシビリティ、エラー復旧、テストカバレッジ、ドキュメント |

🔴 P0: 主要機能破壊・データ損失・情報露出 / 🟡 P1: 導線混乱・テスト不在・README 不一致 / 🟢 P2: 品質改善・文言・dead code

### 4. GATE（confirm モードのみ）

### 5. Implement → Sweep → Verify → Repeat

1. **Implement**: 最小差分で修正。既存設計・命名・テストパターンに合わせる
2. **Sweep**: 同根原因を全文検索で洗い出し、まとめて直す（**1 件で満足禁止**）
3. **Test**: 回帰防止テスト追加。実機/外部依存で閉じない箇所は機械的代替（manifest 整合・文言同期・契約テスト）
4. **Verify**: diagnostics → lint → typecheck → test → build
5. **Repeat**: 検証失敗は原因を読み Fix now / Guard now / Block に再分類。テスト期待値更新は、既存仕様・README・テスト・後方互換を確認し実装が正しいと説明できる場合のみ

実行ルール: 既存 scripts/CI 優先、ターミナルは非対話・単発・timeout 付き、watch/dev server は起動しない。使い終わった terminal は原則閉じ、残す場合は理由を最終報告に書く。

### 5.5. Coverage Sweep（standard / auto 必須）

修正後に全観点を再スイープ。standard は追加 1 件まで修正、auto は gap が尽きるまで。quick は P0/P1 限定。

### 6. Documentation Sweep

修正に応じて README / Quick Start / ヘルプ / エラーメッセージ / CHANGELOG / 用語一貫性を同期。

### 7. Cleanup

不要な一時ファイル / dead code / 検証用資材を削除。迷うものは Next Steps へ。terminal / task / dev server は停止。

### 8. Release Loop（ソフトウェア配布物 + 明示 Release intent 時）

ドキュメント等は skip。ソフトウェア配布物で明示 Release intent がある場合は、§5/§5.5 の品質改善ループを完了してから full release まで進める。

「配布まで進めますか？」の確認は、Release intent が曖昧な場合だけ行う。`Release` / `publish` / `PushPublish` / `Marketplace` / `マケプレ` が明示されている場合は確認待ちで local prep に縮退しない。

1. **公開前重複確認**: 対象 version が既に公開済みでないか確認（既存ならパッチを上げる）
2. **Version sync**: package メタ / lockfile / バージョン表示 / CHANGELOG / release notes を同時更新
3. **必須テスト**: typecheck / lint / unit / integration / 依存脆弱性監査
	- `npm audit` 等の監査は publish 前 gate。Fix now 可能なものは直して再検証する。
	- 残件がある場合は、dev-only / upstream fix なし / semver-major 等を分類し、publish 可否を Findings と Safe-to-Fix に明記する。
4. **Build + Pack**: 配布形態に応じた pack（vsix / npm / python / docker 等）
5. **配布物 Hygiene Check**: 中身を必ず列挙し、開発資材（src / test / .github / .vscode / sourcemap / 内部設計資料）混入なしを確認。混入時は publish せず ignore 設定修正 → 再パッケージ。ignore 修正も commit に含める
6. **Commit**: `[Release] vX.Y.Z - <要約>` → Push → Publish（duplicate-safe オプション使用。`already published` は version 上げ直し）
7. **裏取り**: 公開状態を別経路で確認（API 応答だけ信用しない）
	- Marketplace / package registry / GitHub Release など、公開先ごとに別経路で確認する。
	- VS Code Marketplace は HTML 表示が遅延・キャッシュされることがあるため、`vsce show <publisher.extension> --json` の version metadata を優先して確認する。
	- 配布物 SHA256 とサイズを release notes に反映する。
8. **後片付け**: 検証用一時資材を削除

### 9. State Update（任意）

`.github/refine-product.md` が既存なら Run Meta / Next Focus を上書き。存在しなければ作成しない。

## Final Response Format

```markdown
## Done
- {修正内容。自律性原則で仮説判断した場合は根拠も短く併記}

## Sweep
- {同根の横展開。なければ「なし」}

## Check
各検証コマンドと pass/fail (exit code) を 1 行ずつ。失敗したものは「→ 修正後 PASS」も併記。
例:
- `npm test`: PASS (exit 0)
- `node scripts/test-foo.js`: FAIL (exit 1) → 期待値修正後 PASS (exit 0)

## Findings
| Marker | Priority | QP | 観点 | 内容 | 対応 |
| --- | --- | --- | --- | --- | --- |

## Safe-to-Fix 判定
- Fix now / Guard now / Block: {各一覧}

## Coverage Sweep
- 再確認した観点 / 追加で直したもの / 残した観点 / Subagent 使用有無

## Documentation / Cleanup（該当時のみ）

## 100% Pass 判定

## Next Steps（優先度順、[AI] / [User] 担当付き）

`[User]` と書く前に、AI 代替（回帰テスト・静的ガード・チェックリスト）で閉じられないか必ず検討する。

### 新観点（最大 3 件、前回と同観点だけにしない）
### 再発防止
```

## Self-Check（最終報告前に 1 回）

- Sweep 実施済み
- 発見 gap を Fix now / Guard now / Block に分類済み。Block は不足入力と AI 代替検討を記録済み
- Fix now / Guard now は修正後の検証失敗を読み、再修正・再検証まで完了済み
- Coverage Sweep 実施済み
- 検証が具体的（コマンド・exit code 明示）
- 依頼スコープ外への拡張なし
- 仮説判断した場合は Done または Findings.対応に根拠が記録済み
- 一時資材・terminal 残留なし
- サブエージェントを使わなかった場合は理由を記録済み
- 新観点 3 件が優先度順、AI/User 担当が振られ、`[User]` は AI 代替検討済み
- 100% Pass 判定が明示

## Stop Conditions

- plan only / review only 指定
- GATE でユーザーが終了を選んだ
- Prime Directive の 8 自問が全て no
- 同一原因の再試行が 3 回超過
- 安全上ユーザー確認が必要（代替ガード追加後に停止）