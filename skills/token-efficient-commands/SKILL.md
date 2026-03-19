---
name: token-efficient-commands
description: Use when running ANY shell command — all CLI commands must use rtk prefix for token compression, commands must be broken into small steps, never chain destructive or stateful operations
---

# Token-Efficient Commands

## The Rule

**Every CLI command MUST be prefixed with `rtk`.** One operation per call. Stop on failure. No exceptions.

RTK (Rust Token Killer) compresses CLI output by 60-90%. The auto-rewrite hook handles orchestrator commands, but **subagent calls bypass the hook** (opencode limitation #5894). All agents must explicitly prefix with `rtk`.

## Complete Command Reference

### Git (80-92% savings)
```bash
rtk git status           # Compact status
rtk git diff             # Condensed diff
rtk git log --oneline -5 # One-line commits
rtk git add <files>      # → "ok"
rtk git commit -m "msg"  # → "ok abc1234"
rtk git push             # → "ok main"
rtk git pull             # → "ok 3 files +10 -2"
rtk git merge feature/x --no-edit
rtk git cherry-pick <hash>
rtk git rebase main
rtk git stash
rtk git branch -a
```

### GitHub CLI (26-87% savings)
```bash
rtk gh pr list
rtk gh pr view 42
rtk gh pr create --title "x" --body "y"
rtk gh issue list
rtk gh run list
```

### Files & Search (70-80% savings)
```bash
rtk ls .                 # Token-optimized directory tree
rtk read file.ts         # Smart file reading
rtk read file.ts -l aggressive  # Signatures only
rtk find "*.ts" .        # Compact find results
rtk grep "pattern" .     # Grouped search results
rtk diff file1 file2     # Condensed diff
rtk smart file.ts        # 2-line heuristic summary
rtk json config.json     # Structure without values
```

### JavaScript/TypeScript (70-99% savings)
```bash
rtk npm install          # Stripped noise
rtk npm test             # Failures only
rtk npm run build        # Errors only
rtk npx <command>
rtk yarn install
rtk pnpm list            # Compact dependency tree
rtk vitest run           # Failures only (99.5% savings)
rtk tsc                  # TS errors grouped by file (83%)
rtk lint                 # ESLint/Biome grouped by rule (84%)
rtk prettier --check .   # Files needing formatting (70%)
rtk next build           # Route metrics only (87%)
rtk playwright test      # Failures only (94%)
rtk prisma generate      # No ASCII art (88%)
```

### Python (70-90% savings)
```bash
rtk pytest               # Failures only (90%)
rtk ruff check           # JSON format, grouped (80%)
rtk ruff format          # Text output
rtk pip list             # Auto-detects uv (70-85%)
rtk pip outdated
rtk pip install -r requirements.txt
rtk python manage.py migrate
rtk python manage.py test
```

### Ruby/Rails
```bash
rtk bin/rails db:migrate
rtk bin/rails test
rtk bin/rails routes
rtk bundle install
rtk bundle exec rspec
rtk bundle exec rake
```

### Go (75-90% savings)
```bash
rtk go test              # NDJSON parser (90%)
rtk go build             # Errors only (80%)
rtk go vet               # Issues only (75%)
rtk golangci-lint run    # JSON grouped by rule (85%)
```

### Rust (80-90% savings)
```bash
rtk cargo build          # Errors only (80%)
rtk cargo test           # Failures only (90%)
rtk cargo clippy         # Warnings grouped (80%)
```

### Containers (80% savings)
```bash
rtk docker ps
rtk docker images
rtk docker logs <container>   # Deduplicated
rtk docker compose ps
rtk kubectl pods
rtk kubectl logs <pod>        # Deduplicated
rtk kubectl services
```

### Utilities
```bash
rtk log app.log          # Deduplicated logs
rtk curl <url>           # Auto-detect JSON + schema
rtk env -f AWS           # Filtered env vars
rtk deps                 # Dependencies summary
rtk summary <command>    # Heuristic summary
rtk proxy <command>      # Raw passthrough (for debugging)
```

## Never Chain Commands

```bash
# NEVER:
git checkout main && git merge feature && npm test

# ALWAYS — one per call:
rtk git checkout main
# check output
rtk git merge feature --no-edit
# check output
rtk npm test
```

**Why:** Chained commands hide failures. A merge conflict mid-chain wastes tokens on broken state.

## Never Pipe RTK Output

```bash
# NEVER:
rtk git log | head -5       # Pipe defeats rtk compression
rtk npm test 2>&1 | tail    # RTK already strips noise

# ALWAYS:
rtk git log --oneline -5    # Use flags, not pipes
rtk npm test                # RTK handles compression
```

## Suppress Dev Server Noise

```bash
PORT=3002 rtk npm run dev > /dev/null 2>&1 &
sleep 3 && curl -s -o /dev/null -w "%{http_code}" http://localhost:3002
```

## Failed Command Recovery

RTK saves full unfiltered output on failure to `~/.local/share/rtk/tee/`. Read the file instead of re-running.

## Analytics

```bash
rtk gain              # Token savings summary
rtk gain --history    # Recent command history
rtk discover          # Find missed savings opportunities
```

## Orchestrator Delegation Rule

Include in every agent briefing:
> "Prefix ALL CLI commands with `rtk`. One command per call. Stop on error."
