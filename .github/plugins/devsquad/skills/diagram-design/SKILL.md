---
name: diagram-design
description: Design and review guidance for software architecture diagrams (Mermaid, Draw.io). Use when creating, reviewing, or editing diagrams in documentation, specs, or ADRs. Covers readability, accessibility, notation, abstraction levels, and tool selection (mermaid vs drawio). Do not use for markdown formatting rules (use documentation-style) or for code visualization/debugging.
---

# Diagram Design

## Principles

A diagram exists to help someone understand something. Before creating one, ask: who is the audience and what question does this diagram answer?

- **Business stakeholders** need system context: what the system does, who uses it, what it connects to. Omit internals and technology.
- **Developers** need technical clarity: components, data flows, technology choices.
- A diagram that tries to serve both audiences usually serves neither.

**Zoom, don't cram.** Each diagram should answer one question at one level of abstraction. Use separate diagrams for context, containers, components, and code, like zooming into a map.

**Keep it simple.** When a diagram feels cluttered, split it. Avoid crossing arrows, limit to ~15 elements, and prefer clarity over completeness.

**Every element must be meaningful.** Each box needs a name and a responsibility (one sentence). Add technology labels only for technical audiences. If you cannot describe what an element does, remove it.

**Diagrams complement text.** Add a short paragraph for context the visual cannot convey (why, constraints, what is not shown). Do not repeat in text what the diagram already shows.

## Review Checklist

Apply before considering a diagram done:

1. **Title**: describes what the diagram shows, not a generic label
2. **Legend**: present if the diagram uses colors, shapes, line styles, or icons
3. **Labeled relationships**: every arrow has a verb phrase ("sends events to", "reads from")
4. **Consistent arrow direction**: one convention (data flow or dependency), stated explicitly
5. **Boundaries**: elements that share a deployment unit or logical grouping are visually grouped
6. **No orphan elements**: every element has at least one relationship

## Visual Design

**Shapes** help distinguish element types at a glance (rectangle for services, cylinder for data stores, person for actors, cloud for external systems). Pick a consistent mapping and apply it throughout the project.

**Colors** add information but should not be the only differentiator (~8% of males have color vision deficiency). Pair color with shape, pattern, or label so diagrams remain readable in grayscale. Limit to 4-5 colors, avoid red/green as sole distinguishing pair, and document the mapping in the legend.

**Icons** (Draw.io) add recognition but must complement text labels, not replace them. Use official service icon sets and do not mix providers. Read `references/drawio-guide.md` for creation and export workflow.

## Tool Selection: Mermaid vs Draw.io

| Factor | Mermaid | Draw.io |
|--------|---------|---------|
| Complexity | Simple to medium (< 15 elements) | Medium to complex, or spatial layout matters |
| Icons | No native support | Rich icon libraries (cloud providers, UML) |
| Version control | Text-based diff in markdown | Binary `.drawio` (XML, harder to review) |
| Rendering | Inline in GitHub/Azure DevOps | Exported as `.drawio.png`, referenced as image |

Start with Mermaid. Switch to Draw.io when the diagram needs spatial freedom, icons, or more than ~15 elements.

## Mermaid Diagram Types

| What you want to show | Mermaid type |
|------------------------|-------------|
| System context, containers, components | `C4Context`, `C4Container`, `C4Component` |
| Request/response flow between services | `sequenceDiagram` |
| Process or data flow | `flowchart LR` or `flowchart TD` |
| State transitions | `stateDiagram-v2` |
| Entity relationships | `erDiagram` |
| Class structure | `classDiagram` |

Use `LR` (left-to-right) for flows and pipelines; `TD` (top-down) for hierarchies.

## Mermaid Platform Rendering

Detect from the git remote (`git config --get remote.origin.url`):

- **GitHub** (`github.com`): use code block with ` ```mermaid ` and ` ``` `
- **Azure DevOps** (`dev.azure.com` or `visualstudio.com`): use `:::mermaid` and `:::`

Convert existing Mermaid blocks to the correct platform format when editing markdown files.
