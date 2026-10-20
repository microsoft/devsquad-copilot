---
name: work-item-workflow
description: "Work item workflow for implementation. Use when starting or completing work on a GitHub issue or Azure DevOps work item to verify readiness and persist completion evidence. Also use the Completion Checkpoint for verified local-only task lists. Do not use for creating new work items (use work-item-creation), for suggesting the next task (use next-task)."
---

# Work Item Workflow

## Work Source Detection

Classify the work source before any other action. Resolve in this priority order:

1. **GitHub Issue or Azure DevOps Work Item** if a numeric ID is referenced anywhere in the user's message, the recent conversation, or the tasks.md being implemented (e.g., "implement issue #42", "#15", "work item 1234", "task 5678", or a tasks.md row that links to `#1690`). Any such reference activates board mode for the entire implementation, even if the user phrases the request as "implement the Terraform task" or "continue the work".
2. **tasks.md only** if no issue or work item ID is reachable from the current context. Skip board readiness checks, but run the Completion Checkpoint after verification.

When in doubt between the two, choose board mode and read the work item. Reading is read-only and cheap; silently skipping board updates is the failure this skill exists to prevent.

### Reading the Work Item

1. **Identify platform**: Read `.memory/board-config.md` or detect from remote (`git config --get remote.origin.url`)
2. **Get current user**:
   - GitHub: `gh api user --jq '.login'`
   - Azure DevOps: `az account show --query user.name -o tsv` or ask the user
3. **Read work item via MCP**: Extract title, description, assignee, acceptance criteria, state, and tags/labels

### Resume Check Before State Changes

Inspect the selected item's existing implementation evidence, linked PRs, and code/test evidence before changing its workflow state. If verified work is awaiting review or merge, retain its current state and resume review or finalization rather than reactivating the task or implementing it again. Do not reopen a terminal item without an explicit new scope. If the evidence is incomplete or no longer matches the current code, verify the remaining work before deciding what to implement. Apply the readiness state transition below only to work that genuinely needs implementation.

## Required Checks

Execute in order. If any check blocks, **STOP** and inform the user.

### 1. Assignee check

| Situation | Action |
|-----------|--------|
| Assigned to another dev | **STOP**: "Work item already assigned to [name]." |
| No assignee | Assign current user (see below), then inform: "Assigned this task to you." |
| Assigned to the current user | Proceed |

When the work item has no assignee, do not skip this step. Execute the assignment before moving to the State update check:

- **GitHub**: Call `github/issue_write` with `method: "update"`, the issue number, and `assignees: ["<current-user-login>"]` (the login obtained in step "Get current user").
- **Azure DevOps**: Call `ado/wit_update_work_item` to set the `System.AssignedTo` field to the current user.

If the assignment call fails (permission error, user lookup empty, API error), **STOP** and report the failure rather than silently proceeding to later checks. The downstream flow (state update, branch creation, PR linkage) assumes the work item is owned by the current user.

### 2. State update

State transitions are mandatory, not advisory. If the board MCP is unreachable, surface a blocking error rather than skipping the transition.

- Move the task to the active state:
  - **GitHub**: Add label `status:in-progress`
  - **Azure DevOps**: Change State per process template (invoke `board-config` skill for details; typical: `New` to `Active`)
- Check the parent User Story:
  - If the parent is not yet in the active state, update it as well
  - Inform: "User Story #[ID] moved to In Progress."
- Confirm the transition succeeded by re-reading the work item and verifying the new state. If the read shows the old state, retry once and then surface the failure to the user before any code is written.

### 3. Dependency check

- **GitHub**: Look for "Depends on: #NNN" in the body
- **Azure DevOps**: Look for links of type "Predecessor"
- For each unfinished dependency (open issue / state != Done|Closed):
  ```
  This task has unfinished dependencies:

  - #[ID]: [title] (state: [state])

  [V] View dependency details
  [O] Work on another task
  [I] Ignore and continue anyway (not recommended)
  ```

### 4. Priority check

- Search for available tasks (no assignee, same feature)
- If there are tasks with **higher priority** available:
  ```
  There are higher priority tasks available:

  - #[ID]: [title] (P1)

  Requested task: #[ID] (P2)

  [P] Pick the higher priority task (recommended)
  [C] Continue with the requested task
  ```

### 5. Capacity check

- Search for in-progress tasks assigned to the current user
- If the user already has **3 or more tasks in progress**:
  ```
  You already have [N] tasks in progress:

  - #[ID]: [title]

  [F] Finish a task before picking up another (recommended)
  [C] Continue and pick up another task
  ```

## Completion Checkpoint

Run this checkpoint after the task's required verification succeeds and before moving to another task or reporting completion. It applies to low-impact work, autonomous execution, and sessions where the developer deferred committing or opening a PR. Verification failure is not completion.

1. Read the current task or local checklist. On a resumed session, inspect existing implementation-status comments, linked PRs, and available code/test evidence before editing. If the task is already implemented and awaiting review or merge, continue from that stage instead of implementing it again. An active label alone does not prove work is missing or complete.
2. For a local-only `tasks.md`, mark only the verified task's checkbox `[x]` and read it back before staging the logical task commit. Preserve unchecked work and unrelated text. If committing is deferred, still persist the checkbox update.
3. For GitHub, add or update a durable issue comment stating "Implementation verified, pending PR" or "Implementation verified, pending merge" as applicable. Include the implemented scope, verification commands and outcomes, branch or commit when available, PR URL when present, and any remaining work. Keep the issue open with `status:in-progress` until merge and retain `Closes #N` in the eventual PR body. Do not mark unrelated or unmet acceptance criteria as satisfied.
4. For Azure DevOps, inspect the detected process and the actual work item type's allowed states. Use a supported nonterminal implementation-complete state when one exists, or retain the active state and add the same verified-implementation evidence in a comment. Do not assume every Task supports `Resolved`, and do not set terminal `Done` or `Closed` before the required merge or acceptance event.
5. Read back the updated checklist, issue comment, or work item state and comment to confirm it persisted. If the update is missing, retry once. If writing or verifying still fails, report the blocking synchronization error and do not advance to another task or claim completion.
6. For a parent story, record child progress with links and distinguish verified implementation from merged completion. Do not mark a parent complete or close it merely because its children have code written. Use Cascade Closure only after the required child completion events and user approval.

## tasks.md (when no issue/work item is mentioned)

1. Identify the current feature by checking the `docs/features/` directory. If the user specified a feature, use it.
2. Read tasks.md for the task list and execution plan
3. Proceed with the implementation flow

## Main Execution Rule

Developers should work on **only one task at a time**. Work happens at the task level, not at the feature, user story, or epic level directly.

## Board Synchronization

When synchronizing with the board, the agent should:

1. **List ALL issues/work items** in the repository/project
2. **Identify feature-related issues** using multiple strategies:
   - By label/tag: `feature:<name>`, `type:user-story`, `type:task`
   - By title: contains the feature name or keywords
   - By content: mentions files or concepts from the plan
3. **Classify found issues**:
   - **With copilot-generated label**: Issues created by the agent (managed)
   - **Without labels, related**: Manual issues that appear related
   - **Without labels, unrelated**: Issues from other features/contexts
4. **For unlabeled issues that appear related**, ask the user:
   - Add labels and incorporate into the plan
   - Ignore (not from this feature)
   - Mark as duplicate of a planned task
5. **Map current state**: User Stories and Tasks (open, in progress, closed)
6. **Present summary to user** with comparison between board and plan

## Cascade Closure

When synchronizing with the board, check and propose cascade closures:

| Condition | Action |
|-----------|--------|
| All tasks of a User Story closed | Propose closing the User Story |
| All User Stories of a Feature closed | Propose closing the Feature |
| All Features of an Epic closed | Propose closing the Epic |

### Closure Rules

- Always ask before closing (do not close automatically)
- Show summary of what will be closed
- Validate that there are no orphan tasks/US before closing

## Work Item Hierarchy

### GitHub

- Use sub-issues for parent-child hierarchy
- For dependencies between tasks, use the "Dependencies" section in the body: `Depends on: #123`

### Azure DevOps

- **Parent-Child**: use `ado/wit_add_child_work_items`
- **Dependencies**: use `ado/wit_work_items_link` with link type `Predecessor`/`Successor`
