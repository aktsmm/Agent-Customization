---
applyTo: "**/*.py,**/pyproject.toml,**/requirements*.txt"
---

<!-- description: Python 環境設定（仮想環境必須、uv 推奨、並列化パターン） -->

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Python Environment Instructions

Python プロジェクトでは**必ず仮想環境を使用**してください。グローバル環境への直接インストールは禁止です。

## 基本ルール

- パッケージ管理は `uv venv` + `uv pip` を使う（pip 直は NG）
- ワークスペースごとに `.venv` を作成
- LFS ファイルは `git lfs pull` してから使用

---

## 推奨: uv

[uv](https://docs.astral.sh/uv/) は pip より 10〜100 倍高速な Rust 製パッケージマネージャー。pip / venv / pyenv を 1 つに統合します。

### uv のメリット

- **高速**: pip の 10〜100 倍速（Rust 製）
- **統合**: Python バージョン管理 + 仮想環境 + パッケージ管理を 1 ツールで
- **互換**: pip コマンドと同じ感覚で使える（`uv pip install`）
- **ロックファイル**: `uv.lock` で再現性を担保

```powershell
# インストール
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Python & 仮想環境
uv python install 3.12
uv venv --python 3.12

# パッケージ
uv pip install requests pandas
```

## 代替: venv（標準）

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

---

## エージェントへの指示

1. **仮想環境を先に作成** — `uv venv` または `python -m venv .venv`
2. **有効化を確認** — `python -c "import sys; print(sys.executable)"` でパスをチェック
3. **依存関係を記録** — `requirements.txt` または `pyproject.toml` を更新
4. **グローバル禁止** — `pip install --user` も NG

---

## よくあるエラーと対処

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

### Failed to inspect Python interpreter

古い `.venv` が壊れている場合に発生。

```
error: Failed to inspect Python interpreter from virtual environment at `.venv\Scripts\python.exe`
```

**対処**: 仮想環境を再作成

```powershell
Remove-Item .venv -Recurse -Force
uv venv .venv --python 3.12
```

### No Python at ...

Python のパスが変わった場合に発生。

**対処**: `uv venv` で再作成

---

## 仮想環境なしで直接実行

有効化せずに Python スクリプトを実行:

```powershell
.venv\Scripts\python.exe -c "import pandas; print(pandas.__version__)"
.venv\Scripts\python.exe script.py
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
