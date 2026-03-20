# Agent Tool Extension

* **Status**: Proposed [Preview]
* **Date**: 2026-03-19

## Context

When consumers install the plugin, agents are loaded with a static `tools:` array in their YAML frontmatter. This array is read-only in installed plugins. Enterprise teams routinely need to integrate agents with external systems (Confluence, Jira, Slack, Datadog, SonarQube, custom APIs) by adding MCP server tools. The Copilot CLI does not support dynamic tool injection, tool wildcards, or agent extension files at the platform level.

The framework needs a mechanism that allows consumers to inject arbitrary MCP server tools into existing plugin agents without modifying the plugin source and without the framework prescribing which tools can be added.

### Platform constraints

- Agent `tools:` is a static YAML frontmatter array. No wildcards, no inheritance, no dynamic includes.
- Plugin agents are read-only after `copilot plugin install`.
- Agent ID equals filename with first-found-wins resolution: workspace `.github/agents/X.agent.md` completely replaces the plugin's `X.agent.md`.
- MCP servers can be added by consumers in `.vscode/mcp.json`, but agents will not use tools absent from their `tools:` array.
- Skills are text-based instructions that teach agents behavior but cannot grant tool access.

## Priorities and Requirements (ordered)

1. **Tool agnosticism** -- Consumers must be able to inject any MCP server tool from any provider. The framework must not prescribe, limit, or predefine which tools can be added.
2. **No plugin modification** -- The mechanism must work with the plugin installed as read-only. Consumers must not need to fork, patch, or manually edit plugin agent files.
3. **Consumer simplicity** -- Adding tools to an agent should require minimal steps: declare tools, run one command, done. No deep knowledge of agent internals required.
4. **Maintainability across updates** -- When the plugin updates (new agent content, new tools), the consumer's extensions must not silently break. The system should detect staleness and guide re-sync.

## Options Considered

### Option 1: Skill Bridge (text-based instructions)

Consumers create a skill that teaches agents about external tools through natural language instructions. The skill describes what each tool does and when to use it. Agents discover skills via semantic relevance and follow the instructions.

**Evaluation against priorities**:
- **Tool agnosticism**: Partial. Skills can describe any tool, but they cannot add tools to the agent's `tools:` array. If the tool is not in the array, the agent cannot call it regardless of what the skill says.
- **No plugin modification**: Met. Skills are additive and do not touch plugin files.
- **Consumer simplicity**: Good. Writing a skill is straightforward.
- **Maintainability across updates**: Good. Skills are independent of plugin version.

**Disqualifying limitation**: Skills fundamentally cannot grant tool access. An agent that does not have `confluence/search_pages` in its `tools:` array will never call that tool, regardless of skill instructions. This approach only works for tools the agent already has access to.

### Option 2: Fixed Extension Port (predefined generic tools)

The framework adds a fixed set of generic tool names (e.g., `ext/search`, `ext/fetch`, `ext/create`, `ext/update`, `ext/query`) to every agent's `tools:` array. Consumers implement an MCP server that exposes tools matching these names. A skill teaches agents when and how to use the generic tools.

**Evaluation against priorities**:
- **Tool agnosticism**: Not met. Tools are limited to the predefined set of 5-6 generic names. A consumer wanting `jira/transition_issue` and `confluence/get_page` must map them to `ext/update` and `ext/fetch`, losing semantic clarity.
- **No plugin modification**: Met. The fixed tools are added to the plugin at framework level.
- **Consumer simplicity**: Moderate. Consumers must build an adapter layer that maps their real tools to the generic contract.
- **Maintainability across updates**: Good. Fixed tools do not change across versions.

**Disqualifying limitation**: Fails the primary priority. Forcing all external integrations through 5-6 generic tool names removes semantic information that agents use for tool selection. An agent cannot distinguish between "search Confluence" and "search Jira" when both are `ext/search`.

### Option 3: Agent Overlay Generation (sync script)

A sync script reads the original plugin agent files and consumer-provided YAML patches, then generates workspace-level agent overrides (`.github/agents/`) with the merged tools and optional instructions appended. A sessionStart hook detects when extensions exist but are not synced or are stale.

Consumer YAML schema:

```yaml
# .github/devsquad/tool-extensions/devsquad.implement.yaml
tools:
  - confluence/search_pages
  - confluence/get_page
  - jira/get_issue
instructions: |
  ## Confluence
  Search Confluence when specs reference external documentation.
```

**Evaluation against priorities**:
- **Tool agnosticism**: Fully met. Consumers declare any tool from any MCP server. No predefined set, no adapter layer.
- **No plugin modification**: Met. The script reads plugin agents as input and writes workspace overrides. Plugin files are untouched.
- **Consumer simplicity**: Good. Three steps: add MCP server config, create YAML file, run sync script. The YAML schema has two fields (`tools` and `instructions`).
- **Maintainability across updates**: Good. A lock file tracks hashes and plugin version. The sessionStart hook warns when the plugin updated or extension YAMLs changed since last sync.

**Trade-off**: Generated overrides contain the full agent body copied at sync time. When the plugin updates, the consumer must re-run the sync script to pick up new agent content. The staleness hook mitigates this by alerting immediately.

### Option 4: Native agent.extend.yaml (platform-level)

The Copilot CLI platform natively supports `*.agent.extend.yaml` files that declaratively merge into the base agent. No scripts, no overrides, no generation step.

**Evaluation against priorities**:
- **Tool agnosticism**: Fully met.
- **No plugin modification**: Fully met.
- **Consumer simplicity**: Ideal. Drop a YAML file, done.
- **Maintainability across updates**: Ideal. Platform handles merge at load time.

**Disqualifying limitation**: This capability does not exist in the Copilot CLI platform. It would require an upstream contribution to `github/copilot-cli`. Documented here as the ideal future state. If the platform adds this, Option 3 becomes unnecessary and can be deprecated.

## Decision

Agent Overlay Generation (Option 3). It is the only option that fully meets the primary priority (tool agnosticism) using capabilities available in the current platform. Options 1 and 2 fail the agnosticism requirement. Option 4 is ideal but unavailable.

The accepted trade-off is the generation step: consumers must run a sync script after changing extensions or updating the plugin. The staleness detection hook reduces the risk of running with outdated overlays by warning at session start.

### YAML contract

Extension files are placed in `.github/devsquad/tool-extensions/<agent-id>.yaml`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `tools` | list of strings | Yes | MCP tool names in `namespace/tool_name` format |
| `instructions` | string (markdown) | No | Additional instructions appended to the agent body |

The `tools` list is merged (union) with the original agent's tools. The `instructions` block is appended after the original agent body, separated by a section header.

### Plugin discovery

The sync script must locate the original plugin agent files, which vary by client and install method. The plugin name defaults to `devsquad` but can be overridden via `DEVSQUAD_PLUGIN_NAME` for forks that rename the plugin directory. The script searches the following paths in order:

1. `DEVSQUAD_PLUGIN_DIR` environment variable (explicit path override)
2. `.github/plugins/${PLUGIN_NAME}/agents/` (in-repo development)
3. `~/.copilot/installed-plugins/` (Copilot CLI, all subdirectories)
4. OS-dependent VS Code agent plugins directory:
   - macOS: `~/Library/Application Support/Code/agentPlugins/`
   - Linux: `~/.config/Code/agentPlugins/`
   - Windows: `%APPDATA%/Code/agentPlugins/`

Within each base directory, the script searches for a `*/${PLUGIN_NAME}/*/agents` path containing `.agent.md` files. This handles variable directory names from marketplace installs (`_direct/microsoft--devsquad-copilot/...`), git URL installs, and VS Code's `github.com/owner/repo/...` layout.

| Variable | Default | Purpose |
|----------|---------|---------|
| `DEVSQUAD_PLUGIN_NAME` | `devsquad` | Plugin directory name used in discovery and file paths |
| `DEVSQUAD_PLUGIN_DIR` | (auto-discovered) | Explicit path to the plugin agents directory, skips discovery |

### Summary comparison

| Aspect | Skill Bridge | Fixed Extension Port | Agent Overlay | Native extend |
|--------|-------------|---------------------|---------------|---------------|
| Tool agnosticism | Partial (no access) | Not met (5-6 fixed) | Fully met | Fully met |
| No plugin modification | Met | Met | Met | Met |
| Consumer simplicity | Good | Moderate | Good | Ideal |
| Maintainability | Good | Good | Good (with hook) | Ideal |
| Available today | Yes | Yes | Yes | No |

## Implementation Notes

The sync script is authored in the plugin at `.github/plugins/devsquad/hooks/sync-tool-extensions.sh` but is copied to the consumer project at `.github/devsquad/sync-tool-extensions.sh` during scaffolding by the `devsquad.extend` agent. This gives consumers a local, predictable path regardless of how the plugin is installed (Copilot CLI, VS Code, marketplace, direct). When the plugin is updated, the consumer should also re-copy the script to pick up any sync logic changes.

## References

* `extensibility.md` -- Tool Extensions section with consumer walkthrough and directory structure
* `sync-tool-extensions.sh` -- sync script implementation
* `detect-tool-extensions.sh` -- sessionStart staleness hook
* `devsquad.extend.agent.md` -- agent that scaffolds tool extensions for consumers
* `mcp-servers.md` -- MCP server configuration reference
