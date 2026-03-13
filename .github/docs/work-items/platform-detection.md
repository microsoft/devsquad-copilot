# Platform Detection

This guide defines how to detect and configure the work item platform (GitHub Issues or Azure DevOps).

## Detect Work Environment

The repository and the work board can be on different platforms.

### 1. Check Repository Remote

```bash
git config --get remote.origin.url
```

### 2. Classify Repository Platform

| URL contains | Platform |
|------------|------------|
| `github.com` | GitHub |
| `dev.azure.com` or `visualstudio.com` | Azure DevOps |
| Other | Unknown platform |

### 3. Ask About the Board

If not specified previously:

```
Repository detected: [GitHub/Azure DevOps/Other]

Where do you want to create work items?

[G] GitHub Issues (same repository)
[A] Azure DevOps Boards
[L] Local only (tasks.md)

If Azure DevOps, provide the project URL:
Example: https://dev.azure.com/org/project
```

### 4. Supported Scenarios

| Repository | Board | Action |
|-------------|-------|------|
| GitHub | GitHub | Create issues on GitHub (default) |
| GitHub | Azure DevOps | Create work items on Azure DevOps |
| Azure DevOps | Azure DevOps | Create work items on Azure DevOps |
| Azure DevOps | GitHub | Create issues on GitHub |
| Any | Local | Generate tasks.md only |

### 5. Save Preference

Save to `.memory/board-config.md`:

```markdown
# Board Config

> Work item platform configuration. Created by setup, read by all agents.

Platform: [github|azdo|local]
Azure DevOps URL: [https://dev.azure.com/org/project] (if applicable)
Process Template: [scrum|agile|basic|cmmi] (if Azure DevOps)
```

## GitHub Configuration

GitHub Issues is simpler than Azure DevOps, but may have Projects configured.

### Check Existing Labels

1. Search existing issues to identify the label pattern used
2. If you find labels like `type:bug`, `type:feature`, `priority:high` → project already has conventions
3. Adapt generated labels to follow the existing pattern

### Available Fields

- Title, Body (markdown), Labels, Assignees, Milestone
- If the repository uses GitHub Projects: Status, Priority, Size, Iteration (custom fields)

### Label Pattern Detection

| If found | Use pattern |
|--------------|-------------|
| `type:xxx` or `kind:xxx` | Prefix `type:` or `kind:` |
| `priority:xxx` or `P1/P2/P3` | Same format found |
| `feature/xxx` or `feature:xxx` | Same format found |
| No pattern | Use sdd default: `type:user-story`, `feature:<name>` |

## Azure DevOps Configuration

### Identify Process Template

Different process templates have different work item types and fields:

| Process Template | User Story Type | Task Type | Specific Fields |
|------------------|-----------------|-----------|-------------------|
| **Scrum** | Product Backlog Item | Task | Effort, Remaining Work |
| **Agile** | User Story | Task | Story Points, Original Estimate |
| **Basic** | Issue | Task | Effort |
| **CMMI** | Requirement | Task | Size, Original Estimate |

### Detect Template

1. Use `ado/wit_get_work_item` to fetch an existing work item and check its type
2. Or search work items with `ado/search_workitem` and identify by returned types:
   - If you find "Product Backlog Item" → Scrum
   - If you find "User Story" → Agile
   - If you find "Issue" (without PBI/US) → Basic
   - If you find "Requirement" → CMMI
3. If no work items are found or you cannot identify, ask the user:
   ```
   Which process template does the Azure DevOps project use?
   
   [S] Scrum (Product Backlog Item)
   [A] Agile (User Story)
   [B] Basic (Issue)
   [C] CMMI (Requirement)
   ```

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
