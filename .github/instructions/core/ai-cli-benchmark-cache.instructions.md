---
description: "Copilot CLI / Codex CLI / OpenAI API の性能・token・費用比較で、model prompt cache とローカルcacheを区別し、公平な測定条件と報告項目を揃える"
applyTo: "**/*benchmark*.{js,mjs,cjs,ts,py,ps1,md,json},**/*comparison*.{js,mjs,cjs,ts,py,ps1,md,json},**/*performance*.{js,mjs,cjs,ts,py,ps1,md,json}"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/Agent-Customization -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->
<!-- updated: 2026-09-22 -->

# AI CLI Benchmark Cache

Copilot CLI、Codex CLI、直接 API の性能・token・費用を比較するときの cache 境界を扱う。

## Cache Control

- Copilot CLI / Codex CLI には、provider 側の model prompt cache を無効化する公開 option がない。fresh process、一時 home、ephemeral、nonce を使っても `cache off` と断定しない。
- `COPILOT_CACHE_HOME` は Marketplace cache、自動更新 package、その他の一時データの保存先であり、model prompt cache とは別物として扱う。設定・認証・session state は `COPILOT_HOME` 側にある。
- `COPILOT_MCP_TOOL_CACHE=false` はローカル MCP server の tool-list snapshot の読み込みと永続化だけを止める。既存 cache file は削除せず、model prompt cache にも影響しない。
- OpenAI の prompt cache は手動消去できない。GPT-5.6 以降を Responses API から直接呼ぶ場合だけ、`prompt_cache_options.mode = "explicit"` かつ breakpoint なしで、その request の prompt caching / cache write を避けられる。CLI 経由へこの性質を推測適用しない。
- 一意 nonce は user prompt 全体の再利用を避ける補助であり、それより前の provider-owned system / agent prefix の cache read を防がない。

## Benchmark Setup

- model、reasoning、prompt、schema、入力順、tool policy、network boundary を固定する。
- CLI は fresh process、repo 外の作業 directory、一時 home、instruction / tool / MCP 無効で実行する。認証 material だけを必要最小限で渡し、secret は出力しない。
- `cache read = 0` を要求する gate は診断に使えるが、CLI が cache-off を保証した証拠にはしない。失敗時も provider、cache read、測定時刻を artifact に残す。
- 単発の時間差を cache の因果効果と断定しない。性能主張には複数 run の median / p95 と分散を使う。

## Record And Report

- provider、CLI version、model、reasoning、prompt hash、nonce hash、fresh-process条件、測定境界を記録する。
- usage は通常入力、cache read、cache write、出力、reasoningを別列で保存する。`input_tokens` が cache区分を内包するか、区分が排他的かを provider schema で確認するまで合算しない。
- cache write は cache hit ではない。cache-write料金がある model では費用に影響するため、readと分けて掲載する。
- 時間は `1 request`、`serial total`、`fresh-process end to end`などの境界を明記する。異なる境界をmodel単体速度として比較しない。
- `uncached run`とは呼ばず、観測事実に合わせて`cache read 0 run`または`cache-observed run`と書く。

## References

- OpenAI Prompt caching: https://developers.openai.com/api/docs/guides/prompt-caching
- GitHub Copilot CLI command reference: https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference
