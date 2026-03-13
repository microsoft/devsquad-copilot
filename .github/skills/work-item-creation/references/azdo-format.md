# Azure DevOps Format

## Work Item Types per Process Template

| Process Template | User Story Type | Task Type |
|------------------|-----------------|-----------|
| **Scrum** | Product Backlog Item | Task |
| **Agile** | User Story | Task |
| **Basic** | Issue | Task |
| **CMMI** | Requirement | Task |

## Epics

- **Type**: Epic
- **Tags**: `copilot-generated`, `ai-model:<name>`

## Features

- **Type**: Feature
- **Priority**: 1/2/3
- **Tags**: `copilot-generated`, `ai-model:<name>`
- **Parent**: use `ado/wit_add_child_work_items`

## User Stories (or equivalent)

- **Title**: `[<feature>] <user story title>`
- **Tags**: `copilot-generated`, `ai-model:<name>`, `feature:<name>`, `priority:<p1|p2|p3>`
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

### Template-specific fields

| Template | Estimate Field | Priority Field | Risk Field |
|----------|---------------|----------------|------------|
| Scrum | Effort | Priority (1-4) | Risk (1-Low, 2-Medium, 3-High) |
| Agile | Story Points | Priority (1-4) | Risk (1-Low, 2-Medium, 3-High) |
| Basic | Effort | Priority (1-4) | - |
| CMMI | Size | Priority (1-4) | Risk |

**Priority mapping**: P1=1, P2=2, P3=3

## Tasks

- **Title**: `[<feature>] <short task description>`
- **Tags**: `copilot-generated`, `ai-model:<name>`, `feature:<name>`, `phase:<phase>`
- **Description**:
  ```
  Feature: [feature name]
  Phase: [phase]

  ## Description
  [Full task description]

  ## Files
  - [file/path]
  ```

### Template-specific fields

| Template | Estimate Fields | Activity Field |
|----------|----------------|----------------|
| Scrum | Remaining Work | Activity (Development, Testing, etc.) |
| Agile | Original Estimate, Remaining Work | Activity |
| Basic | Remaining Work | - |
| CMMI | Original Estimate, Remaining Work | Discipline |

## Missing ADRs

| Classification | Required tags | Title |
|----------------|---------------|-------|
| cross-cutting | `type:adr`, `scope:cross-cutting`, `copilot-generated`, `ai-model:<model>` | `[ADR] <domain>` |
| feature-scoped | `type:adr`, `scope:feature-scoped`, `feature:<name>`, `copilot-generated`, `ai-model:<model>` | `[<feature>][ADR] <domain>` |

## Tech Debt

- **Required tags**: `type:tech-debt`, `severity:<high|medium|low>`, `copilot-generated`, `ai-model:<model>`
- **Work Item Type**: Bug (or Issue in Basic template)
- **Title**: `[Tech Debt] <concise description>`
- **Body**: same format as GitHub section (see `references/github-format.md`)

## Azure DevOps Hierarchy

- **Parent-Child**: use `ado/wit_add_child_work_items`
- **Dependencies**: use `ado/wit_work_items_link` with link type `Predecessor`/`Successor`
