---
description: "Python 環境設定（仮想環境必須、uv 推奨、並列化パターン）"
applyTo: "**/*.py,**/pyproject.toml,**/requirements*.txt"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-07-13 -->

# Python Environment Instructions

## 基本ルール

- Python プロジェクトでは仮想環境を必須とし、グローバル環境や `pip install --user` へ直接インストールしない。
- 既存の `.venv`、`pyproject.toml`、`uv.lock`、`requirements*.txt` と repo の実行手順を先に確認し、既存の管理方式を尊重する。
- 新規環境は `uv venv` + `uv pip` を優先し、uv がない場合だけ標準 `venv` + `pip` を使う。
- 依存を追加・変更したら、repo が採用する `pyproject.toml`、lock file、または `requirements*.txt` に記録する。
- terminal 間で activation が共有されない場合は、`.venv\Scripts\python.exe` を直接呼ぶ。
- `py_compile` などが生成した `__pycache__/` や `*.pyc` を差分へ残さない。

基本コマンド:

```powershell
uv venv .venv --python 3.12        # uv（推奨）
python -m venv .venv               # 代替: 標準 venv
```

## よくあるエラーと対処

- `UnicodeEncodeError` や文字化けが出たら、PowerShell / subprocess の UTF-8 設定と出力ファイル本体を確認し、表示だけの問題か切り分ける。
- `externally-managed-environment` が出たら system Python を変更せず、仮想環境を作成して依存を導入する。
- interpreter path が無効なら、削除前に対象が workspace の `.venv` であることを確認してから再作成する。

## ProcessPoolExecutor 並列化パターン（Windows 対応）

### 必須ルール

- Windows は spawn のため、worker 関数と initializer はモジュールレベルに定義し、`if __name__ == "__main__"` ガードを置く。
- 認証やレート制限のある外部 API は main process で取得し、worker へ必要データだけ渡す。

### パフォーマンス設計

- 大きな共有データは initializer で一度だけ渡し、タスク引数と戻り値を小さく保つ。
- 進捗が必要なら `as_completed()` で完了数、経過時間、rate、ETA を間引いて出す。

---

## Out of Scope Here

- uv / pyenv の導入手順（uv 公式: https://docs.astral.sh/uv/ を参照）
- パッケージマネージャーの詳細比較
- 長いセットアップ tutorial

それらは uv 公式 docs や repo の onboarding 手順に分ける。
