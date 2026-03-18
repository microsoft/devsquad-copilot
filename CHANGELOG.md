# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [v0.1.0] - 2026-03-13

Initial release of the DevSquad Delivery Framework.

### Added

- **Conductor agent (`devsquad`)**: Unified entry point that guides the developer through all phases with Socratic behavior and delegation to specialized agents
- **16 specialized agents**:
  - `devsquad.init`: Project scaffolding with sub-agents for configuration (`devsquad.init-config`), documentation templates (`devsquad.init-docs`), and community files (`devsquad.init-scaffold`)
  - `devsquad.envision`: Strategic vision capture through structured questions about customer, pain points, goals, and business context
  - `devsquad.kickoff`: Project hierarchy structuring (epics, features, dependencies) with board sync
  - `devsquad.specify`: Feature specification creation from natural language descriptions with requirements clarification
  - `devsquad.plan`: Implementation planning with architecture design, Azure best practices, and cost estimates
  - `devsquad.decompose`: Spec decomposition into user stories, tasks, and work items on GitHub Issues or Azure Boards
  - `devsquad.implement`: Task execution with incremental commits, CI failure diagnosis, and coverage verification
  - `devsquad.security`: Dual-mode security assessment (architectural threat modeling and code vulnerability analysis)
  - `devsquad.review`: Implementation validation against spec, ADRs, and plan with PR inline comments
  - `devsquad.refine`: Backlog health analysis, inconsistency detection, and item readiness classification
  - `devsquad.sprint`: Sprint planning with velocity analysis, adaptive capacity, and committed vs stretch scope
  - `devsquad.extend`: Extension guide for creating custom skills, agents, hooks, and instructions
- **13 skills**: adr-workflow, board-config, complexity-analysis, documentation-style, engineering-practices, git-branch, git-commit, next-task, pull-request, quality-gate, reasoning, work-item-creation, work-item-workflow
- **5 path-specific instructions**: Feature specs, ADRs, task lists, envisioning documents, and documentation style
- **4 session hooks**: Repository platform detection, branching strategy detection (trunk-based vs GitFlow), work item tag validation, and markdown linting
- **5 MCP servers**: GitHub, Azure DevOps, Azure, Microsoft Learn, and Draw.io
- **7 distributed templates**: Feature spec, envisioning, copilot-instructions, SECURITY.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, LICENSE
- **Plugin manifest** (`plugin.json`): Installation via `copilot plugin install`
- **Coding guidelines**: Test doubles hierarchy, behavior coverage criteria, conventional commits, and PR review rubric
- **Framework documentation**: Architecture decisions (agent orchestration, Socratic AI, conductor communication, context management, activation model), core component guides, and extensibility documentation
