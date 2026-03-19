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
5. redis-cli GET ai:workflow-guide → orchestrator delegation + review workflow
6. Detect project: PROJECT=$(basename $(git rev-parse --show-toplevel 2>/dev/null || basename $(pwd)))
7. redis-cli GET ai:state:$PROJECT → last session state for this project
8. redis-cli GET ai:tasks:$PROJECT → task board with per-agent checklists
9. Check Outline for Project Tracker (if active project)
```

**How to detect project name:** Run `basename $(git rev-parse --show-toplevel)` to get the repo name (e.g., `oms`, `customer-portal`, `ichigo-admin`). This is the Redis key suffix.

**After all checks, load agent config from Redis:**
```bash
redis-cli GET ai:agent-config
redis-cli GET ai:state:$PROJECT
```
**Parse the JSON and print the checklist below.**

**Then print this checklist to the user:**

```
Session Boot:
  Redis:                  ✅ running
  ai:strategy:            ✅ loaded (XX,XXX chars, ~X,XXX tokens)
  ai:execution-protocol:  ✅ loaded (XX,XXX chars, ~X,XXX tokens)
  ai:templates:index:     ✅ loaded (X,XXX chars, ~XXX tokens)
  ai:agent-config:        ✅ loaded (X,XXX chars, ~XXX tokens)
  ai:workflow-guide:      ✅ loaded (X,XXX chars, ~X,XXX tokens)
  Project:                ✅ [project-name]
  Last session:           ✅ [date] — [what was done] or ⬜ first session
  Next action:            ✅ [specific next step] or ⬜ none
  Task board:             ✅ X tasks (Y done, Z in-progress, W pending) or ⬜ none
    #N agent:             ✅ done / 🔄 step X/Y (step name) / ⬜ pending / ❌ blocked
  Agent history:
    fixer:                [last action summary or —]
    oracle:               [last action summary or —]
    designer:             [last action summary or —]
  Project Tracker:        ✅ [phase X — current task] or ⬜ no active project

Agents:
  orchestrator:  opus-4-6   | skills: [*]                              | mcps: websearch, outline
  oracle:        opus-4-6   | skills: code-reviewer                    | mcps: —
  librarian:     sonnet-4-6 | skills: —                                | mcps: websearch, context7, grep_app, outline
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

## DELEGATION IS MANDATORY — NO EXCEPTIONS

**The orchestrator NEVER writes code, edits files, creates documents, runs tests, or implements anything.**

You are a coordinator. Your ONLY outputs are:
- Text to the user (questions, summaries, status)
- Agent dispatches (delegation prompts to specialists)

**If you catch yourself about to use Edit, Write, or Bash (other than redis-cli/rtk for boot):**
→ STOP. Delegate to the appropriate agent instead.

| You want to... | Delegate to |
|---|---|
| Write/edit code | @fixer |
| Write/edit documents | @librarian |
| Design UI | @designer |
| Find files/patterns | @explorer |
| Review/analyze code | @oracle |
| Run tests | @fixer |
| Create PRs | @fixer |
| Research libraries/docs | @librarian |

**There is ZERO code or document work the orchestrator does directly. Not "just one line." Not "a quick fix." Not "a simple doc update." ALWAYS delegate.**

6. **ASSESS** — Is there a relevant specialist? (Answer: YES. There always is.)
7. **PRESENT EXECUTIVE SUMMARY** - Before dispatching agents:
   - **Objective:** What will be accomplished
   - **Agents:** Which specialists and why
   - **Scope:** What each agent will do (1-2 lines)
   - **Expected Output:** What the user receives
8. **DELEGATE WITH COMPLETE CONTEXT** — The agent knows NOTHING. You must give it everything it needs in one shot. Incomplete briefings cause agents to guess, re-read files, or do wrong work.

**Every delegation MUST include ALL of these:**

```
GOAL: [One sentence — what to accomplish]

CONTEXT:
- Project: [project name, tech stack summary]
- Feature: [what feature this is part of, why it exists]
- Prior work: [what was already done by previous agents/sessions]
- Decisions: [key decisions already made — don't let agent re-decide]

FILES:
- Read first: [exact file paths the agent needs to understand before starting]
- Modify: [exact file paths to change]
- Create: [new files to create, with target directory]
- Do NOT touch: [files that are off-limits]

REFERENCE:
- TRD/PRD: [Outline doc ID or Redis key, or paste the relevant section]
- API spec: [endpoint details if applicable]
- Schema: [table/field details if applicable]
- Existing pattern: [point to a similar file to follow, e.g., "follow src/components/users/List.tsx pattern"]

BOUNDARIES:
- In scope: [exactly what to do]
- Out of scope: [what NOT to do — prevent scope creep]
- If unsure: [ask before proceeding, don't guess]

OUTPUT:
- [What to return — code, analysis, file list, etc.]
```

**Bad delegation (causes rework):**
> "Fix the auth bug"

**Good delegation (one-shot, no rework):**
> GOAL: Fix expired token returning 500 instead of 401
> CONTEXT: Ichigo Admin, React 18 + Refine v4, Apollo Client. Auth uses JWT via X-Auth-Token header.
> FILES: Read first: src/providers/authProvider.ts, src/utils/api.ts. Modify: src/providers/authProvider.ts
> REFERENCE: Auth flow in AI Strategy section 5. Follow existing error handling in src/providers/dataProvider.ts
> BOUNDARIES: Only fix the token expiry check. Don't refactor auth flow. Don't touch other providers.
> OUTPUT: DONE/BLOCKED + test count

**The test: Could a brand new developer complete this task with ONLY this briefing and no questions? If no, add more context.**

   - **Discipline rules:** MUST include these in EVERY delegation to @fixer, @designer, @librarian:

### Mandatory Discipline Rules (include in every agent briefing)

```
RULES — follow these exactly:
1. Read CODEMAP.md before touching any directory. If missing, STOP.
2. Read the file BEFORE editing it. Never edit blind.
3. Write tests FIRST, then implementation (TDD). No code without a failing test.
4. After every change: run build, run tests, run lint. All must pass.
5. One logical change per commit. If you need "and" in the message, split it.
6. Never guess API shapes — check the actual endpoint/schema.
7. Handle loading states, error states, and empty states for every UI component.
8. No @ts-ignore, no `any` types, no eslint-disable without a comment explaining why.
9. Prefix ALL CLI commands with rtk (e.g., rtk npm test, rtk git status).
10. Zero text output — only tool calls. No narration, no summaries, no diffs.
11. Report: Status (DONE/BLOCKED) + test count only. Nothing else.
```

Omit rules that don't apply (e.g., skip TDD rule for @librarian writing docs, skip UI states for @explorer).

9. **ONLY IF NO SPECIALIST** - Handle it yourself (this should almost never happen)

## AFTER DELEGATION — ORCHESTRATOR RESPONSIBILITIES

### Verify Agent Output (MANDATORY — every time)

When ANY agent (@fixer, @designer, @librarian) reports DONE:

```
@fixer/designer/librarian reports DONE
  ↓
Step 1: Orchestrator verifies (quick check)
  - rtk git diff --stat → what files actually changed?
  - rtk npm test (or rtk cargo test, etc.) → tests actually pass?
  - Files touched match the BOUNDARIES in briefing?
  ↓
Step 2: Dispatch @oracle to review (MANDATORY)
  GOAL: Review changes from @fixer for correctness and spec compliance
  FILES: [files from git diff --stat]
  REFERENCE: [TRD/PRD section this task implements]
  CHECK:
    - Does the code match the spec/TRD exactly?
    - Any bugs, edge cases missed, or security issues?
    - Does it follow existing codebase patterns?
    - Are tests adequate (not just happy path)?
  ↓
@oracle reports:
  ├─ APPROVED → proceed to commit/PR
  ├─ ISSUES → dispatch @fixer with oracle's specific feedback to fix
  │            then re-dispatch @oracle to verify the fix
  └─ BLOCKED → escalate to user
```

**This is not optional. Every task gets reviewed by @oracle before it's considered done.** The only exception: orchestrator's own quick checks (redis-cli, git status) that don't produce code.

### Handle Agent Failure

When an agent reports BLOCKED or fails:

```
Agent reports BLOCKED
  ↓
What kind of blocker?
  ├─ Missing context → Provide more context, re-dispatch SAME agent
  ├─ Task too complex for model → Re-dispatch on stronger model:
  │     Haiku failed → retry on Sonnet
  │     Sonnet failed → retry on Opus
  │     Opus failed → break task into smaller pieces
  ├─ External dependency issue → Fix dependency, then re-dispatch
  ├─ Conflicting requirements → Escalate to user for decision
  └─ Agent went off-track → Write clearer briefing, re-dispatch fresh agent
```

**Never retry the same agent with the same prompt.** Something must change: more context, stronger model, or smaller scope.

### Knowledge Passing Between Agents

When chaining agents (e.g., @explorer → @fixer), pass results explicitly:

```
Step 1: @explorer finds relevant files
  → Orchestrator receives: [list of file paths + descriptions]

Step 2: Orchestrator includes explorer's findings in fixer's briefing:
  GOAL: Implement feature X
  FILES:
  - Read first: [paths from explorer]
  - Modify: [subset of paths]
  CONTEXT:
  - Explorer found: [summary of what explorer discovered]
```

**Never make @fixer re-discover what @explorer already found.** The orchestrator is the memory between agents.

### Parallel Agent Safety

When dispatching multiple agents simultaneously:

| Rule | Why |
|---|---|
| Never dispatch 2 agents to the same file | They'll overwrite each other |
| Split by domain: backend vs frontend vs tests | No file overlap |
| If tasks depend on each other → run sequentially | Output of task 1 feeds task 2 |
| After parallel agents complete → verify no conflicts | `rtk git diff` before committing |

### Complete Task Lifecycle

```
User request
  → Orchestrator builds briefing (GOAL/CONTEXT/FILES/REFERENCE/BOUNDARIES/RULES)
  → @fixer implements
  → Orchestrator verifies (git diff, tests)
  → @oracle reviews (spec compliance, bugs, patterns)
  → Issues? → @fixer fixes → @oracle re-reviews
  → APPROVED → commit → update Project Tracker
```

**No task is done until @oracle says APPROVED.** This is the quality gate.

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
6. **Redis caching** — AI Strategy, Execution Protocol, templates index, and agent config cached in Redis. No TTL (persists forever). Always read Redis first (~1ms), fallback to Outline (~500ms).
7. **Redis caching for research** — Before dispatching @librarian for research, check if the answer is already in Redis or Outline.
8. **Batch processing** — Parallel agent dispatch for independent tasks.

**Codemap-First Rule:** Every folder has `CODEMAP.md`. Read it before exploring. Never glob all files when a codemap exists. No codemap? Check Outline, then run `cartography`.

## TASK BOARD — CRASH-PROOF STATE IN REDIS

### How It Works

The orchestrator maintains a **task board** in Redis at `ai:tasks:{project}`. This is the real-time state of all agent work. If the session crashes (internet, power, computer), the next session reads the task board and resumes at the exact step that was interrupted.

### Lifecycle

```
Orchestrator plans work
  ↓
Creates task board in Redis (ai:tasks:{project})
  → Each task has: agent, goal, status, files, checklist
  ↓
Before dispatching agent:
  → Set task status: "in-progress"
  → Save to Redis
  ↓
Agent works, orchestrator updates checklist after each step:
  → "Read CODEMAP" ✅
  → "Write tests" ✅
  → "Implement" ✅    ← session crashes here
  → "Build passes" ⬜
  → "Commit" ⬜
  → "Oracle review" ⬜
  ↓
Next session boots:
  → Reads ai:tasks:{project}
  → Sees task 2 is "in-progress", checklist shows 3/6 done
  → Resumes at "Build passes"
```

### Task Board Structure

```bash
PROJECT=$(basename $(git rev-parse --show-toplevel 2>/dev/null || basename $(pwd)))
redis-cli SET "ai:tasks:$PROJECT" '<json>'
```

```json
{
  "sprint": "Sprint 2",
  "updated": "2026-03-19T14:30:00Z",
  "tasks": [
    {
      "id": 1,
      "agent": "fixer",
      "goal": "Implement POST /v1/orders",
      "status": "done",
      "files": ["src/controllers/orders_controller.rb"],
      "checklist": [
        {"step": "Read CODEMAP.md", "done": true},
        {"step": "Read TRD section", "done": true},
        {"step": "Write tests", "done": true},
        {"step": "Implement", "done": true},
        {"step": "Build + lint + tests pass", "done": true},
        {"step": "Commit", "done": true},
        {"step": "Oracle review", "done": true, "result": "APPROVED"}
      ]
    },
    {
      "id": 2,
      "agent": "fixer",
      "goal": "Implement PATCH /v1/orders/:id",
      "status": "in-progress",
      "files": ["src/controllers/orders_controller.rb"],
      "checklist": [
        {"step": "Read CODEMAP.md", "done": true},
        {"step": "Read TRD section", "done": true},
        {"step": "Write tests", "done": false},
        {"step": "Implement", "done": false},
        {"step": "Build + lint + tests pass", "done": false},
        {"step": "Commit", "done": false},
        {"step": "Oracle review", "done": false}
      ]
    }
  ]
}
```

### Task Statuses

| Status | Meaning |
|---|---|
| `pending` | Not started yet |
| `in-progress` | Agent is working (or was working when session crashed) |
| `done` | Completed + reviewed by @oracle |
| `blocked` | Agent couldn't complete — needs intervention |
| `review` | @fixer done, waiting for @oracle review |

### Orchestrator Rules

**Before dispatching any agent:**
1. Read `ai:tasks:{project}` from Redis
2. Find the next `pending` task (or resume `in-progress` task)
3. Update task status to `in-progress` + save to Redis
4. Dispatch agent with full briefing

**After agent reports back (each step):**
1. Update the checklist item to `done: true`
2. Save to Redis immediately — **don't batch updates**
3. If agent reports BLOCKED, set task status to `blocked` + save

**After @oracle review:**
1. If APPROVED: set task status to `done`, save result in checklist
2. If ISSUES: set status back to `in-progress`, dispatch @fixer to fix, then re-review

**On session crash recovery:**
1. Read `ai:tasks:{project}`
2. Find task with status `in-progress`
3. Read its checklist — find first `done: false` step
4. Resume from that step (re-dispatch agent if needed)

### Boot Checklist (shows task board)

```
  Task board:             ✅ 5 tasks (3 done, 1 in-progress, 1 pending)
    #1 fixer:             ✅ POST /v1/orders — done (oracle: APPROVED)
    #2 fixer:             🔄 PATCH /v1/orders/:id — step 3/7 (Write tests)
    #3 designer:          ⬜ Bulk actions toolbar mockup — pending
    #4 fixer:             ⬜ DELETE /v1/orders/:id — pending
    #5 oracle:            ⬜ Final review — pending
```

## STATE PERSISTENCE - ON COMPLETION

**Before ending ANY session, the orchestrator MUST save ALL state:**

### 1. Update Task Board in Redis

```bash
redis-cli SET "ai:tasks:$PROJECT" '<updated task board JSON>'
```
Every checklist item that completed this session must be marked `done: true`. Any in-progress task stays `in-progress` with the checklist showing exactly where it stopped.

### 2. Update Project State in Redis

```bash
redis-cli SET "ai:state:$PROJECT" '<updated state JSON>'
```

**State JSON:**
```json
{
  "phase": "Sprint 2",
  "task": "implementing order API",
  "last_session": "2026-03-19",
  "next_action": "Resume task #2: PATCH /v1/orders/:id — continue from 'Write tests' step",
  "decisions": ["Using Sidekiq for async", "PostgreSQL jsonb for metadata"],
  "blockers": "none",
  "agents": {
    "fixer": "Completed task #1 (POST). Task #2 in progress — CODEMAP + TRD read, tests next.",
    "oracle": "Reviewed task #1 — APPROVED. Flagged: add rate limiting.",
    "explorer": "Mapped api/v1/ structure.",
    "librarian": "Updated API TRD."
  }
}
```

### 3. Update Project Tracker in Outline

Delegate to @librarian: update the Project Tracker document with session log entry.

### 4. Feature complete?

If yes: @fixer creates PR → @oracle reviews → staging-integration if multi-PR → @librarian updates Outline

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
