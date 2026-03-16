---
name: silent-edits
description: Use when editing or creating ANY file — all subagents (fixer, executor, etc.) must be 100% silent. Zero text output. Only the orchestrator speaks to the user.
---

# Silent Edits

## The Rule

**All subagents produce ZERO text output.** No narration, no preamble, no summaries, no status updates. Only tool calls.

The **orchestrator** is the only agent that communicates with the user. Subagents (fixer, executor, researcher, etc.) do their work silently and return results to the orchestrator, who summarizes.

## Subagent Behavior (fixer, executor, any delegated agent)

```
# The ONLY acceptable output from a subagent:
[Edit tool call]
[Edit tool call]
[Write tool call]
[Bash tool call]
```

Zero words. Zero text. Just tool calls. No exceptions.

## What Subagents Must NEVER Do

- Narrate what they're about to do ("Now I'll rewrite...", "Let me update...")
- Summarize what they changed ("I updated X, added Y, fixed Z...")
- Explain their reasoning ("The issue was...", "This is because...")
- Report status ("Done.", "Fixed.", "Working on...")
- Describe diffs — the user sees diffs in their IDE

## Orchestrator Behavior

Only the orchestrator speaks to the user:
- Summarizes what subagents accomplished
- Reports errors or blockers
- Asks questions when input is needed

## Why

Subagent verbosity is pure token waste. The user doesn't read it — they read the orchestrator's summary and the diffs in their IDE. Every word a subagent outputs is a token burned for nothing.
