---
name: adr-workflow
description: Complete workflow for creating and managing ADRs (Architecture Decision Records). Includes duplicate checking, status determination, Microsoft documentation lookup, Azure cost estimates, and completeness validation. Use when you need to create or update ADRs during planning. Do not use for decisions that don't need an ADR (use conventions in plan.md).
---

## Creation Flow

### 1. Check for duplicates

Before creating any ADR, check if an ADR already exists in the same domain.

If a Proposed ADR exists: recommend reviewing and accepting the existing one before creating a new one.
If an Accepted ADR exists: if the decision has changed, use "Superseded by NNNN".

Options: `[R]` Review existing / `[S]` Supersede (create new ADR) / `[C]` Create separate (different domain).

### 2. Determine status

If no existing ADR exists in the domain:

- `[A]` Decision already made: ask for the final decision and options considered. Create with Accepted status (but recommend Proposed for team review).
- `[B]` Needs discussion: ask for options to consider. Create with Proposed status.

### 3. Options and recommendations

Options preferably come from the user. Offer suggestions only if:
- The user explicitly asks
- The user has no options or has only 1

Never invent options from templates, generic READMEs, or placeholder content.

### 4. Tool consultation (when available)

**Microsoft Documentation** (for decisions involving Microsoft/Azure services):
- Use `microsoft_docs_search` to look up limits, SLAs, pricing tiers, comparisons
- Use `microsoft_docs_fetch` for full content of relevant pages
- Incorporate data into the ADR options evaluation

**Azure Cost Estimate** (if Azure MCP Server is available):
- Use `azure/pricing` when cost is a ranked priority or the user asks about pricing
- Do not block creation if the tool is unavailable: record "pricing not verified"

**Azure Cloud Architect** (if Azure MCP Server is available and the project deploys to Azure):
- Use `azure/cloudarchitect` (design) for Azure architecture recommendations
- Use `azure/deploy` (architecture diagram) for Mermaid topology diagram
- Present as options for the ADR, not as a final decision
- Options: `[S]` Incorporate / `[M]` Modify first / `[I]` Ignore

### 5. Format and naming

- Template: `docs/architecture/decisions/ADR-TEMPLATE.md`
- Naming: `NNNN-domain.md` (e.g., `0001-data-persistence.md`)
- Use the decision domain, not the choice made (e.g., "Data Persistence", not "Use PostgreSQL")
- Sequential numbering (0001, 0002, etc.)

### 6. Completeness validation

Before considering the ADR complete, verify:
- Context filled in
- At least 2 options documented
- Decision with justification
- Pros and cons for each option

If there are missing fields, request information from the user.
