# Work Item Style Guide: Azure DevOps

This guide defines standards for creating work items in Azure DevOps.

For common rules (traceability, tags, delegation), see `.github/docs/work-items/common.md`.

## Default Tags

| Tag | Usage |
|-----|-----|
| `copilot-generated` | Item created by AI |
| `ai-model:<name>` | Model used (e.g., `ai-model:gpt-4o`) |
| `feature:<name>` | Feature name |
| `priority:<p1/p2/p3>` | Priority |
| `phase:<phase>` | Implementation phase |
| `scope:cross-cutting` | Project-level ADR |
| `scope:feature-scoped` | Feature-level ADR |
| `type:tech-debt` | Identified technical debt |
| `severity:high` | High severity (blocks evolution) |
| `severity:medium` | Medium severity (degrades quality) |
| `severity:low` | Low severity (incremental improvement) |

### Optional Tags

| Tag | Usage |
|-----|-----|
| `parallel` | Parallelizable task |
| `blocked` | Task with unresolved dependencies |
| `copilot-candidate` | Task delegable for autonomous execution |

## Work Item Types by Process Template

| Process Template | User Story Type | Task Type |
|------------------|-----------------|-----------|
| **Scrum** | Product Backlog Item | Task |
| **Agile** | User Story | Task |
| **Basic** | Issue | Task |
| **CMMI** | Requirement | Task |

## Work Item Format

### Epics

- **Type**: Epic
- **Title**: Epic name
- **Tags**: `copilot-generated`, `ai-model:<name>`

### Features

- **Type**: Feature
- **Priority**: 1/2/3
- **Tags**: `copilot-generated`, `ai-model:<name>`
- **Parent**: use `ado/wit_add_child_work_items`
- **Dependencies**: use `ado/wit_work_items_link` (Predecessor)

### User Stories (or equivalent)

- **Title**: `[<feature>] <user story title>`
- **Tags**: `copilot-generated`, `ai-model:<model-name>`, `feature:<name>`, `priority:<p1|p2|p3>`
- **Description**:
  ```
  As a [persona], I want [action] so that [benefit].
  
  ## Acceptance Criteria
  - [criterion 1]
  - [criterion 2]
  
  ## Context
  Feature: [feature name]
  Priority: [P1/P2/P3]
  ```
- **Area Path**: Use the project's default area or ask the user
- **Iteration Path**: Ask the user or leave blank

#### Template-specific fields

| Template | Estimate Field | Priority Field | Risk Field |
|----------|--------------------|--------------------|----------------|
| Scrum | Effort | Priority (1-4) | Risk (1-Low, 2-Medium, 3-High) |
| Agile | Story Points | Priority (1-4) | Risk (1-Low, 2-Medium, 3-High) |
| Basic | Effort | Priority (1-4) | - |
| CMMI | Size | Priority (1-4) | Risk |

**Priority mapping**: P1=1, P2=2, P3=3

**Risk mapping**:
- **Low (1)**: Clear requirements, known technology, no external dependencies
- **Medium (2)**: Some uncertainty, internal dependencies, partially new technology
- **High (3)**: Vague requirements, external integrations, new technology, impact on multiple systems

### Tasks

- **Title**: `[<feature>] <short task description>`
- **Tags**: `copilot-generated`, `ai-model:<model-name>`, `feature:<name>`, `phase:<phase>`
- **Description**:
  ```
  Feature: [feature name]
  Phase: [phase]
  
  ## Description
  [Complete task description]
  
  ## Files
  - [path/to/file]
  ```

#### Template-specific fields

| Template | Estimate Fields | Activity Field |
|----------|---------------------|--------------------|
| Scrum | Remaining Work | Activity (Development, Testing, etc.) |
| Agile | Original Estimate, Remaining Work | Activity |
| Basic | Remaining Work | - |
| CMMI | Original Estimate, Remaining Work | Discipline |

### Missing ADRs

| Classification | Required tags | Title |
|---------------|-------------------|--------|
| cross-cutting | `type:adr`, `scope:cross-cutting`, `copilot-generated`, `ai-model:<model>` | `[ADR] <domain>` |
| feature-scoped | `type:adr`, `scope:feature-scoped`, `feature:<name>`, `copilot-generated`, `ai-model:<model>` | `[<feature>][ADR] <domain>` |

### Tech Debt

- **Required tags**: `type:tech-debt`, `severity:<high|medium|low>`, `copilot-generated`, `ai-model:<model>`
- **Optional tag**: `feature:<name>` (if associated with a specific feature)
- **Work Item Type**: Bug (or Issue in the Basic template)
- **Title**: `[Tech Debt] <concise description>`
- **Description**:

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

- **Parent-Child**: use `ado/wit_add_child_work_items`
- **Dependencies**: use `ado/wit_work_items_link` with link type `Predecessor`/`Successor`

## Creation Instructions

### Creation Order

1. First: Create all User Stories (or PBI/Requirement per template)
2. Second: Create all Tasks
3. Third: Link Tasks as children of the corresponding User Stories
4. Fourth: Add Predecessor/Successor links between tasks (if there are dependencies)

### Create User Stories

For each user story from spec.md that does not yet exist on the board:

1. Create a Work Item of the correct type (based on template) with title, description, and tags per the format above
2. Fill in template-specific fields (Effort/Story Points, Priority, Risk)
3. Note the created work item ID to use as parent for tasks

### Create Tasks

For each task that does not yet exist on the board:

1. Create a Work Item of type "Task" with title, description, and tags per the format above
2. Link as child of the parent User Story using `ado/wit_add_child_work_items`
3. Create dependency links between tasks using `ado/wit_work_items_link` (link type: `Predecessor`)

**NEVER create duplicate work items**. If a similar task already exists, skip it and record it in the report.
