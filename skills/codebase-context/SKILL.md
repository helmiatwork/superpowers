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

### Step 1: Detect Project

```
Check current working directory to identify the project:
- customer-portal → search "Customer Portal Codebase"
- ichigo-admin → search "Ichigo Admin Codebase"
```

### Step 2: Fetch from Outline

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

### Step 3: Inject Context

Summarize the loaded context in 1-2 lines per document so the agent knows:
- What tech stack is in use
- How the codebase is organized
- What patterns to follow
- What to watch out for

### Step 4: Proceed

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

## Fallback

If Outline is unreachable or docs don't exist yet:
- Check if `.slim/cartography.json` exists locally (from cartography skill)
- Check if `.planning/codebase/` exists locally (from GSD)
- If nothing exists, suggest running cartography or `/gsd:map-codebase` first
