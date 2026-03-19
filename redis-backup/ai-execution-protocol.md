# AI Project Execution Protocol

> **This document governs how AI agents execute project templates.** Every template in this collection has a corresponding AI workflow below. The AI MUST follow this protocol — no exceptions, no shortcuts, no "I'll come back to that later."

## The Three Laws


1. **Read before act.** Never start work without reading the relevant template AND all referenced documents (TRDs, PRDs, prior phase outputs). If a document is referenced but doesn't exist yet, STOP and create it.
2. **Persist before close.** Before ending any session, save state to Supermemory AND update the project tracker in Outline. The next AI session must be able to resume with zero context loss.
3. **Check before claim.** Never mark a checklist item done without running verification. "I believe it works" is not verification. Run the command, read the output, confirm the result.


---

## Project Tracker (Living Document)

**Every project MUST have a Project Tracker document in Outline.** This is the AI's memory across sessions.

Create it at project start using this structure:

```markdown
# [Project Name] — Project Tracker

## Current Status
**Phase:** [Phase number and name]
**Current task:** [What's being worked on]
**Blocker:** [None / description]
**Last session:** [Date, what was done]
**Next action:** [Exactly what the next session should do first]

## Phase Completion Status
| Phase | Status | Completion Date | Notes |
|---|---|---|---|
| 0. Discovery | [ ] Not started / [~] In progress / [x] Complete | | |
| 0.5. Stack Selection | | | |
| 1. PRD | | | |
| 1.5. Design | | | |
| 1.5. Domain Model | | | |
| 2. Architecture TRD | | | |
| 2. API TRD | | | |
| 2. Data Model TRD | | | |
| 2. Infrastructure TRD | | | |
| 2. Security Review | | | |
| 2. Testing Strategy | | | |
| 2. Data Governance | | | |
| 3. Sprint Plan | | | |
| 3. Analytics Plan | | | |
| 4. Sprint 0 (Foundation) | | | |
| 5+. Feature Sprints | | | |
| 6. Launch | | | |
| 7. Post-Launch | | | |

## Decisions Made
| Date | Decision | Reason | Phase |
|---|---|---|---|
| | | | |

## Open Questions
| Question | Context | Needs Answer From | Status |
|---|---|---|---|
| | | | |

## Session Log
| Date | Session | What was done | What's next |
|---|---|---|---|
| | | | |
```


---

## Session Start Protocol (MANDATORY)

Every AI session MUST begin with:

```
1. Load AI Strategy document (from Outline: AI Strategy collection)
2. Load Project Tracker (from Outline: project collection)
3. Read "Current Status" → understand where we are
4. Read "Next action" → know exactly what to do
5. Read "Open Questions" → don't re-ask answered questions
6. Read "Decisions Made" → don't revisit settled decisions
7. Check Supermemory for additional context
8. ONLY THEN begin work
```

**If Project Tracker doesn't exist:** Create it first. Do no other work until the tracker exists.

**If this is the first session:** Create the project collection in Outline, create the Project Tracker, then begin Phase 0.


---

## Session End Protocol (MANDATORY)

Every AI session MUST end with:

```
1. Update Project Tracker in Outline:
   - Current Status (phase, current task, blockers)
   - Session Log (what was done this session)
   - Next action (specific — not "continue work")
   - Any new Decisions Made
   - Any new Open Questions
2. Save state to Supermemory:
   - What was accomplished
   - Key decisions and why
   - Exact next step
   - Any blockers or concerns
3. If mid-phase: List exactly which checklist items are done vs remaining
4. Commit all code changes (if any)
```

**The "Next action" must be specific enough that a fresh AI with zero context can read it and know exactly what to do.**

Bad: "Continue working on the API" Good: "Implement POST /v1/orders endpoint per API TRD section 'Orders'. Previous session completed GET /v1/orders and GET /v1/orders/:id. Tests for existing endpoints pass."


---

## Phase Execution Workflows

### Phase 0: Discovery & Validation

**AI tasks:**


1. Load the Phase 0 template from Project Templates collection
2. Copy template to project collection as new document
3. Work through each section with the user:
   * Ask clarifying questions ONE AT A TIME (not a wall of questions)
   * Fill in sections as answers are provided
   * Flag assumptions explicitly
4. Update Outline document after each section is filled
5. When all sections complete → present Go/No-Go checklist to user

**AI STOP gate:** Do NOT proceed to Phase 1 until user explicitly approves Go/No-Go.

**Checklist (AI must verify each):**

- [ ] Problem statement filled with specific pain point
- [ ] At least 3 rows in Business Model Canvas
- [ ] Market analysis has TAM/SAM/SOM numbers
- [ ] Feasibility assessment completed
- [ ] Stakeholder map has at least 2 stakeholders
- [ ] Go/No-Go decision recorded with date and names
- [ ] Document saved to Outline
- [ ] Project Tracker updated

### Phase 0.5: Stack Selection

**AI tasks:**


1. Load Stack Selection template
2. Copy to project collection
3. Fill constraints table based on Phase 0 findings + user input
4. Match product type to architecture recommendation
5. Create decision matrix with 2-3 stack options
6. Check ecosystem (library checklist) for top candidate
7. Present recommendation with reasoning to user
8. Record decision as ADR

**AI STOP gate:** Do NOT proceed until user confirms stack choice.

**Checklist:**

- [ ] Constraints table filled (all 8 rows)
- [ ] Product type matched to architecture
- [ ] Decision matrix scored for 2+ options
- [ ] Ecosystem checklist verified for chosen stack
- [ ] Anti-patterns reviewed (none apply)
- [ ] Decision recorded with rationale
- [ ] Document saved to Outline
- [ ] Project Tracker updated

### Phase 1: PRD

**AI tasks:**


1. Load PRD template
2. Copy to project collection
3. Work through sections with user — PRD is collaborative, not AI-solo
4. For each user story: write acceptance criteria, get user approval
5. For non-functional requirements: propose defaults from stack choice, confirm with user
6. Define scope boundaries explicitly — list what's OUT

**AI STOP gate:** Do NOT proceed to Phase 2 until PRD has user approval on ALL sections.

**Checklist:**

- [ ] Problem statement links back to Phase 0
- [ ] At least 1 measurable success metric with target number
- [ ] At least 1 user persona with goals and pain points
- [ ] All epics have user stories with acceptance criteria
- [ ] At least 1 user flow diagram
- [ ] Non-functional requirements have specific numbers (not "fast" but "p95 < 300ms")
- [ ] Scope: In-scope AND out-of-scope both documented
- [ ] Dependencies identified
- [ ] Risks listed with mitigations
- [ ] Timeline has specific dates
- [ ] Privacy/data requirements filled (or marked N/A)
- [ ] Release strategy defined
- [ ] Approval section signed off
- [ ] Document saved to Outline
- [ ] Project Tracker updated

### Phase 2: Technical Design (TRDs)

**AI tasks (per TRD):**


1. Load the relevant TRD template
2. Copy to project collection
3. Read the PRD first — every TRD decision must trace back to a PRD requirement
4. For Architecture TRD: propose stack structure based on Phase 0.5 decision
5. For API TRD: derive endpoints from PRD user stories
6. For Data Model TRD: derive tables from PRD entities + API spec
7. For each TRD: AI drafts → user reviews → AI revises → user approves

**AI STOP gate:** ALL TRDs must be approved before Sprint 0 begins.

**Order of creation:**


1. Architecture TRD (must be first — other TRDs reference it)
2. Data Model TRD (API depends on knowing the schema)
3. API Specification TRD
4. Infrastructure TRD
5. Security Design Review
6. Testing Strategy
7. Data Governance (if handling PII)

**Checklist (per TRD):**

- [ ] Every section filled (no placeholders remaining)
- [ ] References PRD for requirements traceability
- [ ] Diagrams included (mermaid)
- [ ] ADRs document key decisions with alternatives
- [ ] Approval section signed off
- [ ] Document saved to Outline
- [ ] Project Tracker updated

### Phase 3: Sprint Planning

**AI tasks:**


1. Load Sprint Plan template
2. Decompose PRD epics into tasks referencing TRDs
3. Each task must specify: which files to create/modify, which TRD section to follow, acceptance criteria, test approach
4. Estimate effort for each task
5. Assign to sprints based on dependencies
6. Create Sprint 0 (Foundation) with all infrastructure tasks

**AI STOP gate:** Sprint plan must be approved before any implementation begins.

**Checklist:**

- [ ] Every PRD requirement maps to at least one task
- [ ] Every task references a TRD section (or says "no TRD needed" with reason)
- [ ] Sprint 0 includes all foundation tasks (repo, CI/CD, auth, DB, etc.)
- [ ] Dependency map shows no circular dependencies
- [ ] Risk register has at least 3 risks with mitigations
- [ ] DoR and DoD defined
- [ ] Document saved to Outline
- [ ] Project Tracker updated

### Phase 4+: Implementation (Sprints)

**AI tasks per sprint:**


1. Read Sprint Plan for current sprint tasks
2. Read ALL relevant TRDs before writing any code
3. For each task:

   
   a. Read the task spec and referenced TRD sections
   b. Read CODEMAP.md for target directories
   c. Implement following TDD (test first, then code)
   d. Run build + lint + tests
   e. Commit with conventional commit message
   f. Mark task complete in Sprint Plan
4. After all tasks: request code review
5. Update Project Tracker with progress

**AI STOP gates:**

* Before each task: verify the referenced TRD section exists and is approved
* Before committing: build passes, tests pass, no lint errors
* Before marking sprint done: ALL tasks complete, ALL tests pass

**Per-task checklist:**

- [ ] Read TRD section before implementation
- [ ] Read CODEMAP.md for directories touched
- [ ] Tests written BEFORE implementation code
- [ ] Implementation matches TRD exactly (no improvisation)
- [ ] Build passes: `npm run build` or equivalent
- [ ] Lint clean: no new warnings
- [ ] Type check clean: `tsc --noEmit`
- [ ] CODEMAP.md updated if files added/removed
- [ ] Committed with atomic, conventional commit
- [ ] Project Tracker updated

### Phase 6: Launch

**AI tasks:**


1. Load Launch Checklist template
2. Go through EVERY item systematically
3. For each item: run the actual verification (not "I think this is done")
4. Record evidence for each checked item (command output, screenshot, URL)
5. Present Go/No-Go to user with all evidence

**AI STOP gate:** Do NOT deploy until user explicitly approves Go/No-Go with all P0 items checked.


---

## Anti-Freelancing Rules

AI agents MUST NOT:

| Violation | Consequence | Correct Behavior |
|-----------|-------------|------------------|
| Skip reading a document | Work will be wrong | Read every referenced doc before starting |
| Make architecture decisions not in TRD | Inconsistency, tech debt | Propose in TRD, get approval, then implement |
| Add features not in PRD | Scope creep, wasted tokens | Only build what's specified |
| Skip a checklist item | Incomplete work | Every item must be checked with evidence |
| Use a different pattern than established | Inconsistency | Follow existing codebase patterns |
| Proceed past a STOP gate without approval | Misaligned work | Wait for user confirmation |
| Close session without updating tracker | Next session is blind | Always persist state before closing |
| Say "done" without running verification | Bugs in production | Run build + test + lint, read output |


---

## State Persistence Checklist

**Before EVERY session close, verify:**

- [ ] Project Tracker "Current Status" updated
- [ ] Project Tracker "Session Log" entry added with specific details
- [ ] Project Tracker "Next action" is specific and actionable
- [ ] Any new decisions added to "Decisions Made"
- [ ] Any new questions added to "Open Questions"
- [ ] Supermemory updated with session summary
- [ ] All code committed (no uncommitted changes)
- [ ] All Outline documents updated (no stale docs)


---

## Redis Cache Management

### Keys

| Key | Content | Source of Truth |
|-----|---------|-----------------|
| `ai:strategy` | AI Agent Strategy — Global Rules | Outline doc `5a830d18-ffdf-4368-80c0-aff2a035a224` |
| `ai:execution-protocol` | AI Project Execution Protocol | Outline doc `2149642d-1da4-4f18-b259-548586cf0733` |
| `ai:templates:index` | Project Templates collection index | Outline collection `d8923b12-4e5c-45c3-b656-383055a46df5` |

Keys persist forever (no TTL). Outline is always the source of truth.

### When Redis is empty (restart, flush, new machine)

The AI self-heals automatically:


1. AI reads Redis → empty
2. AI fetches from Outline → gets content
3. AI caches to Redis → future reads are instant

No manual action needed. The next AI session that starts will rebuild the cache.

### Manual refresh (after editing documents in Outline)

If you update the AI Strategy or Execution Protocol in Outline and want Redis updated immediately:

```bash
# Refresh all AI keys from Outline
python3 -c "
import json, urllib.request, subprocess
KEY = 'ol_api_L7Xvu9kYtSNqdamjbLSORrJ2kdOQhdvCHZlW6H'
docs = {
    'ai:strategy': '5a830d18-ffdf-4368-80c0-aff2a035a224',
    'ai:execution-protocol': '2149642d-1da4-4f18-b259-548586cf0733',
}
for rk, did in docs.items():
    req = urllib.request.Request('http://localhost:3000/api/documents.info',
        json.dumps({'id': did}).encode(),
        headers={'Authorization': f'Bearer {KEY}', 'Content-Type': 'application/json'})
    text = json.loads(urllib.request.urlopen(req).read())['data']['text']
    subprocess.run(['redis-cli', 'SET', rk, text], capture_output=True)
    print(f'Refreshed: {rk} ({len(text)} chars)')
"
```

Or ask the AI: "refresh Redis cache from Outline"

### Verify Redis state

```bash
redis-cli KEYS "ai:*"           # List all AI keys
redis-cli STRLEN ai:strategy    # Check size
redis-cli TTL ai:strategy       # Should be -1 (no expiry)
```


---

## How This Connects to Templates

```
Project Templates (the WHAT)     AI Protocol (the HOW)
─────────────────────────────    ─────────────────────
Phase 0 — Discovery           → AI: Ask questions, fill sections, get Go/No-Go
Phase 0.5 — Stack Selection   → AI: Score matrix, verify ecosystem, get approval
Phase 1 — PRD                 → AI: Collaborative writing, every story needs ACs
Phase 1.5 — Design            → AI: Ensure all states designed, handoff checklist
Phase 2 — TRDs                → AI: Draft from PRD, review cycle, approval gate
Phase 3 — Sprint Plan         → AI: Decompose PRD→tasks, every task→TRD ref
Phase 4+ — Implementation     → AI: TDD per task, verify per commit, track progress
Phase 6 — Launch              → AI: Every checklist item verified with evidence
Phase 7 — Post-Launch         → AI: Collect metrics, compare to PRD targets
```

Every phase produces artifacts. Every artifact is saved to Outline. Every session persists state. The next AI can always pick up exactly where the last one left off.


---

## Quick Reference: What AI Does at Each Gate

| Gate | AI Action | User Action |
|------|-----------|-------------|
| Phase 0 complete | Present filled Discovery doc + Go/No-Go | Approve or reject |
| Stack selected | Present scored matrix + recommendation | Confirm choice |
| PRD complete | Present full PRD with all sections | Approve all sections |
| Each TRD complete | Present draft for review | Approve or request changes |
| Sprint Plan complete | Present task breakdown + estimates | Approve plan |
| Each sprint complete | Present completed tasks + test results | Review, approve merge |
| Launch ready | Present checklist with all evidence | Give Go/No-Go |
| Post-launch | Present metrics vs targets + v1.1 plan | Approve v1.1 scope |
