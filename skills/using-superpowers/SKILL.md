---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

# ORCHESTRATOR DELEGATION - FIRST PRIORITY

**IF YOU ARE AN ORCHESTRATOR OR TOP-LEVEL AGENT:**

Before taking ANY action — even before reading the user's message:

### Boot Sequence (LOAD EVERYTHING — FULL CONTEXT)

**The orchestrator reads ALL Redis keys in full.** Every key. No summaries. No shortcuts. The orchestrator needs full context to delegate correctly and resume work instantly.

```bash
# 0. Ensure Redis
redis-cli ping  # if not PONG → brew services start redis

# 1. Detect project
PROJECT=$(basename $(git rev-parse --show-toplevel 2>/dev/null || basename $(pwd)))

# 2. Load ALL keys — read full content
# ai:strategy — NOT loaded (covered by ai:knowledge + superpowers skills)
# ai:execution-protocol — load ON DEMAND when starting a new project phase
redis-cli GET ai:templates:index
redis-cli GET ai:agent-config
# NOTE: ai:workflow-guide is NOT loaded here — it's already loaded as this skill via [*]
redis-cli GET ai:knowledge:$PROJECT
redis-cli GET ai:state:$PROJECT
redis-cli GET ai:tasks:$PROJECT
redis-cli KEYS "ai:feature:*"  # then GET each feature key found
```

**ALL keys are read in FULL.** The orchestrator must understand:
- ai:strategy → coding conventions, tech stack, branching rules
- ai:execution-protocol → phase checklists, STOP gates
- ai:knowledge → business rules, API gotchas, data model, features
- ai:state → last session, next action, agent history
- ai:tasks → task board with every feature, sub-task, step, checklist

**Then print a SUMMARY checklist to the user** (content is in memory, show only status):

**Then print this checklist to the user:**

```
Session Boot:
  Redis:                  ✅ running
  ai:strategy:            ✅ covered by ai:knowledge + skills
  ai:execution-protocol:  ⏸️ on-demand (new project phases only)
  ai:templates:index:     ✅ loaded (X,XXX chars, ~XXX tokens)
  ai:agent-config:        ✅ loaded (X,XXX chars, ~XXX tokens)
  workflow-guide:          ✅ loaded via skill [*]
  Project:                ✅ [project-name]
  Knowledge:              ✅ loaded (X,XXX chars, ~X,XXX tokens)
    Docs:                 [N] required (loaded), [N] reference (on-demand)
    Business rules:       [N] rules loaded
    API gotchas:          [N] gotchas loaded
    Data model:           [N] relationships, [N] key fields
    Known issues:         [N] issues loaded
    Features:             [N] features ([N] in-progress, [N] planned)
    UI patterns:          ✅ loaded
  Last session:           ✅ [date] — [what was done] or ⬜ first session
  Next action:            ✅ [specific next step] or ⬜ none
  Task board:             ✅ X tasks (Y done, Z in-progress, W pending) or ⬜ none
    #N agent:             ✅ done / 🔄 step X/Y (step name) / ⬜ pending / ❌ blocked
  Cross-repo feature:    ✅ [feature-name] — this repo: [status], depends on: [repos] or ⬜ none
  Project Tracker:        ✅ [phase X — current task] or ⬜ no active project

Agents:
| Agent | Skills | MCPs | Last | Next |
|---|---|---|---|---|
| orchestrator | [*] | websearch, outline | [last] | [next] |
| oracle | code-reviewer | — | [last] | [next] |
| librarian | — | websearch, context7, grep_app, outline | [last] | [next] |
| explorer | — | — | [last] | [next] |
| designer | agent-browser, ui-design-system | opencode-browser | [last] | [next] |
| fixer | senior-fullstack | — | [last] | [next] |

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

## PROJECT KNOWLEDGE — LOAD BEFORE ANY WORK

After reading `ai:knowledge:{project}`, the orchestrator MUST:

1. **Load all `required` docs from Outline** — fetch each doc by ID, read in full. These are TRDs, API specs, architecture docs that the AI MUST understand before touching code.
2. **Note `reference` docs** — don't load now, but know they exist. Load on-demand when a task touches that area.
3. **Check `features` section** — know which features exist, their status, and which TRD/API sections cover them.
4. **When delegating to agents**, include relevant knowledge:
   - Working on `creators` feature? → include TRD section "Creators" + API section "Creator endpoints" in the briefing
   - Working on `curated-lists`? → include TRD section "Curated Lists" + API section "CuratedList endpoints"
   - **Never let agents work without the relevant TRD/API section in their briefing**

### Knowledge Structure

```json
{
  "project": "ichigo-admin",
  "description": "Internal admin panel for Ichigo platform",
  "stack": "React 18 + Refine v4 + Mantine v5 + Apollo Client",
  "api": "GraphQL, auth via X-Auth-Token (JWT)",
  "outline_collection": "dc175c88",

  "docs": {
    "required": [{"id": "...", "title": "TRD", "type": "trd", "load": "full"}],
    "reference": [{"id": "...", "title": "PR Plan", "type": "plan", "load": "on-demand"}]
  },
  "business_rules": ["Curated lists: Draft → Sourcing → Ready → Complete", "..."],
  "api_gotchas": ["Auth in X-Auth-Token, NOT Authorization Bearer", "..."],
  "data_model": {
    "key_relationships": ["Brand has_many Campaigns, CuratedLists", "..."],
    "important_fields": ["Creator.status: active/inactive/blacklisted", "..."]
  },
  "environment": {"api_url": "REACT_APP_CP_API_URL", "auth_token": "REACT_APP_CP_API_TOKEN"},
  "known_issues": ["Mantine v5 only — NOT v7", "Apollo cache can serve stale data after mutations"],
  "external_services": [{"name": "Customer Portal API", "url": "localhost:3007"}],
  "ui_patterns": {"list_views": "useList + TanStack Table", "show_views": "useShow + DetailsCard"},
  "testing_patterns": {"mocking": "MockedProvider, not jest.mock"},
  "features": {
    "creators": {"trd_section": "Creators", "api_section": "Creator endpoints", "status": "in-progress", "depends_on": []},
    "proposals": {"trd_section": "Proposals", "status": "planned", "depends_on": ["creators", "campaigns"]}
  }
}
```

**Every section has a purpose:**

| Section | Prevents |
|---|---|
| `business_rules` | AI inventing wrong business logic |
| `api_gotchas` | AI using wrong auth header, wrong error format |
| `data_model` | AI guessing wrong relationships between entities |
| `known_issues` | AI using Mantine v7 APIs, stale cache bugs |
| `ui_patterns` | AI inventing new patterns instead of following existing ones |
| `features.depends_on` | AI building proposals before creators exist |
```

### When user asks to work on a feature:

```
User: "work on the creators feature"
  ↓
Orchestrator reads ai:knowledge:ichigo-admin
  → features.creators.trd_section = "Creators"
  → features.creators.api_section = "Creator endpoints"
  ↓
Orchestrator loads from Outline:
  → TRD doc (ab543398) → reads "Creators" section
  → API doc (86584564) → reads "Creator endpoints" section
  ↓
Includes BOTH in the agent briefing:
  REFERENCE:
  - TRD: [paste Creators section]
  - API: [paste Creator endpoints section]
  ↓
Agent has FULL knowledge — no guessing, no re-reading
```

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

## REDIS-BEFORE-HANDOFF — EVERY AGENT, EVERY TIME

**No agent passes work to another agent without updating Redis first.** This is the crash-protection guarantee.

```
RULE: Update Redis BEFORE every handoff. No exceptions.

Orchestrator → Fixer:
  1. Orchestrator plans the work
  2. Orchestrator creates/updates task board in Redis ← SAVE HERE
  3. Orchestrator dispatches Fixer

Fixer → Orchestrator (done):
  1. Fixer completes each step, updates Redis after EACH ← SAVE HERE
  2. Fixer finishes all steps
  3. Fixer sets status to "review", saves Redis ← SAVE HERE
  4. Fixer reports to Orchestrator

Orchestrator → Oracle (review):
  1. Orchestrator receives Fixer report
  2. Orchestrator updates task board (Fixer done, Oracle review pending) ← SAVE HERE
  3. Orchestrator dispatches Oracle

Oracle → Orchestrator (review result):
  1. Oracle reviews code
  2. Oracle writes review result to task board ← SAVE HERE
  3. Oracle reports to Orchestrator

Orchestrator → Fixer (fixes needed):
  1. Orchestrator receives Oracle review
  2. Orchestrator creates fix checklist in task board ← SAVE HERE
  3. Orchestrator dispatches Fixer with fixes

Fixer → Orchestrator (fixes done):
  1. Fixer completes each fix, updates Redis after EACH ← SAVE HERE
  2. Fixer sets status to "review" ← SAVE HERE
  3. Fixer reports to Orchestrator
```

**The pattern:** DO THE WORK → SAVE TO REDIS → THEN HAND OFF.

**Never:** Do the work → hand off → forget to save. If session crashes between "hand off" and "save", the work is lost.

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
12. **UPDATE REDIS BEFORE EVERY HANDOFF AND AFTER EVERY STEP.** Run: redis-cli SET "ai:tasks:$PROJECT" '<updated json>'. Save BEFORE reporting to orchestrator. Save AFTER each completed step. This is NON-NEGOTIABLE — if session crashes between steps or during handoff, the next session must know exactly where you stopped.
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

### Lifecycle — Agents Own Their Checklists

```
Orchestrator delegates task to @fixer
  ↓
@fixer analyzes the task, creates its OWN checklist:
  redis-cli SET "ai:tasks:{project}" → adds checklist items:
    ⬜ Update database schema
    ⬜ Update API endpoint
    ⬜ Update UI component
    ⬜ Add action button
    ⬜ Write tests
    ⬜ Build + lint passes
  ↓
@fixer works through each item, updates Redis AFTER EACH:
    ✅ Update database schema        ← Redis saved
    ✅ Update API endpoint            ← Redis saved
    ✅ Update UI component            ← Redis saved
    💥 CRASH (power/internet)
    ⬜ Add action button
    ⬜ Write tests
    ⬜ Build + lint passes
  ↓
Next session boots → reads ai:tasks:{project}
  → Task: "in-progress", 3/6 done
  → Resume: "Add action button"
  → @fixer continues from exact step
  ↓
@fixer finishes all items → status: "review"
  ↓
Orchestrator dispatches @oracle to review
  ↓
@oracle reviews, creates its OWN checklist:
    ⬜ Check spec compliance
    ⬜ Check error handling
    ⬜ Check test coverage
  ↓
@oracle finds bugs → creates fix checklist:
    ⬜ Fix: missing error state on API failure
    ⬜ Fix: add index on orders.user_id
  → status: "fix-needed"
  ↓
@fixer reads oracle's fix checklist → works through it:
    ✅ Fix: missing error state         ← Redis saved
    ✅ Fix: add index                   ← Redis saved
  → status: "review"
  ↓
@oracle re-reviews → APPROVED → status: "done"
  ↓
Loop ends. Next task begins.
```

### Task Board Structure (Three Levels: Feature → Sub-task → Steps)

```bash
PROJECT=$(basename $(git rev-parse --show-toplevel 2>/dev/null || basename $(pwd)))
redis-cli SET "ai:tasks:$PROJECT" '<json>'
```

```json
{
  "updated": "2026-03-19T14:30:00Z",
  "features": [
    {
      "id": 1,
      "name": "Authentication",
      "status": "in-progress",
      "subtasks": [
        {
          "id": "1a",
          "goal": "Login — Controller + Model",
          "agent": "fixer",
          "status": "done",
          "checklist": [
            {"step": "Read CODEMAP.md", "done": true},
            {"step": "Create User model + migration", "done": true},
            {"step": "Create AuthController with login action", "done": true},
            {"step": "Write tests", "done": true},
            {"step": "Build + lint passes", "done": true}
          ],
          "review": {"agent": "oracle", "status": "APPROVED", "fixes": []}
        },
        {
          "id": "1b",
          "goal": "Login — UI Form",
          "agent": "designer",
          "status": "in-progress",
          "checklist": [
            {"step": "Read existing UI patterns from ai:knowledge", "done": true},
            {"step": "Create LoginForm component", "done": false},
            {"step": "Connect to auth API", "done": false},
            {"step": "Handle error states (wrong password, locked)", "done": false},
            {"step": "Build + lint passes", "done": false}
          ],
          "review": null
        },
        {
          "id": "1c",
          "goal": "Login — E2E Tests",
          "agent": "fixer",
          "status": "pending",
          "depends_on": ["1a", "1b"],
          "checklist": [],
          "review": null
        }
      ]
    },
    {
      "id": 2,
      "name": "Registration",
      "status": "pending",
      "subtasks": [
        {
          "id": "2a",
          "goal": "Registration — Controller + Model",
          "agent": "fixer",
          "status": "pending",
          "checklist": [],
          "review": null
        },
        {
          "id": "2b",
          "goal": "Registration — UI Form",
          "agent": "designer",
          "status": "pending",
          "depends_on": ["2a"],
          "checklist": [],
          "review": null
        }
      ]
    }
  ]
}
```

**Three levels:**
- **Feature** (Authentication) — the big unit, tracks overall status
- **Sub-task** (Login Controller, Login UI) — one agent owns each, has its own checklist
- **Steps** (Create model, Write tests) — agent-level work, updated after each completion

**Feature status** is derived from sub-tasks:
- All sub-tasks `done` → feature `done`
- Any sub-task `in-progress` → feature `in-progress`
- All sub-tasks `pending` → feature `pending`
- Any sub-task `blocked` → feature `blocked`

### Task Statuses

| Status | Meaning |
|---|---|
| `pending` | Not started — agent hasn't created checklist yet |
| `in-progress` | Agent is working through its checklist |
| `review` | Agent finished, waiting for @oracle review |
| `fix-needed` | @oracle found issues — fix checklist created |
| `done` | @oracle APPROVED — sub-task complete |
| `blocked` | Agent can't proceed — needs help |

### Sub-task Dependencies

Sub-tasks can have `depends_on` — a list of sub-task IDs that must be `done` before this one starts:

```json
{"id": "1c", "goal": "E2E Tests", "depends_on": ["1a", "1b"], "status": "pending"}
```

The orchestrator checks dependencies before dispatching. If `1a` or `1b` isn't done, `1c` stays `pending`.

### Agent Rules (included in every delegation)

**When dispatched, EVERY agent MUST:**

1. **Read the task board:** `redis-cli GET ai:tasks:{project}`
2. **Find your sub-task** by ID (e.g., `1b`)
3. **If resuming (in-progress):** Find first `done: false` step, continue from there
4. **If new (pending):** Create your checklist of concrete steps, save to Redis, set status to `in-progress`
5. **After EACH step:** Update to `done: true`, save to Redis IMMEDIATELY — no batching
6. **When all steps done:** Set status to `review`
7. **If fix-needed:** Read review.fixes, create fix steps, work through them

**Include this in every agent briefing:**
```
TASK BOARD: redis-cli GET ai:tasks:{project}
YOUR SUB-TASK: #{id} — {goal}
FEATURE: {feature name}
RULES:
- Read the task board first — find your sub-task by ID
- Create your own checklist of concrete steps before starting
- Save to Redis BEFORE starting: redis-cli SET ai:tasks:{project} '<json>'
- ⚠️ AFTER EVERY STEP: update done:true, save to Redis IMMEDIATELY
  → No batching. No waiting. Crash protection.
- When all done: set status to "review"
- If fix-needed: read review.fixes, create fix steps, work through them
```

### The Review Loop

```
Agent finishes sub-task → status: "review"
  ↓
Orchestrator dispatches @oracle:
  "Review sub-task #{id} of feature {name}.
   Check: spec compliance, error handling, tests, patterns."
  ↓
@oracle reviews:
  ├─ APPROVED → status: "done" ✅
  │   → Check: are all sub-tasks for this feature done?
  │   → Yes: feature status → "done"
  │   → No: dispatch next pending sub-task
  └─ ISSUES → creates fix list in review.fixes[]
               → status: "fix-needed"
               → orchestrator dispatches same agent with fixes
               → agent works through fix steps → status: "review"
               → @oracle re-reviews → loop until APPROVED
```

### Boot Checklist (summary by default)

```
  Task board:             ✅ 2 features (1 in-progress, 1 pending)
    1. Authentication:    🔄 in-progress (1/3 sub-tasks done)
       1a. fixer:         ✅ Controller + Model (5/5 — APPROVED)
       1b. designer:      🔄 UI Form — step 2/5 (Create LoginForm)
       1c. fixer:         ⬜ E2E Tests — waiting on 1a, 1b
    2. Registration:      ⬜ pending (0/2 sub-tasks)
```

Only expand the `in-progress` feature by default. Show pending features as one-line summaries.

## CROSS-REPO FEATURES

When a feature spans multiple repos (e.g., API in OMS + UI in ichigo-admin + checkout in customer-portal):

### Create a Feature Key

```bash
redis-cli SET "ai:feature:{feature-name}" '<json>'
```

```json
{
  "name": "Payment Integration",
  "status": "in-progress",
  "created": "2026-03-19",
  "updated": "2026-03-19",
  "repos": {
    "oms":              {"branch": "feature/payment-integration", "status": "in-progress", "pr": null, "summary": "API endpoints. 3/5 done."},
    "ichigo-admin":     {"branch": "feature/payment-integration", "status": "pending",     "pr": null, "summary": "Admin UI. Waiting for OMS API."},
    "customer-portal":  {"branch": "feature/payment-integration", "status": "pending",     "pr": null, "summary": "Checkout flow. Waiting for OMS API."}
  },
  "dependency_order": ["oms", "ichigo-admin", "customer-portal"],
  "merge_order": ["oms", "ichigo-admin", "customer-portal"],
  "integration_tested": false,
  "decisions": ["OMS owns payment logic", "Stripe webhooks for async"]
}
```

### Rules

| Rule | Why |
|---|---|
| Work repos in `dependency_order` | Don't start UI until API is done |
| Same branch name across repos | Easy to track |
| Each repo has its own `ai:tasks:{project}` and `ai:state:{project}` | Per-repo state stays independent |
| Feature key tracks the big picture | Which repos are done, which are waiting |
| Merge in `merge_order` | Backend before frontend, shared libs first |
| Integration test after ALL repos done | Use `staging-integration` skill |

### Cross-Repo Flow

```
Orchestrator reads ai:feature:{name}
  ↓
Find first repo in dependency_order with status != "done"
  ↓
Switch to that repo (or tell user to open it)
  ↓
Work using normal ai:tasks:{project} flow
  ↓
When repo is done:
  → Update ai:feature:{name} → repo status: "done", pr: "#123"
  → Move to next repo in dependency_order
  ↓
All repos done?
  → Integration test across repos (staging-integration skill)
  → Update ai:feature:{name} → integration_tested: true
  → Merge in merge_order
```

### Boot Checklist (cross-repo)

When a cross-repo feature is detected:
```
  Cross-repo feature:    ✅ Payment Integration
    oms:                 🔄 in-progress (3/5 tasks) — branch: feature/payment-integration
    ichigo-admin:        ⬜ pending — waiting for oms API
    customer-portal:     ⬜ pending — waiting for oms API
    Integration tested:  ⬜ not yet
    Merge order:         oms → ichigo-admin → customer-portal
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
    "orchestrator": {"last": "Delegated task #1 and #2 to fixer", "next": "Dispatch fixer for task #2 remaining steps"},
    "fixer":        {"last": "Completed task #1 (POST). Task #2: CODEMAP + TRD read done", "next": "Task #2: write tests, implement PATCH"},
    "oracle":       {"last": "Reviewed task #1 — APPROVED. Flagged: add rate limiting", "next": "Review task #2 when fixer completes"},
    "designer":     {"last": "—", "next": "—"},
    "explorer":     {"last": "Mapped api/v1/ structure", "next": "—"},
    "librarian":    {"last": "Updated API TRD", "next": "Update TRD after PATCH done"}
  }
}
```

### 3. Update Cross-Repo Feature (if applicable)

If this project is part of a cross-repo feature:
```bash
redis-cli SET "ai:feature:{feature-name}" '<updated json with this repo status>'
```

### 4. Update Project Tracker in Outline

Delegate to @librarian: update the Project Tracker document with session log entry.

### 5. Feature complete?

**Single-repo:** @fixer creates PR → @oracle reviews → merge

**Cross-repo:** Update feature key → check if all repos done → if yes: staging-integration across all repos → merge in `merge_order`

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
