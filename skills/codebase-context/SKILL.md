---
name: codebase-context
description: Auto-load codebase maps from Outline on session start - fetches architecture, stack, integrations, conventions docs for the current project
---

# Codebase Context Loader

Load project codebase maps from Outline at session start so all agents have architectural context without polluting the repo.

## When to Use

- **Automatically** at session start (before any task work)
- When switching between repos (customer-portal, ichigo-admin)
- When an agent needs architectural context about the codebase

## How It Works

1. Detect which project directory we're in
2. Search Outline for that project's codebase map collection
3. Load key documents into context

## Session Start Protocol

On every new session, before doing any work:

### Step 0: Ensure Redis

```bash
rtk redis-cli ping
# If not PONG → brew services start redis
```

### Step 1: Load AI Strategy from Redis

```bash
rtk redis-cli GET ai:strategy
# If empty → fetch from Outline (doc: 5a830d18-ffdf-4368-80c0-aff2a035a224)
# → re-cache: redis-cli SET ai:strategy "<content>" ```

### Step 2: Detect Project

```
Check current working directory to identify the project:
- customer-portal → search "Customer Portal Codebase"
- ichigo-admin → search "Ichigo Admin Codebase"
```

### Step 3: Fetch Codebase Context from Outline

Use the Outline MCP to search and retrieve codebase maps:

```
Search Outline for: "{project-name} Codebase Map"

Fetch these documents (if they exist):
- Stack (languages, frameworks, dependencies)
- Architecture (patterns, layers, data flow)
- Structure (directory layout, key locations)
- Integrations (external APIs, services)
- Conventions (code style, naming patterns)
- Concerns (tech debt, known issues)
```

### Step 4: Inject Context

Summarize the loaded context in 1-2 lines per document so the agent knows:
- What tech stack is in use
- How the codebase is organized
- What patterns to follow
- What to watch out for

### Step 5: Proceed

Hand off to the requested task with full codebase awareness.

## Outline Document Structure

Each project should have a collection in Outline:

```
Collection: "{Project Name} - Codebase Map"
  ├── Overview (index linking all docs)
  ├── Tech Stack
  ├── Architecture
  ├── Directory Structure
  ├── Integrations
  ├── Conventions
  ├── Testing
  └── Concerns & Tech Debt
```

## Keeping Maps Fresh

Maps should be updated when:
- Major architectural changes are made
- New integrations are added
- Significant refactoring occurs

To update: run `/gsd:map-codebase` or cartography, then push updated docs to Outline via librarian agent.

## Fallback Chain

1. **Redis** (`ai:strategy`, `ai:execution-protocol`) — fastest (~1ms)
2. **Outline** — source of truth for all documents
3. **Local files** — `.slim/cartography.json` or `.planning/codebase/`
4. **Generate** — run cartography or `/gsd:map-codebase`

If Redis is empty → fetch from Outline → cache to Redis (no TTL (persists forever)).
If Outline is unreachable → use local files.
If nothing exists → generate before proceeding.

## Redis Keys Reference

| Key | Content | TTL |
|---|---|---|
| `ai:strategy` | AI Agent Strategy — Global Rules | 7 days |
| `ai:execution-protocol` | AI Project Execution Protocol | 7 days |
| `ai:templates:index` | Project Templates collection index | no TTL |
| `ai:agent-config` | Agent models, skills, MCPs config | no TTL |
| `ai:workflow-guide` | Orchestrator delegation + review workflow | no TTL |
| `ai:state:{project}` | Last session state per project (e.g., `ai:state:oms`) | no TTL |
| `ai:tasks:{project}` | Task board with per-agent checklists (e.g., `ai:tasks:oms`) | no TTL |
| `ai:feature:{name}` | Cross-repo feature state (e.g., `ai:feature:payment-integration`) | no TTL |

To refresh manually: fetch from Outline → `redis-cli SET <key> "<content>" EX 604800`
