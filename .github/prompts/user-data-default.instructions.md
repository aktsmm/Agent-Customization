---
description: "Use when creating VS Code prompts, instructions, agents, or skills for personal customization. Default to personal scope, prefer User Data for prompts/instructions/agents, and keep clarification questions minimal unless the target scope is unclear."
applyTo: "**/*.prompt.md,**/*.instructions.md,**/*.agent.md,**/SKILL.md"
---

<!-- syncToGlobal: true -->
<!-- author: aktsmm -->
<!-- repository: https://github.com/aktsmm/ghc_template -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 aktsmm -->

# User Data Default

- 個人用の VS Code カスタマイズを作る依頼では、明示的な指定がなければ personal scope を第一候補にする
- prompts / instructions / agents は User Data 側を優先し、skills は `~/.copilot/skills/` など personal skill の標準保存先を使う
- `.github/copilot-instructions.md`、`AGENTS.md`、workspace 配下の `.instructions.md` は personal metadata ルールの対象として扱わない
- GitHub Copilot CLI でも自動ロードしたい always-on instruction は `~/.copilot/instructions/` を優先し、User Data 側には VS Code 用のコピーを置く
- 保存先の確認が必要でも、質問は最小限にとどめる
- 単純なひな形作成では、まず最小構成で作ってから不足分だけ確認する