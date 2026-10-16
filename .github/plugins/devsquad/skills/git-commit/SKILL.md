---
name: git-commit
description: "Create standardized git commits with Conventional Commits. Use when the user asks to commit changes, generate a commit message, or at the end of an implementation. Analyzes the actual diff to determine type, scope, and message. Supports logical file grouping and work item references (GitHub Issues and Azure DevOps). Do not use for branch creation (use git-branch), push, or pull requests (use pull-request)."
---

# Git Commit — Conventional Commits for SDD

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

References: [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/) and [How to Write a Git Commit Message](http://chris.beams.io/posts/git-commit/).

## Commit Types

| Type | Usage |
|------|-------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation-only change |
| `style` | Formatting, semicolons, whitespace (no logic change) |
| `refactor` | Refactoring without behavior change |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `build` | Build system or external dependencies |
| `ci` | CI/CD configuration |
| `chore` | General maintenance (scripts, configs) |
| `revert` | Revert a previous commit |

### Mapping to SDD Artifacts

| SDD Artifact | Likely type |
|---|---|
| `docs/features/**/spec.md` | `docs` |
| `docs/architecture/decisions/*.md` (ADR) | `docs` |
| `tasks.md`, work items | `docs` or `chore` |
| Implementation code | `feat`, `fix`, `refactor`, `perf` |
| Tests | `test` |
| Agents, skills, instructions (`.github/`) | `chore` or `ci` |

## Breaking Changes

```bash
# ! marker after type/scope
feat!: remove deprecated endpoint

# Or BREAKING CHANGE footer
feat(api): allow extensible configuration

BREAKING CHANGE: behavior of the `extends` key changed
```

## Workflow

### 1. Analyze Diff

```bash
# If there are staged files, use staged diff
git diff --staged --stat
git diff --staged

# If nothing is staged, use working tree
git diff --stat
git diff

# Check overall status
git status --porcelain
```

Determine from the diff:
- **Type**: What kind of change is this? (see table above)
- **Scope**: Which module/area was affected? (e.g., `auth`, `api`, `docs`, `spec`)
- **Description**: One-line summary of what changed

### 2. Group and Stage (if needed)

If the diff contains logically distinct changes, group them into separate commits:

```bash
# Group by logical area
git add src/auth/*.ts          # commit 1: feat(auth)
git add tests/auth/*.test.ts   # commit 2: test(auth)
git add docs/features/login/   # commit 3: docs(login)
```

**Principle: one commit = one coherent logical change.**

Even for a single logical unit, stage explicit reviewed paths rather than using `git add -A`. Before staging, exclude agent-generated `structure.md` caches, ignored `.memory/` drafts, and board-mode `tasks.md` files. Local-only task lists remain durable artifacts and their verified checkbox updates belong in the task commit.

If an agent-generated cache is already staged, remove only that cache from the index without deleting its working copy. Do not unstage user changes or remove existing authored files automatically. If a legacy tracked task list needs migration to the board, require an approved scope and verified board transfer before staging its removal.

### 3. Pre-Commit Checks

Before committing, verify:

```bash
# Does .gitignore exist?
test -f .gitignore && echo "OK" || echo "⚠ .gitignore missing"

# No secrets being committed?
git diff --staged --name-only | grep -iE '\.(env|pem|key|credentials|secret)' && echo "⚠ POSSIBLE SECRET" || echo "OK"
```

**Never commit**: `.env`, private keys, tokens, credentials, `credentials.json`.

### 3b. Integration Branch Guard

Before committing, check if the current branch is the integration branch:

```bash
CURRENT_BRANCH=$(git branch --show-current)
```

Resolve the integration branch in this order:

1. `Integration Branch` from `.memory/git-config.md` (if it exists)
2. Repository default branch via `git symbolic-ref refs/remotes/origin/HEAD`
3. Fallback: match against `main`, `master`, or `develop`

If the current branch matches the integration branch:

```
You are about to commit directly to `[branch]`. Direct commits to the integration branch bypass code review and are difficult to revert safely.

[B] Create a feature branch first (recommended)
[C] Continue on [branch] (I understand the risks)
```

If the user chooses **[B]**:

| Current state | Recovery action |
|---|---|
| Changes are staged but not committed | Run `git switch -c <feature-branch>` (preserves working tree and index) |
| Changes are unstaged | Run `git switch -c <feature-branch>` (preserves working tree) |

After switching, continue the commit flow on the new branch.

If the user chooses **[C]**, proceed with the commit. Log the override in the reasoning log (if active).

**Never commit to the integration branch without explicit user confirmation.**

### 4. Generate Message and Commit

Every agent-generated commit **must** include the co-authorship trailer as the last `-m`:

```
Co-authored-by: GitHub Copilot <noreply@github.com>
```

This keeps the developer as the primary author and records Copilot's participation in a traceable way.

```bash
# Without body
git commit -m "<type>(<scope>): <description> (#<issue>)" \
  -m "" \
  -m "Co-authored-by: GitHub Copilot <noreply@github.com>"

# With body
git commit -m "<type>(<scope>): <description> (#<issue>)" \
  -m "<body with additional context>" \
  -m "Co-authored-by: GitHub Copilot <noreply@github.com>"
```

### 5. Work Item References

Always reference the task or issue when available:

```bash
# GitHub Issues
feat(auth): add OAuth login (#42)
fix(api): fix timeout on long-running requests (Closes #87)

# Azure DevOps
feat(auth): add OAuth login (AB#1234)
fix(api): fix timeout on long-running requests (AB#5678)
```

## Message Rules

| Rule | Correct example | Incorrect example |
|------|----------------|-------------------|
| Imperative, present tense | `add validation` | `added validation` |
| Lowercase first letter in description | `fix: fix date parsing` | `fix: Fix date parsing` |
| No period at end of description | `feat: add filter` | `feat: add filter.` |
| Description ≤ 72 characters | — | — |
| Body separated by blank line | — | — |
| Body explains the **why**, not the **what** | — | — |

## Git Security Protocol

- **NEVER** change global git config
- **NEVER** run `--force` or `reset --hard` without explicit user request
- **NEVER** use `--no-verify` to skip hooks without explicit user request
- **NEVER** force push to `main`/`master`
- If a commit fails due to hooks, fix the issue and create a **new** commit (do not use `--amend` automatically)
- If the hook fails repeatedly, inform the user about the error and wait for instructions

## Complete Examples

> All examples below omit the `Co-authored-by` trailer for brevity. It is required as per section 4.

### Simple commit (feature)

```
feat(auth): add JWT authentication (#42)
```

### Commit with body (complex fix)

```
fix(api): fix race condition in session cache (#87)

The shared cache between workers did not have proper locking,
causing inconsistent data under high load (>100 req/s).

Replaced Map with ConcurrentMap with configurable TTL.
```

### SDD documentation commit

```
docs(login): create login feature specification

Includes user scenarios, functional requirements (FR-001 to FR-005),
success criteria, and compliance criteria.
```

### ADR commit

```
docs(adr): add ADR 0003 — cache strategy

Documents decision to use Redis as distributed cache.
Alternatives evaluated: Memcached, local in-memory cache.
```

### Breaking change

```
feat(api)!: migrate endpoints from v1 to v2 (#120)

BREAKING CHANGE: all /api/v1/* endpoints have been removed.
Clients must migrate to /api/v2/* per the migration guide.
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I will commit when the feature is done" | One giant commit is impossible to review, debug, or revert. Commit each logical slice. |
| "The message does not matter" | Messages are documentation. Future developers and agents need to understand what changed and why. |
| "I will squash it all later" | Squashing destroys the development narrative. Prefer clean incremental commits from the start. |
| "These changes are too small to commit separately" | Small commits are free. Large commits hide bugs and make rollbacks painful. |
| "Formatting changes can go with behavior changes" | Mixed concerns make review harder, reverts riskier, and history less useful. Separate them. |

## Red Flags

- Large uncommitted changes accumulating across multiple files
- Commit messages like "fix", "update", "misc", or "WIP"
- Formatting changes mixed with behavior changes in the same commit
- Secrets or credentials appearing in the staged diff
- No work item reference when one is available
