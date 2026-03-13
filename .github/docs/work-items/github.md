# Work Item Style Guide: GitHub Issues

This guide defines standards for creating work items in GitHub Issues.

For common rules (traceability, labels, delegation), see `.github/docs/work-items/common.md`.

## Default Labels

| Label | Usage |
|-------|-----|
| `copilot-generated` | Item created by AI |
| `ai-model:<name>` | Model used (e.g., `ai-model:gpt-4o`) |
| `epic` | Identifies epic |
| `feature` | Identifies feature |
| `feature:<name>` | Feature name |
| `type:user-story` | User story |
| `type:task` | Task |
| `type:adr` | Missing ADR |
| `type:tech-debt` | Identified technical debt |
| `severity:high` | High severity (blocks evolution) |
| `severity:medium` | Medium severity (degrades quality) |
| `severity:low` | Low severity (incremental improvement) |
| `priority:p1/p2/p3` | Priority |
| `phase:<phase>` | Implementation phase |
| `scope:cross-cutting` | Project-level ADR |
| `scope:feature-scoped` | Feature-level ADR |

### Optional Labels

| Label | Usage |
|-------|-----|
| `parallel` | Parallelizable task |
| `blocked` | Task with unresolved dependencies |
| `copilot-candidate` | Task delegable for autonomous execution |

## Work Item Format

### User Stories

- **Title**: `[<feature>] <user story title>`
- **Required labels**: 
  - `copilot-generated`
  - `ai-model:<model-name>`
  - `type:user-story`
  - `feature:<name>`
  - `priority:<p1|p2|p3>`
- **Body**:
  ```markdown
  ## User Story
  
  As a [persona], I want [action] so that [benefit].
  
  ## Acceptance Criteria
  
  - [ ] [criterion 1]
  - [ ] [criterion 2]
  
  ## Context
  
  Feature: [feature name]
  Priority: [P1/P2/P3]
  Spec: [link to spec.md]
  ```

### Tasks

- **Title**: `[<feature>] <short task description>`
- **Required labels**:
  - `copilot-generated`
  - `ai-model:<model-name>`
  - `type:task`
  - `feature:<name>`
  - `phase:<phase>`
- **Body**:
  ```markdown
  ## Context
  
  Feature: [feature name]
  Phase: [phase]
  
  ## Description
  
  [Complete task description]
  
  ## Acceptance Criteria
  
  - [ ] [criterion 1]
  - [ ] [criterion 2]
  
  ## Files
  
  - `[path/to/file]`
  
  ## Dependencies
  
  - Depends on: #[dependency issue number] (if any)
  ```

### Epics

- **Title**: `[Epic] [Name]`
- **Labels**: `epic`, `copilot-generated`, `ai-model:<name>`
- **Body**: Description + list of features

### Features (as Issue)

- **Title**: `[Feature] [Name]`
- **Labels**: `feature`, `copilot-generated`, `ai-model:<name>`, `priority:p1/p2/p3`
- **Body**: `Part of #[epic-id]`, dependencies
- **Link as sub-issue**: use `github/sub_issue_write` to create parent-child relationship between the epic (parent) and the feature (child)

### Missing ADRs

| Classification | Required labels | Title |
|---------------|---------------------|--------|
| cross-cutting | `type:adr`, `scope:cross-cutting`, `copilot-generated`, `ai-model:<model>` | `[ADR] <domain>` |
| feature-scoped | `type:adr`, `scope:feature-scoped`, `feature:<name>`, `copilot-generated`, `ai-model:<model>` | `[<feature>][ADR] <domain>` |

### Tech Debt

- **Required labels**: `type:tech-debt`, `severity:<high|medium|low>`, `copilot-generated`, `ai-model:<model>`
- **Optional label**: `feature:<name>` (if associated with a specific feature)
- **Title**: `[Tech Debt] <concise description>`
- **Body**:

```markdown
## Problem
<What is wrong or suboptimal in the current code/architecture>

## Impact
<Concrete consequences of not resolving: recurring bugs, high cost of change, etc.>

## Location
<Affected files, modules, or areas>

## Suggested Resolution
<Recommended approach to resolve>
```

| Severity | Criteria |
|------------|-----------|
| `high` | Blocks evolution, causes recurring bugs, or security risk |
| `medium` | Degrades quality, increases cost of change in active area |
| `low` | Incremental improvement, functional but suboptimal code |

## Hierarchy and Relationships

- Use sub-issues for parent-child hierarchy, using `github/sub_issue_write` to create the relationship
- For dependencies between tasks (not parent-child), use the "Dependencies" section in the body
- Format: `Depends on: #123`

## Creation Instructions

### Creation Order

1. First: Create all User Stories
2. Second: Create all Tasks
3. Third: Link Tasks as sub-issues of User Stories via `github/sub_issue_write`
4. Fourth: Add dependencies between tasks (if any)

### Create User Stories

For each user story from spec.md that does not yet exist on the board:

1. Create an issue with title, body, and labels per the format above
2. Note the created issue number to use as parent for tasks

### Create Tasks

For each task that does not yet exist on the board:

1. Create an issue with title, body, and labels per the format above
2. Link as sub-issue of the parent User Story (see "Hierarchy and Relationships" section)
3. Create dependency links between tasks using the "Dependencies" section in the body

**NEVER create duplicate issues**. If a similar task already exists, skip it and record it in the report.
