# Estimation and Risk Management

**Status**: Accepted
**Date**: 2026-03-07

## Context

The framework needs a model for estimating user story and task complexity that is useful for decision-making. Isolated numerical estimates (story points, hours) are widely used in the industry, but often become vanity metrics: the team debates whether something is "3 or 5 points" without that distinction changing any decision. The real problem is visibility into uncertainty and risk, not numerical precision.

## Priorities and Requirements (ordered)

1. **Visibility into uncertainty** -- Planning decisions depend on knowing what we *don't* know, not on quantifying what we already know. Unknown risks dominate deviations in software projects.
2. **Actionability** -- The analysis should generate concrete actions (spike, ADR, requirement clarification), not just numbers to fill board fields.
3. **Low maintenance cost** -- The analysis should be quick to produce and update. If it costs more than the value it generates, the team abandons it.
4. **Comparability between stories** -- The team needs to compare relative complexity to decide sprint scope.

## Options considered

### Option 1: Story points (Fibonacci)

Relative scale (1, 2, 3, 5, 8, 13) where the team calibrates by comparison with previous stories. Widely adopted via Scrum.

**Evaluation against priorities**:
- **Visibility into uncertainty**: Weak. An "8" can mean "a lot of known work" or "little work with high uncertainty". The number doesn't distinguish between the two scenarios.
- **Actionability**: Weak. The number doesn't indicate what to do to reduce risk. It doesn't generate actions.
- **Maintenance cost**: Low. Planning poker is fast when the team is calibrated.
- **Comparability**: Good when the team is calibrated. Degrades with turnover.

### Option 2: Estimation in hours/days

Direct temporal estimation. Each task receives an estimated duration.

**Evaluation against priorities**:
- **Visibility into uncertainty**: Weak. Hours estimated for unknown work are inherently imprecise and convey false confidence.
- **Actionability**: Weak. Same limitation as story points.
- **Maintenance cost**: Low to produce, but high to maintain (frequent re-estimations).
- **Comparability**: Intuitive, but misleading. Comparing "3 days" across two stories ignores that one may have high risk and the other zero risk.

### Option 3: Complexity analysis by unknown work

Separate work into known (estimable with confidence) and unknown (risks). For each risk, identify what it is, why it's a risk, and the impact if materialized. Present 2-3 scenarios with trade-offs ("if it goes well" vs "if risks materialize"). Consolidated classification into High/Medium/Low risk.

**Evaluation against priorities**:
- **Visibility into uncertainty**: High. The known/unknown separation makes explicit exactly where the uncertainty lies and enables action on it.
- **Actionability**: High. Each identified risk generates an action: spike for first-time work, ADR for pending decision, clarification for vague requirement.
- **Maintenance cost**: Medium. More elaborate than story points, but the format is structured and the agent assists in production.
- **Comparability**: Good via High/Medium/Low classification. Less granular than numbers, but the lost granularity is the kind that generated unproductive debate.

## Decision

Complexity analysis by unknown work (Option 3). The primary priority is visibility into uncertainty, and this model is the only one that makes explicit where the risk lies and generates concrete actions to reduce it. The accepted trade-off is higher production cost compared to story points, mitigated by the `complexity-analysis` agent's assistance in structuring the analysis.

Explicitly prohibited anti-patterns: giving a number without justification, ignoring risks, presenting a single scenario as "the solution", and claiming confidence that doesn't exist.

### Summary comparison

| Aspect | Story points | Hours/days | Unknown work |
|--------|-------------|------------|--------------|
| Visibility into uncertainty | Weak | Weak | High |
| Actionability | Weak | Weak | High |
| Maintenance cost | Low | Medium | Medium |
| Comparability | Good (calibrated) | Intuitive (misleading) | Good (less granular) |

## References

* `complexity-analysis/SKILL.md` -- skill that implements this model
* `docs/work-items/complexity-analysis.md` -- detailed guide to the analysis structure
