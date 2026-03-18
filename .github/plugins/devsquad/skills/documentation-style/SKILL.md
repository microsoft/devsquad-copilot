---
name: documentation-style
description: Formatting and style rules for markdown documentation. Use when generating or editing specs, ADRs, envisioning, tasks, or any project markdown document. Do not use for source code, code comments, commit messages, or work item content.
---

# Documentation Style Guide

This guide defines standards for all documentation generated in the project.

## Formatting

- Ensure there are no spelling errors. Avoid emojis and decorative Unicode characters (such as →, •, ★, ✓, 🎯, ✅).
- Avoid hyphens or dashes as separators between concepts. Instead of "concept A - concept B", rewrite the sentence.
- Prefer lists and tables over long paragraphs.
- Keep documents concise: specs and ADRs should be 1-2 pages, not novels.
- **Never use `#<number>` in free text** (e.g., "#1 priority", "#3 option"). Azure DevOps automatically converts `#<number>` into a work item link. Use "first", "third option", or rephrase the sentence.

## Language

- Avoid promotional or exaggerated language.
- Do not use contrastive constructions:
  - "it's not just X, it's Y"
  - "it's not just about..."
  - "more than just..."
  - "goes beyond..."
- Describe directly what something is, without negating or minimizing alternatives.
- Use active voice and direct sentences.
- Avoid generic framing: if the sentence works in any project without modification, it is not saying anything useful.
  - **Avoid**: rhetorical questions followed by an obvious answer ("The solution? Test everything that matters.")
  - **Prefer**: go straight to the statement with project-specific context.

## Diagrams

- **Mermaid**: use for simple inline diagrams in markdown (flows, sequences, relationships).
  - **GitHub**: use code block with ` ```mermaid ` and close with ` ``` `
  - **Azure DevOps**: use `:::mermaid` and close with `:::`
  - Detect the repository by remote: `git config --get remote.origin.url`
    - If it contains `dev.azure.com` or `visualstudio.com` → Azure DevOps
    - If it contains `github.com` → GitHub
  - **Mandatory conversion**: When creating or editing markdown files, check and convert all Mermaid code blocks to the correct platform format:
    - Azure DevOps: convert ` ```mermaid ` → `:::mermaid` and ` ``` ` → `:::`
    - GitHub: convert `:::mermaid` → ` ```mermaid ` and `:::` → ` ``` `
- **Draw.io**: use for system architecture diagrams or more complex diagrams. Read `references/drawio-guide.md` for creation, export, and recommended workflow instructions.
- Keep diagrams simple: avoid colors, custom styles, icons, and excessive formatting. The focus should be on structure and relationships, not aesthetics.

## Document Structure

- Start with the most important content (conclusion, decision, summary).
- Use consistent hierarchical headings (H1 for title, H2 for main sections).
- Include metadata when relevant (Status, Date, Version).
