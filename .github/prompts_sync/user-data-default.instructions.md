---
description: "Use when creating VS Code prompts, instructions, agents, or skills for personal customization. Default to personal scope, prefer User Data for prompts/instructions/agents, and keep clarification questions minimal unless the target scope is unclear."
---

# User Data Default

- 個人用の VS Code カスタマイズを作る依頼では、明示的な指定がなければ personal scope を第一候補にする
- prompts / instructions / agents は User Data 側を優先し、skills は `~/.copilot/skills/` など personal skill の標準保存先を使う
- GitHub Copilot CLI でも自動ロードしたい always-on instruction は `~/.copilot/instructions/` を優先し、User Data 側には VS Code 用のコピーを置く
- 保存先の確認が必要でも、質問は最小限にとどめる
- 単純なひな形作成では、まず最小構成で作ってから不足分だけ確認する
