---
name: token-efficient-commands
description: Use when running ANY shell command — all CLI commands must use rtk prefix for token compression, commands must be broken into small steps, never chain destructive or stateful operations
---

# Token-Efficient Commands

## Overview

Every CLI command MUST be prefixed with `rtk` for 60-90% token savings on output. Commands must be small, focused, and sequential — never long chains. This is non-negotiable.

**Core principle:** `rtk <command>` always. One operation per call. Stop on failure.

## The Rule

```
# EVERY command gets the rtk prefix:

# Git
rtk git status
rtk git diff
rtk git log --oneline -1
rtk git merge feature/xyz --no-edit
rtk git cherry-pick <commit-hash>
rtk git rebase main
rtk git pull
rtk git push
rtk git stash
rtk git branch -a

# Rails / Ruby — ALWAYS use rtk, never pipe through tail/head to truncate
rtk bin/rails db:migrate
rtk bin/rails db:seed
rtk bin/rails routes
rtk bin/rails test
rtk bin/rails console
rtk bin/rails server
rtk bin/rails runner "load 'path/to/script.rb'"
rtk bundle install
rtk bundle exec rspec
rtk bundle exec rake
rtk bundle exec rails runner "SomeTask.run"

# npm / Node
rtk npm install
rtk npm run dev
rtk npm run build
rtk npm test
rtk npx <command>
rtk yarn install
rtk yarn dev
rtk yarn build

# Python
rtk python manage.py migrate
rtk python manage.py runserver
rtk python manage.py test
rtk pip install -r requirements.txt
rtk pytest
rtk python -m venv .venv
rtk uv pip install -r requirements.txt

# Other
rtk cargo build
rtk docker ps
rtk kubectl get pods
```

**No exceptions.** Not "just a quick git status." Not "it's only one command." Every. Single. One.

## What RTK Does

RTK (Rust Token Killer) compresses CLI output by 60-90%, stripping noise like:
- File-by-file diff stats from git merge
- Package update banners (refine, npm, yarn)
- Verbose build output
- Rails deprecation warnings, Sentry init logs, autoload notices, full stack traces
- Ruby/Rails runner verbose output, seed file logging
- Docker/kubectl table formatting bloat
- ANSI color codes and decorative borders

Without RTK, a single `git merge` can dump 50+ lines. With RTK: 2-3 lines.

## Never Chain Commands

```bash
# NEVER do this:
git checkout main && git branch -D feature && git checkout -b feature && git merge other --no-edit && npm run dev &

# ALWAYS do this — one command per tool call:
rtk git checkout main
# (check output, then next)
rtk git branch -D feature
# (check output, then next)
rtk git checkout -b feature
# (check output, then next)
rtk git merge other --no-edit
# (check output — if CONFLICT, stop and handle it)
```

**Why:** Chained commands hide failures. A merge conflict mid-chain doesn't stop `&&` — the rest keeps running, wasting tokens on output from a broken state. One command per call lets you react to each result.

## Allowed Compound Commands

Only these patterns are acceptable:

```bash
# Short, safe, read-only pipes:
rtk git log --oneline -1

# Environment setup + single command:
PORT=3002 rtk npm run dev

# Kill + restart (idempotent):
kill $(lsof -ti:3002) 2>/dev/null; rtk npm run dev
```

## Suppress Noise at Source

```bash
# Dev servers: background + discard stdout
PORT=3002 rtk npm run dev > /dev/null 2>&1 &

# Then check health separately:
sleep 5 && curl -s -o /dev/null -w "%{http_code}" http://localhost:3002

# Git: use quiet flags when you don't need output
rtk git checkout main -q
rtk git merge feature/xyz --no-edit -q
```

## Stop on Conflict or Error

If any command returns an error or conflict:

1. **STOP** — do not run the next command
2. **Read the error** — understand what happened
3. **Fix it** — resolve the conflict or error
4. **Then continue** — only after the fix is confirmed

Never power through errors hoping the chain will work out.

## Red Flags

| Pattern | Problem | Fix |
|---------|---------|-----|
| `git status` (no rtk) | No compression | `rtk git status` |
| `cmd1 && cmd2 && cmd3 && cmd4` | Hidden failures, token waste | One per call |
| `npm run dev 2>&1` without redirect | Dev server dumps entire stdout | `> /dev/null 2>&1 &` |
| Continuing after `CONFLICT` | Broken state, wasted work | Stop and resolve |
| `git merge` without `-q` | Full file list dumped | Add `-q` or use `rtk` |
| `bin/rails db:migrate` (no rtk) | Deprecation warnings, init logs flood output | `rtk bin/rails db:migrate` |
| `bundle exec rails runner ... 2>&1 \| tail` | Still dumps full stack traces | `rtk bundle exec rails runner ...` |
| `rtk <cmd> 2>&1 \| head -20` or `\| tail -20` | Pipe defeats rtk compression — rtk already strips noise | `rtk <cmd>` (no pipes) |
| Any `rails` or `bundle exec` without rtk | Verbose Ruby output wastes tokens | Always prefix with `rtk` |
| `python manage.py migrate` (no rtk) | Verbose migration output | `rtk python manage.py migrate` |
| `pip install` (no rtk) | Package download noise | `rtk pip install -r requirements.txt` |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "It's faster to chain them" | It's faster until one fails mid-chain and you debug for 10 minutes |
| "RTK is just for git" | RTK compresses npm, yarn, cargo, docker, kubectl, Rails, and more |
| "This command is too simple for rtk" | Simple commands still produce verbose output. Always use rtk. |
| "I'll check the output after" | You can't un-burn tokens. Compress first. |

## Integration with Orchestrator

When the orchestrator delegates to any agent, include in the briefing:

> "Always prefix CLI commands with `rtk` (e.g., `rtk git status`, `rtk npm test`). Never chain more than 2 commands. Stop immediately on any error or conflict."
