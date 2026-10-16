---
name: 'Documentation Style'
description: 'Formatting and style rules for markdown documentation'
applyTo: 'docs/**/*.md'
---

When editing markdown documentation, follow these formatting rules:

- Ensure there are no spelling errors.
- Do not use emojis or decorative Unicode characters (such as →, •, ★, ✓, 🎯, ✅, ⚠️, ❌).
- Do not introduce the em-dash character (Unicode U+2014) in newly written or rewritten Markdown text. Rephrase the sentence instead.
- Avoid semicolons in newly written or rewritten prose. Recast the sentence naturally using a conjunction, a clearer sentence structure, or separate sentences when appropriate. Preserve the original meaning, and avoid turning connected ideas into a series of short, abrupt sentences. Keep semicolons required by code, technical syntax, or verbatim quotations.
- Preserve existing text outside the requested scope. Do not scan or rewrite documents solely to remove existing em dashes or semicolons.
- Do not use hyphens or dashes as separators between concepts ("concept A - concept B"). Rewrite the sentence.
- Do not use `#<number>` in free text (Azure DevOps converts it to a work item link). Use "first", "third option", etc.
- Do not use promotional language: "it's not just X, it's Y", "goes beyond...", "more than just...". Describe directly.
- Do not use rhetorical questions followed by obvious answers. State the assertion directly.
- Prefer lists and tables over long paragraphs.
- Prefer plain, widely understood vocabulary for non-native English speakers. Follow the `documentation-style` skill for examples and exceptions that preserve technical precision.
- Prefer descriptive names and links over invented identifiers. Follow the `documentation-style` skill for exceptions required by artifact-specific rules and for preserving existing references.
- Mermaid: detect the platform via the remote (`git config --get remote.origin.url`).
  - Azure DevOps (`dev.azure.com` or `visualstudio.com`): use `:::mermaid` and `:::`
  - GitHub (`github.com`): use code block with ` ```mermaid ` and ` ``` `
  - Convert existing blocks to the correct format for the platform.
