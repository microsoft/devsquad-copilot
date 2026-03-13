# Skills

**Location**: `.github/skills/*/SKILL.md`

Skills are loaded by Copilot based on the semantic relevance of their description. Unlike instructions (path-based), skills are activated when the conversation context matches the `description` field in the YAML frontmatter.

| Skill | When it is loaded |
|-------|-------------------|
| `board-config` | Board platform configuration (GitHub Issues vs Azure DevOps) |
| `complexity-analysis` | Estimation or complexity analysis of user stories |
| `documentation-style` | Generation or editing of specs, ADRs, envisioning, tasks, or any markdown document |
| `git-branch` | Branch creation and management for implementation |
| `git-commit` | Commits with Conventional Commits, co-authorship, and work item references |
| `next-task` | Next task suggestion after completing implementation |
| `pull-request` | Finalization with PR, automatic reviews, Copilot review, and merge flow |
| `quality-gate` | Quality validation of specs, ADRs, tasks, and code before delivery |
| `reasoning` | Decision recording (Reasoning Log) and context passing between agents (Handoff Envelope) |
| `engineering-practices` | Proactive engineering practice suggestions (DevOps, SRE, CI/CD, branch strategy, observability) during planning |
| `adr-workflow` | ADR creation and management workflow (duplicate checking, status, Azure/Microsoft lookup, validation) |
| `work-item-creation` | Creation of issues, user stories, tasks with auto-creation of labels |
| `work-item-workflow` | Starting work on an issue/work item (assignee, dependencies, priority, capacity) |

**Benefit**: Specialized knowledge available on-demand without overloading agent context with rules that are not always needed.
