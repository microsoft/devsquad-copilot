---
name: pull-request
description: "Implementation finalization with PR. Use when implementation is complete and you need to commit, push, or open a pull request. Includes automated reviews and technical debt tracking. Do not use during implementation (use sdd.implement), for standalone intermediate commits (use git-commit), or for branch creation (use git-branch)."
---

# Pull Request — Implementation Finalization

## Check Git State

Use `read/changes` to list source control changes. In addition:

```bash
git status
git diff --stat
```

## Commit

If there are uncommitted changes, use the `git-commit` skill to commit.

## Offer PR Creation

If the automated review was already executed by `sdd.implement` (step 9 of the orchestration flow), **do not re-execute review**. Use the result already obtained.

```
Implementation completed and committed.

Would you like me to open a Pull Request?

[Y] Yes, open PR
[R] Review implementation before PR (recommended for medium/high impact)
[N] No, just push
```

If the user chooses **[R]** and the automated review was already executed, present the existing result instead of re-executing.

## Automated Reviews (sub-agents)

The type of review depends on the task's impact. Security review is delegated to `sdd.review` when it is invoked — both never run separately.

### High impact: Implementation Review (includes security)

**Triggers** (any of):

- Task classified as high impact
- Multiple user stories affected
- Changes to public API or schema

Execute `sdd.review` as a **sub-agent**. Pass the feature, task, and modified files.

```
High impact task. Running independent review...
```

After sub-agent result:

- **PASSED**: Proceed with PR.
- **PASSED_WITH_FINDINGS**: Present findings and ask if they want to fix now or proceed (findings are recorded in the review log).
- **FAILED**: Do not proceed with PR. Present critical findings and offer to fix or escalate for spec/plan review.

### Medium/low impact: Direct Security Review

When `sdd.review` is **not** invoked automatically, assess if a security review is needed by evaluating the security triggers defined in `sdd.security` (Authentication/Authorization, Sensitive data, External input, Persistence, Integrations).

If a trigger is detected, execute `sdd.security` as a **sub-agent** in code mode.

After the result, present the verdict (PASSED / PASSED_WITH_FINDINGS / FAILED) following the same format above.

If no trigger is detected, proceed with PR.

### Summary: who runs what

| Impact | Review | Security |
|--------|--------|----------|
| High | `sdd.review` (auto) | Delegated by `sdd.review` internally |
| Medium/Low + security trigger | No (available via `[R]`) | `sdd.security` direct |
| Medium/Low without trigger | No (available via `[R]`) | No |

## Record Technical Debt

If during implementation you find problematic code **outside the scope of the current task**, record it as a work item.

| Signal | Example |
|--------|---------|
| Existing TODO/FIXME/HACK comments | `// TODO: refactor this` |
| Significant duplication | Same logic in 3+ places |
| Excessive coupling | Change in one module requires changes in several others |
| Code without tests in critical area | Business logic without coverage |
| Outdated dependency with vulnerability | Package with known CVE |

Ask the user:

```
I identified technical debt outside the scope of this task:

[problem description]
Files: [list]
Suggested severity: [high/medium/low]

[C] Create tech debt work item on the board
[I] Ignore (do not record)
```

If confirmed, create the work item following the `work-item-creation` skill (Tech Debt section).

## Determine Target Branch

Before creating the PR, determine the target branch:

```bash
cat .memory/git-config.md 2>/dev/null
```

Use `Integration Branch` from the config. If it doesn't exist, use the repository's default branch.

## Create Pull Request

Before creating, check if a PR already exists for the branch:

```
github/list_pull_requests(owner, repo, head: "<owner>:<branch>", state: "open")
```

If an open PR already exists, inform and ask if they want to update the existing one.

Push the branch:

```bash
git push -u origin <branch-name>
```

Create PR with:

- **Title**: Based on the main issue/task
- **Body**:
  ```markdown
  ## Description

  [Summary of what was implemented]

  ## Related issue

  Closes #[number]

  ## Changes

  - [list of main changes]

  ## Checklist

  - [ ] Tests passing
  - [ ] Code follows project standards
  - [ ] Documentation updated (if needed)
  ```
- **Labels**: Inherit labels from the issue (feature, priority, etc.)

After creating the PR, ask about reviewers:

```
Pull Request created: [link]

Would you like to assign reviewers?

[Y] Yes, suggest (search repo members)
[N] No, I'll request review manually
[name] Assign directly to: _
```

If the user chooses [Y] or provides names, use `github/update_pull_request` with the `reviewers` field to assign.

## Check CI (post-creation)

After PR creation, check the status of checks:

```
github/pull_request_read(owner, repo, pullNumber, method: "get_check_runs")
```

Report summarized check status (passed / failed / pending).

If there are failures, use `github/get_job_logs` (if available) to fetch logs from failed jobs and present a diagnosis.

Report:

```
Pull Request created: [link]

Branch: [branch] -> [integration-branch]
Issue: Closes #[number]
Reviewers: [list or "none assigned"]
CI: [summarized status]
```

## Request Copilot Review (optional)

If the project uses GitHub Copilot, offer automated review via `github/request_copilot_review(owner, repo, pullNumber)`.

## Update PR Branch

If the PR is behind the base branch, offer update via `github/update_pull_request_branch(owner, repo, pullNumber)`.

## Merge PR

If CI passed and reviews were approved, offer merge with options: squash, rebase, or merge commit.

If confirmed, use `github/merge_pull_request(owner, repo, pullNumber, merge_method: "<choice>")`.

## Push Only (no PR)

```bash
git push -u origin <branch-name>
```

Inform that the PR can be opened later by invoking the skill again.
