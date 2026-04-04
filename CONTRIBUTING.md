# Contributing

First off, thanks for taking the time to contribute!

All types of contributions are encouraged and valued. See the [Table of Contents](#table-of-contents) for different ways to help and details about how this project handles them. Please make sure to read the relevant section before making your contribution.

## Table of Contents

* [Code of Conduct](#code-of-conduct)
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

* Assign an issue to yourself before beginning any effort.
* If an issue for your contribution does not exist, [file an issue](https://github.com/microsoft/devsquad-copilot/issues/new) first.
* Commits should reference related issues for traceability (e.g., "Fixes #123").

### Improving The Documentation

Documentation improvements follow the same process as code contributions. If you see issues with the documentation, open an issue or submit a pull request directly.

## Project Structure

```
.github/
  agents/          # Custom agents (.agent.md)
  skills/          # Agent skills (SKILL.md per directory)
  instructions/    # Path-specific instructions (.instructions.md)
  hooks/           # Session hooks (hooks.json + scripts)
  docs/            # Internal documentation
docs/
  framework/
    decisions/     # Architecture Decision Records
    images/        # Framework diagrams
  templates/       # Templates distributed to consumer repos
  features/        # Feature specifications
  architecture/    # Architecture Decision Records
  envisioning/     # Vision documents
docs-site/         # Published documentation site (source of truth for guides)
```

### Contribution Areas

| Area | Location | Description |
|------|----------|-------------|
| Agents | `.github/plugins/devsquad/agents/` (symlinked at `.github/agents/`) | Specialized agents for each delivery phase |
| Skills | `.github/plugins/devsquad/skills/` (symlinked at `.github/skills/`) | Reusable capabilities activated by semantic matching |
| Instructions | `.github/instructions/` | Path-specific rules applied automatically by glob pattern |
| Hooks | `.github/plugins/devsquad/hooks/` | Session lifecycle scripts (sessionStart, preToolUse, etc.) |
| Templates | `docs/templates/` | Files distributed to consumer projects via `devsquad.init` |
| Documentation | [docs-site](https://microsoft.github.io/devsquad-copilot/) | Framework architecture, component guides, extensibility |
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
* See the [documentation-style skill](.github/skills/documentation-style/SKILL.md) for complete formatting rules

## Pull Request Process

1. Create a branch from `main` with a descriptive name.
2. Make your changes following the style guides above.
3. Ensure your changes do not break existing functionality.
4. Update relevant documentation if your changes affect it.
5. Open a pull request with a clear title and description.
6. Link related issues using GitHub closing keywords (e.g., "Fixes #42").
7. Wait for review. All PRs require at least one reviewer approval before merge.

## Attribution

This guide is based on [contributing.md](https://contributing.md/).
