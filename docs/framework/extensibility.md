# Framework Extensibility

The framework was designed to be adapted to the needs of each project. The base components (agents, skills, instructions, hooks) cover the generic engagement flow; extensions add domain-specific, stack-specific, or organization-specific knowledge.

This documentation guides **when and how** to extend the framework, focusing on solving real project needs.

## Extension Points

| Mechanism | Activation | Scope | Context cost |
|-----------|----------|--------|--------------------|
| [Instructions](#instructions) | Deterministic (file glob) | Every edit matching the pattern | Always loaded |
| [Skills](#skills) | Semantic (description) | When relevant to the conversation | On demand |
| [Agents](#agents) | Explicit (invocation) or delegation (sub-agent) | Isolated context | Isolated |
| [Hooks](#hooks) | Automatic (lifecycle event) | Post-action, deterministic | Zero (external script) |
| [MCP Servers](#mcp-servers) | Per tool call | Tools available to agents | On demand |

### When to use each mechanism

:::mermaid
flowchart TD
    start["I need to add specific<br>knowledge to the framework"]

    start --> q1{"Does the knowledge apply<br>whenever a specific file<br>type is edited?"}
    q1 -->|Yes| instruction["**Instruction**<br>applyTo: file glob"]
    q1 -->|No| q2{"Is the knowledge<br>reusable by<br>multiple agents?"}

    q2 -->|Yes| q3{"Is the volume of rules<br>large (> 200 lines)<br>or does it require its own tools?"}
    q3 -->|Yes| agent["**Agent**<br>specialized sub-agent"]
    q3 -->|No| skill["**Skill**<br>loaded by relevance"]

    q2 -->|No| q4{"Is it a deterministic<br>post-action<br>validation?"}
    q4 -->|Yes| hook["**Hook**<br>lifecycle script"]
    q4 -->|No| q5{"Does it need access<br>to an external system<br>via API?"}
    q5 -->|Yes| mcp["**MCP Server**<br>tools for agents"]
    q5 -->|No| agent2["**Agent or Skill**<br>depends on volume"]
:::

---

## Instructions

**Location**: `.github/instructions/*.instructions.md`

Instructions are rules automatically applied by Copilot when the context involves files that match the glob defined in the `applyTo` frontmatter. They do not require explicit invocation.

### Use cases

- Code conventions by language or framework (naming, patterns, error handling)
- Artifact formatting rules (specs, ADRs, tasks)
- Project constraints that must be followed in every edit of a given file type

### Instruction example

```markdown
<!-- .github/instructions/python.instructions.md -->
---
applyTo: "**/*.py"
---
# Python - Project Conventions

- Type hints required on every public signature
- Domain errors inherit from `AppError` (src/core/errors.py)
- Async by default for I/O (httpx, asyncpg)
- Tests with pytest; shared fixtures in the module's conftest.py
- Imports organized: stdlib, third-party, local (isort with black profile)
```

### Instructions by project need

| Need | File | `applyTo` |
|------|------|-----------|
| Python conventions | `python.instructions.md` | `**/*.py` |
| TypeScript conventions | `typescript.instructions.md` | `**/*.ts` |
| Go conventions | `go.instructions.md` | `**/*.go` |
| Terraform patterns | `terraform.instructions.md` | `**/*.tf` |
| Bicep patterns | `bicep.instructions.md` | `**/*.bicep` |
| REST API rules | `api-contracts.instructions.md` | `**/contracts/**` |
| Migration rules | `migrations.instructions.md` | `**/migrations/**` |
| Dockerfile rules | `docker.instructions.md` | `**/Dockerfile*` |

### Advantages and disadvantages

| Advantage | Disadvantage |
|-----------|--------------|
| Deterministic: activates whenever the glob matches | Consumes context on every edit, even for typos |
| Works with any agent (implement, review, plan) | Does not differentiate impact (low vs high) |
| Simple to maintain: one file per scope | Does not support conditional logic |
| Does not require changes to existing agents | Large content degrades response quality |

### Size guideline

Keep instructions short (< 50 lines of rules). If the content grows beyond that, migrate to a skill or agent.

---

## Skills

**Location**: `.github/skills/*/SKILL.md`

Skills are specialized knowledge blocks loaded by semantic relevance of the description. Unlike instructions (path-based), skills activate when the conversation context matches the `description` field in the frontmatter.

### Skill use cases

- Specialized knowledge needed only in specific scenarios
- Rules shared across multiple agents
- Checklists, rubrics, or reusable workflows
- Content between 50-200 lines that should not be loaded every time

### Skill example

```markdown
<!-- .github/skills/python-patterns/SKILL.md -->
---
name: python-patterns
description: Python implementation patterns for the project. Use when
  implementing Python code, including error handling patterns, async,
  tests, and module structure.
---
# Python Patterns

## Error Handling

- Use Result type (returns library) for expected errors
- Exceptions only for unexpected failures (infra, I/O)
- ...

## Async Patterns

- asyncio.gather for independent operations
- Semaphore to limit concurrency in external calls
- ...

## Testing Patterns

- Fixtures per module in conftest.py
- Factory functions for domain entities
- ...
```

### Skills by project need

| Need | Skill | Description (semantic field) |
|------|-------|-----------------------------|
| Advanced Python patterns | `python-patterns` | Python implementation patterns for the project |
| React/Next.js patterns | `react-patterns` | React component, hooks, and state patterns |
| Retry/resilience patterns | `resilience-patterns` | Retry, circuit breaker, and fallback patterns |
| Business domain rules | `domain-rules` | Business rules and domain invariants |
| Deploy checklist | `deploy-checklist` | Verification checklist before production deploy |
| Observability patterns | `observability-patterns` | Logging, metrics, and tracing patterns |

### Skill advantages and disadvantages

| Advantage | Disadvantage |
|-----------|--------------|
| Loaded on demand by relevance | Depends on Copilot correctly matching semantic relevance |
| Does not pollute context when not needed | May not activate when it should (poorly written description) |
| Reusable by multiple agents | Not guaranteed like instructions (which are deterministic) |
| Can contain more detail than instructions | Activation is not controllable by the user |

### Description guideline

The description is the primary activation factor. Include keywords that Copilot will associate with the context:

```yaml
# Bad: too generic, does not activate in the right scenarios
description: Code patterns

# Good: specific, with domain keywords
description: Python implementation patterns for the project. Use when
  implementing Python code, including error handling patterns with
  Result type, async with asyncio, tests with pytest and module structure.
```

---

## Agents

**Location**: `.github/agents/*.agent.md`

Agents are specialists that operate in isolated context with their own tools, sub-agents, and handoffs. They can be invoked directly by the user or delegated as sub-agents by other agents.

### Agent use cases

- Large volume of rules (> 200 lines) or complex conditional logic
- Need for specific tools (e.g., linters, formatters, APIs)
- Multi-step flow with checkpoints and decisions
- Context isolation needed (e.g., independent review)

### Agent example

```yaml
# .github/agents/sdd.implement-python.agent.md
---
description: Python implementation specialist. Invoked by
  sdd.implement for task execution in Python projects.
tools: ['edit/editFiles', 'edit/createFile', 'execute/runInTerminal',
  'execute/getTerminalOutput', 'search/codebase']
---
```

Followed by the markdown prompt with the agent's instructions.

### Agent structure

| Section | Required | Purpose |
|---------|----------|---------|
| YAML Frontmatter | Yes | description, tools, agents (sub-agents), handoffs |
| Style Guide | Recommended | Reference to coding-guidelines and documentation-style |
| User Input | Yes | `$ARGUMENTS` to receive input |
| Execution Flow | Yes | Steps the agent follows |
| Execution as Sub-agent | If applicable | Behavior when invoked by another agent |
| Handoff Envelope | If applicable | Context passing format |

### Agent modalities

| Modality | Activation | Example |
|----------|----------|---------|
| **Direct** | User selects from the Chat dropdown | `sdd.implement`, `sdd.plan` |
| **Sub-agent** | Programmatically invoked by another agent | `sdd.security` (invoked by `sdd.plan`) |
| **Both** | Accessible directly and as sub-agent | `sdd.review` (direct or via `sdd.implement`) |

### Agents by project need

| Need | Agent | Modality |
|------|-------|----------|
| Specialized Python implementation | `sdd.implement-python` | Sub-agent of implement |
| Specialized TypeScript implementation | `sdd.implement-typescript` | Sub-agent of implement |
| Accessibility review | `sdd.accessibility` | Sub-agent of review |
| Regulatory compliance validation | `sdd.compliance` | Direct or sub-agent |
| API documentation generation | `sdd.api-docs` | Direct |
| Data migration | `sdd.migration` | Direct |

### Integration with existing agents

For an existing agent to delegate to the new sub-agent, add it to the frontmatter:

```yaml
# In sdd.implement.agent.md, add to the frontmatter:
agents: ['sdd.security', 'sdd.review', 'sdd.implement-python']
```

And add the delegation logic in the agent body:

```markdown
## Delegation by Stack

Detect the project stack (via plan.md, package.json, pyproject.toml, go.mod):

| Stack | Sub-agent | When to delegate |
|-------|-----------|------------------|
| Python | sdd.implement-python | Implementation tasks in .py |
| TypeScript | sdd.implement-typescript | Implementation tasks in .ts |
```

### Agent advantages and disadvantages

| Advantage | Disadvantage |
|-----------|--------------|
| Full context isolation | More complex to maintain: two agents to synchronize |
| Own tools (linters, formatters) | Invocation overhead as sub-agent |
| Conditional and multi-step logic | Increases the framework surface |
| Scales to multiple languages without polluting base agents | Requires changes to existing agents (routing) |

---

## Hooks

**Location**: `.github/hooks/`

Hooks execute scripts automatically at points in the Copilot session lifecycle. They operate outside the LLM context (they are deterministic).

### Hook use cases

- Validations that must be infallible (do not depend on the LLM getting it right)
- Automatic configuration detection at session start
- Post-edit formatting or linting
- Any guardrail that cannot be "forgotten" by the agent

### Hook types

| Type | When it executes | Example |
|------|------------------|---------|
| `sessionStart` | When starting a Copilot session | Detect repository platform |
| `postToolUse` | After an agent uses a tool | Validate tags on created work items |

### Hook example

Hooks are executable scripts (bash, python, etc.) referenced in the Copilot configuration:

```bash
#!/bin/bash
# .github/hooks/validate-python-imports.sh
# Hook: postToolUse (after editing .py files)

FILE="$1"

if [[ "$FILE" == *.py ]]; then
    if command -v ruff &> /dev/null; then
        ruff check --select I "$FILE" 2>&1
    fi
fi
```

### Hooks by project need

| Need | Hook | Type |
|------|------|------|
| Detect project stack | `detect-project-stack.sh` | sessionStart |
| Detect branching strategy | `detect-branching-strategy.sh` | sessionStart |
| Validate Python imports | `validate-python-imports.sh` | postToolUse |
| Run prettier on edited files | `format-on-save.sh` | postToolUse |
| Check for secrets in code | `scan-secrets.sh` | postToolUse |
| Update diagram after editing .drawio | `export-drawio.sh` | postToolUse |

### Hook advantages and disadvantages

| Advantage | Disadvantage |
|-----------|--------------|
| Deterministic: always executes | Does not have access to conversation context |
| Zero context cost (external script) | Limited to simple validations |
| Last line of defense against errors | Requires tools installed in the environment |

---

## MCP Servers

**Location**: `.vscode/mcp.json`

MCP Servers expose tools from external systems to agents. They allow agents to interact with APIs, databases, or services without custom logic.

### MCP Server use cases

- Integration with external systems (boards, CI/CD, cloud providers)
- Access to APIs that require authentication
- Operations that agents cannot perform natively

### MCP Servers by project need

| Need | MCP Server | Tools provided |
|------|------------|----------------|
| GitHub issue management | [GitHub MCP](https://github.com/github/github-mcp-server) | issue_read, issue_write, create_pull_request |
| Azure DevOps work items | [Azure DevOps MCP](https://github.com/microsoft/azure-devops-mcp) | wit_create, wit_update, search_workitem |
| Azure architecture | [Azure MCP](https://github.com/microsoft/mcp) | cloudarchitect, deploy, bestpractices |
| Microsoft documentation | [Microsoft Learn MCP](https://github.com/MicrosoftDocs/mcp) | docs_search, docs_fetch, code_sample_search |
| Diagrams | [Draw.io MCP](https://www.drawio.com/blog/mcp-server) | create_diagram |
| Project database | PostgreSQL MCP | query, schema |
| Testing tools | Custom MCP | run_tests, coverage_report |

### MCP Server advantages and disadvantages

| Advantage | Disadvantage |
|-----------|--------------|
| Access to external data and operations | Requires configuration and authentication |
| Agents interact natively via tool calls | Latency from remote calls |
| Reusable by any agent that declares the tool | Dependency on server availability |

---

## Common Extension Scenarios

### Project with specific stack

**Situation**: Python/Django project with code conventions, model/view/serializer patterns, and tests with pytest.

**Recommended extensions**:

| What | Mechanism | Justification |
|------|-----------|---------------|
| Basic conventions (naming, imports, type hints) | Instruction (`**/*.py`) | Applies on every edit, short rules |
| Django patterns (models, views, serializers) | Skill (`django-patterns`) | Activated when implementing, not for typos |
| Pytest and fixtures rules | Instruction (`**/test_*.py`) | Applies on every test edit |
| Ruff as post-edit linter | Hook (postToolUse) | Deterministic validation |

### Polyglot project

**Situation**: Backend in Go, frontend in TypeScript/React, infra in Terraform.

**Recommended extensions**:

| What | Mechanism | Justification |
|------|-----------|---------------|
| Go conventions | Instruction (`**/*.go`) | Short rules, always applies |
| TypeScript conventions | Instruction (`**/*.ts`, `**/*.tsx`) | Short rules, always applies |
| React patterns (components, hooks, state) | Skill (`react-patterns`) | Larger volume, activated by relevance |
| Terraform patterns | Instruction (`**/*.tf`) | Short rules, always applies |
| Go implementation agent (if > 200 lines) | Agent (`sdd.implement-go`) | Isolated context with own tools |

### Project with regulatory compliance

**Situation**: Project in a regulated sector (financial, healthcare) with compliance requirements.

**Recommended extensions**:

| What | Mechanism | Justification |
|------|-----------|---------------|
| Compliance rules in code | Instruction (per language) | Applies on every edit |
| Pre-PR compliance checklist | Skill (`compliance-checklist`) | Activated at PR time |
| Compliance review agent | Agent (`sdd.compliance`) | Multi-step flow with evidence |
| Post-edit sensitive data validation | Hook (postToolUse) | Deterministic, must not fail |

### Project with complex domain

**Situation**: System with complex business rules (e.g., financial calculations, tax rules).

**Recommended extensions**:

| What | Mechanism | Justification |
|------|-----------|---------------|
| Domain terms glossary | Skill (`domain-glossary`) | Activated when terms appear |
| Business invariants | Skill (`domain-rules`) | Activated during implementation |
| Validation rules per entity | Instruction (models path) | Applies when editing models |

### Project with Azure integration

**Situation**: Project deploying to Azure with multiple services.

**Recommended extensions**:

| What | Mechanism | Justification |
|------|-----------|---------------|
| Azure MCP Server | MCP Server | Architecture and best practices tools |
| Microsoft Learn MCP Server | MCP Server | API validation and code samples |
| Azure SDK patterns | Skill (`azure-sdk-patterns`) | Activated when using Azure SDKs |
| Bicep/Terraform rules | Instruction (`**/*.bicep` or `**/*.tf`) | Applies on every IaC edit |

---

## Decision Guide by Rule Volume

| Rule volume | Usage frequency | Mechanism |
|-------------|-----------------|-----------|
| < 50 lines | Whenever editing that file type | **Instruction** (applyTo) |
| 50-200 lines | When implementing (not for typos) | **Skill** (semantic) |
| > 200 lines or conditional logic | Specific scenarios | **Agent** (sub-agent) |
| Deterministic validation | After every edit | **Hook** (script) |
| External system access | When agent needs data | **MCP Server** |

---

## Extension via Plugin (Consumers)

When the framework is installed as a plugin (`copilot plugin install`), consumers **cannot edit** the plugin files (agents, skills, hooks). Extensions must be created in the **consumer's project**.

### Mechanisms available to consumers

| Mechanism | Available | How |
|-----------|-----------|-----|
| Instruction | Yes | Create in the project's `.github/instructions/` |
| Skill | Yes | Create in the project's `.github/skills/`. Enriches plugin agents automatically via semantic relevance |
| Agent direct | Yes | Create in the project's `.github/agents/`. Explicitly invoked by the user |
| Hook | Yes | Create `hooks.json` in the project. Complements plugin hooks |
| Integrated sub-agent | No | Requires editing the parent agent's `agents:` frontmatter, which is in the plugin (read-only) |
| Component override | With caution | Creating a component with the same name overrides the plugin's (first-found-wins) |

### Limitation: integrated sub-agents

Consumers cannot create sub-agents that are automatically invoked by plugin agents (e.g., `sdd.implement-python` delegated by `sdd.implement`). This requires editing the `agents:` frontmatter of the parent agent, which is in the installed plugin.

The `sdd.extend` detects this automatically by checking if the parent agent exists as a locally editable file (`.github/agents/{parent}.agent.md`). If it does not exist, it suggests alternatives.

**Recommended alternatives:**

1. **Skill**: create a skill with a good description. It automatically enriches the context of any agent (including `sdd.implement`) via semantic relevance. This is the most powerful mechanism for consumers.
2. **Direct agent**: create an agent that the developer explicitly invokes when stack specialization is needed.

### Guide agent: `sdd.extend`

The `sdd.extend` agent interactively guides the creation of extensions. It:

- Detects if the parent agent exists as a locally editable file before suggesting sub-agents
- Recommends the appropriate mechanism with justification
- Scaffolds the artifact with the correct structure (frontmatter, naming, paths)
- Detects name collisions with plugin components
- Validates quality (skill description, instruction size)

Invoke directly or via conductor: `sdd.extend` or ask `sdd` to "extend the framework".

---

## Extension Rules

1. **Start with the simplest mechanism**. Instruction solves most cases. Scale to skill or agent only when the volume or complexity justifies it.

2. **Do not duplicate knowledge**. If a rule is in an instruction, do not repeat it in an agent. Instructions and skills enrich the context of any agent automatically.

3. **Instructions are for stable rules**. If the rule changes frequently or depends on conversation context, use a skill.

4. **Skills need a good description**. Semantic activation depends on the keywords in the description. Test whether the skill activates in the expected scenarios.

5. **Sub-agent agents need a contract**. Define input (what it receives), output (what it returns), and behavior (no interactive confirmations when in sub-agent mode).

6. **Hooks are the last line of defense**. Use for validations that cannot depend on the LLM. Hooks do not replace instructions or skills, they complement them.

7. **Keep the Conductor updated**. If you add a direct agent (not a sub-agent), add the corresponding entry in the sub-agents table of `sdd.agent.md`.

8. **Document extensions in the delivery-framework README**. Project-specific extensions should be listed so that new team members know they exist.
