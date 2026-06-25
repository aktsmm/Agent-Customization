---
name: "review-workflow-runtime"
description: "ワークフロー定義と参照 scripts/hooks/validators を横断し、実行時ロジック・I/O・冪等性・冗長処理・検証ゲートをレビューし、低リスク修正まで行う"
argument-hint: "対象パス、all / FIX / review-only、重点観点"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# review workflow runtime

ワークフロー定義と、それが参照する scripts / hooks / validators / CLIs を横断して、実行時に本当に安全に動くかをレビューする。

## When to Use

- 使う: agent / prompt / instruction / AGENTS が scripts / hooks / validators / CLI を参照している workflow を確認したいとき
- 使う: `dry-run -> apply -> verify`、I/O schema、冪等性、重複防止、cleanup、error handling が実装と一致しているか見たいとき
- 使う: scripts の冗長な処理、重複関数、長すぎる分岐、不要な手順を見つけて安全に整理したいとき
- 使う: workflow が「設計上は良い」が、実スクリプトや実行手順まで噛み合っているか不安なとき
- 使わない: agent / instruction / prompt の構造・SSOT だけを見たいとき。その場合は `/review-workflow-structure` を使う
- 使わない: 通常のコード品質レビューだけをしたいとき。その場合は通常の review として扱う

## Default Behavior

- 既定スコープは `referenced-only`: 対象 workflow 資産から明示参照された scripts / hooks / validators / CLIs だけを追う
- `all` / `徹底的` / `deep` が指定された場合は、参照された script と同じ workflow folder / scripts folder の近接ファイルも確認する
- 既定の修正モードは `safe-auto-fix`: 低リスク修正は実施してよい
- `review-only` が指定された場合は変更しない
- destructive operation、外部反映、認証・secret、履歴改変、広範囲 refactor は実行前に確認する

## Reference Sources

ワークスペース内に存在する場合は、次を補助 SSOT として読む。

- `.github/skills/agentic-workflow-guide/SKILL.md`
- `.github/skills/agentic-workflow-guide/references/review-checklist.md`
- `.github/instructions/**.instructions.md` のうち対象 script / workflow に apply されるもの
- `AGENTS.md` / `.github/copilot-instructions.md` / 関連 `.agent.md` / `.prompt.md`

存在しない場合は、この prompt 単体のチェック項目でレビューを続行する。

## Context Gate

1. 対象 workflow 資産を特定する。
2. Markdown links、backtick path、code block、CLI examples、script 名から参照 script / hook / validator を抽出する。
3. 抽出した path が実在するか確認する。
4. script が存在しない場合は `missing script contract` として報告する。
5. script が見つからない workflow は、workflow logic review のみ実施し、script coverage が無いことを明記する。

## Review Checks

### 1. Workflow Logic

- trigger / mode / phase / stop condition が明確か
- preflight、apply、verify、cleanup の順序が実行可能か
- user confirmation が必要な判断と、自動実行してよい判断が分かれているか
- retry / resume / partial failure の扱いがあるか

### 2. Script Contract

- script path が実在し、呼び出し例と一致しているか
- CLI args、default 値、required args、exit code、stdout/stderr の前提が workflow 側と一致しているか
- `--help`、schema、README、docstring のいずれかで使用法を確認できるか
- dry-run / apply / verify の境界が実装または runbook にあるか
- script output が後続 agent / prompt の期待する JSON / Markdown / file に合っているか

### 3. Idempotency and Safety

- 再実行で重複作成、二重投入、二重送信、二重削除が起きないか
- 既存 state / artifact / ID を確認してから mutation するか
- destructive operation は明示 flag や confirmation を要求するか
- secret、token、local absolute path、個人環境値を出力や成果物へ混ぜないか

### 4. Deterministic Offload

- extract / count / validate / diff / format / parse / lint が LLM ループに残っていないか
- LLM 判断の前後に、script / schema / hook による fail-fast gate があるか
- file-based IR を使う場合、materialize する理由と cleanup 方針があるか

### 5. Script Simplicity

- 同じ処理、同じ validation、同じ CLI 呼び出し、同じ変換ロジックが重複していないか
- 長い if / switch / try-catch / copy-paste block を小さな helper へ切り出せるか
- 設定値、path、magic number、出力 schema を複数箇所に持っていないか
- 1 コマンドや既存 helper で済む連続処理を script / prompt / agent が重ねていないか
- リファクタ後も CLI contract、exit code、output schema、side effect が変わらないか

### 6. Verification

可能な範囲で read-only / deterministic な確認を実行する。

- Markdown link / referenced path の存在確認
- Python: 構文確認、該当テスト、`--help`、安全な dry-run
- PowerShell: `[scriptblock]::Create((Get-Content -Raw -Encoding UTF8 <file>))`
- Node: package scripts、typecheck、lint、dry-run 相当
- 実行できない場合は、理由と代替確認を明記する

## Safe-Auto-Fix Policy

既定の `safe-auto-fix` で自動修正してよいもの。

- 壊れた相対リンクや stale script path の修正（正しい実在 path が一意に分かる場合）
- workflow 資産側の CLI example / option 名 / output field 名の修正（script 実装が正本として確認できる場合）
- frontmatter、typo、deprecated wording、明らかな重複説明の圧縮
- 冗長な helper / validation / option handling の統合（CLI contract、output schema、side effect が変わらない場合）
- 長い処理を読みやすい小関数へ切り出すリファクタ（テストまたは構文確認で検証できる場合）
- read-only validation のための一時 script 作成と作業後 cleanup
- 小さな guard / validation 追加で、外部副作用や既存 CLI contract を変えないもの

確認してから行うもの。

- script の mutation behavior、外部 API 呼び出し、認証、削除、submit、publish、apply を変える修正
- CLI contract の破壊的変更
- 大きな refactor、ファイル移動、履歴改変
- 性能改善や抽象化を目的にした、挙動差を検証しにくい rewrite
- 一意に正しい path / schema / expected behavior が判断できない修正

## Output Format

### ✅ Good Points

- {良い点}

### ⚠️ Improvements Needed

- {優先度} [{削除|統合|分離|移動|追加|維持|修正}] {カテゴリ}: {file}:{line} -> {解決策} | Impact={runtime-affected|review-only} | Evidence={script/doc/test}

### Script Contract Matrix

| Workflow Asset | Referenced Script / Tool | Contract Status | Verification |
| --- | --- | --- | --- |
| {path} | {script} | PASS / MISMATCH / MISSING / NOT_RUN | {確認内容} |

### Fixes Applied

- {変更したファイルと理由。review-only の場合は `None`}

### Verification

- {実行した検査、exit code、未実行理由}

### Recommendation

- {総合評価と次アクション}

## Completion Criteria

- 対象 workflow 資産を読んだ
- 参照 scripts / hooks / validators / CLIs を抽出した
- 実在確認と contract 照合をした
- script output と workflow input の整合性を確認した
- 冗長処理、重複ロジック、不要な連続手順を確認した
- dry-run / apply / verify / cleanup の境界を確認した
- safe-auto-fix の範囲内で必要な修正を行った、または review-only として停止した
- 検証結果と未確認リスクを報告した
