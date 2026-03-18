---
name: quality-gate
description: Quality gate for SDD artifacts (specs, ADRs, tasks, code). Use when generating or updating specs, ADRs, task decomposition, or code implementation to validate quality before delivering to the user. Do not use for linting, code formatting, human code review, or validation of intermediate artifacts marked as draft/WIP.
---

# Quality Gate — SDD Artifact Validation

## Principle

SDD artifacts propagate quality downstream: a vague spec generates ambiguous tasks that generate incorrect code. Evaluating quality at the point of creation is cheaper than fixing it later.

## When to Use

Use this skill **after generating an artifact and before presenting it to the user**:

| Agent | Artifact | Activate when |
|-------|----------|---------------|
| `devsquad.specify` | spec.md | Spec generated or updated |
| `devsquad.plan` | ADRs, plan.md | ADR created or plan finalized |
| `devsquad.decompose` | tasks.md, work items | Task decomposition completed |
| `devsquad.implement` | Code | Medium or high impact task implemented |

**Do not use for**: low impact tasks (typo, log, formatting), intermediate artifacts that will be reviewed manually, or when the user explicitly asks to skip validation.

## General Flow

```
Generate artifact → Evaluate against rubric → Identify failures → Fix → Re-evaluate (if needed) → Deliver
```

Maximum of **2 correction iterations**. If after 2 attempts there are still failures, deliver the artifact with documented failures for human decision.

## Evaluation Levels

Evaluation depth scales with the artifact's risk. Use the classification from the `complexity-analysis` skill when available, or infer from context.

| Level | When | What to evaluate |
|-------|------|------------------|
| **Quick** | Low impact, established pattern | Only critical criteria (immediate FAIL) |
| **Standard** | Medium impact, most artifacts | Complete rubric for the artifact type |
| **Deep** | High impact, high risk, first time | Complete rubric + cross-verification with related artifacts |

---

## Rubrics by Artifact Type

Each artifact type has a dedicated rubric. Read **only** the rubric for the artifact being evaluated:

| Artifact | Rubric |
|----------|--------|
| spec.md | Read `references/rubrica-spec.md` |
| ADR | Read `references/rubrica-adr.md` |
| tasks.md / work items | Read `references/rubrica-tasks.md` |
| Code (implementation) | Read `references/rubrica-code.md` |

---

## Output Format

After evaluation, present the result in a compact form. Adapt to the evaluation level.

### If ALL critical criteria pass

```
Evaluation: [artifact type]
Result: OK (N/N critical criteria pass)
Alerts: [list quality criteria that failed, if any]
```

Proceed with delivery to the user.

### If any critical criterion FAILS

```
Evaluation: [artifact type]
Result: FAILURES FOUND

Critical:
- [ID]: [dimension] — [what is wrong] → [how to fix]

Quality:
- [ID]: [dimension] — [observation]

Fixing automatically...
```

Fix the critical issues, re-evaluate, and only then deliver.

### If failures persist after 2 iterations

```
Evaluation: [artifact type]
Result: PERSISTENT FAILURES (after 2 correction attempts)

Unresolved failures:
- [ID]: [dimension] — [description] — Reason: [why it could not be resolved]

Action needed: Human decision on how to proceed.
```

Deliver the artifact with documented failures.

---

## Convergence and Limits

| Parameter | Value | Justification |
|-----------|-------|---------------|
| Max correction iterations | 2 | Avoid infinite loop. If 2 attempts don't resolve it, the problem requires human intervention. |
| Timeout per evaluation | Proportional to artifact | Spec: evaluate all dimensions. Task with 50 items: 30% sampling. |
| Sampling for tasks | If > 20 tasks, evaluate 100% of critical criteria + 30% sample for quality | Balance between coverage and context cost. |

## When NOT to Evaluate

- User explicitly asked to skip: "generate directly", "no validation"
- Artifact is a declared draft: "draft", "WIP", "exploratory"
- Re-evaluation of an artifact that already passed (unless it has been modified)

## Anti-patterns

- Do not invent problems to seem useful. If the artifact is good, say "OK" and move on.
- Do not evaluate style or formatting that is already covered by markdownlint or existing linters.
- Do not block delivery for quality criteria (only critical criteria block).
- Do not re-evaluate infinitely: maximum 2 iterations, then escalate to human.
- Do not evaluate artifacts outside the scope of the current agent (e.g., devsquad.specify does not evaluate tasks).
