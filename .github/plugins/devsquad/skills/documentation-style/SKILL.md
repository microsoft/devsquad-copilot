---
name: documentation-style
description: Formatting and style rules for markdown documentation. Use when generating or editing any project markdown document. Do not use for source code, code comments, or commit messages. For work item content (titles, descriptions, comments on GitHub Issues or Azure DevOps), use the Content Style section of the `work-item-creation` skill.
---

# Documentation Style Guide

This guide defines standards for all documentation generated in the project.

## Formatting

- Ensure there are no spelling errors. Avoid emojis and decorative Unicode characters (such as →, •, ★, ✓, 🎯, ✅).
- Do not introduce the em-dash character (Unicode U+2014) in newly written or rewritten Markdown text. Rephrase the sentence instead.
- Avoid semicolons in newly written or rewritten prose. Recast the sentence naturally using a conjunction, a clearer sentence structure, or separate sentences when appropriate. Preserve the original meaning, and avoid turning connected ideas into a series of short, abrupt sentences. Keep semicolons required by code, technical syntax, or verbatim quotations.
- Preserve existing text outside the requested scope. Do not scan or rewrite documents solely to remove existing em dashes or semicolons.
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
- Prefer plain, widely understood vocabulary so non-native English speakers can follow the document. Use "place" or "location" instead of "locus", "use" instead of "utilize", and "make easier" instead of "facilitate" when the meaning is unchanged. Keep precise domain terms, API names, code identifiers, and verbatim quotations. Explain necessary unfamiliar terms on first use instead of replacing them with a less accurate word.
- Avoid generic framing: if the sentence works in any project without modification, it is not saying anything useful.
  - **Avoid**: rhetorical questions followed by an obvious answer ("The solution? Test everything that matters.")
  - **Prefer**: go straight to the statement with project-specific context.

## Names and References

1. Use descriptive headings, scenario names, and plain statements instead of inventing codes for requirements, stories, tasks, assumptions, risks, or review findings. Do not replace numeric codes with another opaque naming scheme.
2. Add formal identifiers only when explicitly requested or required by an established project convention, compliance process, or artifact-specific template or instruction. Current spec templates and verification rules still require requirement and conformance IDs, so preserve those contracts until they are changed together.
3. Reference behavior by its descriptive name and document or section link when available. Use a precise link when names could be ambiguous. Preserve native board IDs, existing ADR numbers, and technical identifiers such as protocol fields and error codes.
4. Keep ordinary numbered procedures and meaningful numeric values. Avoid repeating the same requirement in multiple sections solely to assign it another identifier, while retaining distinct inputs, expected outcomes, and constraints.
5. Apply these defaults to newly written or rewritten text only. Preserve existing identifiers, anchors, and inbound references outside the requested scope. Convert an existing document only within an approved scope that includes its affected references.

## Diagrams

For diagram design, review, tool selection (Mermaid vs Draw.io), and platform rendering rules, use the `diagram-design` skill.

## Document Structure

- Start with the most important content (conclusion, decision, summary).
- Use consistent hierarchical headings (H1 for title, H2 for main sections).
- Include metadata when relevant (Status, Date, Version).
