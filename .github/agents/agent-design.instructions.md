---
applyTo: ".github/agents/**/*.agent.md"
---

# Agent Workflow Design Instructions

## Part 1: Agent Design Principles

### 1. Single Responsibility Principle (SRP)

- **1 Agent, 1 Goal**: Give each agent one clearly defined role.
- **Separation of Roles**: Separate by phase: "planning", "implementation", "review", "testing".

### 2. Stateless & Idempotency

- Design agents to judge based on file system state, not conversation history.
- Design workflows to converge to correct state when re-run.

### 3. Orchestration

- For complex tasks, use "manager agent" delegating to "worker agents".
- Clearly define expected deliverables for handoffs.

### 4. Fail-safe & Human-in-the-loop

- Before irreversible operations, ask human confirmation.
- Design prompts to analyze errors and attempt fixes.

### 5. Observability

- Record decisions as Issue comments or documents.
- For long tasks, have regular status reports.

## Part 2: Workflow Architecture

### 6. Two-stage Architecture

Input → IR (Intermediate Representation) → Output

### 7. IR Specification

- Define allowed structure (JSON/YAML/structured Markdown)
- Strict validation; do not auto-complete

### 8. Separation of Concerns

| Responsibility | Description            |
| -------------- | ---------------------- |
| Generate       | Generate IR            |
| Validate       | Verify IR              |
| Transform      | Convert IR to output   |
| Render         | Output to final format |

### 9. Determinism

Same IR → Same output. No creativity in transformation.

## Part 3: Agent Manifest Specification

### 10. YAML Front Matter Requirements

Agent definition files (`.agent.md`) require the following YAML front matter:

```yaml
---
name: <agent-name> # Required: Identifier for @mentions
description: <description> # Required: One-line role description
model: <model-name> # Required: LLM model to use
---
```

### 11. Tools Field Specification

| Specification   | Behavior                         | Use Case                |
| --------------- | -------------------------------- | ----------------------- |
| **Omitted**     | All tools available              | General-purpose agent   |
| `tools: []`     | No tools                         | Conversation only       |
| List tool names | Only specified tools (whitelist) | When restriction needed |

#### When to Explicitly Specify Tools

- **Read-only**: Research/analysis agents → Exclude editing tools
- **Safety-focused**: Prevent destructive operations → Exclude `run_in_terminal`
- **Cost optimization**: Reduce unnecessary tool calls
- **Intent clarity**: Reviewers can understand agent capabilities

> **Note**: MCP tools are automatically available at runtime; no need to specify in front matter. Unknown tool names will cause errors.

### 12. Agent Structure Template

Each agent should have the following sections:

| Section        | Required    | Description                                                 |
| -------------- | ----------- | ----------------------------------------------------------- |
| Role           | ✅          | One-sentence responsibility definition                      |
| Goals          | ✅          | List of objectives                                          |
| Done Criteria  | ✅          | Verifiable completion conditions (**single location only**) |
| Permissions    | ✅          | Allowed/prohibited actions                                  |
| I/O Contract   | ✅          | Input/output definitions                                    |
| Workflow       | Recommended | Step-by-step procedure                                      |
| Error Handling | Recommended | Error patterns and responses                                |
| Idempotency    | Recommended | How to ensure idempotency                                   |
