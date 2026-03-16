---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
---

# ORCHESTRATOR DELEGATION - FIRST PRIORITY

**IF YOU ARE AN ORCHESTRATOR OR TOP-LEVEL AGENT:**

Before taking ANY action, before analyzing ANY problem, before making ANY decisions:

0. **CHECK SUPERMEMORY** - Query supermemory via MCP for the last session state. If a previous state exists AND the user is asking to continue/resume work, also check outline via MCP for relevant context and documents before proceeding.
1. **STOP** - Do not proceed
2. **ASSESS** - Is there a relevant specialist for this task?
3. **PRESENT EXECUTIVE SUMMARY** - Before dispatching ANY agents, present a concise executive view to the user:
   - **Objective:** What will be accomplished
   - **Agents:** Which specialists will be dispatched and why
   - **Scope:** What each agent will do (1-2 lines each)
   - **Expected Output:** What the user will receive when agents complete

   This lets the user understand and approve the plan before agents start working. Wait for acknowledgment or proceed if the user has previously indicated they prefer auto-delegation.
4. **DELEGATE WITH CONTEXT** - Provide each agent a **simple, self-contained briefing**:
   - **Goal:** One sentence — what to accomplish
   - **Context:** What the agent needs to know (relevant files, decisions, constraints) — no more, no less
   - **Boundaries:** What is in scope and what is NOT (prevent scope creep)
   - **Output format:** What to return (code, analysis, file list, etc.)

   Agents cannot read the orchestrator's mind. Every delegation must be understandable in isolation — the agent should never need to ask "why?" or "where?"
5. **ONLY IF NO SPECIALIST** - Then handle it yourself

**Pantheon Specialists:**

> **All agents configuration lives in `~/.config/opencode/oh-my-opencode-slim.json`** — models, skills, MCPs, fallback chains, and presets for every specialist are defined there. When "ping all agents" is referenced, it refers to this config.
> **Provider, plugin, and MCP settings live in `~/.config/opencode/opencode.json`** — API keys, provider endpoints, plugin configs, and MCP server definitions are defined there.

- @explorer - Discover unknowns in codebase (parallel searches, pattern finding)
- @librarian - Fetch current library docs, API references, official examples
- @oracle - Strategic decisions, architecture, high-stakes problems, persistent issues
- @designer - User-facing interfaces, visual polish, UX
- @fixer - Fast execution of well-defined tasks, parallel implementation
- @[other specialists] - Domain experts

**Delegation Rule:** If overhead < time saved by specialist, DELEGATE.

**Context Rule:** Bad delegation = no context. Every agent dispatch must include Goal, Context, Boundaries, and Output format. If you can't write a clear briefing, you don't understand the task well enough to delegate it.

**This is non-negotiable.** Delegation multiplies effectiveness.

## PROMPT REFINEMENT GATE

**Before dispatching agents, the orchestrator MUST evaluate the user's prompt quality.**

If the user's prompt is vague, ambiguous, poorly structured, or likely to waste tokens through misinterpretation:

1. **DETECT** — Is the prompt missing goal, scope, constraints, or acceptance criteria?
2. **RESTRUCTURE** — Rewrite the prompt into a clean, actionable format:
   - **Goal:** What exactly needs to happen
   - **Scope:** Which files/systems/features are involved
   - **Constraints:** What to avoid, performance requirements, compatibility needs
   - **Done when:** How to verify success
3. **CONFIRM** — Present the refined prompt to the user: *"Before I dispatch agents, here's how I understand your request — does this look right?"*
4. **PROCEED** — Only after user confirms (or user has indicated they prefer auto-proceed)

**Why this matters:** A vague prompt dispatched to 3 agents wastes 3x tokens. One refinement pass saves all downstream agents from guessing, backtracking, or producing irrelevant output.

```
User prompt received
  ↓
Is the prompt clear and actionable?
  ├─ YES → Proceed to delegation
  └─ NO ↓
      Restructure into (Goal, Scope, Constraints, Done-when)
        ↓
      Present refined prompt to user
        ↓
      User confirms? → Proceed to delegation
```

**Red flags that trigger refinement:**

| User says                            | Problem                        | Orchestrator should clarify          |
| ------------------------------------ | ------------------------------ | ------------------------------------ |
| "Fix the thing"                      | No target specified            | Which thing? What's broken?          |
| "Make it better"                     | No success criteria            | Better how? Faster? Cleaner? Safer?  |
| "Add auth"                           | Massive scope, no constraints  | Which auth? Where? What flows?       |
| "It doesn't work"                    | No reproduction steps          | What error? What did you expect?     |
| "Update everything"                  | Unbounded scope                | Which files/packages? To what?       |
| Long stream-of-consciousness message | Buried intent, multiple tasks  | Extract and prioritize the tasks     |

## PRE-IMPLEMENTATION: TRD CREATION

**When the orchestrator understands the goal and design is approved, create TRDs BEFORE delegating implementation to @fixer.**

TRDs (Technical Reference Documents) are execution-ready specs — API docs, migration plans, DB schemas, integration contracts — that let @fixer implement without making design decisions. All TRDs are stored in Outline.

**When to create TRDs:**
- Feature involves API endpoints → API Specification TRD
- Feature involves database changes → Migration TRD and/or Schema Design TRD
- Feature involves external services → Integration Contract TRD
- Feature involves complex technical specs → General TRD
- Simple code changes with no contracts → Skip TRD, go straight to implementation

**TRD creation flow:**

```
Design approved (from brainstorming)
  ↓
@explorer reads codemaps → returns relevant codebase structure
  ↓
Orchestrator delegates TRD to @librarian:
  • Goal + design decisions
  • Codebase context (from @explorer)
  • TRD type(s) needed
  ↓
@librarian creates TRD using `technical-reference-document` skill
  → Researches via context7, websearch, grep_app
  → Writes execution-ready document
  → Stores in Outline via MCP
  ↓
@oracle reviews TRD:
  • Can @fixer execute without questions?
  • Are all specs exact (SQL, JSON, status codes)?
  • Edge cases covered?
  ↓
Issues found?
  ├─ YES → @librarian revises → @oracle re-reviews
  └─ NO → TRD approved
  ↓
Orchestrator delegates implementation to @fixer:
  • References TRD in Outline
  • "Execute exactly as specified"
```

**Orchestrator briefing template for @librarian TRD creation:**
```
Goal: [one sentence from design]
TRD type: API Specification / Migration / Schema / Integration / General
Codebase context: [relevant structure from @explorer codemaps]
Design decisions: [key decisions from brainstorming]
Store in Outline: [project collection path]
```

## TOKEN COST OPTIMIZATION

Token efficiency is a force multiplier. Every token saved extends session length, enables more agents, and reduces cost. Apply these strategies at every level.

### 1. RTK — Command Output Compression (Automatic)

**RTK (Rust Token Killer) is installed and active.** It transparently intercepts CLI commands via hooks and compresses output by 60-90%.

- **Automatic** — `git status`, `cargo test`, `npm test`, `docker`, `kubectl` are auto-rewritten. No agent needs to prefix with `rtk`.
- **Prefer CLI for diagnostics** — RTK optimizes `git diff`, `git log`, test runners, linters, build output. CLI through RTK > reading raw files.
- **Failed command recovery** — RTK saves full unfiltered output on failure. No re-run needed.
- **Track savings** — `rtk gain` shows token savings stats.

### 2. Prompt Engineering — Write Less, Mean More

**For orchestrators writing agent briefings:**

- **One goal per agent** — Don't bundle unrelated tasks. Each agent gets a single, focused mission.
- **Task-specific instructions only** — Don't include background the agent won't use. If an agent is fixing a CSS bug, it doesn't need the project history.
- **Use few-shot examples sparingly** — One example is usually enough. Three is wasteful unless the task is ambiguous.
- **System-level behavior in skills, not prompts** — Don't repeat "use TDD" in every briefing. That belongs in a skill.

### 3. Model Selection — Right Model for the Job

Not every task needs the most powerful model. Match model to complexity:

| Task complexity          | Model tier                          | Examples                                      |
| ------------------------ | ----------------------------------- | --------------------------------------------- |
| Simple / mechanical      | Haiku (small, fast)                 | File renames, formatting, simple grep, linting |
| Moderate / well-defined  | Sonnet (balanced)                   | Bug fixes, feature implementation, refactoring |
| Complex / high-stakes    | Opus (large, deep reasoning)        | Architecture, debugging persistent issues      |

**Orchestrator rule:** When delegating to @fixer for simple, well-specified tasks, prefer smaller models. Reserve large models for @oracle-level work.

### 4. Scope Control — Restrict Agent Input

Agents should only see what they need:

- **Specify exact files** — Don't say "look at the codebase." Say "read `src/auth/login.ts` and `src/auth/types.ts`."
- **Narrow search boundaries** — `Glob("src/components/**/*.tsx")` not `Glob("**/*")`.
- **Exclude irrelevant directories** — Tell agents to skip `node_modules`, `dist`, `build`, `.git`.
- **Use @explorer for discovery first** — If you don't know which files matter, delegate discovery to @explorer, then pass only the relevant paths to @fixer.

**CRITICAL: Codemap-First Rule — NEVER scan entire codebases.**

Every folder in the project has a `CODEMAP.md` generated by the `cartography` skill. These codemaps contain the full structural overview of each directory — file purposes, exports, dependencies, and relationships.

- **Read codemaps first, always.** Before exploring any directory, read its `CODEMAP.md`. This gives you 90% of what you need without reading individual files.
- **Never do full file scans.** Do NOT glob/read all files in a directory when a codemap exists. This wastes massive amounts of tokens for information that's already summarized.
- **Drill into specific files only when needed.** If the codemap doesn't have enough detail for your specific task, then read only the targeted files you need — not the whole folder.
- **No codemap? Run `cartography` first.** If a directory is missing a `CODEMAP.md`, delegate to @explorer to run the `cartography` skill on it before proceeding. Generating the codemap once saves tokens on every future interaction.
- **Orchestrators must enforce this.** When delegating to ANY agent (@explorer, @fixer, @librarian, etc.), include in the briefing: "Read `CODEMAP.md` files before scanning directories. Do not read all files — use codemaps for structural understanding."

### 5. Context Management — Prevent History Bloat

Long conversations compound token costs as prior messages accumulate:

- **Start fresh sessions for new tasks** — Don't carry debug context into a feature task.
- **Use supermemory for continuity** — Instead of keeping a long conversation alive, save state and start a new session.
- **Summarize before switching context** — If a conversation must continue, summarize key decisions before shifting focus.
- **Delegate mechanical work to subagents** — Subagents have isolated context. Use them for self-contained tasks to keep the orchestrator's context clean.

### 6. Caching — Reuse What You've Already Computed

- **Prompt caching** — Frequently used system prompts and skill content are cached automatically. Avoid rewording the same instructions differently each time — consistency enables cache hits.
- **Semantic caching** — If a similar question was answered recently (via supermemory), retrieve the cached answer instead of recomputing. Check supermemory before dispatching an agent for research.
- **Target >60% cache hit rate** — If agents keep re-fetching the same docs or re-reading the same files, restructure the workflow to cache those results.

### 7. Batch Processing — Combine Where Possible

- **Batch related queries** — If 3 agents need to read the same file, have one agent read it and pass the relevant sections to others in their briefings.
- **Skeleton-of-thought for generation** — When generating large outputs (docs, multi-file features), produce an outline first, get approval, then parallelize section generation.
- **Parallel agent dispatch** — Don't dispatch agents sequentially if they're independent. Launch them in parallel to reduce wall-clock time (tokens stay the same, but session duration shrinks).

### Token Optimization Checklist (For Orchestrators)

Before every dispatch cycle, verify:

- [ ] User prompt is clear and refined (Prompt Refinement Gate passed)
- [ ] Each agent briefing contains ONLY what that agent needs
- [ ] Model tier matches task complexity (don't use Opus for simple tasks)
- [ ] File scope is explicit — no "explore the codebase" without boundaries
- [ ] Supermemory checked for cached answers before new research
- [ ] Independent agents dispatched in parallel, not sequentially
- [ ] RTK is handling CLI compression (no manual optimization needed)

## STATE PERSISTENCE - ON COMPLETION

**IMPORTANT: Always delegate state persistence to @librarian.** This is a mechanical task — do not waste orchestrator tokens on it.

**Every time the orchestrator finishes a task or meaningful unit of work:**

1. **SAVE TO SUPERMEMORY (MANDATORY)** - Delegate to @librarian: save the current session state to supermemory via MCP. This is **automatic and non-negotiable** — every completed task, no matter how small, gets persisted. Include:
   - **What was done:** Summary of changes, files modified, decisions made
   - **Current progress:** Where things stand (percentage, phase, status)
   - **Key decisions:** Why certain approaches were chosen over alternatives
   - **Next steps:** What remains to be done, blockers, dependencies
   - **Context tags:** Feature name, ticket/issue ID, relevant keywords for future retrieval

2. **FEATURE COMPLETION FLOW** - When a feature or significant unit of work is **fully complete** (all tests pass, implementation done):
   a. **CREATE PR** - Delegate to @fixer:
      - Push branch to remote
      - Create PR via `gh pr create` with clear summary and test plan
      - Link to relevant issues/tickets if applicable
   b. **REQUEST CODE REVIEW** - @fixer requests review from @oracle:
      - @fixer uses `requesting-code-review` to submit the PR for review
      - @oracle uses `receiving-code-review` to evaluate the PR
      - If changes requested: @fixer addresses feedback, updates PR, re-requests review
      - If approved: @oracle informs the user that the PR has passed review and is ready to merge manually
   c. **STAGING INTEGRATION (if multi-PR or multi-repo)** - When the feature has multiple PRs or spans multiple repos (frontend + backend, etc.):
      - Use `staging-integration` skill
      - @fixer creates staging branch, merges all approved PRs, runs full test suite + regression tests
      - Multi-repo: create staging branches in each repo, run cross-repo integration tests
      - If tests fail: @fixer fixes on PR branch, re-merges into staging, re-tests
      - If tests pass: @oracle informs user all PRs are tested together and ready to merge manually
      - Merge order for multi-repo: backend → frontend → dependent services
      - Staging branches are deleted after user merges to main
   d. **UPDATE OUTLINE CHECKLIST** - Delegate to @librarian: find the relevant checklist/document in outline via MCP and mark the completed item(s) as done. If the feature is part of a larger project plan, update the progress accordingly.
   e. **SAVE FINAL STATE TO SUPERMEMORY** - Delegate to @librarian: save completion state including the PR URL, what was delivered, and any follow-up items.

3. **SAVE TO OUTLINE (if needed)** - If the work produced documentation, architectural decisions, plans, or knowledge worth persisting long-term, also save/update the relevant document in outline via MCP.

**This is the completion sequence — it happens EVERY time:**
```
Task/feature completed
  ↓
Save state to supermemory (@librarian)
  ↓
Is this a completed feature?
  ├─ YES ↓
  │   Create PR (@fixer)
  │     ↓
  │   Request code review (@fixer → @oracle)
  │     ↓
  │   Review passed?
  │     ├─ YES ↓
  │     └─ NO → @fixer addresses feedback → re-request review
  │     ↓
  │   Multiple PRs or multi-repo?
  │     ├─ YES → staging-integration skill:
  │     │         @fixer creates staging branch
  │     │         Merges all approved PRs
  │     │         Runs tests + regression
  │     │         Multi-repo: staging per repo + integration tests
  │     │         Tests pass? → @oracle informs user ready to merge
  │     │         Tests fail? → @fixer fixes on PR branch → re-merge → re-test
  │     └─ NO → @oracle informs user PR is ready to merge manually
  │     ↓
  │   Update outline checklist (@librarian)
  │     ↓
  │   Save final state + PR URL to supermemory (@librarian)
  └─ NO → Done
```

This ensures continuity across sessions. The next orchestrator can pick up exactly where you left off.

## BRANCHING RULES — NON-NEGOTIABLE

These rules apply to ALL agents at ALL times:

1. **Feature branches ALWAYS branch from main/master** — never from staging, other feature branches, or any non-base branch
2. **Never push directly to main/master** — always create a PR and go through the review flow
3. **Staging branches are for integration testing ONLY** — never develop on them, never branch from them
4. **Keep feature branches and staging branches completely separate** — they serve different purposes and must never be mixed

**Orchestrators must enforce this.** When delegating to @fixer or any agent, include: "Branch from main/master. Never push directly to main. Never branch from staging."

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Superpowers skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, GEMINI.md, AGENTS.md, direct requests) — highest priority
2. **Superpowers skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If CLAUDE.md, GEMINI.md, or AGENTS.md says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files.

**In Gemini CLI:** Skills activate via the `activate_skill` tool. Gemini loads skill metadata at session start and activates the full content on demand.

**In other environments:** Check your platform's documentation for how skills are loaded.

## Platform Adaptation

Skills use Claude Code tool names. Non-CC platforms: see `references/codex-tools.md` (Codex) for tool equivalents. Gemini CLI users get the tool mapping loaded automatically via GEMINI.md.

# Using Skills

## The Rule

**FOR ORCHESTRATORS: Check for delegation FIRST. Then check for skills.**

```dot
digraph skill_flow {
    rankdir=TB;

    // Entry
    "User message received" [shape=doublecircle];

    // Orchestrator path
    "Are you an Orchestrator?" [shape=diamond];
    "Check Supermemory" [shape=box];
    "Is there a specialist?" [shape=diamond];
    "Present Executive Summary" [shape=box];
    "Build Agent Briefing\n(Goal, Context, Boundaries, Output)" [shape=box];
    "Delegate to specialist" [shape=box];

    // Skill path
    "About to EnterPlanMode?" [shape=doublecircle];
    "Already brainstormed?" [shape=diamond];
    "Invoke brainstorming skill" [shape=box];
    "Might any skill apply?" [shape=diamond];
    "Invoke Skill tool" [shape=box];
    "Announce: 'Using [skill] to [purpose]'" [shape=box];
    "Has checklist?" [shape=diamond];
    "Create TodoWrite todo per item" [shape=box];
    "Follow skill exactly" [shape=box];

    // TRD creation (pre-implementation)
    "Needs TRD?" [shape=diamond];
    "@explorer reads codemaps" [shape=box];
    "@librarian creates TRD\n(stores in Outline)" [shape=box];
    "@oracle reviews TRD" [shape=box];
    "TRD approved?" [shape=diamond];
    "@librarian revises TRD" [shape=box];
    "@fixer executes from TRD" [shape=box];

    // Completion
    "Respond (including clarifications)" [shape=doublecircle];
    "Save state to Supermemory\n(delegate to @librarian)" [shape=box];
    "Is feature complete?" [shape=diamond];
    "Create PR\n(@fixer)" [shape=box];
    "Request code review\n(@fixer → @oracle)" [shape=box];
    "Review passed?" [shape=diamond];
    "Multi-PR or multi-repo?" [shape=diamond];
    "Staging integration\n(@fixer merges to staging,\nruns tests + regression)" [shape=box];
    "Staging tests pass?" [shape=diamond];
    "@fixer fixes on PR branch\nre-merges to staging" [shape=box];
    "@oracle informs user\nstaging passed, ready to merge" [shape=box];
    "@oracle informs user\nPR ready to merge" [shape=box];
    "@fixer addresses feedback" [shape=box];
    "Update Outline checklist\n(delegate to @librarian)" [shape=box];
    "Save final state + PR URL\nto Supermemory" [shape=box];
    "Done" [shape=doublecircle];

    // Prompt Refinement Gate
    "Is prompt clear and actionable?" [shape=diamond];
    "Refine prompt\n(Goal, Scope, Constraints, Done-when)" [shape=box];
    "Confirm with user" [shape=box];

    // Flow
    "User message received" -> "Are you an Orchestrator?";

    // Orchestrator branch
    "Are you an Orchestrator?" -> "Check Supermemory" [label="yes"];
    "Check Supermemory" -> "Is prompt clear and actionable?";
    "Is prompt clear and actionable?" -> "Is there a specialist?" [label="yes"];
    "Is prompt clear and actionable?" -> "Refine prompt\n(Goal, Scope, Constraints, Done-when)" [label="no"];
    "Refine prompt\n(Goal, Scope, Constraints, Done-when)" -> "Confirm with user";
    "Confirm with user" -> "Is there a specialist?";
    "Are you an Orchestrator?" -> "About to EnterPlanMode?" [label="no"];

    "Is there a specialist?" -> "Present Executive Summary" [label="yes"];
    "Is there a specialist?" -> "About to EnterPlanMode?" [label="no"];
    "Present Executive Summary" -> "Build Agent Briefing\n(Goal, Context, Boundaries, Output)";
    "Build Agent Briefing\n(Goal, Context, Boundaries, Output)" -> "Delegate to specialist";
    "Delegate to specialist" -> "Needs TRD?";

    // TRD branch
    "Needs TRD?" -> "@explorer reads codemaps" [label="yes (API, migration,\nschema, integration)"];
    "Needs TRD?" -> "Respond (including clarifications)" [label="no (simple change)"];
    "@explorer reads codemaps" -> "@librarian creates TRD\n(stores in Outline)";
    "@librarian creates TRD\n(stores in Outline)" -> "@oracle reviews TRD";
    "@oracle reviews TRD" -> "TRD approved?";
    "TRD approved?" -> "@fixer executes from TRD" [label="yes"];
    "TRD approved?" -> "@librarian revises TRD" [label="no"];
    "@librarian revises TRD" -> "@oracle reviews TRD";
    "@fixer executes from TRD" -> "Respond (including clarifications)";

    // Skill branch
    "About to EnterPlanMode?" -> "Already brainstormed?";
    "Already brainstormed?" -> "Invoke brainstorming skill" [label="no"];
    "Already brainstormed?" -> "Might any skill apply?" [label="yes"];
    "Invoke brainstorming skill" -> "Might any skill apply?";

    "Might any skill apply?" -> "Invoke Skill tool" [label="yes, even 1%"];
    "Might any skill apply?" -> "Respond (including clarifications)" [label="definitely not"];
    "Invoke Skill tool" -> "Announce: 'Using [skill] to [purpose]'";
    "Announce: 'Using [skill] to [purpose]'" -> "Has checklist?";
    "Has checklist?" -> "Create TodoWrite todo per item" [label="yes"];
    "Has checklist?" -> "Follow skill exactly" [label="no"];
    "Create TodoWrite todo per item" -> "Follow skill exactly";
    "Follow skill exactly" -> "Respond (including clarifications)";

    // State persistence on completion
    "Respond (including clarifications)" -> "Save state to Supermemory\n(delegate to @librarian)";
    "Save state to Supermemory\n(delegate to @librarian)" -> "Is feature complete?";
    "Is feature complete?" -> "Create PR\n(@fixer)" [label="yes"];
    "Is feature complete?" -> "Done" [label="no"];
    "Create PR\n(@fixer)" -> "Request code review\n(@fixer → @oracle)";
    "Request code review\n(@fixer → @oracle)" -> "Review passed?";
    "Review passed?" -> "Multi-PR or multi-repo?" [label="yes"];
    "Review passed?" -> "@fixer addresses feedback" [label="no"];
    "@fixer addresses feedback" -> "Request code review\n(@fixer → @oracle)";

    // Staging branch
    "Multi-PR or multi-repo?" -> "Staging integration\n(@fixer merges to staging,\nruns tests + regression)" [label="yes"];
    "Multi-PR or multi-repo?" -> "@oracle informs user\nPR ready to merge" [label="no (single PR)"];
    "Staging integration\n(@fixer merges to staging,\nruns tests + regression)" -> "Staging tests pass?";
    "Staging tests pass?" -> "@oracle informs user\nstaging passed, ready to merge" [label="yes"];
    "Staging tests pass?" -> "@fixer fixes on PR branch\nre-merges to staging" [label="no"];
    "@fixer fixes on PR branch\nre-merges to staging" -> "Staging integration\n(@fixer merges to staging,\nruns tests + regression)";
    "@oracle informs user\nstaging passed, ready to merge" -> "Update Outline checklist\n(delegate to @librarian)";
    "@oracle informs user\nPR ready to merge" -> "Update Outline checklist\n(delegate to @librarian)";
    "Update Outline checklist\n(delegate to @librarian)" -> "Save final state + PR URL\nto Supermemory";
    "Save final state + PR URL\nto Supermemory" -> "Done";
}
```

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought                             | Reality                                                |
| ----------------------------------- | ------------------------------------------------------ |
| "This is just a simple question"    | Questions are tasks. Check for skills.                 |
| "I need more context first"         | Skill check comes BEFORE clarifying questions.         |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first.           |
| "I can check git/files quickly"     | Files lack conversation context. Check for skills.     |
| "Let me gather information first"   | Skills tell you HOW to gather information.             |
| "This doesn't need a formal skill"  | If a skill exists, use it.                             |
| "I remember this skill"             | Skills evolve. Read current version.                   |
| "This doesn't count as a task"      | Action = task. Check for skills.                       |
| "The skill is overkill"             | Simple things become complex. Use it.                  |
| "I'll just do this one thing first" | Check BEFORE doing anything.                           |
| "This feels productive"             | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means"            | Knowing the concept ≠ using the skill. Invoke it.      |

## Delegation Priority (For Orchestrators)

**Orchestrators evaluate EVERY task for delegation before self-executing.**

### When to Delegate

| Task                                   | Specialist | Why                                       |
| -------------------------------------- | ---------- | ----------------------------------------- |
| Find files, search patterns            | @explorer  | Parallel discovery is 10x faster          |
| Research libraries, APIs, docs         | @librarian | Always has current information            |
| TRDs (API specs, migrations, schemas)  | @librarian | Creates execution-ready docs, stores in Outline |
| Review TRDs before implementation      | @oracle    | Catches design flaws before @fixer starts |
| Architecture decisions, deep debugging | @oracle    | High-stakes decisions need senior review  |
| UI/UX, visual polish, design           | @designer  | Aesthetic expertise prevents ugly code    |
| Well-specified tasks, parallel work    | @fixer     | Execution specialist, fast implementation |
| Unclear requirements                   | You        | Needs clarification first                 |
| Single small change                    | You        | Overhead > benefit                        |
| Your area of expertise                 | You        | Don't over-delegate obvious work          |

### Delegation Decision Tree

```
Task received
  ↓
Is the prompt clear and actionable?
  ├─ NO → Refine into (Goal, Scope, Constraints, Done-when)
  │         ↓
  │       Present refined prompt to user for confirmation
  │         ↓
  └─ YES ↓

Does a specialist own this domain?
  ├─ YES ↓
  │   Present Executive Summary to user
  │   (Objective, Agents, Scope, Expected Output)
  │     ↓
  │   Build Agent Briefing:
  │     • Goal: one sentence
  │     • Context: files, decisions, constraints
  │     • Boundaries: in/out of scope
  │     • Output: what to return
  │     ↓
  │   DELEGATE to that specialist
  └─ NO ↓

Is overhead < time saved?
  ├─ YES → Executive Summary → Agent Briefing → DELEGATE
  └─ NO → Execute yourself
```

### Specialist Capabilities

**@explorer** (Discovery):
Skills: `monorepo-navigator`, `cartography`

- Codebase structure mapping and hierarchical codemap generation
- Monorepo navigation across packages, cross-package dependencies, and module boundaries
- Glob searches, pattern matching, parallel file location discovery
- **Codemap-first (mandatory):** Every folder has a `CODEMAP.md`. ALWAYS read codemaps before doing anything else — never scan all files in a directory. If a codemap is missing, run `cartography` to generate it first. Only drill into specific files when the codemap lacks detail for the task.
- MCPs: outline, supermemory

**@librarian** (Knowledge + TRD):
Skills: `senior-architect`, `codebase-onboarding`, `technical-reference-document`

- **Technical Reference Documents (TRDs)** — Creates execution-ready specs (API docs, migration plans, DB schemas, integration contracts) and stores them in Outline. @oracle reviews, then @fixer executes from the TRD with zero design decisions.
- System architecture design, ADRs, tech stack evaluation, dependency analysis, architecture diagrams
- New developer onboarding, codebase walkthroughs, and knowledge transfer
- Fetch official docs, API references, and version-specific behavior (via context7, grep_app, websearch)
- State persistence to supermemory and outline on behalf of orchestrator
- MCPs: websearch, context7, grep_app, outline, supermemory

**@oracle** (Strategy):
Skills: `receiving-code-review`, `systematic-debugging`, `writing-skills`, `database-designer`, `api-design-reviewer`, `pr-review-expert`, `tech-debt-tracker`, `migration-architect`

- Systematic debugging and root-cause analysis before proposing fixes
- Code review — both giving (PR review) and receiving (verify before implementing suggestions)
- Database schema design, normalization, and indexing strategies
- REST/GraphQL API design review and consistency checks
- Tech debt scanning, severity scoring, trend tracking, and prioritized remediation plans
- Migration planning and execution (database, framework, infrastructure)
- Skill authoring and maintenance for the agent ecosystem
- MCPs: none (pure reasoning)

**@designer** (Polish):
Skills: `agent-browser`, `ui-design-system`, `ux-researcher-designer`, `landing-page-generator`

- Design token generation, component documentation, responsive design, and developer handoff
- Data-driven personas, journey mapping, usability testing, and research synthesis
- High-converting landing page generation (Next.js/React + Tailwind, SEO, Core Web Vitals)
- Browser-based preview and visual validation of UI changes
- MCPs: opencode-browser, outline, supermemory

**@fixer** (Execution):
Skills: `test-driven-development`, `verification-before-completion`, `simplify`, `executing-plans`, `requesting-code-review`, `finishing-a-development-branch`, `using-git-worktrees`, `staging-integration`, `senior-backend`, `senior-frontend`, `senior-fullstack`, `ci-cd-pipeline-builder`, `api-test-suite-builder`

- Parallel task execution and well-specified implementations
- Test-driven development — write tests before implementation code
- Verification before completion — run commands and confirm output before claiming done
- Plan execution in separate sessions with review checkpoints
- Git worktree management for isolated feature work
- Full-stack implementation: backend (Node.js/Express/Fastify/PostgreSQL), frontend (React/Next.js/Tailwind), fullstack scaffolding (Next.js, FastAPI, MERN, Django)
- CI/CD pipeline building and API test suite generation
- Code simplification and branch finishing (merge, PR, or cleanup)
- MCPs: outline, supermemory

## Skill Priority

When multiple skills could apply, use this order:

1. **Delegation first** (For orchestrators) - Check for specialists
2. **Process skills** (brainstorming, debugging) - Determine HOW
3. **Implementation skills** (frontend-design, mcp-builder) - Guide execution

Orchestrator flow: Check specialists → Brainstorm → Skills → Execute

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## UI Preview for Brainstorming

**When any change involves UI (components, layouts, styling, pages, visual elements):**

Always create a UI preview during brainstorming. Before implementing, generate a visual preview (mockup, wireframe, or rendered prototype) so the user can see and approve the direction before code is written. This applies to new UI, UI modifications, and design-related changes.

- **@designer** should produce a preview as part of their output when handling UI/UX tasks
- **@fixer** should produce a preview when implementing well-specified UI tasks (parallel implementation of components, layouts, styling changes)
- **Orchestrators** must include "produce UI preview" in the agent briefing when delegating UI work to either @designer or @fixer
- **No UI code lands without a preview shown during brainstorming**

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
