# GitHub Issues Format

## User Stories

- **Required labels**: `copilot-generated`, `ai-model:<name>`, `type:user-story`, `feature:<name>`, `priority:<p1|p2|p3>`
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

## Tasks

- **Required labels**: `copilot-generated`, `ai-model:<name>`, `type:task`, `feature:<name>`, `phase:<phase>`
- **Body**:
  ```markdown
  ## Context

  Feature: [feature name]
  Phase: [phase]

  ## Description

  [Full task description]

  ## Acceptance Criteria

  - [ ] [criterion 1]
  - [ ] [criterion 2]

  ## Files

  - `[file/path]`

  ## Dependencies

  - Depends on: #[dependency issue number] (if any)
  ```

## Epics

- **Title**: `[Epic] [Name]`
- **Labels**: `epic`, `copilot-generated`, `ai-model:<name>`
- **Body**: Description + list of features

## Features (as Issue)

- **Title**: `[Feature] [Name]`
- **Labels**: `feature`, `copilot-generated`, `ai-model:<name>`, `priority:p1/p2/p3`
- **Body**: `Part of #[epic-id]`, dependencies
- **Link as sub-issue**: use `github/sub_issue_write`

## Missing ADRs

| Classification | Required labels | Title |
|----------------|-----------------|-------|
| cross-cutting | `type:adr`, `scope:cross-cutting`, `copilot-generated`, `ai-model:<model>` | `[ADR] <domain>` |
| feature-scoped | `type:adr`, `scope:feature-scoped`, `feature:<name>`, `copilot-generated`, `ai-model:<model>` | `[<feature>][ADR] <domain>` |

## Tech Debt

- **Required labels**: `type:tech-debt`, `severity:<high|medium|low>`, `copilot-generated`, `ai-model:<model>`
- **Title**: `[Tech Debt] <concise description>`
- **Body**:
  ```markdown
  ## Problem
  <What is wrong or suboptimal>

  ## Impact
  <Concrete consequences of not resolving>

  ## Location
  <Files, modules, or affected areas>

  ## Suggested Resolution
  <Recommended approach>
  ```

| Severity | Criteria |
|----------|----------|
| `high` | Blocks evolution, causes recurring bugs, or security risk |
| `medium` | Degrades quality, increases cost of change in active area |
| `low` | Incremental improvement, functional but suboptimal code |

## GitHub Hierarchy

- Use sub-issues for parent-child via `github/sub_issue_write`
- For dependencies between tasks: "Dependencies" section in body (`Depends on: #123`)
