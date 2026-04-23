---
applyTo: "**"
---

<!-- description: Microsoft 公式ドキュメント参照（MCP ツール活用、ソース明記） -->

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Microsoft Documentation Instructions

Microsoft 製品に関するコード生成・回答を行う際のドキュメント参照ガイドラインです。

---

## 1. 基本方針

Microsoft/Azure 関連の質問やコード生成を行う際は、**最新の公式ドキュメント**を参照して回答の正確性を担保してください。

### MCP ツール一覧

| MCP サーバー      | 用途                             | いつ使う？                                              |
| ----------------- | -------------------------------- | ------------------------------------------------------- |
| **Docs**          | ドキュメント検索・コードサンプル | ✅ 基本はこれ（ハウツー、API 仕様、ベストプラクティス） |
| **Azure Updates** | サービスアップデート情報         | 🆕 新機能・廃止予定・GA 情報を知りたいとき              |

### 使い分けフロー

```
質問の種類は？
├─ 「〜の使い方は？」「〜のコード例は？」 → Docs MCP
├─ 「最近のアップデートは？」「いつGAになった？」 → Azure Updates MCP
└─ 両方必要なケース → Docs で概要 → Updates で最新情報を補完
```

### 必須手順

1. **MCP ツールの活用**: 上記のツールを使用して最新情報を取得する
2. **ソース明記**: 回答には必ず参照元 URL を含める
3. **バージョン確認**: API やサービスのバージョンに注意し、最新の推奨方法を提示する

---

## 2. 参照すべき公式リソース

### 2.1 Microsoft Learn ドキュメント

| リポジトリ                                                     | 用途                                  | 備考                |
| -------------------------------------------------------------- | ------------------------------------- | ------------------- |
| [MicrosoftDocs/learn](https://github.com/MicrosoftDocs/learn)  | Cloud & AI トレーニングコンテンツ     | 閲覧のみ（PR 不可） |
| [MicrosoftDocs Organization](https://github.com/MicrosoftDocs) | Azure・各種製品の公式ドキュメント     | PR 受付可能         |
| [MicrosoftLearning](https://github.com/MicrosoftLearning)      | コース・ラボ教材（AZ-400、AZ-700 等） | 567+ リポジトリ     |

### 2.2 主要なラボ教材リポジトリ例

- `MicrosoftLearning/mslearn-azure-ml` - Azure Machine Learning
- `MicrosoftLearning/AZ-400-DesigningandImplementingMicrosoftDevOpsSolutions` - DevOps
- `MicrosoftLearning/AZ-700-DesigningandImplementingMicrosoftAzureNetworkingSolutions` - ネットワーク
- `MicrosoftLearning/SC-401T00A-Administering-Microsoft-365-Security` - セキュリティ

---

## 3. Docs MCP ツールの使用ガイド

### 3.1 検索ワークフロー

```
1. microsoft_docs_search  → 概要・関連ドキュメントの発見
2. microsoft_code_sample_search → コードサンプルの取得
3. microsoft_docs_fetch → 詳細情報・完全なコンテンツの取得
```

### 3.2 ツール選択基準

| シナリオ                             | 使用ツール                     |
| ------------------------------------ | ------------------------------ |
| Azure/Microsoft 製品の概要を知りたい | `microsoft_docs_search`        |
| 具体的なコード例が必要               | `microsoft_code_sample_search` |
| 詳細な手順・チュートリアルが必要     | `microsoft_docs_fetch`         |
| 特定リポジトリのコードを参照したい   | `github_repo` ツール           |

### 3.3 使用例

```markdown
# 質問: Azure Functions の Python での書き方を教えて

## エージェントの行動:

1. `microsoft_docs_search` で "Azure Functions Python" を検索
2. `microsoft_code_sample_search` で Python コードサンプルを取得
3. 必要に応じて `microsoft_docs_fetch` で詳細ページを取得
4. 回答に参照 URL を明記
```

---

## 4. GitHub リポジトリの直接参照

MCP ツールで情報が不足する場合は、`github_repo` ツールで直接リポジトリを検索してください。

### 検索例

```
repo: "MicrosoftDocs/azure-docs"
query: "app service deployment slots"
```

---

## 5. 回答フォーマット

Microsoft 製品に関する回答には、以下を含めてください：

### 必須項目

- ✅ **参照元 URL**: 公式ドキュメントへのリンク
- ✅ **API バージョン**: 使用している API のバージョン（該当する場合）
- ✅ **更新日の確認**: ドキュメントが古い場合はその旨を注記

### 推奨フォーマット

```markdown
## 回答

[回答内容]

### 参照ソース

- [ドキュメントタイトル](URL) - Microsoft Learn
- API バージョン: 2024-01-01
```
