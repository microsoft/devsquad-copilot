---
name: 'Architecture Decision Records'
description: 'Guidelines for creating and managing ADRs'
applyTo: 'docs/architecture/decisions/*.md'
---

When editing Architecture Decision Records (ADRs), follow these rules:

- Use the template at `docs/architecture/decisions/ADR-TEMPLATE.md`.
- File naming: `NNNN-domain.md` (use the decision domain, not the choice made).
- ADR title = domain (e.g., "Data Persistence", not "Use PostgreSQL").
- Required fields: Status, Date, Context, Priorities and Requirements (ranked), Options considered (evaluated against priorities), Decision.
- Priorities must be defined BEFORE listing options. Options are evaluated against each priority.
- Do not use generic pros/cons lists. Evaluate each option against the ranked priorities.
- Valid statuses: Proposed, Accepted, Superseded by NNNN.
- ADRs must be created with Status `Proposed` and reviewed by at least one other team member before moving to `Accepted`. The agent must warn when the user tries to accept an ADR without review.
- Options should preferably come from the user, not invented by the agent.
- Never infer options from templates, generic READMEs, or placeholder content.
- Follow the formatting rules in the `documentation-style` skill.
