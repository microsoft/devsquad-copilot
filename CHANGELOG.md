# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [v0.6.0] - 2026-03-22

### Changed

- **Subagent nesting resolution (ADR 0011)**: Converted L2 sub-agents to skills to comply with GitHub Copilot's 1-level subagent nesting limit, enabling the conductor guided mode to work correctly
  - `devsquad.security` workflow extracted to `security-review` skill (consumed by plan, implement, review agents)
  - `devsquad.refine` backlog health checks flattened into `devsquad.sprint` agent
  - `devsquad.init-config` converted to `init-config` skill with `references/templates.md`
  - `devsquad.init-docs` converted to `init-docs` skill with `references/templates.md`
  - `devsquad.init-scaffold` converted to `init-scaffold` skill
  - `devsquad.init` rewritten to use skills instead of sub-agents
  - `devsquad.plan`, `devsquad.review`: removed `agents:` field and `agent` tool, security review now via skill
  - `devsquad.implement`: removed `devsquad.security` from `agents:` (kept `devsquad.review`), security review now via skill
  - `devsquad.sprint`: removed `agents:` field and `agent` tool, backlog health analysis inlined from refine

### Added

- `security-review` skill: STRIDE, OWASP, Azure compliance, GitHub security alerts workflow
- `init-config` skill: SDD Framework configuration file verification and creation
- `init-docs` skill: SDD Framework documentation template verification and creation
- `init-scaffold` skill: Community and governance file creation (SECURITY.md, CONTRIBUTING.md, LICENSE, CODE_OF_CONDUCT.md)
- ADR 0011: Subagent Nesting Resolution documenting the architectural decision

### Removed

- `devsquad.init-config` agent (replaced by `init-config` skill)
- `devsquad.init-docs` agent (replaced by `init-docs` skill)
- `devsquad.init-scaffold` agent (replaced by `init-scaffold` skill)

## [v0.5.0] - 2026-03-21

### Added

- **Migration Specification Support**: Dual-purpose spec system supporting both feature development and infrastructure migration (lift-and-shift, rehost, replatform) scenarios
  - `docs/migrations/TEMPLATE.md`: Migration spec template with System Mapping, Environment Parity, Migration Scenarios (replacing User Stories), Migration Strategy, Data Migration, Cutover Plan, Rollback Plan, NFRs, Conformance Criteria, and Related Specs
  - `docs/templates/migration-spec.md`: Distributed template for consumer repos
  - `.github/instructions/migration-specs.instructions.md`: Path-specific rules for editing migration specs (`docs/migrations/**/spec.md`)
  - `.github/instructions/migration-tasks.instructions.md`: Path-specific rules for editing migration task lists (`docs/migrations/**/tasks.md`)
  - `rubrica-migration-spec.md`: Quality gate rubric with 6 critical criteria (system mapping, data migration, cutover plan, rollback plan, conformance criteria, quantified NFRs) and 7 quality criteria

### Changed

- **`devsquad.specify`**: Spec type detection (feature vs migration) with heuristic-based suggestion from description keywords. Full migration flow: migration short name generation, migration directory creation, migration template loading, migration-specific execution steps, validation, and guidelines
- **`devsquad.plan`**: Context detection for both `docs/features/` and `docs/migrations/`. New Step 4M (Migration Architecture) with infrastructure mapping analysis, data migration architecture, and cutover/rollback architecture. Migration-specific artifact generation (`infra-mapping.md`, `migration-plan.md`). Additional security review triggers for migration scenarios
- **`devsquad.decompose`**: Dual spec loading from features and migrations directories. Migration-specific task generation with 6-phase structure (Setup, Foundational, Infrastructure Provisioning, Data Migration Setup, Cutover Automation, Rollback and Validation, Polish). Migration-specific consistency validation
- **`quality-gate` skill**: Split spec rubric by type (feature vs migration) with directory-based detection
- **`devsquad.init-docs`**: Manages 4 files (was 3). Creates `docs/migrations/` directory and distributes migration spec template to consumer repos
- **`devsquad.init-config`**: Manages 10 files (was 8). Distributes `migration-specs.instructions.md` and `migration-tasks.instructions.md` to consumer repos
- **Feature spec templates**: Added Related Specs section for bidirectional linking with migration specs (both `docs/features/TEMPLATE.md` and `docs/templates/feature-spec.md`)

## [v0.4.0] - 2026-03-20

### Added

- **Tool Extensions [Preview]**: Consumers can inject any MCP server tools (Confluence, Jira, Slack, Datadog, SonarQube, custom APIs) into existing plugin agents via YAML patches and a sync script
  - `sync-tool-extensions.sh`: Generates workspace agent overrides by merging plugin agents with consumer tool-extension YAML files. Multi-platform plugin discovery (Copilot CLI, VS Code) across macOS, Linux, and Windows
  - `detect-tool-extensions.sh`: sessionStart hook that warns when extensions are unsynced, stale, or the plugin version changed
  - Configurable plugin name via `DEVSQUAD_PLUGIN_NAME` for forks, and explicit path override via `DEVSQUAD_PLUGIN_DIR`
  - Tool name validation, atomic writes, overwrite protection for manually-created agent overrides, and empty YAML fail-fast
- **ADR-0010 (Agent Tool Extension)**: Documents the decision to use agent overlay generation over skill bridge, fixed extension port, and native extend YAML approaches
- **`devsquad.extend` agent**: Updated with Tool Extension as a mechanism option, scaffolding steps (MCP config, YAML template, script copy, sync), and quality checklist

### Changed

- **README**: Expanded Extensibility section with prompt examples for all extension mechanisms (instructions, skills, agents, hooks, tool extensions). Moved to its own top-level section after Usage
- **`extensibility.md`**: Added Tool Extensions section with YAML contract, consumer walkthrough, multi-platform plugin discovery table, environment variables reference, and decision guide updates
- **`mcp-servers.md`**: Added cross-reference to Tool Extensions for injecting tools into plugin agents
- **Framework README**: Added ADR-0010 to the ADR table

## [v0.3.0] - 2026-03-19

### Added

- **New skill (`diagram-design`)**: Design and review guidance for architecture diagrams covering readability principles, review checklist, visual design (shapes, colors, accessibility), tool selection (Mermaid vs Draw.io), and mermaid diagram type selection
- **`azure/wellarchitectedframework` tool** added to `devsquad.plan` and `devsquad.security` agents

### Changed

- **Architecture diagrams split**: Replaced the single monolithic diagram (~35 elements) in the framework README with two focused diagrams: Agent Interaction (~17 elements) and Extension Mechanisms (5 elements). Added missing `extend` agent, labeled all arrows, and added legends
- **`documentation-style` skill**: Extracted all diagram-related content to the new `diagram-design` skill. The diagrams section now references `diagram-design` instead of inlining rules
- **Plugin README**: Enhanced with lifecycle flow, integrations, and refined introduction

### Fixed

- **Mermaid line breaks**: Replaced `\n` with `<br/>` in all mermaid diagram labels (mermaid does not interpret `\n` as line breaks)
- **Broken subgraph reference**: Fixed `subagents` subgraph being used as a node source in the architecture diagram

## [v0.2.0] - 2026-03-17

### Changed

- **Agent namespace**: Renamed all `sdd.*` agents to `devsquad.*` namespace
- **Plugin restructure**: Restructured as self-contained plugin for VS Code compatibility
- **README**: Improved storytelling, added audience guide, consolidated usage section

### Fixed

- **Duplicate agents**: Removed symlinks causing duplicate agents in VS Code
- **Plugin install**: Restored root-level `plugin.json` for direct install, added marketplace manifest
- **Mermaid format**: Converted Mermaid blocks to GitHub format
- **Cleanup**: Removed redundant root `.mcp.json` and workspace hooks config

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
