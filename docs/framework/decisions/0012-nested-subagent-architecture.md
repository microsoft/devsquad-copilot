# Nested Subagent Architecture

* **Status**: Proposed
* **Date**: 2026-03-29
* **Supersedes**: 0011

## Context

VS Code 1.113 (March 25, 2026) introduced nested subagent support via the `chat.subagents.allowInvocationsFromSubagents` setting. Subagents can now invoke other subagents up to a depth of 5 levels. Copilot CLI supports the same capability.

This removes the platform constraint that motivated ADR 0011 (Subagent Nesting Resolution), which converted L2 agents into skills as a workaround for the 1-level nesting limit. With the constraint lifted, the framework can reconsider its agent topology.

The current architecture uses a flat star topology: one conductor at depth 0, 12 specialized agents at depth 1, and only one nested relationship (`implement` invokes `review` at depth 2). Three agents are monolithic hotspots exceeding 500 lines each (`implement`: 514, `review`: 504, `plan`: 502), performing diverse responsibilities sequentially in a single context window.

An additional economic factor: GitHub Copilot charges 1 premium request per user chat message regardless of how many subagents execute. Decomposing agents into workers has zero marginal cost to users while improving quality through context isolation and parallelism.

Affected agents and their inline responsibilities:

| Agent | Lines | Inline work that could be delegated |
|---|---|---|
| `implement` | 514 | spec validation, impact classification, coding execution, self-verification, review orchestration, PR workflow, CI diagnostics |
| `review` | 504 | spec compliance, ADR compliance, code consistency, security triggers, test/build validation, severity classification, PR publishing |
| `plan` | 502 | context mining, ADR governance, architecture analysis, security assessment, artifact authoring |
| `refine` | ~300 | 8 independent backlog health analysis categories |
| `decompose` | 333 | per-story complexity analysis, task generation, work-item creation |

Additionally, `plan` documents invoking `security` as a sub-agent but the frontmatter lacks the `agents:` and `agent` tool wiring.

## Priorities and Requirements (ordered)

1. **Leverage platform capability** — The nested subagent feature enables patterns previously impossible. The architecture should take advantage of context isolation, parallel execution, and recursive delegation where they improve quality.
2. **Preserve guided mode** — The conductor pattern (ADR 0001) remains the orchestration backbone. Decomposition happens within agents, not at the conductor level.
3. **Zero user cost increase** — Agent decomposition must not increase premium request consumption (1 request per chat message regardless of subagent count).
4. **Context isolation for quality** — Validation/review workers should approach code with clean context (unbiased by prior analysis steps), producing higher-quality independent assessments.
5. **Parallel execution where independent** — Independent subtasks (review categories, plan analysis steps, refine health checks) should run concurrently to reduce latency.
6. **Maintainability** — Worker agents are small, focused, and reusable. Shared logic remains in skills. Workers use `user-invocable: false` to stay out of the user dropdown.
7. **Incremental adoption** — Changes can be delivered per-agent without requiring all agents to decompose simultaneously. Skills created under ADR 0011 remain valid and complement workers.

## Options Considered

### Option 1: Decompose monolithic agents into coordinator + workers

Transform the 3 largest agents into lightweight coordinators that delegate to focused worker sub-agents. Workers are new `.agent.md` files with `user-invocable: false` and minimal tool sets.

Proposed decomposition:

**implement (coordinator)**:
- `implement.validate` (spec validation, impact classification)
- `implement.execute` (coding execution per task/[P] group)
- `implement.verify` (build, lint, test, coverage mapping)
- `review` (already exists, invoked as sub-agent)
- `implement.finalize` (PR creation, board update, next-task)

**review (coordinator)**:
- 5 parallel compliance checkers: spec, ADR, code-consistency, security-trigger, tests-build
- Coordinator merges findings, classifies severity, produces verdict

**plan (coordinator)**:
- `plan.context` (parallel reads: spec, envisioning, ADRs, related specs)
- `plan.architecture` (systemic impact, engineering practices, ADR conflicts)
- `plan.adr-author` (Socratic ADR creation)
- `security` (architectural review, fixing the broken wiring)
- `plan.design` (data model, contracts, research) or `plan.migration` (infra mapping, cutover)

Additionally: fix `plan`'s broken `security` wiring and enable recursive self-reference in `decompose` for complex epics. Enable parallel fan-out in `refine` for its 8 independent health check categories.

Max nesting depth: 3 (conductor -> implement -> review -> review-workers = depth 3 from conductor's perspective, depth 4 total). Well within the platform limit of 5.

**Evaluation against priorities**:
- **Leverage platform capability**: Full use of nesting (depth 4), parallel execution, and recursive delegation.
- **Preserve guided mode**: Conductor is unchanged. L1 agents become coordinators internally.
- **Zero user cost increase**: All workers execute within the same premium request.
- **Context isolation**: Each worker gets a clean context window. Review checkers approach code independently (unbiased).
- **Parallel execution**: Review runs 5 checkers simultaneously. Plan runs context loading in parallel. Refine runs 8 health checks in parallel.
- **Maintainability**: Workers are small and focused (50-100 lines each). Shared logic stays in skills. Worker count increases file count but reduces per-file complexity.
- **Incremental adoption**: Each agent can be decomposed independently. Start with review (clearest parallel win), then implement, then plan.

### Option 2: Keep ADR 0011 skill conversion + selective nesting

Retain the skill-based approach from ADR 0011 for shared workflows (security-review, init-*) and add nesting only where skills are insufficient (implement -> review is already wired).

Only change: fix plan -> security wiring and enable `allowInvocationsFromSubagents` in framework docs.

**Evaluation against priorities**:
- **Leverage platform capability**: Minimal. Only fixes one broken connection and documents the setting. Does not decompose monolithic agents or enable parallel workers.
- **Preserve guided mode**: Fully preserved (no changes).
- **Zero user cost increase**: Yes (no new agents).
- **Context isolation**: Not improved. Plan/implement/review still run everything in one context.
- **Parallel execution**: Not improved. Sequential execution remains.
- **Maintainability**: Same as today. Skills remain the primary reuse mechanism.
- **Incremental adoption**: Already implemented (ADR 0011).

### Option 3: Hierarchical conductor (phase grouping)

Introduce sub-conductors that group agents by lifecycle phase (design, planning, delivery, operations). Top conductor manages 4 phase-conductors instead of 12 agents.

**Evaluation against priorities**:
- **Leverage platform capability**: Uses depth for orchestration tiers, not for worker parallelism.
- **Preserve guided mode**: Preserved but adds orchestration complexity. Phase boundaries must be managed.
- **Zero user cost increase**: Yes.
- **Context isolation**: Improves conductor context pressure but does not address monolithic agent internals.
- **Parallel execution**: Phases are inherently sequential (design before plan, plan before implement). Limited parallel benefit.
- **Maintainability**: Adds 4 new conductor files. Phase boundaries may shift over time, creating maintenance overhead.
- **Incremental adoption**: Requires restructuring all agents simultaneously to assign them to phases.

## Decision

**Option 1: Decompose monolithic agents into coordinator + workers.**

This option maximizes the value of the nested subagent platform capability while preserving the conductor pattern and maintaining zero additional cost to users. The parallel execution model for review (5 concurrent checkers) and the context isolation for workers directly address quality concerns in the current architecture.

Skills created under ADR 0011 remain valid as a complementary pattern. Skills are appropriate for shared cross-cutting workflows (security-review, documentation-style, git-commit). Workers are appropriate for phase-internal subtasks that benefit from context isolation and parallel execution. The two patterns serve different purposes and coexist.

The hierarchical conductor (Option 3) is deferred. It addresses conductor-level context pressure, which is a secondary concern compared to agent-internal monolith decomposition. It can be revisited after Option 1 is validated.

Key trade-off accepted: increased file count (estimated 15-20 new worker agent files) in exchange for reduced per-file complexity and parallel execution capability. This is acceptable because worker files are small (50-100 lines), focused, and follow a consistent pattern.

## Implementation Notes

1. **Setting requirement**: Consumer repos must enable `chat.subagents.allowInvocationsFromSubagents: true`. Document in framework README and consider adding to `.vscode/settings.json` template.
2. **Phase 1 (quick wins)**:
   - Fix `plan` -> `security` wiring (add `agents: ['devsquad.security']` and `agent` tool to plan frontmatter).
   - Enable recursive self-reference in `decompose` for complex epics.
3. **Phase 2 (review decomposition)**: Decompose `review` into coordinator + 5 parallel checkers. Clearest parallel benefit, lowest risk (read-only workers).
4. **Phase 3 (implement decomposition)**: Decompose `implement` into coordinator + 5 workers. Highest complexity, test thoroughly.
5. **Phase 4 (plan decomposition)**: Decompose `plan` into coordinator + artifact workers.
6. **Phase 5 (refine parallel fan-out)**: Decompose `refine` into 8 parallel health check workers.
7. **Worker conventions**: All workers use `user-invocable: false`, minimal tool sets (principle of least privilege), and return structured summaries to their coordinator.
8. **Existing skills preserved**: Skills from ADR 0011 (`security-review`, `init-config`, `init-docs`, `init-scaffold`) remain as shared cross-cutting behaviors. Workers may load these skills internally.
9. **Supersedes ADR 0011**: The skill conversion workaround is no longer the primary nesting strategy. However, the skills themselves remain as reusable artifacts.

## References

- VS Code 1.113 nested subagents: https://code.visualstudio.com/updates/v1_113#_nested-subagents
- Subagents documentation: https://code.visualstudio.com/docs/copilot/agents/subagents
- ADR 0011 (superseded): docs/framework/decisions/0011-subagent-nesting-resolution.md
- ADR 0001 (unchanged): docs/framework/decisions/0001-agent-orchestration.md
- ADR 0002 (unchanged): docs/framework/decisions/0002-conductor-sub-agent-communication.md
- ADR 0003 (unchanged): docs/framework/decisions/0003-context-management.md
