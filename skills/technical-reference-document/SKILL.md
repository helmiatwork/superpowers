---
name: technical-reference-document
description: Use when the orchestrator needs detailed technical documents (API specs, migration plans, DB schemas, integration contracts) before delegating implementation to @fixer. Creates execution-ready TRDs stored in Outline.
---

# Technical Reference Document (TRD)

Create precise, execution-ready technical documents so @fixer can implement without making design decisions. Every TRD is stored in Outline for team visibility and future reference.

## When to Use

- Orchestrator has a clear goal from brainstorming/design
- Implementation requires technical specs that @fixer shouldn't have to figure out
- Work involves APIs, database changes, migrations, integrations, or system contracts
- Multiple agents need a shared source of truth for what to build

## Who Does What

| Role | Responsibility |
|------|---------------|
| **Orchestrator** | Provides goal, scope, and constraints from brainstorming/design |
| **@explorer** | Reads codemaps, returns current codebase structure relevant to the TRD |
| **@librarian** | Creates the TRD, researches libraries/APIs via MCPs, stores in Outline |
| **@oracle** | Reviews TRD for correctness, completeness, and edge cases |
| **@fixer** | Executes from the TRD — zero design decisions |

## TRD Flow

```
Orchestrator has goal + design approved
  ↓
@explorer reads codemaps → returns relevant structure to orchestrator
  ↓
Orchestrator delegates TRD creation to @librarian with:
  • Goal (what to build)
  • Codebase context (from @explorer)
  • Design decisions (from brainstorming)
  • TRD type (API, migration, schema, etc.)
  ↓
@librarian creates TRD:
  • Researches current state (codemaps, context7, websearch)
  • Writes execution-ready document
  • Stores in Outline via MCP
  ↓
@oracle reviews TRD:
  • Correctness (will this actually work?)
  • Completeness (can @fixer execute without questions?)
  • Edge cases (what's missing?)
  ↓
Issues found?
  ├─ YES → @librarian fixes → @oracle re-reviews
  └─ NO → TRD approved
  ↓
Orchestrator delegates implementation to @fixer with:
  • Link to TRD in Outline
  • "Execute exactly as specified, no design decisions"
```

## TRD Types and Templates

### 1. API Specification

Use when building or modifying REST/GraphQL endpoints.

```markdown
# API TRD: [Feature Name]

## Overview
[One sentence: what this API does]

## Base Path
`/api/v1/[resource]`

## Endpoints

### [METHOD] /path
**Purpose:** [What this endpoint does]

**Authentication:** [Required/Optional, method]

**Request:**
- Headers: [required headers]
- Params: [path/query params with types]
- Body:
  ```json
  {
    "field": "type — description (required/optional, default, constraints)"
  }
  ```

**Response (200):**
```json
{
  "field": "type — description"
}
```

**Error Responses:**
| Status | Code | When |
|--------|------|------|
| 400 | INVALID_INPUT | [condition] |
| 404 | NOT_FOUND | [condition] |
| 409 | CONFLICT | [condition] |

**Business Rules:**
- [Rule 1: exact behavior]
- [Rule 2: exact behavior]

---
[Repeat for each endpoint]

## Data Models
[Shared types/interfaces with exact field definitions]

## Integration Notes
- [Which existing services this touches]
- [Auth flow details]
- [Rate limiting / pagination rules]
```

### 2. Database Migration

Use when adding/modifying tables, columns, indexes, or data transformations.

```markdown
# Migration TRD: [Feature Name]

## Overview
[What changes and why]

## Current State
[Relevant existing tables/columns — from codemaps or codebase exploration]

## Migration Steps

### Step 1: [Description]
**Type:** schema / data / index
**Reversible:** yes / no

```sql
-- Up
[exact SQL]

-- Down
[exact rollback SQL]
```

**Verification:**
```sql
[Query to verify migration succeeded]
```

### Step 2: ...
[Repeat for each step]

## Execution Order
1. [Step] — [why this order matters]
2. [Step] — [dependency on previous]

## Risks
- [Risk 1: what could go wrong, mitigation]
- [Risk 2: what could go wrong, mitigation]

## Rollback Plan
[Step-by-step rollback if something fails mid-migration]

## Performance Impact
- [Table lock duration estimates]
- [Index build time estimates for large tables]
- [Recommended maintenance window: yes/no]
```

### 3. Database Schema Design

Use when designing new tables or restructuring existing ones.

```markdown
# Schema TRD: [Feature Name]

## Overview
[What this schema supports]

## Entity Relationship
[List entities and their relationships — 1:1, 1:N, M:N]

## Tables

### [table_name]
**Purpose:** [What this table stores]

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | gen_random_uuid() | Primary key |
| ... | ... | ... | ... | ... |

**Indexes:**
| Name | Columns | Type | Why |
|------|---------|------|-----|
| idx_[name] | (col1, col2) | btree | [query pattern it optimizes] |

**Constraints:**
- UNIQUE(col1, col2) — [why]
- CHECK(col > 0) — [why]
- FK → other_table(id) ON DELETE CASCADE — [why cascade vs restrict]

[Repeat for each table]

## Access Patterns
| Query Pattern | Expected Frequency | Index Used |
|--------------|-------------------|------------|
| Find by user_id + status | High | idx_user_status |
| ... | ... | ... |

## Data Volume Estimates
- [Table]: ~[N] rows at launch, ~[N] rows at 1yr
- [Partitioning needed: yes/no, strategy]
```

### 4. Integration Contract

Use when connecting to external services or defining inter-service communication.

```markdown
# Integration TRD: [Service/Feature Name]

## Overview
[What systems are being connected and why]

## Systems Involved
| System | Role | Owner |
|--------|------|-------|
| [Our service] | Consumer/Producer | [team] |
| [External service] | Consumer/Producer | [team/vendor] |

## Contract

### Data Flow
[System A] → [payload] → [System B] → [response] → [System A]

### Request Format
```json
{
  "field": "type — description"
}
```

### Response Format
```json
{
  "field": "type — description"
}
```

### Authentication
[API key / OAuth / mTLS — exact setup steps]

### Error Handling
| Error | Retry | Fallback |
|-------|-------|----------|
| Timeout (>5s) | 3x exponential backoff | [fallback behavior] |
| 5xx | 3x exponential backoff | [fallback behavior] |
| 4xx | No retry | [error propagation] |

### SLA / Rate Limits
- Rate limit: [N] req/min
- Expected latency: [N]ms p50, [N]ms p99
- Availability SLA: [N]%

## Environment Config
| Env | Base URL | API Key Source |
|-----|----------|---------------|
| Dev | [url] | [env var / secret manager] |
| Staging | [url] | [env var / secret manager] |
| Prod | [url] | [env var / secret manager] |
```

### 5. General Technical Reference

Use for anything that doesn't fit the above categories.

```markdown
# TRD: [Feature Name]

## Overview
[What and why — one paragraph]

## Current State
[How things work now — from codemaps]

## Target State
[How things should work after implementation]

## Technical Specification
[Exact details: algorithms, data structures, flows, configs]

## Files Affected
| File | Change | Details |
|------|--------|---------|
| path/to/file.ts | Modify | [what changes] |
| path/to/new.ts | Create | [purpose] |

## Dependencies
- [Library/service 1: version, why]
- [Library/service 2: version, why]

## Testing Requirements
- [What to test and how]
- [Edge cases to cover]
```

## Writing TRDs — Rules

1. **Execution-ready** — @fixer should NEVER need to ask "what should I do here?" Every decision must be made in the TRD.
2. **Exact, not vague** — Write `type: varchar(255) NOT NULL DEFAULT ''` not "add a name field." Write exact HTTP status codes, exact SQL, exact JSON shapes.
3. **Codemap-first** — Read codemaps before writing. Reference existing patterns, files, and conventions from the codebase.
4. **Include the "why"** — For each design decision, briefly note why. This prevents @fixer from "improving" things that were intentional.
5. **Verification steps** — Every section should include how to verify it works (SQL queries, curl commands, test assertions).
6. **No implementation code** — TRDs define WHAT to build, not HOW to code it. @fixer handles implementation. Exception: exact SQL for migrations.

## Storing in Outline

**All TRDs MUST be stored in Outline via MCP.** This is non-negotiable.

@librarian stores the TRD using the Outline MCP:
1. Find or create the project's TRD collection in Outline
2. Create a new document with title: `TRD: [Feature Name] — [Type]`
3. Paste the full TRD content
4. Tag with: project name, TRD type, date, status (draft/reviewed/approved)
5. After @oracle approves, update status tag to "approved"

**Outline document structure:**
```
Project Collection/
  └── Technical Reference Documents/
        ├── TRD: User Auth — API Specification (approved)
        ├── TRD: User Auth — Database Migration (approved)
        └── TRD: Payment Integration — Integration Contract (draft)
```

## Review Checklist (For @oracle)

@oracle reviews each TRD against this checklist:

- [ ] **Executable** — Can @fixer implement this without asking questions?
- [ ] **Complete** — Are all endpoints, fields, constraints, error cases defined?
- [ ] **Correct** — Do the SQL, JSON shapes, and contracts actually work?
- [ ] **Consistent** — Does this align with existing codebase patterns (from codemaps)?
- [ ] **Edge cases** — Are failure modes, nullability, concurrency, and limits covered?
- [ ] **Verification** — Does each section include how to verify it works?
- [ ] **No gaps** — Is there any point where the implementer would need to make a judgment call?

If ANY checkbox fails, @oracle sends specific feedback to @librarian for revision.

## Integration with Other Skills

**Upstream (feeds into TRD):**
- `brainstorming` → Design decisions and requirements
- `writing-plans` → Can reference TRD for technical details
- `cartography` → Codebase structure for current state

**Downstream (uses TRD):**
- `executing-plans` / `subagent-driven-development` → @fixer executes from TRD
- `requesting-code-review` → Reviewer can check implementation against TRD
- `finishing-a-development-branch` → TRD in Outline serves as feature documentation
