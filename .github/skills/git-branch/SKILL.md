---
name: git-branch
description: "Branch management for implementation. Use when you need to create a branch, switch branches, checkout, or verify branching strategy before implementing code. Do not use for commits (use git-commit), pull requests (use pull-request), or advanced git operations (rebase, merge)."
---

# Git Branch — Branch Management

## Check Branching Strategy Config

```bash
cat .memory/git-config.md 2>/dev/null
```

If `Branching Strategy` is filled in, use the configured strategy. The `detect-branching-strategy.sh` hook automatically seeds on `sessionStart`.

If the config has `Confidence: medium`, confirm with the dev before using (see Detect Branching Strategy section).

## Check Git State

Before starting implementation:

```bash
git branch --show-current
git status
git fetch origin
```

## Remote Synchronization

If on main/master/develop, check synchronization:

```bash
git rev-list HEAD..origin/<branch> --count
```

| Situation | Action |
|-----------|--------|
| Branch behind (commits behind remote) | Alert and suggest pull |
| Branch with uncommitted local changes | Alert about pending changes |
| Branch up to date and clean | Proceed normally |

If the main branch is behind:

```
Your branch [main] is [N] commits behind the remote.

I recommend updating before creating a new branch:

[P] Pull and continue
[I] Ignore and continue anyway (not recommended)
[A] Abort implementation
```

## Evaluate Situation for Branch Creation

| Situation | Action |
|-----------|--------|
| Already on a feature branch (not main/master/develop) | Use current branch |
| On main/master/develop without changes **with work item** | Create branch automatically (see below) |
| On main/master/develop without changes **without work item** | Ask if they want to create a branch |
| On main/master/develop with changes | Alert and ask how to proceed |

## Automatic Creation (when there is a work item)

When the source of work is a GitHub issue or Azure DevOps work item, create the branch automatically.

**Naming convention**:

```
feature/<id>-<short-description>
```

**Rules for `<short-description>`**:

- Derived from the work item title
- Lowercase letters, numbers, and hyphens only
- Maximum 50 characters in the total branch name
- Remove articles, prepositions, and unnecessary words

**Examples**:

| Work Item | Branch |
|-----------|--------|
| #42 "Implement user authentication" | `feature/42-user-authentication` |
| #108 "Add rate limiting to API endpoints" | `feature/108-rate-limiting-api` |
| WI 5678 "Create financial reports endpoint" | `feature/5678-financial-reports-endpoint` |

**Action**: Create branch and inform the user:

```
Branch created: feature/<id>-<short-description>

[C] Continue with this branch
[R] Rename branch: _
```

The user can rename, but the flow does not block waiting for confirmation to create.

## Interactive Creation (without work item)

When the source is tasks.md (without issue/work item), ask the user:

```
You are on the main branch. Do you want me to create a branch for this implementation?

Suggestion: feature/<short-description>

[S] Yes, create suggested branch
[N] No, continue on current branch
[C] Create with another name: _
```

## Existing Branch

If the user is already on a feature branch, use the current branch without additional questions.

## Detect Branching Strategy

When `.memory/git-config.md` does not exist or does not have `Branching Strategy`, detect automatically:

```bash
# 1. Default branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

# 2. Does develop branch exist?
HAS_DEVELOP=$(git ls-remote --heads origin develop 2>/dev/null | grep -q develop && echo "yes" || echo "no")

# 3. Do release/* or hotfix/* branches exist? (GitFlow pattern)
HAS_GITFLOW_BRANCHES=$(git branch -r 2>/dev/null | grep -qE '(release|hotfix)/' && echo "yes" || echo "no")
```

### Detection rules

| `develop` | `release/*` or `hotfix/*` | Strategy | Confidence | Action |
|-----------|--------------------------|----------|------------|--------|
| Yes | Yes | GitFlow | High | Save and inform |
| Yes | No | GitFlow | Medium | Ask to confirm |
| No | No | Trunk-Based | High | Save and inform |

**High confidence** — save automatically and inform:

```
Branching strategy detected: [trunk-based|gitflow]
Integration branch: [branch]

Saved to .memory/git-config.md. To change: edit the file or delete it.
```

**Medium confidence** — ask to confirm:

```
I detected a `develop` branch in the repository.

Which branching strategy does the project use?

[G] GitFlow (features → develop)
[T] Trunk-Based (features → main/master)
```

### Save config

Save to `.memory/git-config.md`:

```markdown
# Git Config

Branching Strategy: [trunk-based|gitflow]
Integration Branch: [main|master|develop]
```

### Behavior by Strategy

| Action | Trunk-Based | GitFlow |
|--------|-------------|---------|
| Branch created from | Integration Branch | Integration Branch (`develop`) |
| PR target | Integration Branch | Integration Branch (`develop`) |
| `next-task` returns to | Integration Branch | Integration Branch (`develop`) |
