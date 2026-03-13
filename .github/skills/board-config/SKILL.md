---
name: board-config
description: Configure work item platform (GitHub Issues or Azure DevOps), detect process template, and save preference. Use when you need to identify where to create or read work items. Do not use for creating work items (use work-item-creation) or for managing implementation workflow (use work-item-workflow).
---

## Configure Board

### 1. Check existing config

```bash
cat .memory/board-config.md 2>/dev/null
```

If `Board Platform` is filled in, use the configured platform. If only `Repo Platform` is filled in (hook seed), proceed to confirm board.

### 2. Confirm board platform

The repo and the board can be on different platforms. Ask the user:

```
Repo detected: [Repo Platform from config, or detect from remote]

Where do you want to manage work items?

[G] GitHub Issues
[A] Azure DevOps Boards
[L] Local only (tasks.md)
```

If `Repo Platform` is `azdo`, suggest Azure DevOps Boards as default. If `github`, ask the user (it could be GitHub Issues or Azure DevOps).

### 3. If Azure DevOps, detect process template

Search existing work items and identify by types:

| Type found | Template |
|------------|----------|
| Product Backlog Item | Scrum |
| User Story | Agile |
| Issue (without PBI/US) | Basic |
| Requirement | CMMI |

If there are no work items, ask the user.

### 4. Save config

Save to `.memory/board-config.md`:

```markdown
# Board Config

Repo Platform: [github|azdo]
Board Platform: [github|azdo|local]
Azure DevOps URL: [url] (if applicable)
Process Template: [scrum|agile|basic|cmmi] (if Azure DevOps)
```

## Supported Scenarios

| Repository | Board | Action |
|------------|-------|--------|
| GitHub | GitHub | Create issues on GitHub (default) |
| GitHub | Azure DevOps | Create work items on Azure DevOps |
| Azure DevOps | Azure DevOps | Create work items on Azure DevOps |
| Azure DevOps | GitHub | Create issues on GitHub |
| Any | Local | Generate tasks.md only |

## GitHub Configuration

### Check Existing Labels

1. Search existing issues to identify the label pattern used
2. If labels like `type:bug`, `type:feature`, `priority:high` are found, the project already has conventions
3. Adapt generated labels to follow the existing pattern

### Label Pattern Detection

| If found | Use pattern |
|----------|-------------|
| `type:xxx` or `kind:xxx` | Prefix `type:` or `kind:` |
| `priority:xxx` or `P1/P2/P3` | Same format found |
| `feature/xxx` or `feature:xxx` | Same format found |
| No pattern | Use sdd default: `type:user-story`, `feature:<name>` |

## Process Templates (Azure DevOps)

| Template | User Story Type | Task Type |
|----------|-----------------|-----------|
| Scrum | Product Backlog Item | Task |
| Agile | User Story | Task |
| Basic | Issue | Task |
| CMMI | Requirement | Task |

### Required Fields by Template

**Scrum**:
- Product Backlog Item: Title, Description, Acceptance Criteria, Effort, Priority
- Task: Title, Description, Remaining Work, Activity

**Agile**:
- User Story: Title, Description, Acceptance Criteria, Story Points, Priority
- Task: Title, Description, Original Estimate, Remaining Work, Activity

**Basic**:
- Issue: Title, Description, Effort, Priority
- Task: Title, Description, Remaining Work

**CMMI**:
- Requirement: Title, Description, Size, Priority, Impact
- Task: Title, Description, Original Estimate, Remaining Work, Discipline
