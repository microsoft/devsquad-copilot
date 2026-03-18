---
name: reasoning
description: Record decisions and justifications during SDD agent execution, and pass structured context between agents via handoff envelope. Use when an agent needs to document decisions made (Reasoning Log) or perform a handoff to another agent. Do not use for architecture documentation (use ADRs), complexity analysis (use complexity-analysis), or debug logs.
---

# Reasoning Explainability

Guidelines for making SDD agent reasoning auditable and traceable.

Two complementary mechanisms:

1. **Reasoning Log**: Structured record of decisions made by an agent during its execution.
2. **Handoff Envelope**: Structured context passed from one agent to another during handoff.

## Reasoning Log

Upon completing execution and **before creating artifacts**, present the user with a summary of decisions made.

### Reasoning Log Format

```text
## Reasoning

### Decisions

| # | Decision | Applied principle | Alternatives considered | Justification | Confidence |
|---|----------|-------------------|------------------------|---------------|------------|
| 1 | [what was decided] | [principle or heuristic that guided the choice] | [discarded options] | [why this choice] | [High/Medium/Low] |

### Assumptions

- [assumption made and basis for it]

### Missing information

- [data that was missing and how it impacts the decisions above]
```

#### "Applied principle" column

Connects each decision to the reusable foundation that guided it. The goal is to make **engineering judgment** visible — not just *what* was decided, but *what reasoning pattern* was used.

Examples of principles:

| Type | Example |
|------|---------|
| Design | "Separation of concerns", "Fail-fast", "Idempotency" |
| Trade-off | "Latency vs consistency", "Simplicity vs extensibility" |
| Operational | "Observability in production", "Graceful degradation" |
| Security | "Principle of least privilege", "Defense in depth" |
| Pragmatic | "YAGNI", "Rule of 3 uses before abstracting" |

**Rules:**
- Fill in only when the principle is not obvious from the justification. If the justification already contains the rationale, use "—".
- Use direct language, not academic jargon. "Fail-fast to detect errors early" is better than "Application of the rapid failure principle per the defensive paradigm".
- Project principles (defined in `coding-guidelines.md` or ADRs) take priority over generic industry principles.

### Confidence Levels

| Level | Criterion | Expectation |
|-------|----------|-------------|
| **High** | Based on explicit requirement, concrete data, or validated decision (accepted ADR, approved spec) | Does not require additional validation |
| **Medium** | Inferred from existing context (envisioning, project patterns) without explicit validation | Validate with stakeholder before depending on this decision |
| **Low** | Reasonable assumption without direct evidence; industry standard applied due to lack of information | Requires validation before proceeding; mark what is needed to raise confidence |

### Reasoning Log Rules

- Trivial decisions (formatting, already established conventions) do not need to be recorded.
- For **Medium** or **Low** confidence, include what is needed to raise the level.
- If there were no significant decisions, omit the section (do not force reasoning where none exists).
- Keep it concise: 3-8 decisions per execution is expected. If there are more, group related decisions.

## Handoff Envelope

When performing a handoff to another agent, include a structured context block **along with the handoff prompt**.

### Handoff Envelope Format

```text
### Handoff Context

**Relevant artifacts**: [list of files the next agent should read]
**Inherited assumptions**:
- [assumption the upstream agent made that influences the downstream]

**Pending decisions** (for the next agent to resolve):
- [decision that was left open and why]

**Discarded information**:
- [context or alternative that was considered and discarded, with reason]
```

### Handoff Envelope Rules

- Include only information that **impacts** the next agent's work. Do not repeat what is already in the artifacts.
- If there are no inherited assumptions or pending decisions, omit those subsections.
- The envelope complements (does not replace) the user's original input.

## Application by Agent Type

### Agents that produce persistent artifacts

`sdd.envision`, `sdd.kickoff`, `sdd.specify`, `sdd.plan`, `sdd.decompose`, `sdd.implement`, `sdd.security`

- Present Reasoning Log **before** creating/saving artifacts.
- The user can question decisions before they become artifacts.

### Analysis agents (read-only)

`sdd.sprint`, `sdd.refine`

- Integrate reasoning **inline** in the analysis (e.g., "Classified as 'Not ready' because [evidence]").
- Do not use a separate section; the reasoning is the output itself.

### Conductor

`sdd`

- When the intent is not obvious (multiple agents could handle it), briefly document the rationale:

  ```text
  Interpreted "[input]" as [intent] because [reason].
  Delegating to [agent].
  ```

- When the intent is clear, do not add overhead — delegate directly.
