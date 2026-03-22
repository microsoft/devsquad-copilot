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

1. Ensure directories exist: `mkdir -p .github/instructions .github/docs`
2. For each requested file, create with the exact content from the templates in `references/templates.md`
3. To update: delete the existing file (`rm <file>`) and recreate
4. Clean up temporary files: `rm -f /tmp/sdd-init-*`
