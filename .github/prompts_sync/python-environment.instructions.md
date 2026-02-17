---
---

<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Python 環境

- パッケージ管理は `uv venv` + `uv pip` を使う（pip 直は NG）
- ワークスペースごとに `.venv` を作成
- LFS ファイルは `git lfs pull` してから使用

## ProcessPoolExecutor 並列化パターン（Windows 対応）

### 必須ルール

- **Windows は spawn**: worker 関数・initializer はモジュールレベル定義。ローカル関数/lambda は pickle 不可
- **`if __name__ == "__main__"` ガード必須**: spawn がモジュールを再 import するため
- **外部 API (yfinance 等) は main process のみ**: ワーカーからのネットワーク呼び出しはレート制限・認証問題の原因

### パフォーマンス設計

- **Initializer パターン**: 大きなデータ (DataFrame 等) は `ProcessPoolExecutor(initializer=fn, initargs=(data,))` でワーカーのグローバル変数に 1 回だけセット。タスクはパラメータのみ送受信
- **Slim IPC**: ワーカーは最小限の集計値 dict のみ返す。巨大オブジェクト (dataclass リスト, numpy 配列) は confirmed 結果のみ main process で再実行して取得
- **進捗表示**: `as_completed()` ループで N 件ごとに elapsed / rate / ETA を stderr に出力
