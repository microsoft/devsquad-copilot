---
name: init-scaffold
description: "Verify and create community and governance files (SECURITY.md, CONTRIBUTING.md, LICENSE, CODE_OF_CONDUCT.md). Use when initializing a project and the user wants to set up community files. Do not use for SDD Framework configuration files (use init-config) or documentation templates (use init-docs)."
---

# Init Scaffold

Manage 4 optional community and governance files at the repository root:

| File | Purpose |
|------|---------|
| `SECURITY.md` | Security vulnerability reporting policy |
| `CONTRIBUTING.md` | Contribution guidelines for collaborators |
| `LICENSE` | Project license declaration |
| `CODE_OF_CONDUCT.md` | Expected behavior standards |

These files are **optional**.

## Verification Mode

When verifying status, for each file:

1. Check if the file exists at the repository root
2. Return the status:
   - **Exists**: file found (do not compare against a template)
   - **Missing**: file not found

## Guided Creation Mode

When creating files, use the Socratic approach for each file:

### SECURITY.md

Ask:
1. "Who should security vulnerabilities be reported to? (email, team alias, or link)"
2. "What is the expected response timeline? (e.g., acknowledge within 2 business days)"

Generate content based on the template at `docs/templates/SECURITY.md`, replacing `[TODO]` markers with the answers.

### CONTRIBUTING.md

Ask:
1. "What is the project name?"
2. "What is the branch naming convention? (e.g., `feature/description`, `fix/description`)"
3. "What commit message convention do you use? (e.g., Conventional Commits, free-form)"
4. "How many reviewers are required for a PR?"

Generate content based on the template at `docs/templates/CONTRIBUTING.md`, replacing `[TODO]` markers with the answers.

### LICENSE

Ask:
1. "Which license would you like? Common options: MIT, Apache 2.0, GPLv3, BSD, or proprietary/all rights reserved."
2. "What is the copyright holder name? (e.g., organization or individual name)"

Based on the chosen license:
- **MIT**: Generate the full MIT License text with the copyright holder and current year.
- **Apache 2.0**: Generate the full Apache License 2.0 text with the copyright holder and current year.
- **GPLv3**: Generate the full GNU GPLv3 preamble with the copyright holder and current year.
- **BSD 2-Clause**: Generate the full BSD 2-Clause text with the copyright holder and current year.
- **Proprietary**: Generate a simple "All rights reserved" notice with the copyright holder and current year.
- **Skip / Undecided**: Use the placeholder from `docs/templates/LICENSE`.

### CODE_OF_CONDUCT.md

Ask:
1. "Would you like to adopt the Contributor Covenant (widely used standard), or create a custom code of conduct?"
2. "Who should violations be reported to? (email or contact link)"

If Contributor Covenant: Generate the standard Contributor Covenant v2.1 text with the enforcement contact.
If custom: Generate content based on the template at `docs/templates/CODE_OF_CONDUCT.md`, replacing `[TODO]` markers with the answers.

## Batch Mode

When asked to create with `--placeholder` flag, skip all questions and create files directly from the templates in `docs/templates/`, preserving the `[TODO]` markers.

## File Placement

All files are created at the **repository root**:
- `SECURITY.md`
- `CONTRIBUTING.md`
- `LICENSE`
- `CODE_OF_CONDUCT.md`
