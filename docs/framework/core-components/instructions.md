# Path-specific Instructions

**Location**: `.github/instructions/*.instructions.md`

Instructions automatically applied by Copilot when the context involves files matching the glob defined in the `applyTo` frontmatter. No explicit invocation is needed.

| File | Scope (`applyTo`) | Purpose |
|------|-------------------|---------|
| `specs.instructions.md` | `docs/features/**/spec.md` | Format and required sections for specs |
| `adrs.instructions.md` | `docs/architecture/decisions/*.md` | ADR format with status and traceability |
| `tasks.instructions.md` | `docs/features/**/tasks.md` | Format and rules for task decomposition |
| `envisioning.instructions.md` | `docs/envisioning/**` | Format for envisioning documents |

**Benefit**: Ensures that any edit to specs, ADRs, or tasks (by agent or human) follows the correct format, without relying on inline instructions within agents.
