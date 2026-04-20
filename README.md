<h1 align="center">DevSquad Copilot</h1>

<p align="center">
  <img src="./docs/src/assets/logos/devsquad-logo-medium-transparent.png" alt="DevSquad logo" width="320" />
</p>

A delivery framework for GitHub Copilot with agents that guide teams from **business intent** to **implementation**, keeping the **why**, **what**, and **how** aligned through persistent artifacts and incremental learning.

> [!WARNING]
> This project is under active development. It follows [semantic versioning](https://semver.org/); breaking changes may occur in minor releases until 1.0. See the [changelog](CHANGELOG.md) for release notes.

## Delivery as a Feedback Loop

Specs are sliced thin and revised as you learn. You spec the smallest slice that delivers value, build it, and let what you learn during implementation refine the next slice. The artifact chain (envisioning, spec, ADRs, tasks) is the shared memory that lets multiple developers and agents collaborate without re-deriving context; it is not a gate that must be fully filled in before work begins.

## How it Works

Each turn through the delivery cycle produces a small, reviewable increment and refines the shared understanding captured in persistent artifacts.

1. Before any code is written, the framework suggests starting with an agent that helps you surface the *why*: what are the pain points, business objectives, and what does success look like. That's the *envisioning* phase, and it produces a short document the whole team can align on.

2. **Spec the next slice, not the whole feature.** User stories are prioritized (P1, P2, P3) and independently testable. The framework explicitly prefers the smallest vertical slice that delivers user-visible value, and resists specifying P2/P3 in detail until P1 is implemented and reviewed. The spec captures *what* and *why*, never *how*; not "make it fast", but "p95 latency under 200ms".

3. **Plan only what the current slice needs.** Architecture decisions get recorded as ADRs evaluated against ranked priorities, not generic pros/cons lists. Engineering practices are surfaced through Socratic questions. Decisions are persistent artifacts, not tribal knowledge.

4. **Decompose that slice** into tasks granular enough for a single implementation session, each with clear acceptance criteria. Tasks flow into GitHub Issues or Azure DevOps as real work items.

5. **Implement with TDD discipline.** The implement agent picks up a task, validates it against the spec, classifies impact, writes code test-first, runs the build, and commits with conventional messages. Impact classification scales rigor to risk: low-impact changes proceed directly; high-impact changes require explicit approval and an ADR.

6. **Learn in the open.** When implementation reveals that the spec or an ADR no longer matches reality (a data-model shift, a user-research insight, a technical constraint), the framework treats this as a first-class event. The implement agent suggests amending the affected section, the refine agent applies a scoped update, and the decompose agent regenerates tasks for the feature so they reflect the amended spec. See [Spec Amendment During Implementation](https://microsoft.github.io/devsquad-copilot/concepts/spec-amendment/).

7. **Review in an independent context.** A separate review agent validates the increment against the (amended) spec, ADRs, and plan, catching drift before it compounds. A security agent runs architectural assessments during design and code-level scans during implementation.

8. **Refine continuously.** Between slices and between sprints, the refine agent scans the backlog for staleness and spec/board inconsistencies. Any developer or agent can pick up where someone else left off because every decision is a persistent artifact.

The loop is the unit of delivery. The whole system is orchestrated by a conductor agent that guides developers and agents with Socratic questions, delegates to 13 specialized sub-agents, and keeps every decision traceable from business intent to merged code. And because it's extensible, you can add your own instructions, skills, agents, and hooks for your stack, domain, or organization. The framework adapts to how your team works, not the other way around.

## Design Principles

The framework is shaped by a few deliberate choices about how agents behave, how they're engineered, and how they fit into an existing codebase.

- **Socratic over prescriptive**: agents ask before they act. Scope, engineering practices, and architectural choices are surfaced as questions, not defaults silently applied on the user's behalf.
- **Human-in-the-loop by impact**: autonomy scales with risk. Low-impact changes execute directly, medium ones require a plan, and high-impact changes require explicit approval plus an ADR.
- **Specs are living artifacts**: specs and ADRs are refined as implementation reveals new understanding. The framework has a named seam for amending them mid-flight, so discoveries made during the work update the shared model instead of being silently absorbed or lost.
- **Context isolation by default**: sub-agents run in their own context windows and return only structured results, keeping the main conversation small and decisions traceable.
- **Principle of least privilege**: each agent exposes only the granular tools it needs, not full access to every MCP server. This reduces blast radius and cuts model overhead from oversized tool catalogs during selection.
- **Trusted MCP servers only**: the framework ships with a curated set of [first-party MCP servers](https://microsoft.github.io/devsquad-copilot/core-components/mcp-servers/). No opaque third-party servers are required, which keeps the tool surface reliable and makes enterprise security review straightforward.
- **Decisions as transparent artifacts**: every core architectural choice is documented as an [ADR](https://microsoft.github.io/devsquad-copilot/decisions/) with ranked priorities, evaluated options, and trade-offs, so contributors can trace *why* the framework behaves the way it does.
- **Extensibility without forking**: custom instructions, skills, agents, and hooks layer on top of the framework, so stack or domain adaptations don't require modifying core.
- **Engineering discipline travels with your stack**: test-first implementation, ADRs, security review, quality gates, and source verification are embedded regardless of the language or AI model. Team- and stack-specific coding guidelines live in a file you own (`.github/docs/coding-guidelines.md`) and can be rewritten any time.
- **Minimal dependencies**: no framework-specific CLI, no Python runtime, no language-specific toolchain. Node.js is the only prerequisite, so onboarding and CI setup stay simple across stacks.

## Who is this for?

Teams where multiple developers share decisions, handoffs, and backlog coordination. Projects that need traceability and cross-role visibility through persisted artifacts (specs, ADRs, plans).

This is not a vibe-coding tool. If you are looking for one-shot, fully autonomous code generation without review, this framework will feel like friction, and that friction is intentional.

## Getting Started

See the [Getting Started guide](https://microsoft.github.io/devsquad-copilot/getting-started/) for installation on VS Code and GitHub Copilot CLI, prerequisites, and project initialization.

## Learn More

| | |
|---|---|
| [Full documentation](https://microsoft.github.io/devsquad-copilot/) | Framework architecture, core concepts, delivery guardrails, guides |
| [Agents catalog](https://microsoft.github.io/devsquad-copilot/agents/overview/) | All 13 agents and when to use each one |
| [Extensibility](https://microsoft.github.io/devsquad-copilot/extensibility/) | Add custom instructions, skills, agents, hooks, and tool extensions |
| [Changelog](CHANGELOG.md) | Release notes |
| [Contributing](CONTRIBUTING.md) | How to contribute |
| [Acknowledgments](ACKNOWLEDGMENTS.md) | Inspirations and credits |
