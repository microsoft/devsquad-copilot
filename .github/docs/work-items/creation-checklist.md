# Work Item Creation Checklist

Mandatory checklist for EVERY work item created by agents. Applies to user stories, tasks, epics, features, and ADRs.

## Before Creating

1. Check if a similar work item already exists on the board (avoid duplicates)
2. Identify the platform in `.memory/board-config.md`
3. Load platform format:
   - GitHub: `.github/docs/work-items/github.md`
   - Azure DevOps: `.github/docs/work-items/azdo.md`

## Required Tags/Labels (every work item)

| Tag/Label | Required | Description |
|-----------|-------------|-----------|
| `copilot-generated` | Always | Identifies item created by AI |
| `ai-model:<name>` | Always | Model used (see detection below) |

## Tags/Labels by Type

### User Stories

| Tag/Label | Required |
|-----------|-------------|
| `type:user-story` (GitHub) | Yes |
| `feature:<name>` | Yes |
| `priority:<p1\|p2\|p3>` | Yes |

### Tasks

| Tag/Label | Required |
|-----------|-------------|
| `type:task` (GitHub) | Yes |
| `feature:<name>` | Yes |
| `phase:<phase>` | Yes |

### Epics

| Tag/Label | Required |
|-----------|-------------|
| `epic` (GitHub) | Yes |

### Features

| Tag/Label | Required |
|-----------|-------------|
| `feature` (GitHub) | Yes |
| `priority:<p1\|p2\|p3>` | Yes |

### Missing ADRs

| Tag/Label | Required |
|-----------|-------------|
| `type:adr` | Yes |
| `scope:cross-cutting` or `scope:feature-scoped` | Yes |
| `feature:<name>` | Yes (if feature-scoped) |

### Tech Debt

| Tag/Label | Required |
|-----------|-------------|
| `type:tech-debt` | Yes |
| `severity:<high\|medium\|low>` | Yes |
| `feature:<name>` | No (optional, if associated with a feature) |

## Title

- Format: `[<feature>] <description>` (for user stories and tasks)
- Format: `[Epic] <name>` (for epics)
- Format: `[Feature] <name>` (for features)
- Format: `[ADR] <domain>` or `[<feature>][ADR] <domain>` (for ADRs)
- Format: `[Tech Debt] <description>` (for technical debt)

## Hierarchy

- Tasks must be linked as sub-issues/children of the parent User Story
- Features must be linked as children of the parent Epic
- Dependencies between tasks must be documented (body or link)

## AI Model Detection

To fill in `ai-model:<name>`:

1. Try reading Copilot CLI logs:
   ```bash
   grep -h "Using.*model" ~/.copilot/logs/*.log 2>/dev/null | tail -1
   ```
2. If not found, check config:
   ```bash
   cat ~/.copilot/config.json 2>/dev/null | grep -i model
   ```
3. If unable to identify, ask the user:
   ```
   Could not detect the AI model automatically.
   Which model is being used? (e.g., gpt-4o, claude-sonnet-4)
   ```
4. Last resort: use `ai-model:unknown`

## Final Validation

Before submitting the work item, confirm:

- [ ] Title in the correct format
- [ ] All required tags/labels present
- [ ] Body filled in per the platform format
- [ ] Correct hierarchy (parent linked)
- [ ] Not a duplicate of an existing item
