---
description: "Python 環境設定（仮想環境必須、uv 推奨、並列化パターン）"
applyTo: "**/*.py,**/pyproject.toml,**/requirements*.txt"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Python Environment Instructions

Python プロジェクトでは**必ず仮想環境を使用**してください。グローバル環境への直接インストールは禁止です。

## 基本ルール

- パッケージ管理は [uv](https://docs.astral.sh/uv/)（`uv venv` + `uv pip`）を優先する（pip 直は NG）。uv は pip 互換コマンドと `uv.lock` で再現性を担保する
- uv が無い場合のみ標準 `venv` + `pip` を使う
- ワークスペースごとに `.venv` を作成する
- LFS ファイルは `git lfs pull` してから使用する

基本コマンド:

```powershell
uv venv .venv --python 3.12        # uv（推奨）
python -m venv .venv               # 代替: 標準 venv
```

有効化せず直接実行する場合は `.venv\Scripts\python.exe script.py` のようにフルパスで呼ぶ。

---

## エージェントへの指示

1. **仮想環境を先に作成** — `uv venv` または `python -m venv .venv`
2. **有効化を確認** — `python -c "import sys; print(sys.executable)"` でパスをチェック
3. **依存関係を記録** — `requirements.txt` または `pyproject.toml` を更新
4. **グローバル禁止** — `pip install --user` も NG
5. **検証後の掃除** — `py_compile` などで生成した `__pycache__/` や `*.pyc` を差分へ残さない

---

## よくあるエラーと対処

### Windows PowerShell で `UnicodeEncodeError: 'cp932' codec can't encode character '\xa5'`

Python CLI が `¥` などの非ASCII文字を `print` するとき、PowerShell の標準出力エンコーディングが cp932 だと落ちる。

**対処**: スクリプト冒頭で stdout を UTF-8 ラッパに差し替える。

```python
import io, sys
if hasattr(sys.stdout, "buffer"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", line_buffering=True)
```

コンソール表示が `ﾂ･` 等に化けても**ファイル本体は正常**なケースが多い。デバッグ時は出力ファイルを別エディタで開いて確認する。

### externally-managed-environment エラー

uv 管理の Python に直接 `pip install` しようとすると発生。

```
error: externally-managed-environment
× This environment is externally managed
╰─> This Python installation is managed by uv and should not be modified.
```

**対処**: 仮想環境を作成してからインストール

```powershell
uv venv .venv --python 3.12
.venv\Scripts\activate
uv pip install pandas openpyxl
```

### Failed to inspect Python interpreter / No Python at ...

壊れた `.venv` や Python パス変更で発生。対処は再作成。

```powershell
Remove-Item .venv -Recurse -Force
uv venv .venv --python 3.12
```

---

## ProcessPoolExecutor 並列化パターン（Windows 対応）

### 必須ルール

- **Windows は spawn**: worker 関数・initializer はモジュールレベル定義。ローカル関数/lambda は pickle 不可
- **`if __name__ == "__main__"` ガード必須**: spawn がモジュールを再 import するため
- **外部 API (yfinance 等) は main process のみ**: ワーカーからのネットワーク呼び出しはレート制限・認証問題の原因

### パフォーマンス設計

- **Initializer パターン**: 大きなデータ (DataFrame 等) は `ProcessPoolExecutor(initializer=fn, initargs=(data,))` でワーカーのグローバル変数に 1 回だけセット。タスクはパラメータのみ送受信
- **Slim IPC**: ワーカーは最小限の集計値 dict のみ返す。巨大オブジェクト (dataclass リスト, numpy 配列) は confirmed 結果のみ main process で再実行して取得
- **進捗表示**: `as_completed()` ループで N 件ごとに elapsed / rate / ETA を stderr に出力

---

## Out of Scope Here

- uv / pyenv の導入手順（uv 公式: https://docs.astral.sh/uv/ を参照）
- パッケージマネージャーの詳細比較
- 長いセットアップ tutorial

それらは uv 公式 docs や repo の onboarding 手順に分ける。
