---
name: cartography
description: Repository understanding and hierarchical codemap generation - use when mapping, understanding, or documenting codebase structure
---

# Cartography Skill

You help users understand and map repositories by creating hierarchical codemaps.

## When to Use

- User asks to understand/map a repository
- User wants codebase documentation
- Starting work on an unfamiliar codebase
- Pre-push hook detected file changes that need codemap updates

## Workflow

### Step 1: Check for Existing State

**First, check if `.slim/cartography.json` exists in the repo root.**

If it **exists**: Skip to Step 3 (Detect Changes) - no need to re-initialize.

If it **doesn't exist**: Continue to Step 2 (Initialize).

### Step 2: Initialize (Only if no state exists)

1. **Analyze the repository structure** - List files, understand directories
2. **Infer patterns** for **core code/config files ONLY** to include:
   - **Include**: `src/**/*.ts`, `package.json`, etc.
   - **Exclude (MANDATORY)**: Do NOT include tests, documentation, or translations.
     - Tests: `**/*.test.ts`, `**/*.spec.ts`, `tests/**`, `__tests__/**`
     - Docs: `docs/**`, `*.md` (except root `README.md` if needed), `LICENSE`
     - Build/Deps: `node_modules/**`, `dist/**`, `build/**`, `*.min.js`
   - Respect `.gitignore` automatically
3. **Run cartographer.py init**:

```bash
rtk python3 "${CLAUDE_PLUGIN_ROOT}/skills/cartography/scripts/cartographer.py" init \
  --root ./ \
  --include "src/**/*.ts" \
  --exclude "**/*.test.ts" --exclude "dist/**" --exclude "node_modules/**"
```

This creates:
- `.slim/cartography.json` - File and folder hashes for change detection
- Empty `codemap.md` files in all relevant subdirectories

4. **Delegate to Explorer agents** - Spawn one explorer per folder to read code and fill in its specific `codemap.md` file.

### Step 3: Detect Changes (If state already exists)

1. **Run cartographer.py changes** to see what changed:

```bash
rtk python3 "${CLAUDE_PLUGIN_ROOT}/skills/cartography/scripts/cartographer.py" changes \
  --root ./
```

2. **Review the output** - It shows:
   - Added files
   - Removed files
   - Modified files
   - Affected folders

3. **Only update affected codemaps** - Spawn one explorer per affected folder to update its `codemap.md`.
4. **Run update** to save new state:

```bash
rtk python3 "${CLAUDE_PLUGIN_ROOT}/skills/cartography/scripts/cartographer.py" update \
  --root ./
```

### Step 4: Finalize Repository Atlas (Root Codemap)

Once all specific directories are mapped, create or update the root `codemap.md`:

1. **Map Root Assets**: Document root-level files and the project's overall purpose.
2. **Aggregate Sub-Maps**: Create a "Repository Directory Map" section with responsibility summaries from each folder's `codemap.md`.
3. **Cross-Reference**: Include paths to sub-maps so agents can jump directly to relevant details.

## Codemap Content

Explorers should document each folder's `codemap.md` with:

- **Responsibility** - Define the specific role of this directory
- **Design** - Identify patterns, abstractions, and interfaces
- **Flow** - Trace how data enters and leaves the module
- **Integration** - List dependencies and consumer modules

Example codemap:

```markdown
# src/agents/

## Responsibility
Defines agent personalities and manages their configuration lifecycle.

## Design
Each agent is a prompt + permission set. Config system uses:
- Default prompts (orchestrator.ts, explorer.ts, etc.)
- User overrides from config
- Permission wildcards for skill/MCP access control

## Flow
1. Plugin loads -> calls getAgentConfigs()
2. Reads user config preset
3. Merges defaults with overrides
4. Applies permission rules
5. Returns agent configs

## Integration
- Consumed by: Main plugin (src/index.ts)
- Depends on: Config loader, skills registry
```

Example **Root Codemap (Atlas)**:

```markdown
# Repository Atlas

## Project Responsibility
Brief description of what this project does.

## System Entry Points
- `src/index.ts`: Main entry point.
- `package.json`: Dependency manifest.

## Directory Map
| Directory | Responsibility | Detailed Map |
|-----------|---------------|--------------|
| `src/agents/` | Agent personalities and model routing | [View](src/agents/codemap.md) |
| `src/config/` | Configuration loading pipeline | [View](src/config/codemap.md) |
```
