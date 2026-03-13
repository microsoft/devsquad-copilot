---
name: next-task
description: "Next task suggestion after completing implementation. Use when the developer finishes a task and wants a recommendation for the next one. Do not use during an ongoing implementation, for initial task selection (use work-item-workflow), or for sprint planning (use sdd.sprint)."
---

# Next Task — Next Task Suggestion

## Offer Suggestion

After completing implementation (PR created or push performed):

```
Task completed! Would you like a suggestion for the next task?

[Y] Yes, suggest next task
[N] No, end session
```

## Find Available Tasks

- **GitHub**: Issues with label `type:task`, no assignee, state open
- **Azure DevOps**: Work items of type Task, no Assigned To, state New/To Do, in the current sprint

## Sort by Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Priority | High | P1 > P2 > P3 |
| Dependencies satisfied | High | Tasks without blockers first |
| Same User Story | Medium | Context continuity |
| Same feature | Medium | Domain continuity |
| Sequential phase | Low | Setup → Foundation → Core → Integration |

## Check Open PRs

Before presenting suggestions, check if there are open PRs in the repository that haven't been merged yet. The dependency is about **code that is not in main**, regardless of who opened the PR.

```bash
# List open PRs in the repository
# GitHub: github/list_pull_requests(owner, repo, state: "open")
# Azure DevOps: ado/list_pull_requests (status: "Active")
```

If there are open PRs, check if the suggested tasks depend on the code in those PRs (same user story, later phase, or explicit dependency in tasks.md).

## Present Suggestions (top 3)

```
Recommended next tasks:

1. #[number]: [title]
   Priority: P1 | Feature: [name] | Phase: [phase]
   Reason: Highest priority, same feature

2. #[number]: [title]
   Priority: P1 | Feature: [name] | Phase: [phase]
   Reason: Dependency from previous task satisfied

3. #[number]: [title]
   Priority: P2 | Feature: [name] | Phase: [phase]
   Reason: User Story continuity

[1/2/3] Select task
[O] See other options
[N] End session
```

If the selected task depends on code from an open PR (not merged), alert:

```
Warning: this task depends on code from PR #[number] ([title]), which has not been merged yet.

If you create the branch from the main branch, the code from the previous task will not be available.

[W] Wait for PR merge and continue later
[B] Create branch from the previous branch ([branch-name]) — stacked branch
[I] Ignore and create from the main branch anyway
```

**Note**: Option [B] (stacked branch) works, but requires rebase after the previous PR is merged. Alert the dev about this implication.

## Branch Transition

If the user selects a task:

### Check pending changes

```bash
git status
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null
```

If there are uncommitted changes:

```
You have uncommitted changes on the current branch:

[modified files]

[C] Commit changes and continue
[S] Stash and continue (not recommended)
[A] Abort and continue on the current task
```

If there are unpushed commits:

```
You have local commits not pushed to remote:

[list of commits]

[P] Push and continue
[A] Abort and continue on the current task
```

### Return to main branch

If the current branch is not main/master/develop:

```
You are on branch: [branch-name]

To keep branches short-lived, I recommend:

[M] Return to main/develop and create a new branch
[C] Continue on the current branch (not recommended for different tasks)
```

### Start new task

After ensuring a clean branch:

- Read branching strategy: `cat .memory/git-config.md 2>/dev/null`
- If it doesn't exist, use fallback: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
- Return to integration branch: `git checkout <integration-branch>`
- Update: `git pull origin <integration-branch>`
- Create new branch for the selected task
- Start implementation flow
- Apply all checks (assignee, dependencies, priority, capacity)
