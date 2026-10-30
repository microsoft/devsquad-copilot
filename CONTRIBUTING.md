# Contributing

First off, thanks for taking the time to contribute!

All types of contributions are encouraged and valued. See the [Table of Contents](#table-of-contents) for different ways to help and details about how this project handles them. Please make sure to read the relevant section before making your contribution.

## Table of Contents

* [Code of Conduct](#code-of-conduct)
* [Vouch System](#vouch-system)
* [I Have a Question](#i-have-a-question)
* [I Want To Contribute](#i-want-to-contribute)
  * [Reporting Bugs](#reporting-bugs)
  * [Suggesting Enhancements](#suggesting-enhancements)
  * [Your First Code Contribution](#your-first-code-contribution)
  * [Improving The Documentation](#improving-the-documentation)
* [Project Structure](#project-structure)
* [Style Guides](#style-guides)
* [Pull Request Process](#pull-request-process)

## Code of Conduct

This project and everyone participating in it is governed by the [Code of Conduct](./CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Vouch System

This project uses a **vouch system** to ensure that code contributions come from people who understand the project and have been reviewed by a maintainer.

### How it works

1. Open a [Discussion](https://github.com/microsoft/devsquad-copilot/discussions) using the **Vouch Request** template.
2. Describe what you want to contribute and why.
3. A maintainer reviews your request and, if approved, adds your username to the vouched contributors list.
4. Once vouched, you can open Pull Requests.

### What does not require a vouch

* Opening issues (bug reports, ideas)
* Asking questions
* Participating in discussions

### Pull Requests without a vouch

PRs from non-vouched contributors are automatically closed with an explanation and a pointer to the Vouch Request discussion template. This is intentional and ensures that contributors have context about the project before submitting code.

### Maintaining the vouch workflows

* Add approved contributors to [`.github/VOUCHED.md`](.github/VOUCHED.md) as one `@username` per line. Matching ignores case and surrounding whitespace but requires the complete username.
* `OWNER`, `MEMBER`, `COLLABORATOR`, and `CONTRIBUTOR` associations remain exempt. Both workflows read the list through the API at the trusted `pull_request_target` workflow commit (`context.sha`). They never check out or execute PR code. A read failure fails the workflow without closing the PR.
* Keep the workflow paths, workflow names, and job names (`check` and `close`) stable so existing status-check references continue to work. Keep `contents: read` in both workflows and grant `pull-requests: write` only to the auto-close workflow.
* Run `node --test .github/tests/vouch-workflows.test.cjs` from the repository root after changing either workflow. The tests require Node.js 20 or later and Ruby with its standard YAML library. They execute the actual inline scripts with controlled GitHub API responses and do not call GitHub or modify PRs.

#### Actions event-policy authorization

GitHub's default event policy will block `pull_request_target` workflows in affected public repositories on **December 2, 2026** unless an applicable policy permits them. Repository-side hardening alone does not grant authorization.

1. Review the [security guidance for `pull_request_target`](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target). Run CodeQL Actions analysis covering privileged and non-privileged untrusted checkouts and checkout time-of-check/time-of-use (TOCTOU) risks, and confirm zero violations for those checks. Alternatively, obtain a review from the security team. An AI review does not replace that approval.
2. Ask an administrator with JIT-enabled repository admin access to configure a narrowly targeted event policy for `.github/workflows/auto-close-pr.yml` and `.github/workflows/block-pr.yml`. Verify organization and enterprise policies too because repository policies cannot override stricter parent policies. Follow [GitHub's workflow execution policy guidance](https://docs.github.com/en/actions/how-tos/administer/control-workflow-execution).
3. Check **Settings > Actions > Policy insights** for blocked and would-be-blocked runs. Validate vouched external contributors, unvouched external contributors, exempt associations, and applicable bot scenarios. Actor restrictions must not prevent the moderation workflows from handling the external PRs they are intended to check.
4. After authorization and merge, confirm that both workflows still run and report the expected checks. Do not treat a skipped or policy-blocked workflow as a successful vouch check.

## I Have a Question

Before you ask a question, please search for existing [Issues](https://github.com/microsoft/devsquad-copilot/issues) that might help you. If you have found a suitable issue and still need clarification, you can write your question in that issue.

If you still need to ask a question:

* Open an [Issue](https://github.com/microsoft/devsquad-copilot/issues/new).
* Provide as much context as you can about what you are running into.

## I Want To Contribute

> ### Legal Notice
>
> When contributing to this project, you must agree that you have authored 100% of the content, that you have the necessary rights to the content and that the content you contribute may be provided under the project license.

### Reporting Bugs

#### Before Submitting a Bug Report

* Make sure that you are using the latest version of the project.
* Check if there is already a bug report for your issue in [GitHub Issues](https://github.com/microsoft/devsquad-copilot/issues).
* Collect information about the bug: expected vs actual behavior, steps to reproduce, and relevant environment details.

#### How Do I Submit a Good Bug Report?

We use GitHub Issues to track bugs and errors. If you run into an issue:

* Open an [Issue](https://github.com/microsoft/devsquad-copilot/issues/new).
* Explain the behavior you would expect and the actual behavior.
* Provide reproduction steps that someone else can follow to recreate the issue.
* Include which agent or skill is affected, and any relevant configuration.

### Suggesting Enhancements

#### Before Submitting an Enhancement

* Make sure that you are using the latest version.
* Read the [README](./README.md) and [framework documentation](https://microsoft.github.io/devsquad-copilot/framework/) carefully to check if the functionality is already covered.
* Search existing [Issues](https://github.com/microsoft/devsquad-copilot/issues) to see if the enhancement has already been suggested.

#### How Do I Submit a Good Enhancement Suggestion?

* Use a **clear and descriptive title** for the issue.
* Provide a **step-by-step description of the suggested enhancement**.
* **Describe the current behavior** and **explain which behavior you expected to see instead**.
* **Explain why this enhancement would be useful** to most users.

### Your First Code Contribution

* **You must be vouched before opening a Pull Request.** See [Vouch System](#vouch-system) for details.
* Assign an issue to yourself before beginning any effort.
* If an issue for your contribution does not exist, [file an issue](https://github.com/microsoft/devsquad-copilot/issues/new) first.
* Commits should reference related issues for traceability (e.g., "Fixes #123").

#### Local Development Setup

Open the repository root in VS Code and register `.github/plugins/devsquad` in `chat.pluginLocations` in **User Settings**, or **Remote Settings** for a remote window. The repository's `.vscode/settings.json` enables plugin support and nested subagents.

For Copilot CLI, run `copilot --plugin-dir .github/plugins/devsquad` from the repository root.

See the [Local Development Setup guide](https://microsoft.github.io/devsquad-copilot/contributing/#local-development-setup) for cloning, the settings example, and verification steps. Develop against the local plugin instead of an installed copy.

### Improving The Documentation

Documentation improvements follow the same process as code contributions. If you see issues with the documentation, open an issue or submit a pull request directly.

## Project Structure

```
.vscode/
  settings.json    # Plugin support and nested subagent settings
.github/
  plugins/devsquad/
    agents/        # Custom agents (.agent.md)
    skills/        # Agent skills (SKILL.md per directory)
    hooks/         # Plugin lifecycle scripts and hooks.json
    .mcp.json      # MCP server configuration
  instructions/    # Path-specific instructions (.instructions.md)
  hooks/           # Workspace hooks referencing plugin scripts
  docs/            # Internal documentation
docs/
  framework/
    decisions/     # Architecture Decision Records
    images/        # Framework diagrams
  templates/       # Templates distributed to consumer repos
  features/        # Feature specifications
  architecture/    # Architecture Decision Records
  envisioning/     # Vision documents
  src/content/docs/ # Published documentation pages (Starlight/Astro)
```

### Contribution Areas

| Area | Location | Description |
|------|----------|-------------|
| Agents | `.github/plugins/devsquad/agents/` | Specialized agents for each delivery phase |
| Skills | `.github/plugins/devsquad/skills/` | Reusable capabilities activated by semantic matching |
| Instructions | `.github/instructions/` | Path-specific rules applied automatically by glob pattern |
| Hooks | `.github/plugins/devsquad/hooks/` | Session lifecycle scripts (sessionStart, preToolUse, etc.) |
| Templates | `docs/templates/` | Files distributed to consumer projects via `devsquad.init` |
| Documentation | `docs/` ([site](https://microsoft.github.io/devsquad-copilot/)) | Framework architecture, component guides, extensibility |
| ADRs | `docs/framework/decisions/` | Architecture Decision Records |

## Style Guides

### Agents

* Naming: `devsquad.<phase>.agent.md`
* Required frontmatter: `description`, `tools`
* Instructions must be procedural and imperative (third person)
* Each agent must have the minimum required tools (principle of least privilege)

### Skills

* Directory name matches the `name` field in SKILL.md frontmatter (kebab-case)
* Required frontmatter: `name`, `description`
* `description` must include when to use and when not to use the skill
* Keep SKILL.md under 500 lines; move bulky context to `references/` or `assets/`

### Instructions

* One instruction per artifact type
* Must include `applyTo` glob pattern in frontmatter
* Content must be concise and actionable rules, not documentation

### Hooks

* Scripts must have a shebang (`#!/bin/bash`) and be executable
* JSON output must be on a single line (validate with `jq -c`)
* Handle errors with descriptive messages on stderr

### Documentation

* All documentation in English
* No emojis or decorative Unicode characters
* Prefer lists and tables over long paragraphs
* See the [documentation-style skill](.github/plugins/devsquad/skills/documentation-style/SKILL.md) for complete formatting rules

### Changelog

The CHANGELOG follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Use the standard categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

Two project-specific categories extend the standard set to make compatibility impact obvious to consumer repos:

* **Breaking / Migration Required** — Behavior changes that consumers cannot ignore. Examples: an agent contract changes shape, a hook output schema bumps incompatibly, a config file moves, the lock file format changes. Each entry must describe the failure mode if the consumer does nothing and the migration step.
* **Template changes (consumer action required)** — Edits to files distributed by `sdd-init.sh` that consumers will need to re-run `update-all` for, plus any artifact-level changes (heading renames, ID prefix shifts) that affect documents already authored from the old template.

Rules:

* Place these two categories above `Added` so a reader scanning the release notes sees compatibility impact first.
* Always pair an entry under either category with a one-line "what to do" for the consumer.
* If a release has no entries in these categories, omit them. Do not leave empty headings.

## Pull Request Process

1. Confirm you have been [vouched](#vouch-system). PRs from non-vouched contributors are automatically closed.
2. Create a branch from `main` with a descriptive name.
3. Make your changes following the style guides above.
4. Ensure your changes do not break existing functionality.
5. Update relevant documentation if your changes affect it.
6. Open a pull request with a clear title and description.
7. Link related issues using GitHub closing keywords (e.g., "Fixes #42").
8. Wait for review. All PRs require at least one reviewer approval before merge.

## Attribution

This guide is based on [contributing.md](https://contributing.md/).
