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

For diagram design, review, tool selection (Mermaid vs Draw.io), and platform rendering rules, use the `diagram-design` skill.

## Document Structure

- Start with the most important content (conclusion, decision, summary).
- Use consistent hierarchical headings (H1 for title, H2 for main sections).
- Include metadata when relevant (Status, Date, Version).
