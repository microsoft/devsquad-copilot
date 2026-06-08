# Agent Intent Governance

* **Status**: Accepted
* **Date**: 2026-05-14

## Context

The framework ships a suite of delegated executors (`devsquad.*` agents) and instructs consumer repos to author specs that those agents implement. Two structural gaps surfaced while evaluating the discipline described in "The Architecture of Intent" (AoI):

* The framework's own agents (specify, plan, decompose, implement, review, plus the sub-agent fleet) have no explicit behavioral envelope. A reviewer reading `devsquad.implement.agent.md` cannot determine, in under a minute, what the agent is authorized to do, what it must never do (beyond the runtime `tools:` array), and how it composes its sub-agents.
* The spec template (`.github/plugins/devsquad/hooks/templates/docs/features/TEMPLATE.md`) treats every feature as a product feature. Consumer teams using devsquad to spec AI-agent capabilities in their own products have no template fragment for behavioral constraints or operational cost commitments. They either reinvent the structure ad hoc or omit it.

A third, smaller gap exists in the failure-diagnosis surface (`debugging-recovery`, `quality-gate`): there is no upstream-artifact taxonomy that maps a failure to the artifact that should change. Patches accumulate in prompts and agent files instead of in specs or composition declarations.

AoI offers a vocabulary that addresses these gaps directly. The decision is which parts of that vocabulary to adopt, in what scope, with what enforcement.

## Priorities and Requirements (ordered)

1. **Preserve the existing SDD spine** (Envision, Specify, Plan, Decompose, Implement, Review). The phase names, agent IDs, marketplace plugin manifest, and consumer documentation must continue to work without rename or migration.
2. **Close the agent-class governance gap, both internally and externally**. Coordinator agents that own a side-effect surface must declare their behavioral envelope. Consumer specs that embed AI behavior must have a canonical block for operational cost commitments.
3. **Avoid ceremony for non-agent specs**. Most consumer features are product features, not AI capabilities. Forcing AI-specific structure on every spec would generate noise and erode adoption.
4. **Keep changes additive and non-breaking**. Existing specs, ADRs, agents, and consumer repos must remain valid after the change. No mandatory migration scripts.
5. **Make failures diagnosable by upstream artifact**. When an agent misbehaves, the upstream artifact that owns the fix must be identifiable from the failure category, so corrections compound structurally rather than as prompt patches.

## Options Considered

### Option 1: Full AoI adoption (replace template, rename phases, add signal metrics)

Adopt the canonical 12-section AoI spec template wholesale. Rename Envision, Specify, Plan, Decompose, Implement, Review to Frame, Specify, Delegate, Validate, Evolve. Introduce the four AoI signal metrics (spec-gap rate, first-pass validation, cost per correct outcome, oversight load) with telemetry infrastructure to collect them.

**Evaluation against priorities**:

* **Preserve SDD spine**: Fails. Phase rename breaks agent IDs, marketplace manifest, instructions, consumer documentation, and the muscle memory of every adopting team.
* **Close governance gap**: Meets. The 12-section template covers it.
* **Avoid ceremony for non-agent specs**: Fails. AoI's template is built for agent systems; forcing every feature spec through 12 sections including Archetype Declaration adds significant overhead for product-feature specs that do not need it.
* **Additive and non-breaking**: Fails. Wholesale replacement is breaking by definition.
* **Failures diagnosable by upstream artifact**: Meets. AoI's failure taxonomy ships with the framework.

### Option 2: Selective adoption (gated AI block on feature specs, behavioral envelope on agents, upstream-artifact taxonomy)

Adopted. Four targeted constructs layered onto the existing framework:

1. `## Behavioral Constraints` body section on user-facing agents (5 coordinators plus `specify` and `decompose`). Captures rules the runtime `tools:` array cannot enforce (e.g., "never APPROVE on a PR", "never commits to integration branch"). Worker sub-agents carry no manifest; they inherit their envelope from their parent's composition declaration and their own `description:` frontmatter.
2. Spec Evolution Log section in feature and migration spec templates, plus a gated `AI Cost Posture` block in the feature template (model-tier commitment, latency budget, prompt-stability invariant, per-call cost ceiling, cost-incident escalation). The block is gated by `Describes AI capability: yes/no`; when `no`, the block is omitted and the template is unchanged in size for the reader. Behavioral constraints on AI-capability specs use the general `Invariants` section; composition uses the general `Requirements` and `User Scenarios` sections.
3. `## Composition` body section on 4 coordinator agents (`devsquad.implement`, `devsquad.plan`, `devsquad.review`, `devsquad.refine`). Declares load-bearing cross-component invariants between the coordinator and its typed sub-agents. The runtime surfaces each sub-agent's `description:` at invocation time, so the section does not re-list sub-agents.
4. Three-category upstream-artifact failure taxonomy (`failure (spec)`, `failure (validation)`, `failure (agent)`) in `debugging-recovery`, with one worked example showing the spec-vs-validation distinction. Each category maps to one upstream artifact that owns the fix. `quality-gate` consults the same three categories when recording failure-driven amendments in the Spec Evolution Log trigger column.

**Evaluation against priorities**:

* **Preserve SDD spine**: Meets. No phase rename, no agent ID change, no breaking removal.
* **Close governance gap**: Meets. Coordinator agents that own the side-effect surface declare their behavioral envelope. Consumer specs that embed AI behavior have a canonical AI Cost Posture block.
* **Avoid ceremony for non-agent specs**: Meets. The gate keeps non-AI specs unchanged in shape. The only universal addition is the Spec Evolution Log (small, replaces the implicit Status plus Version pair).
* **Additive and non-breaking**: Meets. All additions are optional or gated. Existing specs remain valid.
* **Failures diagnosable by upstream artifact**: Meets. The three-category taxonomy ships as a reference file in `debugging-recovery` and is referenced by `quality-gate`.

**AoI constructs considered and not adopted in this option**:

* Custom frontmatter scalars on agents (`archetype`, `agency_level`, `autonomy`, `responsibility`, `reversibility`, `oversight_model`). The GitHub Copilot runtime does not consume custom frontmatter keys; the scalars would be inert documentation competing for credibility with the operational fields the runtime reads (`name`, `description`, `tools`, `agents`, `handoffs`, `model`). The behavioral envelope ships in body sections instead.
* Reversibility tier (R1-R4) on spec templates. The migration template's existing `Rollback Plan` section captures rollback semantics directly (maximum rollback time, state compatibility). Feature specs use the existing `Compatibility and Transition` section for the same concern. A categorical tier on top of these is taxonomy without behavioral effect.
* AoI Pattern A/B/C/D/E composition taxonomy. The labels carry no behavioral effect; the cross-component invariants in the `## Composition` section carry the actual contract. The labels are AoI vocabulary that ages with the source material rather than the framework's behavior.
* Seven-category failure taxonomy. Multiple AoI categories (Spec Gap, Spec Ambiguity, Scope Expansion) share one upstream artifact (`spec.md`); the finer granularity did not change what the framework does in response. The collapse to three categories preserves the diagnostic discipline without the vocabulary surface area.
* A standalone `agent-conventions.md` distributed handbook. Plugin authors learn from existing agents in the repo's `agents/` directory and from the inline structure of the agent files themselves; a separate handbook duplicates the runtime contract and creates documentation drift.
* AoI signal metrics, running scenarios, phase rename. Out of scope per priority 1 (preserve SDD spine).

### Option 3: Status quo (no AoI adoption)

Leave the framework as is. Document the AoI vocabulary in an internal reference but make no template, agent, or skill changes.

**Evaluation against priorities**:

* **Preserve SDD spine**: Meets trivially.
* **Close governance gap**: Fails. Both gaps persist. Agent files remain opaque about their authority, and consumer agent specs continue to be ad hoc.
* **Avoid ceremony for non-agent specs**: Meets trivially.
* **Additive and non-breaking**: Meets trivially.
* **Failures diagnosable by upstream artifact**: Fails. The upstream-artifact taxonomy gap persists. Corrections continue to accumulate in prompts.

## Decision

Adopt Option 2 (Selective adoption).

Rationale, tied to the ranked priorities:

* Option 2 is the only option that meets priorities 1, 2, 3, 4, and 5 simultaneously. Option 1 sacrifices priorities 1, 3, 4 for marginal gains on priorities 2 and 5 that Option 2 already delivers. Option 3 sacrifices priorities 2 and 5 entirely.
* The framework's strongest property is that it is small and opinionated. Option 2 preserves that property by gating new structure behind a single declaration (`Describes AI capability: yes/no`) and keeping the new agent body sections optional-by-position but present where the agent governs delegated work.
* Self-application is the most defensible adoption. The framework's own agents are exactly the delegated executors AoI is built to govern. The agent governance work and the composition declarations on coordinator agents are the highest-leverage moves available without changing what the framework looks like to a consumer who is not building agent capabilities.

The implementation lands in the framework `CHANGELOG.md` under the next release entry. This ADR is the structural commitment; the CHANGELOG entry is the catalogue of what shipped.

## Implementation Notes

1. All template changes carry the standard provenance header (`<!-- devsquad-template: ... vX.Y.Z sha=... -->`) and require a version bump in both `plugin.json` copies plus a `CHANGELOG.md` entry.
2. The four copy-source templates (`docs/features/TEMPLATE.md`, `docs/migrations/TEMPLATE.md`, `docs/envisioning/TEMPLATE.md`, `docs/architecture/decisions/ADR-TEMPLATE.md`) continue to carry no inline provenance header. The manifest lock remains their sole provenance source.
3. The four constructs in the Decision are independently reviewable. The order between them is enforced by content (body sections must exist before `quality-gate` can enforce them; failure taxonomy must reference agent body fields), not by ADR.
4. The four AoI signal metrics, the running scenarios, the pattern catalog, and the phase rename remain out of scope.

## References

* "The Architecture of Intent" by Marcel Aldecoa, documentation site at `https://marcelaldecoa.github.io/TheArchitectureOfIntent/`
