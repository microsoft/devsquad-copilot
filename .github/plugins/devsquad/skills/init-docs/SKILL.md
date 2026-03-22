---
name: init-docs
description: "Verify and create SDD Framework documentation templates (feature spec, migration spec, envisioning, ADR templates). Use when initializing a project or checking if documentation templates are up to date. Do not use for configuration files (use init-config) or community files (use init-scaffold)."
---

# Init Docs

Manage 4 SDD Framework documentation templates.

## Managed Files

| File | Purpose |
|------|---------|
| `docs/features/TEMPLATE.md` | Feature specification template |
| `docs/migrations/TEMPLATE.md` | Migration specification template |
| `docs/envisioning/TEMPLATE.md` | Envisioning document template |
| `docs/architecture/decisions/ADR-TEMPLATE.md` | Architecture Decision Record template |

## Verification Mode

When verifying status, for each file:

1. Read the existing file in the project
2. Compare with the template in `references/templates.md`
3. To compare, write the template to `/tmp/sdd-init-<name>` and run `diff --unified <existing> /tmp/sdd-init-<name>`
4. Return the status:
   - **Up to date**: file exists and is identical to the template
   - **Outdated**: file exists but has differences (include summary: "X lines added, Y removed")
   - **Missing**: file does not exist

## Creation Mode

When creating or updating files:

1. Ensure directories exist: `mkdir -p docs/features docs/migrations docs/envisioning docs/architecture/decisions`
2. For each requested file, create with the exact content from the templates in `references/templates.md`
3. To update: delete the existing file (`rm <file>`) and recreate
4. Clean up temporary files: `rm -f /tmp/sdd-init-*`
