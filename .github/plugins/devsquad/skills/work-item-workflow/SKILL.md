---
name: work-item-workflow
description: "Work item workflow for implementation. Use when starting work on a GitHub issue or Azure DevOps work item to verify assignee, dependencies, priority, and capacity. Do not use for creating new work items (use work-item-creation), for suggesting the next task (use next-task), or when the work source is only tasks.md without an issue/work item."
---

# Work Item Workflow

## Work Source Detection

Analyze the user's input to determine the source:

- **GitHub Issue**: user mentions an issue (e.g., "implement issue #42", "#15")
- **Azure DevOps Work Item**: user mentions a work item (e.g., "work item 1234", "task 5678")
- **tasks.md**: no issue/work item mentioned, skip this skill

### Reading the Work Item

1. **Identify platform**: Read `.memory/board-config.md` or detect from remote (`git config --get remote.origin.url`)
2. **Get current user**:
   - GitHub: `gh api user --jq '.login'`
   - Azure DevOps: `az account show --query user.name -o tsv` or ask the user
3. **Read work item via MCP**: Extract title, description, assignee, acceptance criteria, state, and tags/labels

## Required Checks

Execute in order. If any check blocks, **STOP** and inform the user.

### 1. Assignee check

| Situation | Action |
|-----------|--------|
| Assigned to another dev | **STOP**: "Work item already assigned to [name]." |
| No assignee | Assign current user and inform |
| Assigned to the current user | Proceed |

### 2. State update

- Move the task to active state:
  - **GitHub**: Add label `status:in-progress`
  - **Azure DevOps**: Change State per process template (invoke `board-config` skill for details)
- Check the parent User Story:
  - If the parent US is not in progress, update it as well
  - Inform: "User Story #[ID] moved to In Progress."

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
