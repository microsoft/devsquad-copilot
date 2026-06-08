# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

In addition to the standard Keep a Changelog categories, this project uses two
compatibility-focused categories that always appear at the top of a release:

- **Breaking / Migration Required** for behavior changes consumers cannot ignore.
- **Template changes (consumer action required)** for edits to files distributed
  by `sdd-init.sh` that consumers must re-run `update-all` to pick up.

See `CONTRIBUTING.md` for full conventions.

## [Unreleased]

### Added (Agent Intent Governance — selective Architecture of Intent adoption)

Closes three structural gaps in the framework: framework agents had no explicit behavioral envelope (a reviewer reading `devsquad.implement.agent.md` could not determine in under a minute what the agent was authorized to do, must never do, or how it composes sub-agents); consumer specs describing AI capabilities had no canonical fragment for operational cost commitments; the failure-diagnosis surface had no taxonomy mapping a failure to the upstream artifact that owns the fix. Vocabulary and discipline drawn from "The Architecture of Intent" by Marcel Aldecoa (`https://marcelaldecoa.github.io/TheArchitectureOfIntent/`). The framework adopts the load-bearing principles and deliberately omits parts of the source vocabulary that add no behavior (see "AoI constructs considered and not adopted" in ADR 0014).

**Agent body conventions:**

- `## Behavioral Constraints` body section on 7 user-facing agents (`devsquad`, `devsquad.implement`, `devsquad.plan`, `devsquad.review`, `devsquad.refine`, `devsquad.specify`, `devsquad.decompose`). Captures rules the runtime `tools:` array cannot enforce (for example, "never APPROVE on a PR", "never commits to integration branch"). Worker sub-agents (`*.execute`, `*.verify`, `*.finalize`, `*.validate`, `*.context`, `*.architecture`, `*.design`, `*.code`, `*.tests`, `*.spec`, `*.adr`, `*.security`, `*.artifacts`, `*.health`) carry no manifest; they inherit their envelope from the parent's composition declaration and from their own `description:` frontmatter, which the runtime surfaces at invocation time.
- `## Composition` body section on 4 coordinator agents (`devsquad.implement`, `devsquad.plan`, `devsquad.review`, `devsquad.refine`). Declares load-bearing cross-component invariants between the coordinator and its typed sub-agents (for example, `validate` runs before `execute` for Medium and High impact tasks; `plan.context` runs before `plan.architecture` and `plan.design`; the parent never downgrades a sub-Guardian's severity finding).

**Template changes (consumer action required):**

- **Feature spec template** (`docs/features/TEMPLATE.md`):
  - New `Spec Evolution Log` section. Required on every spec, with at least one row at creation time. Each amendment adds a row with version, date, change summary, trigger, and author. Trigger values include `failure (spec)`, `failure (validation)`, `failure (agent)`, plus `new work`, `drift`, `external constraint`, or `other (<short reason>)`.
  - New `Describes AI capability: yes | no` field in the Executive Summary.
  - New gated `## AI Cost Posture` section, required only when `Describes AI capability` is `yes`. Five fields: model-tier commitment (Reasoning / Frontier / Mid / Fast per AI step, with one-line rationale), latency budget (p50, p95, p99, behavior on breach), prompt-stability invariant, per-call cost ceiling, cost-incident escalation. Author-facing comment block includes a tier reference (capability profile and typical use per tier) and an N/A pattern for runtime-managed scenarios where the platform picks the model. Non-AI specs see no AI-specific structure.
- **Migration spec template** (`docs/migrations/TEMPLATE.md`):
  - New `Spec Evolution Log` section, same shape as the feature template.
- **Spec instruction files** (`.github/instructions/specs.instructions.md`, `.github/instructions/migration-specs.instructions.md`):
  - New rule requiring the Spec Evolution Log and the three valid `failure (<category>)` trigger values.
  - Feature spec rule additionally requires `Describes AI capability: yes | no` in the Executive Summary and a complete `AI Cost Posture` section when `yes`.
- **Spec quality rubrics** (`rubrica-spec.md`, `rubrica-migration-spec.md`): new criterion checking presence of Spec Evolution Log; feature rubric additionally checks AI Cost Posture completeness when the gate is `yes`.

Consumers running `sdd-init.sh update-all` after upgrading will see these files rewritten (a timestamped `.pre-<version>-<unix>.bak` is saved automatically). Existing specs authored from the previous template remain valid; the Spec Evolution Log and Executive Summary additions are additive and not retroactive.

**Failure-diagnosis surface:**

- `failure-taxonomy.md` reference file added to the `debugging-recovery` skill. Three-category upstream-artifact principle: `failure (spec)` (artifact: `spec.md`, ADR, glossary, or Non-Scope section), `failure (validation)` (artifact: conformance criteria, tests, or rubric file), `failure (agent)` (artifact: agent file body or `agents:` frontmatter, composition declaration, MCP/tool config, or handoff). One worked example shows the spec-vs-validation distinction end-to-end (silent empty-email field in a signup flow).
- `debugging-recovery/SKILL.md` Failure Source Classification step routes agent-originated failures into the three categories before triage.
- `quality-gate/SKILL.md` Recording Failure-Driven Amendments uses the same three categories as canonical Spec Evolution Log trigger values.
- `devsquad.refine.agent.md` Exception gate references the three categories when classifying findings.

**Architecture Decision Record:**

- ADR 0014 "Agent Intent Governance" added at `docs/framework/decisions/0014-agent-intent-governance.md`. Records the structural gaps, the five ranked priorities, the three options considered (full AoI adoption rejected; selective adoption adopted; status quo rejected), the adopted scope (four constructs above), and the AoI constructs considered and explicitly not adopted (custom frontmatter scalars, Reversibility tier, Pattern A/B/C/D/E composition taxonomy, seven-category failure taxonomy, standalone authoring handbook, AoI signal metrics, phase rename).
- ADR list page (`docs/src/content/docs/decisions/index.mdx`) includes ADR 0014 in the published decisions index.

### Not adopted from AoI

The source vocabulary in "The Architecture of Intent" includes constructs this release deliberately omits because they add documentation surface without changing what the framework does in response. The reasoning for each is recorded in ADR 0014 under "AoI constructs considered and not adopted in this option":

- Custom frontmatter scalars (`archetype`, `agency_level`, `autonomy`, `responsibility`, `reversibility`, `oversight_model`).
- Reversibility tier (R1-R4) on spec templates.
- AoI Pattern A/B/C/D/E composition taxonomy labels.
- Seven-category failure taxonomy (collapsed to three).
- Standalone `agent-conventions.md` distributed handbook.
- AoI signal metrics, running scenarios, phase rename.

## [v0.12.0] - 2026-05-09

### Template changes (consumer action required)

- **Feature spec template heading**: `## Compliance Criteria` and `### Compliance Cases` in `docs/features/TEMPLATE.md` are renamed to `## Conformance Criteria` and `### Conformance Cases` so the feature template aligns with the migration template, the spec instructions, and the rubrics. Consumers running `sdd-init.sh update-all` will see the file rewritten (a timestamped `.pre-<version>-<unix>.bak` is saved automatically). Specs already authored from the old template will keep the `Compliance` heading until their owners rename it; agents that parse for `Conformance` will not match those specs until renamed.
- **ADR template evaluation rows**: `docs/architecture/decisions/ADR-TEMPLATE.md` no longer uses `✅ / ❌ / ⚠️` symbols. Authors are now instructed to write whether each option `meets`, `partially meets`, or `fails` each priority. Existing ADRs are not affected.

### Added

- **`sdd-init.sh` template provenance**: each distributed file (except the four copy-source templates that consumers duplicate per artifact) now carries a one-line provenance header recording the originating plugin version and a SHA prefix of the template body.
- **`.github/devsquad/manifest.lock`**: tracks every managed file with `plugin_version`, `template_sha`, and `written_at`. The lock lives alongside `tool-extensions.lock` in the existing `.github/devsquad/` namespace. `sdd-init.sh verify` exposes `recorded_version` per file when a lock entry exists.
- **`update-all --dry-run`**: previews what `sdd-init.sh update-all` would create or update without writing. The default destructive behavior is unchanged so existing automation in `devsquad.init` and the init skills continues to work.
- **Timestamped backups on apply**: `update-all` writes `<target>.pre-<version>-<unix>.bak` before overwriting an existing file, so repeated applies within one plugin version do not collide.
- **`version-parity.yml` workflow**: fails a PR if `.github/plugin/plugin.json`, `.github/plugins/devsquad/.github/plugin/plugin.json`, and `.github/plugin/marketplace.json` disagree on the plugin version.
- **CHANGELOG conventions**: two new categories (`Breaking / Migration Required`, `Template changes (consumer action required)`) documented in `CONTRIBUTING.md` to make compatibility impact explicit on every release.

### Changed

- **`sdd-init.sh` status comparison**: `file_status()` and `cmd_diff` now strip the provenance header from both sides before comparing. Consumer repos that pre-date the header rollout still report `up-to-date` if their body matches; the first `update-all` after upgrade adds the header without flagging spurious drift.
- **`devsquad.specify` agent step name**: a stale `Generate Compliance Criteria` step is renamed to `Generate Conformance Criteria` so the agent matches the rest of its own flow and the rubrics.

### Fixed

- **Work item state transitions skipped during implement**: `work-item-workflow` Phase 1 (assignee + Active) and `devsquad.implement.finalize` board update were treated as advisory and frequently skipped, leaving issues and work items in `New` through the full implement and PR cycle. Source detection in the `work-item-workflow` skill now activates board mode whenever a work item ID is reachable from the user's request, recent conversation, or tasks.md, even when the user phrases the request without an ID. Phase 1 is documented as a precondition in `devsquad.implement` (no code-editing tool runs until the task and parent user story are Active with the current user as assignee). The Assignee check in `work-item-workflow` now names the exact MCP calls (`github/issue_write` with `method: update` and `assignees`, or `ado/wit_update_work_item` with `System.AssignedTo`) and stops on assignment failure rather than silently proceeding. The `devsquad.implement.finalize` worker replaces the soft "update as appropriate" instruction with an explicit state machine (`Active` on start, `Resolved` on PR open, `Closed` on merge) and reports `Board Updated: #<id> <previous> -> <new>` in its structured output so the coordinator can detect skipped transitions.
- **Harness learnings rarely captured automatically**: `harness-learnings` capture was specified as passive bullets in `implement.execute`, `implement.verify`, `review.code`, and `implement.finalize`, conditioned on a "codebase-specific" judgment call, so the agent typically skipped capture unless the user explicitly asked. Each agent now has a `Learning Capture Checkpoint` step with concrete numeric triggers (2+ correction attempts, REGRESSION/COVERAGE_GAP verdict, Major/Critical findings, contradicted human PR feedback) and surfaces a `[Y]/[N]/[E]` prompt (default `[Y]`) before returning output. The skill itself now documents the four auto-prompt sites in a `How This Skill Is Invoked` section.
- **PR body silently failed to auto-close issues**: the `pull-request` skill template showed `Closes #[number]` as a placeholder without explaining that the keyword itself is what triggers GitHub's `closingIssuesReferences`. Spike PRs and PRs authored with `Refs #N` (instead of one of the magic keywords `close/closes/closed/fix/fixes/fixed/resolve/resolves/resolved`) merged cleanly but left the resolved issue open, requiring manual close and board correction. The `pull-request` skill now lists the recognized keywords, distinguishes resolved (`Closes`) from referenced (`Refs`), spells out the spike-PR case, and adds a pre-flight check that verifies the body contains a closing keyword for every work item the PR resolves before calling `github/create_pull_request` or `ado/repo_pull_request_write`. The `devsquad.implement.finalize` worker requires the same pre-flight verification before delegating to the skill.
- **Version drift**: `.github/plugin/marketplace.json` was at `0.11.0` while both `plugin.json` files were at `0.11.1`. Bumped to match.

## [v0.11.1] - 2026-04-29

### Fixed

- **Integration branch protection**: Added three-layer defense against accidental commits and pushes to the integration branch (`main`, `master`, `develop`). The `git-commit` skill now checks the current branch before committing and offers to create a feature branch. The `pull-request` skill guards all push paths (PR creation and push-only) and detects the "PR from integration branch to itself" dead-end. The `copilot-instructions.md` template adds a framework-level rule so the guard applies even outside skill-driven flows.

## [v0.11.0] - 2026-04-28

### Added

- **New skills**: `test-discipline` (pragmatic TDD), `deep-clarification` (decision-tree interview), `domain-glossary` (term extraction and consistency), `triage-workflow` (label-based state machine for issue triage).
- **`devsquad.triage` agent**: orchestrates issue intake, bug reproduction, and state transitions.
- **LSP server detection hook**: sessionStart hook checks for LSP config and seeds `.memory/lsp-status.md` so agents can adapt tool strategy.
- **Pattern anchoring** in `implement.execute`: search the codebase for similar implementations before writing new code.
- **Context budget awareness** in `implement.execute`: compress completed work and request fresh context when conversation grows large.
- **Spec conformance check** in `implement.verify`: verify the diff against acceptance criteria beyond green tests, with `CONFORMANCE_GAP` verdict.
- **Prompt injection guard** in `debugging-recovery`: untrusted content warning before the Localize step.
- **Documentation style rules** in `copilot-instructions.md`: universal coverage for all agents, not only devsquad.
- **Platform-aware PR creation** in `pull-request` skill: detects GitHub vs Azure DevOps from board-config and uses corresponding MCP tools.
- **ADO repo tools** wired into `implement`, `implement.finalize`, `review`, and `refine` agents (`repo_pull_request`, `repo_pull_request_write`, `repo_branch`, `repo_create_branch`, `repo_pull_request_thread`, `repo_pull_request_thread_write`).
- **Conductor routing** for artifact management: branch, commit, push, and PR operations for phase artifacts (envisioning, specs, ADRs) handled directly by the conductor without delegating to implement.
- **Microsoft Clarity analytics** on docs site.

### Changed

- **Mandatory failure capture** in `debugging-recovery`: every resolved fix now captures a structured record to harness-learnings (previously conditional).
- **`implement.execute`**: replaced dogmatic TDD with `test-discipline` skill reference, consolidated Bug Fix Flow.
- **`devsquad.plan`**: added Refactor Mode with `deep-clarification` integration.
- **`devsquad.specify`**: wired `domain-glossary` and `deep-clarification` skills.
- **`devsquad.decompose`**: wired `domain-glossary`, added needs-human count.
- **`work-item-creation` skill**: durability rules, HITL/AFK autonomy classification.
- **Specs instruction**: added vertical slice (tracer bullet) terminology.
- **Tasks instruction**: added tracer-bullet-first guidance.
- **`next-task` skill**: updated ADO PR tool reference to `ado/repo_pull_request`.
- **LSP guidance** in implement and review agents: educational guidance on LSP precision and degraded fallback when unavailable.

### Fixed

- Renamed `memory` to `vscode/memory` in 5 agents (conductor, implement, review, plan, security).
- Removed stale `execute/testFailure` from 3 agents and body references.

## [v0.10.0] - 2026-04-20

### Added

- **`harness-learnings` skill**: Capture and consult codebase-specific learnings across the lifecycle. Agents record patterns discovered through correction loops, review findings, and test prerequisites in `.memory/harness-learnings.md`. Two-tier maturation: fast local capture (Tier 1) with confidence scoring, promotion to permanent harness controls via `devsquad.extend` (Tier 2). See ADR-0013.
- **Hook output contract**: PostToolUse validation hooks now emit structured JSON with `decision`, `reason`, `instructions`, `files`, and `severity` fields, enabling agents to self-correct from hook feedback without interpreting raw output.
- **ADR-0013 (Harness Learnings)**: Architecture decision for `.memory`-based lifecycle learning mechanism, inspired by harness engineering (Fowler 2025, OpenAI 2025).
- **Agent wiring for harness-learnings**: `implement.execute`, `implement.verify`, `review.code`, `refine.health`, `implement.finalize`, and `debugging-recovery` now consult and capture learnings at their natural feedback points.

### Changed

- **`lint-markdown.sh`**: Now emits structured JSON with per-violation fix instructions instead of raw markdownlint output.
- **`validate-work-item-tags.sh`**: Now emits structured JSON with specific tag-addition instructions instead of plain text warnings.
- **`lint-markdown.sh` grep safety**: Wrapped `grep -oE` in a conditional to prevent script termination under `set -e` on unexpected line formats.

## [v0.9.0] - 2026-04-20

### Added

- **Spec amendment during implementation**: when implementation reveals that a spec or ADR no longer matches reality, the implement agent now surfaces a drift flag and offers a scoped amendment instead of silently continuing. The developer confirms, rejects, or defers. See the [concept doc](https://microsoft.github.io/devsquad-copilot/concepts/spec-amendment/).
- **`devsquad.refine` is now invocable mid-implementation** via the `[AMEND]` prompt prefix for scoped spec/ADR edits, in addition to its existing backlog-health role.

### Changed

- **Usage Scenarios tab renamed**: `Feature-first` is now `Scope-stable`. The iterative scenario is now the first tab. Anyone automating against tab labels will need to update.
- **Spec authoring guidance updated**: specs should describe the smallest vertical slice that delivers user-visible value and are now explicitly treated as living artifacts that can be amended mid-flight. Affects what `devsquad.specify` produces.

### Known Limitations (v1 of the amendment seam)

Documented in the concept doc. Relevant if you plan to rely on the new amendment flow:

- After an amendment, `devsquad.decompose` regenerates tasks for the whole feature. Expect task IDs and board items to churn.
- Design artifacts (`plan.md`, `data-model.md`, `contracts/`) are flagged but not auto-updated on high-impact amendments. A manual `devsquad.plan` pass is required before resume.
- Multi-developer concurrency is not guarded. Coordinate manually when another developer is mid-implementation on an amended story.
- No strict mode for regulated contexts. Reject and defer allow continuation under a known-stale spec.

## [v0.8.1] - 2026-04-15

### Fixed

- **MCP config format**: Renamed `servers` to `mcpServers` in plugin `.mcp.json` to match the Copilot CLI schema after `.vscode/mcp.json` support was removed
- **CLI install docs**: Updated getting-started guide with the new two-step marketplace install flow (`copilot plugin marketplace add` + `copilot plugin install`) and deprecated the direct install method

## [v0.8.0] - 2026-04-12

### Added

- **`debugging-recovery` skill**: Structured debugging with stop-the-line rule, 6-step triage checklist (reproduce, localize, reduce, fix, guard, verify), error-specific decision trees, and untrusted error output safety principle
- **Anti-rationalization tables**: Added "Common Rationalizations" sections to 6 skills (`security-review`, `quality-gate`, `git-commit`, `adr-workflow`, `pull-request`, `engineering-practices`) with domain-specific excuses and rebuttals that counter agent shortcut behavior
- **Red Flags sections**: Added observable warning signs to `security-review`, `quality-gate`, and `git-commit` skills for self-monitoring during execution
- **Source verification protocol**: `implement.execute` now verifies version-sensitive framework APIs against official documentation for non-Microsoft stacks, with explicit `UNVERIFIED:` labels when docs cannot be found
- **Scope discipline output**: `implement.execute` output format now includes "Changes made", "Not touched (intentionally)", and "Potential concerns" sections for visible scope tracking

### Changed

- **Prove-It bug fix flow**: Enhanced `implement.execute` bug fix flow to require confirming test failure for the correct reason before fixing, and running full test suite after fix
- **Save-point protocol**: `implement.execute` now commits after each passing task group and reverts to last committed state on failure instead of debugging on top of broken state
- **Review severity labels**: Standardized 4-tier severity system (Critical/Major/Minor/Suggestion) with explicit author actions and finding prefixes across `devsquad.review` coordinator and `devsquad.review.code` worker
- **Chesterton's Fence rule**: `devsquad.review.code` now requires verifying why code exists (via git blame) before recommending removal or simplification
- **`debugging-recovery` reference**: `implement.execute` now references the debugging skill for structured triage instead of unguided "max 2 attempts then escalate"

## [v0.7.2] - 2026-04-08

### Changed

- **Azure DevOps MCP migration**: Replaced local stdio server (`npx @azure-devops/mcp@next`) with the remote HTTP server (`https://mcp.dev.azure.com/`). Authentication now uses Microsoft Entra ID (OAuth) instead of PAT. No local Node.js or `npx` required. Toolsets (`wit`, `work`, `search`, `repos`) are declared via `X-MCP-Toolsets` header. The `ado_org` prompt input has been removed.

## [v0.7.1] - 2026-04-04

### Changed

- Remove duplicated `docs/framework/` content that is fully covered by the [docs-site](https://microsoft.github.io/devsquad-copilot/); only ADRs (`decisions/`) and images are kept
- Consolidate README into a concise landing page that links to the docs-site for details
- Update all stale `docs/framework/` references in agents (`extend`, `conductor`, `envision`), plugin README, CONTRIBUTING, and sync script to point to docs-site URLs
- Add active development banner to all docs-site pages

## [v0.7.0] - 2026-03-29

### Added

- **Nested sub-agent architecture** (ADR 0012): Decomposed 4 monolithic agents into coordinator + worker patterns leveraging VS Code 1.113 nested subagent support (`chat.subagents.allowInvocationsFromSubagents`)
  - `devsquad.review` → coordinator with 5 parallel compliance checkers: `review.spec`, `review.adr`, `review.code`, `review.security`, `review.tests`
  - `devsquad.implement` → coordinator with 4 workers: `implement.validate`, `implement.execute`, `implement.verify`, `implement.finalize` (plus existing `review` sub-agent)
  - `devsquad.plan` → coordinator with 3 workers: `plan.context`, `plan.architecture`, `plan.design` (plus `security` sub-agent)
  - `devsquad.refine` → coordinator with 2 parallel workers: `refine.artifacts`, `refine.health`
- 14 new worker agent files, all with `user-invocable: false` and minimal tool sets
- ADR 0012: Nested Subagent Architecture (Status: Proposed, supersedes ADR 0011)
- `plan` → `security` sub-agent wiring (previously documented but not connected in frontmatter)

### Changed

- Agent Interaction diagrams in `docs/framework/README.md` redesigned: overview diagram with double-bordered coordinator nodes, plus new zoom-in diagram showing worker topology and parallel execution
- `README.md` prerequisites updated: `chat.subagents.allowInvocationsFromSubagents` added as required VS Code setting
- Review Phase 2 (Implementation Validation) replaced with parallel worker delegation instead of sequential inline execution
- Implement orchestration flow updated to reference worker sub-agents for validation, execution, verification, and finalization steps
- Plan execution flow updated with worker delegation for context loading (Step 1), architecture analysis (Step 2), and feature/migration design (Step 4)
- Refine analysis (Step 3) updated with parallel worker delegation for artifact checks and health checks

### Deprecated

- ADR 0011 (Subagent Nesting Resolution): Status changed to Superseded by 0012. The skill-conversion workaround is no longer the primary nesting strategy, though skills created under ADR 0011 remain valid as shared cross-cutting behaviors

## [v0.6.1] - 2026-03-23

### Changed

- **Init deterministic operations**: Replaced ~45K chars of embedded template content in `init-config` and `init-docs` skill references with `sdd-init.sh` shell script that performs file verification, diff, creation, and updates deterministically
  - 14 template files extracted to `hooks/templates/` with directory-based layout mirroring target paths
  - `init-config` and `init-docs` skills rewritten to delegate all file operations to the script
  - `devsquad.init` agent Steps 1-3 updated to use script commands (verify, create, create-missing, update-all, diff)

### Fixed

- **Init plugin recreation bug**: Added Step 0 plugin existence guard and explicit prohibition against creating files under `.github/plugins/` to prevent the LLM agent from recreating the entire plugin structure when `sdd-init.sh` is missing in consumer repos

### Removed

- `init-config/references/templates.md` (548 lines of embedded template content)
- `init-docs/references/templates.md` (822 lines of embedded template content)
- Duplicate template files from `docs/templates/` that overlapped with `hooks/templates/`
- Consumer-facing TEMPLATE files from `docs/` directories (framework repo doesn't need them)

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
