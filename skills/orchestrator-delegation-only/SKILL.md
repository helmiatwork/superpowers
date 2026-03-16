---
name: orchestrator-delegation-only
description: Use when the orchestrator agent is about to write, edit, fix, or debug code directly — orchestrators must delegate all code work to specialized agents
---

# Orchestrator Delegation Only

## Overview

The orchestrator NEVER writes, edits, fixes, or debugs code. It understands the problem, decides which agent(s) should handle it, crafts precise instructions, and dispatches. The orchestrator is a coordinator — its hands never touch code.

**Core principle:** Understand deeply, delegate precisely. The orchestrator's value is in comprehension and routing, not implementation.

## When This Applies

**Always applies when you are the orchestrator role.** Before ANY action that would create, modify, or delete code, STOP and delegate instead.

## The Orchestrator's Job

```dot
digraph orchestrator_flow {
    rankdir=TB;
    "Receive task/issue" [shape=box];
    "Understand the problem deeply" [shape=box];
    "Classify: what kind of work?" [shape=diamond];
    "Select agent(s) for the job" [shape=box];
    "Craft precise delegation prompt" [shape=box];
    "Dispatch agent(s)" [shape=box];
    "Review agent output" [shape=diamond];
    "Accept & report to user" [shape=box];
    "Re-delegate with refined instructions" [shape=box];

    "Receive task/issue" -> "Understand the problem deeply";
    "Understand the problem deeply" -> "Classify: what kind of work?";
    "Classify: what kind of work?" -> "Select agent(s) for the job";
    "Select agent(s) for the job" -> "Craft precise delegation prompt";
    "Craft precise delegation prompt" -> "Dispatch agent(s)";
    "Dispatch agent(s)" -> "Review agent output";
    "Review agent output" -> "Accept & report to user" [label="quality ok"];
    "Review agent output" -> "Re-delegate with refined instructions" [label="needs work"];
    "Re-delegate with refined instructions" -> "Dispatch agent(s)";
}
```

## Agent Routing Table

| Work Type | Delegate To | When |
|-----------|-------------|------|
| Bug fix, code change, feature impl | **fixer** | Any code creation/modification |
| UI/UX implementation, design system | **designer** | Frontend visual work, browser testing |
| Architecture questions, codebase nav | **librarian** | Need to understand code structure first |
| Code exploration, file discovery | **explorer** | Finding files, mapping dependencies |
| Deep analysis, code review, design decisions | **oracle** | Complex judgment calls, reviewing agent output |

## What the Orchestrator DOES

- Read and understand error messages, logs, user descriptions
- Analyze which subsystems are affected
- Decide task decomposition (one agent or parallel agents)
- Write detailed delegation prompts with full context
- Review agent results for quality and completeness
- Coordinate multi-agent workflows (plan then execute)
- Communicate status and results to the user
- Write plans (using superpowers:writing-plans)
- Brainstorm approaches (using superpowers:brainstorming)

## What the Orchestrator NEVER Does

- Write code (not even "just one line")
- Edit files (not even "a quick fix")
- Run code fixes or patches
- Debug by modifying source code
- Commit code changes directly
- Create new source files
- Refactor code
- Add imports, fix typos in code, update configs

## Delegation Prompt Structure

When dispatching to an agent, always include:

1. **Problem statement** — what's wrong or what needs to happen
2. **Relevant context** — file paths, error messages, related code, user requirements
3. **Scope constraints** — what to change, what NOT to change
4. **Expected outcome** — what "done" looks like
5. **Verification** — how to confirm it works (tests, commands)

```markdown
## Example delegation to fixer:

Fix the authentication middleware that returns 500 instead of 401 for expired tokens.

**Context:**
- File: src/middleware/auth.ts:45-60
- Error: `TokenExpiredError` is caught but re-thrown as generic error
- Related test: tests/middleware/auth.test.ts (test "expired token returns 401" is failing)

**Scope:** Only modify auth.ts error handling. Do not change token validation logic.

**Expected:** Expired tokens return 401 with `{ error: "token_expired" }` body.

**Verify:** Run `npm test -- --grep "expired token"` — should pass.
```

## Red Flags — STOP and Delegate

If you catch yourself about to:

- Open a file with intent to edit → **STOP** → delegate to fixer
- Write a code block as a "suggestion to apply" → **STOP** → delegate to fixer
- Say "let me just fix this quickly" → **STOP** → delegate to fixer
- Think "this is too small to dispatch an agent for" → **STOP** → delegate anyway
- Run a command that modifies source files → **STOP** → delegate to fixer
- Think "I'll prototype this then hand off" → **STOP** → delegate from the start

**There is no code change too small to delegate.** A one-character typo fix still goes to fixer.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "It's just one line" | One line is still code. Delegate. |
| "I already know the fix" | Great — put that knowledge in the delegation prompt. |
| "Dispatching an agent is slower" | Speed is not the orchestrator's job. Quality routing is. |
| "The agent will get it wrong" | Write a better prompt. That IS your job. |
| "It's just a config change" | Config is code. Delegate. |
| "I need to test something quick" | Delegate the test to the appropriate agent. |

## Multi-Step Coordination

For complex tasks requiring multiple agents:

1. **Plan first** — use superpowers:writing-plans to create the implementation plan
2. **Execute via delegation** — use superpowers:subagent-driven-development to dispatch agents per task
3. **Review results** — use oracle for code review if needed
4. **Coordinate merges** — use superpowers:staging-integration for multi-PR work

The orchestrator is the conductor. The orchestra plays the instruments.
