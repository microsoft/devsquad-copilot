---
name: init-config
description: "Verify and create SDD Framework configuration files (.github/copilot-instructions.md, instructions, coding-guidelines, markdownlint). Use when initializing a project or checking if configuration files are up to date. Do not use for documentation templates (use init-docs) or community files (use init-scaffold)."
---

# Init Config

Manage 10 SDD Framework configuration and instruction files.

## Managed Files

| File | Purpose |
|------|---------|
| `.github/copilot-instructions.md` | Pragmatic senior engineer guidelines |
| `.github/instructions/adrs.instructions.md` | ADR creation and management guidelines |
| `.github/instructions/envisioning.instructions.md` | Envisioning document guidelines |
| `.github/instructions/specs.instructions.md` | Feature spec guidelines |
| `.github/instructions/tasks.instructions.md` | Task list guidelines |
| `.github/instructions/migration-specs.instructions.md` | Migration spec guidelines |
| `.github/instructions/migration-tasks.instructions.md` | Migration task guidelines |
| `.github/instructions/documentation-style.instructions.md` | Markdown formatting rules |
| `.github/docs/coding-guidelines.md` | Fundamental values, mandatory rules, code style |
| `.markdownlint.yaml` | Markdown linting configuration |

## Important Constraints

> NEVER create, copy, or recreate files under `.github/plugins/`. The plugin folder is managed externally. If `sdd-init.sh` does not exist, inform the user to install/update the plugin.

## Verification Mode

First verify the script exists, then run it:

```bash
.github/plugins/devsquad/hooks/sdd-init.sh verify
```

Parse the JSON output. Each entry in `config` has `file`, `status` (`up-to-date`, `outdated`, `missing`), and optionally `summary`.

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
