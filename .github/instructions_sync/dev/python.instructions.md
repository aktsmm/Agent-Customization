---
applyTo: "**/*.py,**/pyproject.toml,**/requirements*.txt"
---

<!-- syncToGlobal: true -->

# Python Environment Instructions

Python プロジェクトでは**必ず仮想環境を使用**してください。グローバル環境への直接インストールは禁止です。

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
