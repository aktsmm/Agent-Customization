# Template Repository

このリポジトリは GitHub Copilot × VS Code を使ったエージェント/エージェントワークフロー開発の叩き台、テンプレートだよ。`.github` 配下には README とサンプル Markdown を 1 つずつ置いてあるから、必要に応じてコピーして使ってね。

> **Inspiration & Thanks**
>
> - https://github.com/openjny/dotgh — dotgh の方が高機能だから、本格的にテンプレートを量産したい場合はそっちのツールを使うと手っ取り早いよ。
> - https://zenn.dev/openjny/articles/4313236f8886e4 — dotgh 本体の解説記事。
> - https://zenn.dev/openjny/articles/2619050ec7f167 — runSubagent の要点。
> - https://zenn.dev/openjny/articles/e11450f61d067f — オーケストレーター構成のベストプラクティス。
>
> **Prompt Engineering Resources**
>
> - https://github.com/anthropics/prompt-eng-interactive-tutorial — Anthropic 公式のプロンプトエンジニアリング・インタラクティブチュートリアル。
> - https://www.anthropic.com/engineering — Anthropic のエンジニアリングブログ。エージェント設計やプロンプト最適化のヒントが豊富。
> - https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview — Claude プロンプトエンジニアリング公式ドキュメント。
> - https://github.com/anthropics/anthropic-cookbook — Anthropic 公式のレシピ集。実践的なコード例が多数。

> **External References (Prompts / Reviews)**
>
> - https://platform.openai.com/docs/guides/prompt-engineering — OpenAI のプロンプトエンジニアリング指針。
> - https://www.anthropic.com/engineering/building-effective-agents — エージェント設計の原則とワークフローパターン。
> - https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — コンテキスト設計の考え方と実践。
> - https://code.claude.com/docs/en/best-practices — Claude Code のベストプラクティス集。
> - https://learn.microsoft.com/azure/ai-services/openai/concepts/prompt-engineering — Azure OpenAI のプロンプト設計ガイド。
> - https://cloud.google.com/blog/products/application-development/five-best-practices-for-prompt-engineering — Google Cloud のプロンプトエンジニアリング Best Practices。
> - https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-engineering-guidelines.html — Amazon Bedrock のプロンプト設計ガイドライン。
> - https://www.promptingguide.ai/ — Prompt Engineering Guide（体系的なチートシート／手法集）。
> - https://www.ibm.com/think/prompt-engineering — IBM Think のプロンプトエンジニアリング解説。

## 収録内容

| パス                              | 説明                                                                                       |
| --------------------------------- | ------------------------------------------------------------------------------------------ |
| `.github/copilot-instructions.md` | 共有ガードレール。Copilot が最初に読み込み、回答トーンやレビュー方針を決める。             |
| `.github/agents/`                 | エージェント定義（`sample`, `orchestrator`）。新規エージェントを増やすときはこの例を複製。 |
| `.github/instructions/`           | ドメインガイド（`core/`, `dev/`, `agents/`, `integrations/` にカテゴリ分類）。             |
| `.github/prompts/`                | 再利用可能なプロンプト（設計、レビュー、計画、デバッグ、テスト、Git 操作など）。           |
| `AGENTS.md`                       | 登録済みエージェントの目次。新しいマニフェストを追加したらここにも追記する。               |

## 使い方

1. 必要なカテゴリ（エージェント / インストラクション / プロンプト）でサンプルファイルをコピーする。
2. ファイル名と内容をユースケースに合わせて編集し、`AGENTS.md` や README からリンクを張る。
3. Copilot Chat 側で `/agent <name>` を実行して期待通りに読み込めるか確認する。

> Copilot の話し方やレビュー順を変えたいときは `.github/copilot-instructions.md` を更新、自律タスクの流れや許可範囲を変えたいときは `AGENTS.md` を編集する。

### `.github/copilot-instructions.md` と `AGENTS.md` の違い

| 観点         | `.github/copilot-instructions.md`                      | `AGENTS.md`                                             |
| ------------ | ------------------------------------------------------ | ------------------------------------------------------- |
| 読む主体     | GitHub Copilot（補完/チャット/PR レビュー）            | Copilot Coding Agent や Codex などエージェント系ツール  |
| 役割         | 話し方・出力スタイル・レビュー順序を決める             | ビルド/テスト/デプロイ手順やタスク境界を定義            |
| 適用範囲     | リポジトリ内のすべての Copilot アクション              | エージェントモードでの自律作業（issue 対応、PR 作成）   |
| 内容の粒度   | 「日本語で答える」「ESLint/Prettier 準拠」などポリシー | `pnpm install` など具体コマンド、Git フロー、Boundaries |
| フォーマット | Markdown（構造自由）                                   | Setup / Commands / Boundaries など推奨セクション        |

#### 書き分けの例

- `.github/copilot-instructions.md` に書く: 「回答は日本語」「CLI は PowerShell 形式」「結論 → 手順の順」など普遍ルール。
- `AGENTS.md` に書く: 「依存インストールは `pnpm install`」「テストは `pnpm test`」「DB マイグレーションは触らない」など具体的フロー。

## カスタマイズのヒント

- コーディング規約やテスト方針は `.github/instructions/` にまとめておくと複数エージェントで共有しやすい。
- サンプルの英語コメントはそのままにして、日本語でインラインメモを足したい場合は ASCII で記述する。
- 追加のプロンプトが増えたら `.github/prompts/README.md` に簡単な使い分けを追記すると親切だよ。

## runSubagent 運用メモ

- 参考: https://zenn.dev/openjny/articles/2619050ec7f167 — サブエージェントを併用するとメインセッションのトークン消費を大きく減らせる反面、総トークン数と実行時間は増える。コンテキストをクリーンに保ちたいタスクで使うのがコツ。
- 得意分野は「長尺調査」「ログ解析」「ファイル単位の独立作業」「計画 → 実装 → レビューのような段階分離」。これらはテンプレから派生した自作エージェントでも再現しやすい。
- 苦手分野は「結果の深掘り」「軽量タスク」「前ステップの詳細を後段でも保持したいワークフロー」。runSubagent はステートレスなので追加質問ができない点に注意。
- サブエージェントは直列実行のみ。並列化は現状（2025-12 時点）非対応だから、URL ごとに投げる場合は時間がかかる前提でプロンプトに締め切りや最大試行回数を書いておくと暴走を防げる。

## エージェントワークフローの原則

1. **目的（アウトカム）を最初に固定する** — 何を作るのか・品質・形式を最初に決める
2. **タスクを「最小限の複数ステップ」に分割する** — 1 つの巨大エージェントに全部やらせない
3. **エージェントは単一責務（Single Responsibility）にする** — 調査・構成・執筆・校正など役割ごとに分離
4. **依存関係は一方向で作る（上 → 下）** — writer → planner に戻る等の循環構造は作らない
5. **エージェント間は"構造化データ"で受け渡しする** — YAML / Markdown / JSON で情報を渡す
6. **プロンプトは短く、作業指示だけにする** — 長文禁止、余計な説明禁止、出力形式を明確にする
7. **最終レビュー専用エージェントを必ず用意する** — 体裁 / 一貫性 / 事実誤り / 禁則事項をチェックする

## オーケストレーター構成メモ

- 参考: https://zenn.dev/openjny/articles/e11450f61d067f — runSubagent を「責任分離」のために使うオーケストレーター・パターンの実例。Issue/Plan/Impl/Review/PR をサブエージェントに委譲し、オーケストレーターは進行管理のみに集中させると破綻しにくい。
- 一例として、以下のように `.github/agents/` を分割しておくと役割ごとに差し替えやすい（プロジェクトによって最適構成は変わるので、必要な役割だけ残してね）。

  ```
  .github/agents/
  	orchestrator.agent.md  # 司令塔（コード編集しない）
  	issue.agent.md         # 要望整理と Issue 化
  	plan.agent.md          # 既存コード分析と実装方針
  	impl.agent.md          # TDD に沿った実装 & テスト
  	review.agent.md        # コードレビューと修正
  	pr.agent.md            # PR 作成と要約
  ```

- 各エージェントには Job Responsibility と「やらないこと」をセットで書く。責任境界が曖昧だと、オーケストレーターが勝手に解釈して暴走しやすいので、`.agent.md` 側で KPI/完了条件を箇条書きにする。
- モジュール化の利点: エージェント定義をファイル分割しておくと単体呼び出し・差分更新・チーム共有が楽。オーケストレーターもサブエージェントの定義を尊重し、独自解釈を足さないよう注意書きを入れると安定しやすい。
- コスト面: ユーザー → オーケストレーターへの指示は 1 リクエストで済む一方、内部ではサブエージェントの実行回数だけトークンが積み上がり待ち時間も伸びる。長時間処理を許容できるユースケースかを事前に README へ明記しておくと期待値差が減る。
- オートメーション阻害要因: `/dev/null` へのリダイレクトが VS Code の保護ポリシーに引っかかるため、各エージェント定義で「/dev/null を使わない」旨を記述する。エラーが続くときは人間にハンドオフするエスケープハッチ（例: 最大 3 回で中断）を入れておく。

## テンプレ更新フロー

1. まず `git status` で差分を確認。
2. ドキュメント変更のみならテストは不要。コードに影響する設定を加えた場合は関連スクリプトを案内する（例: `npm run test -- api`）。
3. `AGENTS.md` と各 README の参照が最新ファイルと一致しているか最後にもう一度チェックする。

---

## 🚀 エージェント・ワークフローの作り方

### エージェントを呼び出す

Copilot Chat で以下のショートカットを使う：

```
@workspace /agent sample
```

| エージェント | 呼び出し方                       | 用途                                 |
| ------------ | -------------------------------- | ------------------------------------ |
| Sample Agent | `@workspace /agent sample`       | エージェント定義のテンプレート確認   |
| Orchestrator | `@workspace /agent orchestrator` | 複数エージェントを統括する司令塔の例 |

### プロンプトを呼び出す

Copilot Chat で以下のショートカットを使う：

```
@workspace /prompt create-workflow
```

| プロンプト                     | 呼び出し方                                          | 用途                                     |
| ------------------------------ | --------------------------------------------------- | ---------------------------------------- |
| create-workflow                | `@workspace /prompt create-workflow`                | エージェント/ワークフロー作成（統合版）  |
| review-agents-and-instructions | `@workspace /prompt review-agents-and-instructions` | エージェント・instructions のレビュー    |
| plan-workflow                  | `@workspace /prompt plan-workflow`                  | タスク実行計画                           |
| design-workflow                | `@workspace /prompt design-workflow`                | ワークフロー設計                         |
| debug-error                    | `@workspace /prompt debug-error`                    | エラー分析・原因特定・解決               |
| write-tests                    | `@workspace /prompt write-tests`                    | テスト生成（計画 → 実装 → 検証）         |
| review-retrospective-learnings | `@workspace /prompt review-retrospective-learnings` | 振り返りと学びの抽出                     |
| review-session-export-md       | `@workspace /prompt review-session-export-md`       | セッション内容を Markdown でエクスポート |
| export-log                     | `@workspace /prompt export-log`                     | 汎用作業ログ（AI可読・構造化）           |
| wrap-up-work                   | `@workspace /prompt wrap-up-work`                   | 作業の締め・要約                         |
| gc_Commit                      | `@workspace /prompt gc_Commit`                      | 変更をコミット                           |
| gcp_Commit_Push                | `@workspace /prompt gcp_Commit_Push`                | コミットしてプッシュ                     |
| gpull                          | `@workspace /prompt gpull`                          | リモートからプル                         |
| sample                         | `@workspace /prompt sample`                         | プロンプト作成用テンプレート             |

### 推奨フロー

1. **新しいエージェント/ワークフローを作りたい** → `@workspace /prompt create-workflow` を呼び出す
2. **既存のエージェントをレビューしたい** → `@workspace /prompt review-agents-and-instructions` を呼び出す
3. **手動でエージェントを作りたい** → `.github/agents/sample.agent.md` をコピーして編集

---

## 🎯 ベストプラクティス

### Do ✅

- **単一責務**: 1 エージェント = 1 つの役割
- **IR 活用**: エージェント間は YAML/JSON で受け渡し
- **冪等性**: 同じ入力なら同じ結果
- **レビュー専用エージェント**: 最終チェックは分離する
- **エラーハンドリング**: リトライ上限とフォールバックを明記

### Don't ❌

- 1 つのエージェントに全部やらせる
- 循環依存（A → B → A）を作る
- 長文プロンプトを書く
- `/dev/null` へのリダイレクト
- `git push` を自動実行

---

このテンプレをベースに独自ガイドラインを組み立てて、チームの標準ワークフローに合わせてね。
