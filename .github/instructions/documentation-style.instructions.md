---
name: 'Documentation Style'
description: 'Formatting and style rules for markdown documentation'
applyTo: 'docs/**/*.md'
---

When editing markdown documentation, follow these formatting rules:

- Ensure there are no spelling errors.
- Do not use emojis or decorative Unicode characters (such as →, •, ★, ✓, 🎯, ✅, ⚠️, ❌).
- Do not use hyphens or dashes as separators between concepts ("concept A - concept B"). Rewrite the sentence.
- Do not use `#<number>` in free text (Azure DevOps converts it to a work item link). Use "first", "third option", etc.
- Do not use promotional language: "it's not just X, it's Y", "goes beyond...", "more than just...". Describe directly.
- Do not use rhetorical questions followed by obvious answers. State the assertion directly.
- Prefer lists and tables over long paragraphs.
- Mermaid: detect the platform via the remote (`git config --get remote.origin.url`).
  - Azure DevOps (`dev.azure.com` or `visualstudio.com`): use `:::mermaid` and `:::`
  - GitHub (`github.com`): use code block with ` ```mermaid ` and ` ``` `
  - Convert existing blocks to the correct format for the platform.
