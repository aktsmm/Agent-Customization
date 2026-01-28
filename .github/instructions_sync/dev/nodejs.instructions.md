---
applyTo: "**/*.{js,ts,mjs,cjs,jsx,tsx},**/package.json"
---

<!-- syncToGlobal: true -->

# Node.js Environment Instructions

Node.js プロジェクトでは**バージョン管理ツールを使用**してください。直接インストールよりも柔軟に対応できます。

---

## 推奨: nvm-windows

[nvm-windows](https://github.com/coreybutler/nvm-windows) は Node.js のバージョンを切り替えられるツール。プロジェクトごとに異なるバージョンを使い分けられます。

```powershell
# バージョン確認
nvm version

# インストール可能なバージョン一覧
nvm list available

# Node.js LTS をインストール
nvm install 20

# バージョン切り替え
nvm use 20

# インストール済み一覧
nvm list
```

## 代替: fnm

[fnm](https://github.com/Schniz/fnm) は Rust 製で高速。`.node-version` ファイルで自動切り替え可能。

```powershell
# インストール
winget install Schniz.fnm

# Node.js をインストール
fnm install 20
fnm use 20
```

---

## パッケージマネージャー

| ツール   | 特徴                            |
| -------- | ------------------------------- |
| **npm**  | 標準、安定                      |
| **pnpm** | 高速、ディスク効率              |
| **yarn** | Facebook 製、ワークスペース対応 |

```powershell
# pnpm を使う場合
npm install -g pnpm
pnpm install
```

---

## エージェントへの指示

1. **nvm でバージョン確認** — `nvm list` で現在のバージョンを確認
2. **package.json を尊重** — `engines` フィールドがあれば従う
3. **lock ファイルを維持** — `package-lock.json` / `pnpm-lock.yaml` をコミット
4. **グローバルインストールは最小限** — 開発ツール以外は devDependencies へ

---

## やってはいけないこと

- ❌ `npm install -g <package>` の多用（devDependencies 推奨）
- ❌ `package-lock.json` / `pnpm-lock.yaml` の削除（再現性が壊れる）
- ❌ `node_modules/` をコミット
- ❌ `engines` フィールドを無視したバージョンで実行
- ❌ 異なるパッケージマネージャーの混在（npm と pnpm を同一プロジェクトで使うなど）

---

## 検証方法

```powershell
# Node.js バージョン確認
node --version

# 依存関係の整合性チェック
npm ci  # または pnpm install --frozen-lockfile

# 脆弱性スキャン
npm audit

# package.json の engines フィールド確認
npm pkg get engines
```
