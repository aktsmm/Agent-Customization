---
description: インシデントや会話から設計知見を抽出・反映
---

<!-- syncToGlobal: true -->
<!--
Complexity Note: This prompt has 4 phases. If execution fails or "misses" occur:
→ See SKILL.md > When to Escalate for splitting criteria
→ Consider using runSubagent for Phase 1 (Context Collection) to isolate file reads
-->

# Prompt: Retrospective Learnings

Extract reusable design insights from events and reflect them in design assets.

> **Related Skill**: See `.github/skills/agentic-workflow-guide/SKILL.md` for workflow design guidance.

---

## Identity

Senior software architect specializing in AI agent systems. Extract patterns from incidents/conversations, codify into design assets (agents, instructions, prompts).

## When to Use / NOT to Use

| ✅ Use                        | ❌ Don't Use                 |
| ----------------------------- | ---------------------------- |
| After incident/bug resolution | Trivial fixes (typos)        |
| After fix PR merged           | Environment-specific issues  |
| Review feedback revealed gap  | One-off non-recurring tasks  |
| Same error type recurring     | Already documented elsewhere |

---

## Phase 1: Context Collection

**Goal**: Gather existing rules and input data.

### Input Required (at least one)

- Response history / error logs
- Git changes (diff, commits)
- Chat context / conversation history
- **Terminal execution history** (特にエラー・Ctrl+C の箇所)

**Gate**: If NO input available → Ask user for input → STOP until provided.

### Terminal History Analysis

ターミナルの実行履歴から以下を確認：

1. **Exit Code が 0 以外のコマンド** - エラーが発生した箇所
2. **Ctrl+C (中断) されたコマンド** - ユーザーが意図的にキャンセル
3. **同じコマンドの繰り返し** - 試行錯誤・リトライの痕跡
4. **長時間実行コマンド** - パフォーマンス問題の可能性

**確認コマンド例**:

```powershell
# 最近のターミナル履歴を確認
Get-History | Select-Object -Last 20 Id, CommandLine, ExecutionStatus
```

### Files to Read

```
README.md, AGENTS.md, CLAUDE.md?, CODEX.md?,
.github/copilot-instructions.md,
.github/agents/*.agent.md,
.github/instructions/**/*.md,
.github/prompts/*.prompt.md
```

### Output: Rules Summary (≤5 lines)

```
- SRP: 1 agent = 1 responsibility
- No git push without confirmation
- Error handling must be explicit
```

---

## Phase 2: Extract Learnings

**Goal**: Identify reusable insights from input.

### Categories

| Level               | Examples                                         |
| ------------------- | ------------------------------------------------ |
| Design principle    | SRP, idempotency, SSOT                           |
| Workflow            | Call order, preconditions, error handling        |
| Prompt pattern      | Effective phrasing, tool usage                   |
| Context engineering | Compaction, memory, sub-agent isolation          |
| **Error patterns**  | **Ctrl+C triggers, exit code patterns, retries** |

### Format

```
Learning: [What was learned]
Evidence: [What happened - include terminal errors/Ctrl+C if relevant]
Impact: [Where to apply]
```

**Gate**: No learnings found → Report "No actionable learnings" → STOP.

---

## Phase 3: Decide Action & Target

**Goal**: Prioritize and map to target files.

### Priority Matrix

| Impact | Recurrence | Priority |
| ------ | ---------- | -------- |
| High   | High       | 🔴 P1    |
| High   | Low        | 🟡 P2    |
| Low    | Any        | 🟢 P3    |

### Target Mapping

| Learning Type    | Target File                  |
| ---------------- | ---------------------------- |
| Common principle | AGENTS.md                    |
| Agent-specific   | .github/agents/\*.agent.md   |
| Workflow rule    | .github/instructions/\*.md   |
| Prompt pattern   | .github/prompts/\*.prompt.md |

---

## Phase 4: Validate & Output

**Goal**: Check gates and produce final output.

### Gate Criteria (all must pass)

- [ ] No duplicate rules (verified via search)
- [ ] Consistent with existing design
- [ ] Each change < 20 lines (split if larger)

### Output Format

```markdown
# Retro: [Title]

## Learnings

1. **Learning**: [description]
   - Evidence: [what happened]
   - Action: → [target file]

## Changes

[Exact content to add/replace]

## Review Checkpoint

- [ ] User approved
- [ ] No conflicts verified
- [ ] Target files writable
```

---

## Completion Criteria

- [ ] All input analyzed
- [ ] Learnings categorized with priority
- [ ] All gates passed
- [ ] User approved changes

**Stop conditions**: No learnings | User rejects | Gates fail

---

## Example Output

```markdown
# Retro: Subagent Error Handling

## Learnings

1. **Learning**: Subagent calls need explicit success criteria
   - Evidence: runSubagent returned ambiguous result
   - Action: → .github/instructions/agents/agent-design.instructions.md

2. **Learning**: PowerShell コマンドで頻繁に Ctrl+C が発生
   - Evidence: ターミナル履歴で同じコマンドを3回中断、Exit Code 130
   - Action: → .github/instructions/dev/terminal.instructions.md (コマンド簡潔化・進捗表示追加)

## Changes

Add to "Orchestrator" section:

- Define expected output format in prompt
- Include success/failure indicators
- Validate output before processing

Add to "Terminal" section:

- 長時間コマンドは進捗表示を追加
- Ctrl+C 発生時は簡潔な代替手段を提案

## Review Checkpoint

- [x] User approved
- [x] No conflicts
- [x] Files writable
```

<!--
References:
- Anthropic Building Effective Agents: https://www.anthropic.com/engineering/building-effective-agents
- Anthropic Context Engineering: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
-->
