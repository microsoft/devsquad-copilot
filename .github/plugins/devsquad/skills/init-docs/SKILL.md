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

## Important Constraints

> NEVER create, copy, or recreate files under `.github/plugins/`. The plugin folder is managed externally. If `sdd-init.sh` does not exist, inform the user to install/update the plugin.

## Verification Mode

First verify the script exists, then run it:

```bash
.github/plugins/devsquad/hooks/sdd-init.sh verify
```

Parse the JSON output. Each entry in `docs` has `file`, `status` (`up-to-date`, `outdated`, `missing`), and optionally `summary`.

## Creation Mode

To create or update specific files:

```bash
.github/plugins/devsquad/hooks/sdd-init.sh create <target-path>
```

For bulk operations:

```bash
# Create only missing files
.github/plugins/devsquad/hooks/sdd-init.sh create-missing

# Create missing + overwrite outdated
.github/plugins/devsquad/hooks/sdd-init.sh update-all
```

To show a diff for an outdated file:

```bash
.github/plugins/devsquad/hooks/sdd-init.sh diff <target-path>
```
