# AI Agent Strategy — Global Rules

> **This document is the single source of truth for all AI agent behavior.** The orchestrator MUST load this document at the start of every session and distribute relevant sections to sub-agents in their briefings. No agent may proceed without understanding these rules.


---

## 1. Codemap-First Rule (STRICT — NON-NEGOTIABLE)

**Every folder in the codebase MUST have a** `**CODEMAP.md**`**. If a codemap is missing, the agent MUST STOP and generate one before doing any work.**

### Rules


1. **Before touching ANY directory**, read its `CODEMAP.md` first
2. **If** `**CODEMAP.md**` **does not exist** → STOP. Do not proceed. Generate the codemap using the `cartography` skill BEFORE any other work
3. **Never scan all files in a directory** — codemaps provide structural understanding. Only drill into specific files when the codemap lacks detail for the task
4. **Never use** `**glob("\*\*/\*")**` **or read entire directories** — always use codemaps for discovery
5. **If a codemap is outdated** (files referenced don't exist, or new files aren't listed) → regenerate it before proceeding
6. **After creating/deleting files** → update the relevant `CODEMAP.md` to reflect the change

### Why This Matters

* Prevents wasted tokens on re-discovery every session
* Eliminates bugs from agents not understanding file relationships
* Forces agents to understand structure BEFORE making changes
* Ensures precision — agents know what exists before modifying anything

### Enforcement

The orchestrator MUST include this in EVERY agent briefing:

> "Read `CODEMAP.md` in every directory before doing anything. If a codemap is missing, STOP and generate it first using the `cartography` skill. Do NOT scan directories without a codemap."


---

## 2. Coding Conventions

### General

* **TypeScript everywhere** — no plain JavaScript
* **Strict mode** — all TypeScript projects use `strict: true`
* **No** `**any**` **types** — use proper typing. If truly unknown, use `unknown` with type guards
* **Explicit return types** on exported functions
* **Named exports** preferred over default exports
* **Descriptive naming** — no single-letter variables except loop iterators

### File & Folder Structure

* Feature components live in `src/components/{feature}/`
* Each feature has: `List.tsx`, `Create.tsx`, `Edit.tsx`, `Show.tsx` (CRUD pattern)
* GraphQL queries in `src/graphql/queries/`
* GraphQL mutations in `src/graphql/mutations/`
* Custom hooks in `src/hooks/`
* Shared utilities in `src/utils/`

### React Patterns

* Functional components only — no class components
* Hooks for state management — no HOCs unless library requires it
* Memoize expensive computations with `useMemo`
* Memoize callbacks with `useCallback` when passed to child components
* Error boundaries around feature-level components

### Import Order


1. React and React-related
2. Third-party libraries
3. Internal shared modules (`@/hooks`, `@/utils`, `@/types`)
4. Feature-local imports
5. Styles/CSS


---

## 3. Tech Stack — Approved Technologies

### Ichigo Admin (Frontend SPA)

| Layer | Technology | Version | Notes |
|-------|------------|---------|-------|
| Framework | React      | 18      | SPA, no SSR |
| Admin Framework | Refine     | v4      | CRUD, hooks, data providers |
| UI Library | Mantine    | v5      | Theming, components, notifications |
| Table | TanStack React Table | —       | Column definitions, sorting, filtering |
| Routing | React Router | v6      | Nested routes |
| API Client | Apollo Client | —       | GraphQL, cache-and-network fetch policy |
| Auth  | JWT        | —       | X-Auth-Token header |
| Build | Create React App | —       | REACT_APP_\* env vars |

**DO NOT USE:**

* Mantine v7 (we are on v5, APIs are different)
* Refine v3 or earlier patterns
* Redux, MobX, Zustand (use Refine's built-in state)
* Axios for GraphQL (use Apollo Client)
* CSS-in-JS other than Mantine's `createStyles`

### Customer Portal (Backend)

| Layer | Technology | Notes |
|-------|------------|-------|
| API   | REST       | Base URL: `/api/admin` |
| Data  | GraphQL    | Served alongside REST |

### Shared

* **Package Manager:** npm (not yarn, not pnpm)
* **Node.js:** LTS version
* **Git:** Feature branch workflow (see Git section)


---

## 4. Git & PR Workflow

### Branching Rules


1. **Feature branches ALWAYS branch from the target parent** (main, master, or GRIN-replacement)
2. **Never commit directly to parent branches** — all work on feature branches
3. **Never push parent branches to GitHub** — only push feature branches
4. **Staging branches receive merges only** — no direct commits except merge conflict resolution
5. **Branch naming:** `feature/{ticket-or-description}`, `fix/{description}`, `refactor/{description}`

### Commit Rules

* **Atomic commits** — one logical change per commit
* **Conventional commits:** `feat(scope): description`, `fix(scope): description`, `refactor(scope): description`
* **Each commit must leave codebase in working state** — tests pass, builds succeed
* **If you need "and" in the commit message, split the commit**

### PR Rules

* **Max 20 files per PR** — split larger changes by domain/context
* **Each PR is independently reviewable and mergeable**
* **PR description must include:** what changed, why, how to test
* **Target branch:** GRIN-replacement (for GRIN features), main/master (for other work)

### Current Active Branch Strategy

* **GRIN Replacement features** → branch from `GRIN-replacement`, PR to `GRIN-replacement`
* **GRIN-replacement** lives on GitHub — never push it from local, only update via merged PRs
* **Non-GRIN work** → branch from `main`/`master`, PR to `main`/`master`


---

## 5. Architecture & Project Context

### Ichigo Admin

* **Type:** Frontend-only React 18 SPA
* **Purpose:** Internal admin panel for managing the Ichigo platform
* **API Connection:** REST API at `http://localhost:3007/api/admin` (configurable via `REACT_APP_CP_API_URL`)
* **Auth:** JWT token via `REACT_APP_CP_API_TOKEN` env var
* **Build Mode:** Controlled by `REACT_APP_BUILD_TARGET`
* **Resources:** 45+ admin resources configured
* **Feature Modules:** 36+ organized in `/src/components/`
* **Key Routes:** Dashboard, User management, Gift cards, Surveys, Loyalty, Content, Engagement, Billing, Tea addons, Cancellation flow, Operations, Auth, GRIN features (`/grin/*`)
* **Data Provider:** Configured in `src/dataProvider.ts` for API endpoint mapping

### Key Patterns in Ichigo Admin

* **List views:** Use `useList` hook, TanStack table with `ColumnDef` types
* **Show views:** Use `useShow` hook, `DetailsCard` components in `Grid` layout
* **Create/Edit views:** Use `useForm` from `@refinedev/mantine` with `initialValues` and `validation`
* **Notifications:** Mantine `NotificationsProvider` for toast messages
* **Error Handling:** React Error Boundary for uncaught exceptions
* **Command Palette:** KBar for quick navigation
* **Loading States:** All Show components handle loading states explicitly

### GRIN Replacement

* **Purpose:** Replace the external GRIN influencer management platform with built-in features
* **Modules:** Campaigns, Creators, Curated Lists, Recruitment, Landing Pages, AI Search, Proposals, Contracts, Content, Reporting, Payments, Settings
* **TRD Location:** Outline collection `dc175c88-64ae-4f55-acc6-8690f7a5b629`
* **Feature Map:** Outline doc `29bd4c52-86b1-4f32-9082-da2070ed8af4`
* **PR Strategy:** Outline doc `d45b32f6-ec92-4091-8cf6-32860c7a4a09`


---

## 6. Agent Behavior Rules

### Before Starting Any Work


1. **Load this document** (orchestrator does this automatically)
2. **Check supermemory** for last session state and any prior decisions
3. **Read codemaps** for any directory you'll touch
4. **If no codemap exists → STOP and generate it**
5. **Understand the feature context** — read relevant TRDs, feature maps, or Outline docs before coding

### Quality Standards

* **No bugs shipped** — verify every change works before claiming done
* **Run the build** after changes: `npm run build` must pass
* **Run linting** after changes: no new warnings or errors
* **Test edge cases** — null values, empty arrays, loading states, error states
* **Type safety** — no TypeScript errors, no `@ts-ignore` unless absolutely necessary with a comment explaining why

### What Agents Must NEVER Do

* Guess at API shapes — always check the actual endpoint or GraphQL schema
* Use deprecated patterns — check the tech stack table above
* Skip error handling — every async operation needs error handling
* Ignore loading states — every data fetch needs a loading indicator
* Create files without updating the codemap
* Delete files without updating the codemap
* Proceed without a codemap

### Verification Before Completion

Every agent must verify their work before reporting done:


1. Code compiles without errors (`npm run build`)
2. No new TypeScript errors (`tsc --noEmit`)
3. Affected codemaps are updated
4. Changes match the established patterns (check existing similar components)
5. No hardcoded values that should be env vars or constants


---

## 7. Business Domain Context

### What Is Ichigo?

Ichigo is a **subscription commerce and influencer marketing platform**. The admin panel manages:

* **Subscriptions & Orders** — Customer subscriptions, order management, fulfillment
* **Gift Cards & Loyalty** — Gift card system, loyalty points, rewards
* **Content & Engagement** — Surveys, content management, customer engagement tools
* **Influencer Marketing (GRIN Replacement)** — Campaign management, creator recruitment, proposals, contracts, content tracking, payments, reporting
* **Operations** — Billing, cancellation flows, tea addons, operational tools

### Key Entities

| Entity | Description |
|--------|-------------|
| Brand  | A company/brand running influencer campaigns |
| Creator | An influencer/content creator |
| Campaign | An influencer marketing campaign run by a brand |
| Curated List | A curated collection of creators for a brand to review |
| Proposal | A campaign offer sent to a creator |
| Contract | An agreed-upon deliverable between brand and creator |
| Content | Deliverables (posts, stories, videos) submitted by creators |

### GRIN Replacement Entity Details

* **CuratedList** fields: id, name, brand, status, creatorsCount, description, submittedDate, submittedBy, hasFeedback, creditsUsed, createdAt
* **CuratedList statuses:** Complete, Ready, Draft, Sourcing Creators
* **Curated List routes:** `/grin/curated-lists` (list), `/grin/curated-lists/:id` (detail)


---

## 8. Cost Optimization

### Model Selection

| Task Complexity | Model | When to Use |
|-----------------|-------|-------------|
| Simple/mechanical | Cheapest available (Haiku/small) | File renames, formatting, simple grep, linting, codemap generation |
| Moderate/well-defined | Balanced (Sonnet) | Bug fixes, feature implementation, refactoring |
| Complex/high-stakes | Deep reasoning (Opus) | Architecture, debugging persistent issues, code review |

**Default to the cheapest model that can do the job.** Upgrade only when the task demands it.

### Token Efficiency

* **Read codemaps, not files** — saves 80%+ tokens vs reading all files
* **Specify exact file paths** in agent briefings — never "explore the codebase"
* **Check supermemory before researching** — don't re-discover what's already known
* **Batch related queries** — don't make 10 calls when 1 will do
* **Use RTK for CLI output** — automatically compresses command output

### What NOT to Waste Tokens On

* Re-reading files that haven't changed since last session
* Exploring directories when a codemap exists
* Re-researching libraries when supermemory has the answer
* Verbose explanations unless the user asks for them
* Summarizing what was done unless asked


---

## 9. Session Start Checklist

The orchestrator MUST do these steps at every session start:


1. **Ensure Redis is running** — run `redis-cli ping`. If it returns PONG, proceed. If not, run `brew services start redis` and wait for PONG.
2. **Load AI Strategy from Redis** — `redis-cli GET ai:strategy`. If empty/expired, fetch from Outline (doc ID: 5a830d18-ffdf-4368-80c0-aff2a035a224) and re-cache: `redis-cli SET ai:strategy "<content>" `.
3. **Load AI Execution Protocol from Redis** — `redis-cli GET ai:execution-protocol`. Fallback to Outline (doc ID: 2149642d-1da4-4f18-b259-548586cf0733).
4. **Check Supermemory** for last session state and prior decisions
5. **Check Outline for Project Tracker** — if a project is active:
   * Read "Current Status" to know where we are
   * Read "Next action" to know exactly what to do first
   * Read "Decisions Made" so we don't re-ask settled questions
   * Read "Open Questions" so we don't re-ask answered questions
6. **Read codemaps** for any directories you will touch
7. **If no codemap exists, STOP and generate it** (cartography skill)
8. **Read relevant TRDs/PRDs** before making any implementation decisions
9. **Only then** begin work

### Session End Protocol (EQUALLY MANDATORY)

Before closing ANY session:


1. **Update Project Tracker** in Outline:
   * Current Status (phase, task, blockers)
   * Session Log (what was done — specific, not vague)
   * Next action (specific enough for a fresh AI to resume)
   * Any new decisions or open questions
2. **Save state to Supermemory** (what, why, what is next)
3. **Commit all code changes** (no uncommitted work)
4. **Update codemaps** if files were added/removed

The "Next action" must be specific:

* Bad: "Continue working on the API"
* Good: "Implement POST /v1/orders per API TRD section Orders. GET endpoints done and tested. Tests pass."


---

## 9.5. Project Templates and AI Execution Protocol

**For new projects or features**, use the standardized templates and AI workflow:

* **Project Templates collection** (Outline collection ID: d8923b12-4e5c-45c3-b656-383055a46df5) — 18 templates covering Discovery through PRD, Design, TRDs, Sprint Plan, Launch, Post-Launch
* **AI Project Execution Protocol** (Outline doc ID: 2149642d-1da4-4f18-b259-548586cf0733) — defines exactly what the AI must do at each phase, with STOP gates, checklists, and anti-freelancing rules

### When to Use

| Situation | Action |
|-----------|--------|
| Starting a new project | Load AI Execution Protocol, follow from Phase 0 |
| Starting a new major feature | Load AI Execution Protocol, start at Phase 1 (PRD) or Phase 2 (TRDs) depending on scope |
| Resuming work | Load Project Tracker, read Next action, continue |
| Adding a small feature | May skip templates but MUST still follow TDD, codemap-first, and commit rules from this document |

### The Three Laws (from AI Execution Protocol)


1. **Read before act.** Never start work without reading relevant templates AND all referenced documents.
2. **Persist before close.** Save state to Supermemory AND update Project Tracker before ending any session.
3. **Check before claim.** Never mark anything done without running verification and reading the output.


---

## 10. How to Share Knowledge with Sub-Agents

The orchestrator is the ONLY agent that reads this document. When delegating, include relevant sections in the agent briefing:

### For @explorer

> "Read `CODEMAP.md` in every directory first. If missing, STOP and generate with cartography. Never glob entire directories."

### For @fixer

> "Tech stack: \[relevant section\]. Patterns: \[relevant section\]. Conventions: \[relevant section\]. Verify: build passes, no TS errors, codemaps updated. Never commit to parent branches."

### For @librarian

> "Save state to supermemory after completion. Update Outline docs as needed. Use cheapest model for mechanical tasks."

### For @oracle

> "Architecture context: \[relevant section\]. Business domain: \[relevant section\]. Review against quality standards in this doc."

### For @designer

> "UI library: Mantine v5 (NOT v7). Patterns: \[relevant section\]. Must produce UI preview during brainstorming."


---

*Last updated: 2026-03-18* *Auto-loaded by orchestrator via codebase-context skill*
