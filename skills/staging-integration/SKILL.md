---
name: staging-integration
description: Use when a feature has multiple PRs or spans multiple repos (frontend, backend, etc.) — merge to staging branch for regression testing before production merge
---

# Staging Integration

Coordinate multi-PR and multi-repo features through a staging branch for regression testing before production merge.

**Announce at start:** "I'm using the staging-integration skill to coordinate staging testing."

## When to Use

**Multi-PR features (same repo):**
- Feature is split into 2+ PRs (e.g., API + UI + migrations)
- Feature was split because it exceeded 20 files (atomic PR strategy)
- Each PR passed individual code review but hasn't been tested together
- Need to verify all pieces work as a whole before merging to main

**Multi-repo features:**
- Feature spans frontend and backend repos
- Feature involves a shared library + consuming services
- Any change that requires coordinated deployment across repos

**Single PR, single repo:**
- Skip this skill — normal completion flow is sufficient

## Decision Tree

```
Feature has PRs ready for merge
  ↓
Multiple PRs in same repo?
  ├─ YES → Staging integration (same-repo flow)
  └─ NO ↓

Spans multiple repos?
  ├─ YES → Staging integration (multi-repo flow)
  └─ NO → Normal merge flow (skip this skill)
```

## Staging Branch Convention

```
Branch naming:
  staging/[feature-name]          — single repo, multiple PRs
  staging/[feature-name]/[repo]   — multi-repo coordination

Examples:
  staging/user-auth
  staging/payment-integration/frontend
  staging/payment-integration/backend
  staging/payment-integration/shared-lib
```

**Rules:**
- Staging branches are **temporary** — deleted after feature merges to main
- Staging branches are created from `main` (or the project's base branch)
- Feature branches are ALWAYS created from `main` — never from staging or other feature branches
- **Never commit directly to staging** — staging is merge-only. All commits MUST go on feature branches, then get merged into staging. If a fix is needed during staging testing, commit it on the feature branch and re-merge into staging.
- Never push directly to main/master — always use PRs
- Staging branches are **not** long-lived environment branches
- Staging and feature branches are **completely separate** — never mix them

## Same-Repo Flow (Multiple PRs)

When a feature is split into multiple PRs within the same repository:

```
All PRs passed code review (@oracle approved)
  ↓
@fixer creates staging branch from main:
  git checkout main && git pull
  git checkout -b staging/[feature-name]
  ↓
@fixer merges each PR branch into staging:
  git merge [pr-branch-1] --no-ff
  git merge [pr-branch-2] --no-ff
  git merge [pr-branch-3] --no-ff
  ↓
Merge conflicts?
  ├─ YES → @fixer resolves, @oracle reviews resolution
  └─ NO → Continue
  ↓
@fixer runs full test suite on staging branch:
  [project test command]
  ↓
Tests pass?
  ├─ NO → @fixer investigates integration issues
  │         Switch to the relevant feature branch: git checkout [feature-branch]
  │         Fix the issue on the feature branch (NEVER fix on staging)
  │         Commit and push the feature branch
  │         Switch back to staging: git checkout staging/[feature-name]
  │         Re-merge: git merge [feature-branch] --no-ff
  │         Re-run tests
  └─ YES ↓
  ↓
@fixer runs regression tests (if defined):
  [regression test command or manual verification checklist]
  ↓
Regression pass?
  ├─ NO → @fixer switches to feature branch, fixes there, pushes, re-merges into staging
  └─ YES ↓
  ↓
@oracle informs user:
  "All [N] PRs merged to staging/[feature-name], tests pass,
   regression pass. Ready to merge to main."
  ↓
User merges manually (or approves agent to merge)
```

### Commands

```bash
# 1. Create staging branch
git checkout main && git pull origin main
git checkout -b staging/[feature-name]

# 2. Merge each PR branch (preserve merge commits for traceability)
git merge origin/[pr-branch-1] --no-ff -m "staging: merge [PR title 1]"
git merge origin/[pr-branch-2] --no-ff -m "staging: merge [PR title 2]"

# 3. Run tests
[test command]

# 4. Push staging for CI (if applicable)
git push -u origin staging/[feature-name]

# 5. After user merges to main, cleanup
git branch -d staging/[feature-name]
git push origin --delete staging/[feature-name]
```

## Multi-Repo Flow (Frontend + Backend + Others)

When a feature spans multiple repositories:

```
All PRs in all repos passed code review (@oracle approved)
  ↓
For EACH repo involved:
  @fixer creates staging branch:
    cd [repo]
    git checkout main && git pull
    git checkout -b staging/[feature-name]
    git merge [pr-branch] --no-ff
    git push -u origin staging/[feature-name]
  ↓
All staging branches created?
  ├─ NO → Finish remaining repos
  └─ YES ↓
  ↓
@fixer runs integration tests across repos:
  • Start backend on staging branch
  • Start frontend on staging branch
  • Run E2E / integration test suite
  • Test API contract compatibility
  ↓
Integration tests pass?
  ├─ NO → Identify which repo's changes break integration
  │         @fixer switches to the relevant feature branch in that repo
  │         Fixes the issue on the feature branch (NEVER on staging)
  │         Commits and pushes the feature branch
  │         Switches back to staging, re-merges feature branch
  │         Re-run integration tests
  └─ YES ↓
  ↓
@fixer runs regression tests:
  • Existing features still work?
  • No performance degradation?
  • API backward compatibility intact?
  ↓
Regression pass?
  ├─ NO → @fixer switches to feature branch, fixes there, pushes, re-merges into staging, re-test
  └─ YES ↓
  ↓
@oracle informs user:
  "Feature [name] tested across [N] repos on staging branches.
   All integration and regression tests pass.
   Repos ready to merge:
   - [repo-1]: PR #[N] → staging/[feature-name] ✅
   - [repo-2]: PR #[N] → staging/[feature-name] ✅
   Recommend merging in order: [backend → frontend → ...]"
  ↓
User merges manually in recommended order
```

### Multi-Repo Coordination Checklist

Before starting integration:
- [ ] All PRs in all repos have passed individual code review
- [ ] API contracts between repos are documented (check TRDs in Outline)
- [ ] Shared types/interfaces are compatible across repos
- [ ] Environment variables and config changes are documented

During integration:
- [ ] Staging branches created in all repos from latest main
- [ ] PR branches merged into respective staging branches
- [ ] Backend services start successfully on staging
- [ ] Frontend connects to backend staging successfully
- [ ] Integration test suite passes
- [ ] Regression test suite passes
- [ ] No breaking changes to existing API consumers

After user merges:
- [ ] All staging branches deleted (local + remote)
- [ ] Deployment order documented if sequential deploy needed

## Regression Testing Guide

### What to Test

**Always test:**
- All new feature functionality (from TRD/spec)
- Existing features that share code paths with changes
- API endpoints that were modified or depend on modified code
- Database queries affected by schema changes

**Test if applicable:**
- Cross-browser/cross-device (UI changes)
- Performance benchmarks (data path changes)
- Auth flows (any auth-related changes)
- Webhook/event handling (event system changes)

### How to Test

**Automated (preferred):**
```bash
# Unit + integration tests
[project test command]

# E2E tests (if available)
[e2e test command]

# API contract tests
[contract test command]
```

**Manual verification (when no automated tests exist):**

Create a verification checklist in the PR description:
```markdown
## Regression Checklist
- [ ] Feature A still works: [steps to verify]
- [ ] Feature B still works: [steps to verify]
- [ ] API endpoint X returns expected response
- [ ] UI flow Y completes without errors
```

@fixer executes each checklist item and reports results.

## Integration with Completion Flow

This skill plugs into the feature completion flow in `using-superpowers`:

```
Normal completion flow:
  PRs created → Code review passed
    ↓
  Multiple PRs or multi-repo?
    ├─ YES → staging-integration skill
    │         ↓
    │       Staging tests pass → @oracle informs user ready to merge
    └─ NO → @oracle informs user single PR ready to merge
    ↓
  Update outline checklist (@librarian)
    ↓
  Save final state (@librarian)
```

## Agent Responsibilities

| Agent | Role in Staging Integration |
|-------|---------------------------|
| **Orchestrator** | Detects multi-PR/multi-repo, triggers this skill |
| **@fixer** | Creates staging branches, merges PRs, runs tests, fixes issues |
| **@oracle** | Reviews merge conflict resolutions, informs user of results |
| **@librarian** | Updates Outline with integration status, saves state to supermemory |
| **@explorer** | Reads codemaps to identify affected code paths for regression scope |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Creating feature branches from staging | Feature branches ALWAYS branch from main/master |
| Pushing directly to main/master | Always use PRs — never push directly |
| Mixing feature branch work with staging branch | Keep them completely separate — staging is for integration testing only |
| Creating a single massive PR instead of splitting | PRs with 20+ files must be split by domain/context before review |
| Mixing unrelated changes in one commit | Atomic commits — one logical context per commit |
| Merging PRs to main without integration testing | Always use staging when multiple PRs |
| Testing only the last PR merged | Run full suite after ALL PRs are in staging |
| Forgetting to delete staging branches | Cleanup is part of the flow — always delete after merge |
| Merging multi-repo in wrong order | Backend before frontend, shared libs first |
| Committing or pushing fixes to staging | Fix on feature branch, push feature branch, re-merge into staging |
| Skipping regression for "small" changes | Small changes break things too — always regress |
