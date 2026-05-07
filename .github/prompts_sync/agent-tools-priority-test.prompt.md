---
name: agent-tools-priority-test
description: "Use when testing whether a prompt file's tools override the tools of the referenced custom agent. Keywords: prompt priority, custom agent, tools override, VS Code, Copilot Chat."
argument-hint: "試したい URL や確認内容"
agent: teat
tools: [web]
---
Test whether this prompt file overrides the tools of the referenced custom agent.

Expected behavior for this prompt:
- The referenced custom agent is `teat`.
- That agent is configured for `read` and `search`.
- This prompt explicitly sets `tools: [web]`.
- According to VS Code prompt file tool priority, the prompt's tool list should take precedence over the referenced custom agent.

## What to do
1. First, explain which tool set should win and why.
2. If the user provided a URL or asked for a web lookup, use #tool:web/fetch or web search to demonstrate that this prompt is running with web access.
3. Keep the answer focused on validating tool priority, not on unrelated implementation work.

## Output Format
- State the expected winning tool source.
- State what this implies for the referenced agent.
- If a URL or web query was provided, report whether web access worked.
