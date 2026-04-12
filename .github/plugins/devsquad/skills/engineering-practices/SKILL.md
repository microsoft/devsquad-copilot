---
name: engineering-practices
description: Socratic guide for engineering practice decisions (DevOps, SRE, CI/CD, branch strategy, observability, IaC). Guides the agent to ask questions based on project context, rather than prescribing solutions. Use during planning of initial features. Do not use for application architecture decisions (use devsquad.plan) or for pipeline/infra creation (use devsquad.implement).
---

## Purpose

Guide the agent to ask the right questions about engineering practices, based on the project context. The agent explores decisions with the user — never prescribes.

Basic practices (CI/CD, tests, code review) are an assumed baseline. This skill focuses on choices that vary by context: which platform, which strategy, which stack.

## Baseline

These practices are expected in any project. Confirm existence before exploring decisions:

- CI/CD pipeline (build + tests + automated deploy)
- Code review via PR/MR
- Automated tests in CI
- Version-controlled code with branching strategy

If any baseline does not exist, flag as a gap:

```
I did not find mention of [practice]. This is expected as baseline.
Does it already exist or does it need to be created?
```

Do not suggest baseline as a decision. If everything is covered, confirm and move on.

## Input

Before exploring decisions, collect the project's operational profile.

### If envisioning exists

Extract:
- Team scale (small/medium/large)
- Domain/industry
- Identified technical pain points
- Non-negotiable constraints and principles

### If envisioning does not exist

Ask:

```
To identify which engineering decisions are relevant, I need to understand:

1. How many developers will work on the project?
2. What domain/industry? (regulated, e-commerce, internal, etc.)
3. Do you already have a defined CI/CD platform? Which one?
4. Do you already have a defined branch strategy? Which one?
```

## Context-Based Exploration Guide

Use this matrix to decide which topics to explore with questions. Do not present topics that have no justification in the context.

### Large scale (50+ devs)

Questions to ask:
- "With this volume of developers, how do you coordinate merges today? Have you considered trunk-based with feature flags?"
- "Is there a CODEOWNERS model or module ownership? How does it work?"
- "Are the CI gates sufficient to prevent breakage in main with so many contributors?"

Topics at play: branch strategy, CODEOWNERS, CI gate rigor.

### Medium scale (10-50 devs)

Questions to ask:
- "What branch strategy do you use? Have you experienced friction with it?"
- "How many approvals do you require on PRs? Does it work well or create a bottleneck?"

Topics at play: branch strategy, level of rigor in PR reviews.

### Small scale (<10 devs)

Just confirm baseline. Do not force complexity where it does not solve any real problem.

### Regulated domain (fintech, healthcare, government)

Questions to ask:
- "What compliance requirements affect the pipeline? Do you need SAST, DAST, dependency scan?"
- "Is there a requirement for environment segregation or audit trail?"
- "Is IaC mandatory by policy or is it the team's choice?"

Topics at play: security gates, IaC, environment segregation, compliance gates.

### Observability pain mentioned

Questions to ask:
- "Do you already have some instrumentation or are you starting from scratch?"
- "What level of observability do you need? Would centralized logs suffice, or do you need distributed tracing?"
- "Have you already chosen an observability SDK/platform, or is that decision still open?"

Topics at play: observability stack, tracing, alerts.

### DevOps/CI-CD pain mentioned

Questions to ask:
- "What CI/CD platform do you use? Is the pain with the platform itself or with the pipeline?"
- "How do you deploy today? Is it manual, partially automated, or fully automated?"
- "Have you had rollback issues? Is there a defined strategy?"

Topics at play: CI/CD platform, deploy strategy, rollback.

### SRE/Operations pain mentioned

Questions to ask:
- "Do you use SLOs/SLIs today? Or is operations reactive?"
- "Is there an incident management process? Runbooks?"
- "What level of operational maturity is the team aiming for?"

Topics at play: SLOs/SLIs, error budgets, runbooks, incident management.

### Cloud deploy

Questions to ask:
- "Will you use IaC? Do you already have a preference between Terraform, Bicep, Pulumi?"
- "How many environments do you need? (dev/staging/prod, or more?)"

Topics at play: IaC approach, environment strategy.

## Classification: ADR vs Convention

After the user responds and decisions emerge, classify each one.

### Requires ADR

At least one criterion present:
- Lock-in: changing later requires rewriting code or migrating data
- Significant cost: impacts the project's monthly budget
- Permeates the code: instrumentation, SDK, patterns that appear in multiple modules
- Cross-team impact: affects other teams or systems

Typical examples: observability stack, IaC approach, CI/CD platform.

### Convention in plan.md

All criteria present:
- Reversible without refactoring
- Does not generate technical lock-in
- Configuration local to the repository

Typical examples: branch strategy, level of rigor in PRs, CODEOWNERS, deploy strategy.

## Presentation Template

After exploring with questions and collecting answers, consolidate:

```
Engineering Practices

Baseline: [confirmed / gap identified in X]

Based on what we discussed, these decisions need to be recorded:

**Decisions with lock-in (ADR recommended)**

1. [Decision name]
   What we discussed: [summary of what the user answered]
   Classification: ADR ([reason]: lock-in / cost / permeates code)

**Team conventions**

2. [Decision name]
   What we discussed: [summary]
   Classification: Convention in plan.md (reversible)

For each item:
[A] Create ADR
[R] Record as convention in plan.md
[I] Not relevant
[D] Discuss more before deciding
```

## Rules

1. Ask before suggesting. Never present a decision as an answer without first exploring the context with the user.
2. CI/CD, tests, and code review are baseline, not a decision. Confirm and move on.
3. Present only topics with justification in the context:
   - Do not explore branch strategy for 3 devs without pain.
   - Do not ask about DAST for a project without exposed endpoints.
   - Do not bring up SLOs for MVP/PoC.
4. If the user answers "we already have everything defined", record and move on.
5. If the signal is absent from the envisioning, ask instead of inferring.
6. When the user decides, present alternatives (minimum 2) only for items classified as ADR.
7. The user can promote any convention to ADR (with [A]).
8. The user can downgrade any ADR to convention (with [R]), but warn if there is lock-in risk.
9. Do not prescribe solutions. The agent's role is to help the user arrive at the decision, not decide for them.

## Section in plan.md

Practices accepted as convention ([R]) are recorded in `plan.md`:

```markdown
## Engineering Practices

| Practice | Decision | Reference |
|----------|----------|-----------|
| Branch Strategy | [e.g., Trunk-based + feature flags] | [ADR-NNNN or "Team convention"] |
| CI/CD | [e.g., GitHub Actions with security gates] | [ADR-NNNN or "Team convention"] |
| Code Review | [e.g., 2 approvals + CODEOWNERS] | [Team convention] |
| Observability | [e.g., OpenTelemetry + Azure Monitor] | [ADR-NNNN] |
| IaC | [e.g., Terraform for all environments] | [ADR-NNNN or "Team convention"] |
```

If no practices were discussed (mature project with everything defined), omit this section.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "CI is too slow, skip it for now" | Optimize the pipeline, do not skip it. A 5-minute pipeline prevents hours of debugging broken integrations. |
| "Manual testing is enough" | Manual testing does not scale, is not repeatable, and cannot guard against regressions. Automate what you can. |
| "We will add CI later" | Projects without CI accumulate broken states. Set it up on day one. |
| "This change is trivial, skip the pipeline" | Trivial changes break builds. CI is fast for trivial changes anyway. |
| "We do not need observability yet" | By the time you need it, you will wish you had set it up months ago. Instrumentation is cheapest to add early. |
