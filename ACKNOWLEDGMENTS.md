# Acknowledgments

This project was shaped by ideas, patterns, and prior art from many sources across the community. We want to recognize the projects, articles, and resources that influenced the design and direction of the DevSquad Copilot framework.

## Repositories

| Repository | Influence |
|---|---|
| [microsoft/hve-core](https://github.com/microsoft/hve-core) | Patterns for structuring AI-assisted development workflows |
| [github/spec-kit](https://github.com/github/spec-kit) | Spec-driven development approach and tooling conventions |
| [bradygaster/squad](https://github.com/bradygaster/squad) | Agent coordination and team-oriented development model |
| [mgechev/skills-best-practices](https://github.com/mgechev/skills-best-practices) | Best practices for authoring GitHub Copilot skills |
| [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | Agent-driven development methodology and orchestration patterns |
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | Curated collection of GitHub Copilot resources and ecosystem references |

## Research and Papers

| Reference | Influence |
|---|---|
| [Cognitive Engagement in AI-Assisted Software Development](https://dl.acm.org/doi/10.1145/3779312) (ACM) | Evidence supporting the Socratic AI approach in ADR-0005 |
| [How AI Assistance Affects Coding Skills](https://www.anthropic.com/research/AI-assistance-coding-skills) (Anthropic) | Research on skill formation that shaped the intentional AI and delivery guardrails design |
| [How AI Impacts Skill Formation](https://arxiv.org/abs/2601.20245) | Cognitive-engagement concerns with AI coding, cited in delivery guardrails |

## Articles and Blog Posts

| Article | Influence |
|---|---|
| [Shell tricks that actually make life easier](https://blog.hofstede.it/shell-tricks-that-actually-make-life-easier-and-save-your-sanity/) by Hofstede | Shell scripting patterns used in hooks and automation |
| [Bringing work context to your code in GitHub Copilot](https://developer.microsoft.com/blog/bringing-work-context-to-your-code-in-github-copilot) (Microsoft Developer Blog) | Work IQ MCP context integration approach |
| [The anatomy of a perfect pull request](https://opensource.com/article/18/6/anatomy-perfect-pull-request) (opensource.com) | PR review quality practices in coding guidelines |
| [Clever code considered harmful](https://www.pcloadletter.dev/blog/clever-code/) (pcloadletter.dev) | Readability-first philosophy in coding guidelines |
| [The One True Way Fallacy](https://www.coderancher.us/2025/11/05/the-one-true-way-fallacy-why-mature-developers-dont-worship-a-single-programming-paradigm/) (Code Rancher) | Avoiding dogmatic single-paradigm thinking in coding guidelines |
| [A practical guide to AI-assisted development](https://blog.lpains.net/posts/2026-03-23-ai-dev-guide/) by lpains | Practical guidance on AI-assisted development workflows |
| [AI fatigue is real](https://siddhantkhare.com/writing/ai-fatigue-is-real) by Siddhant Khare | Perspectives on sustainable AI-assisted development and developer experience |
| [How I estimate work](https://www.seangoedecke.com/how-i-estimate-work/) by Sean Goedecke | Work estimation approach that informed complexity analysis |
| [Chesterton's Fence: A Lesson in Thinking](https://fs.blog/chestertons-fence/) (Farnam Street) | Principle adopted in code review: understand why code exists before recommending removal |

## Design Patterns and Standards

| Reference | Influence |
|---|---|
| [Mediator Pattern](https://refactoring.guru/design-patterns/mediator) (Refactoring Guru) | Basis for the conductor/orchestrator architecture in ADR-0001 |
| [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/) | Commit message standard adopted in git-commit skill and coding guidelines |
| [How to Write a Git Commit Message](http://chris.beams.io/posts/git-commit) by Chris Beams | Commit message guidance in coding guidelines |
| [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) | Changelog format standard |
| [Semantic Versioning](https://semver.org/) | Versioning strategy for the framework |
| [Logging Sucks](https://loggingsucks.com/) | Logging guidance referenced in coding guidelines |
| [contributing.md](https://contributing.md/) | Basis for the contributing guide template |

## Platform Documentation

The following official documentation informed the framework's extensibility model:

| Reference | Influence |
|---|---|
| [Custom Agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents) (VS Code Docs) | Agent authoring model and conventions |
| [Subagents](https://code.visualstudio.com/docs/copilot/agents/subagents) (VS Code Docs) | Sub-agent coordination and nesting patterns |
| [Create Skills](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills) (GitHub Docs) | Skill authoring model |
| [Path-Specific Custom Instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions) (GitHub Docs) | Instruction scoping and activation model |
| [Use Hooks](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/use-hooks) (GitHub Docs) | Hook authoring model |
| [Draw.io MCP Server](https://www.drawio.com/blog/mcp-server) (draw.io Blog) | MCP-based diagramming integration |
| [Get the best results from the coding agent](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results) (GitHub Docs) | Coding agent best practices that shaped agent and skill design |

## Talks

| Talk | Influence |
|---|---|
| [Visualising software architecture with the C4 model](https://www.youtube.com/watch?v=x2-rSnhpw0g) by Simon Brown (Agile on the Beach 2019) | Architecture visualization approach that influenced the diagram-design skill and documentation structure |