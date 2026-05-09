---
description: "命名規約（ファイル名、フォルダ名、生成物、カスタマイズ資産）"
applyTo: "**"
---


<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# Naming Conventions

ファイル、フォルダ、生成物、Copilot customization 資産の軽量な命名ルール。

## Default Rule

- 原則は lower-case の kebab-case: `monthly-report-summary.md`。
- 名前は 3〜5語程度で、用途が分かるようにする。
- スペース、意味の薄い略語、頭字語だけの名前、ローカル絶対パス由来の名前は避ける。
- 日本語ファイル名は、ユーザー向け成果物や既存資料名に合わせる必要がある場合だけ使う。

## Folders and Artifacts

- フォルダは複数ファイルを含むなら複数形、単一概念なら単数形にする。
- 中間生成物は `output/`, `tmp/`, `work/`, `artifacts/` など用途別フォルダへ分ける。
- 日付付き成果物は `YYYY-MM-DD-topic-purpose.ext` を優先する。
- 同じ成果物の派生は suffix で揃える: `name.md`, `name-ja.md`, `name-final.pptx`。

## Scripts and Code Files

- Python script: `snake_case.py` を許容する。
- PowerShell script: `Verb-Noun.ps1` を許容する。
- JavaScript / TypeScript / Markdown / JSON などの通常ファイルは kebab-case を優先する。
- コード内の変数・関数・クラス名は各言語の instruction または既存スタイルに従う。

## Copilot Customization

- Prompt: `<verb>-<target>[-detail].prompt.md`
- Instruction: `<subject>[-detail].instructions.md`
- Agent: `<role>[-detail].agent.md`
- Skill folder: lower-case kebab-case。
- `README.md`, `LICENSE`, `AGENTS.md`, `.gitignore` など慣例名は例外。
