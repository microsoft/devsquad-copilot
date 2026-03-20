# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
