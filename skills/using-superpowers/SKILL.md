---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

# ORCHESTRATOR DELEGATION - FIRST PRIORITY

**IF YOU ARE AN ORCHESTRATOR OR TOP-LEVEL AGENT:**

Before taking ANY action — even before reading the user's message:

### Boot Sequence (VISIBLE TO USER — MANDATORY)

Run these checks and **print the checklist to the user** before doing anything else. This is the FIRST output of every session — no exceptions.

```
0. redis-cli ping → if not PONG → brew services start redis
1. redis-cli GET ai:strategy → load or fetch from Outline if empty
2. redis-cli GET ai:execution-protocol → load or fetch from Outline if empty
3. redis-cli GET ai:templates:index → load or fetch from Outline if empty
4. redis-cli GET ai:agent-config → agent models, skills, MCPs
5. Check supermemory for last session state
6. Check Outline for Project Tracker (if active project)
```

**After all checks, load agent config from Redis:**
```bash
redis-cli GET ai:agent-config
```
**This returns the JSON with all agent models, skills, and MCPs. Parse it and print the checklist below.**

**Then print this checklist to the user:**

```
Session Boot:
  Redis:                  ✅ running
  ai:strategy:            ✅ loaded (XX,XXX chars, ~X,XXX tokens)
  ai:execution-protocol:  ✅ loaded (XX,XXX chars, ~X,XXX tokens)
  ai:templates:index:     ✅ loaded (X,XXX chars, ~XXX tokens)
  ai:agent-config:        ✅ loaded (X,XXX chars, ~XXX tokens)
  Supermemory:            ✅ last session: [summary or "no prior state"]
  Project Tracker:        ✅ [phase X — current task] or ⬜ no active project

Agents:
  orchestrator:  opus-4-6   | skills: [*]                              | mcps: websearch, outline, supermemory
  oracle:        opus-4-6   | skills: code-reviewer                    | mcps: —
  librarian:     sonnet-4-6 | skills: —                                | mcps: websearch, context7, grep_app, outline, supermemory
  explorer:      haiku-4-5  | skills: —                                | mcps: —
  designer:      sonnet-4-6 | skills: agent-browser, ui-design-system  | mcps: opencode-browser
  fixer:         haiku-4-5  | skills: senior-fullstack                 | mcps: —

Boot cost: ~XX,XXX tokens
```

**How to calculate tokens:** For each Redis value, count words (`wc -w`) and multiply by 1.3. Sum all for the total boot cost.

Read the actual values from the JSON config — don't hardcode. Show the real model, skills, and mcps per agent.

Use ✅ for loaded, ⚠️ for fetched from fallback (Outline), ❌ for missing/failed.

**If ANY item is ❌, STOP and fix it before proceeding.**

Only after the checklist is printed and all items are ✅ or ⚠️, proceed to:

6. **ASSESS** — Is there a relevant specialist?
7. **PRESENT EXECUTIVE SUMMARY** - Before dispatching agents:
   - **Objective:** What will be accomplished
   - **Agents:** Which specialists and why
   - **Scope:** What each agent will do (1-2 lines)
   - **Expected Output:** What the user receives
8. **DELEGATE WITH CONTEXT** - Each agent gets a self-contained briefing:
   - **Goal:** One sentence
   - **Context:** Relevant files, decisions, constraints
   - **Boundaries:** In/out of scope
   - **Output format:** What to return
9. **ONLY IF NO SPECIALIST** - Handle it yourself

> **Agent config:** `/Users/ichigo/.config/opencode/oh-my-opencode-slim.json` (EXACT path — never guess)
> **Provider/MCP config:** `/Users/ichigo/.config/opencode/opencode.json`

**Specialists:** @explorer (discovery), @librarian (docs/TRDs), @oracle (strategy/review), @designer (UI/UX), @fixer (implementation)

**Rules:** If overhead < time saved → DELEGATE. Bad delegation = no context.

## PROMPT REFINEMENT GATE

If the user's prompt is vague, ambiguous, or likely to waste tokens:

1. **DETECT** — Missing goal, scope, constraints, or acceptance criteria?
2. **RESTRUCTURE** — Rewrite into: Goal, Scope, Constraints, Done-when
3. **CONFIRM** — Present refined prompt to user
4. **PROCEED** — Only after confirmation

## PRE-IMPLEMENTATION: TRD CREATION

When design is approved, create TRDs BEFORE delegating to @fixer:

- API endpoints → API Specification TRD
- Database changes → Migration/Schema TRD
- External services → Integration Contract TRD
- Simple code changes → Skip TRD

**Flow:** @explorer reads codemaps → @librarian creates TRD (stores in Outline) → @oracle reviews → @fixer executes

## TOKEN COST OPTIMIZATION

1. **RTK** — Auto-active via hooks. 60-90% CLI output compression.
2. **Prompt engineering** — One goal per agent. Task-specific context only.
3. **Model selection** — Haiku for mechanical, Sonnet for moderate, Opus for complex.
4. **Scope control** — Specify exact files. Read codemaps first, never scan entire directories.
5. **Context management** — Fresh sessions for new tasks. Supermemory for continuity.
6. **Redis caching** — AI Strategy, Execution Protocol, and templates index cached in Redis (`ai:strategy`, `ai:execution-protocol`, `ai:templates:index`). 7-day TTL. Always read Redis first (~1ms), fallback to Outline (~500ms).
7. **Supermemory caching** — Check supermemory before dispatching research. Target >60% cache hits.
8. **Batch processing** — Parallel agent dispatch for independent tasks.

**Codemap-First Rule:** Every folder has `CODEMAP.md`. Read it before exploring. Never glob all files when a codemap exists. No codemap? Check Outline, then run `cartography`.

## STATE PERSISTENCE - ON COMPLETION

Delegate all persistence to @librarian:

1. **Save to supermemory (MANDATORY)** — What was done, progress, decisions, next steps
2. **Feature complete?** → @fixer creates PR → @fixer requests review from @oracle → staging-integration if multi-PR → @librarian updates Outline checklist → @librarian saves final state

## BRANCHING RULES — NON-NEGOTIABLE

1. Feature branches ALWAYS branch from main/master
2. Never commit to parent branches — all commits on feature branches
3. Never push directly to main/master — always PRs
4. Staging only receives merges from feature branches (merge conflict resolution commits are the only exception)
5. Never push fixes to staging — fix on feature branch, push, re-merge
6. Never push parent branches to GitHub — only feature branches

## ATOMIC COMMITS & PR STRATEGY — NON-NEGOTIABLE

- **One concern per commit** — don't mix domains. Each commit leaves codebase working.
- **Max 20 files per PR** — split by domain if exceeded. Each PR independently mergeable.
- **Split PRs → staging-integration** to test together before merging.

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If there is even a 1% chance a skill might apply, you MUST invoke it. Not negotiable.
</EXTREMELY-IMPORTANT>

## Instruction Priority

1. **User instructions** (CLAUDE.md, AGENTS.md, direct requests) — highest
2. **Superpowers skills** — override defaults
3. **Default system prompt** — lowest

## How to Access Skills

**Claude Code:** Use `Skill` tool. **Gemini CLI:** `activate_skill` tool. **Other:** Check platform docs.

## Skill Priority

1. **Delegation first** (orchestrators) → Check specialists
2. **Process skills** (brainstorming, debugging) → Determine HOW
3. **Implementation skills** → Guide execution

**Rigid skills** (TDD, debugging): Follow exactly. **Flexible skills** (patterns): Adapt to context.

## UI Preview for Brainstorming

When any change involves UI: always produce a visual preview during brainstorming before implementation. Include "produce UI preview" in agent briefings for UI work.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
