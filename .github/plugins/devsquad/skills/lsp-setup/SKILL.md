---
name: lsp-setup
description: "Set up Language Server Protocol (LSP) servers for Copilot CLI by detecting the repository language stack, selecting trusted servers, and merging user or project configuration. Use when the user asks to install or configure a language server, enable code intelligence, or diagnose missing CLI definitions, references, hover, or rename support, including warnings from .memory/lsp-status.md. Do not use for routine coding, VS Code or other editor language-service configuration, MCP setup, or static-analysis indexing."
---

# LSP Setup for Copilot CLI

Configure language servers for the languages actually used in the repository. Keep installation and configuration changes subject to explicit approval.

## Workflow

### 1. Establish client and current state

1. Confirm that the target is Copilot CLI. If the request concerns VS Code language services, explain that CLI LSP configuration does not configure the editor and direct the user to the relevant language extension.
2. Read `.memory/lsp-status.md` if present. Treat it as a session-start snapshot of configuration file presence, not server health or language coverage.
3. Inspect `.github/lsp.json` and `~/.copilot/lsp-config.json` when present and access is permitted. Use `/lsp` output to identify effective servers, including plugin-provided ones. Ask the user to run interactive slash commands if the current tools cannot execute them.
4. Resolve configuration precedence by server name: project configuration overrides plugin configuration, which overrides user configuration. Preserve unrelated entries and intentionally disabled servers. Report malformed configuration before attempting a merge.
5. If the required languages already have working servers, report that no changes are needed. If an existing server fails, diagnose its configuration or startup error before proposing another installation.

### 2. Detect and confirm the language stack

1. Inspect build/dependency manifests and source file extensions, excluding DevSquad scaffolding, documentation examples, templates, vendored dependencies, generated files, and build output. Do not infer a language from documentation examples alone.
2. If no stack can be established and the user has neither requested setup nor explicitly selected languages, defer setup without installing software or creating configuration. Envisioning, specification, and planning can proceed without LSP. Revisit setup when implementation introduces source files or manifests.
3. If the user explicitly requests setup in a repository with no stack evidence, ask which languages they intend to use. Do not choose the application stack on their behalf. If they already explicitly chose languages, offer optional setup for those languages with approval.
4. For polyglot repositories, identify the languages with meaningful source presence and any subproject roots.
5. Present the evidence or explicitly chosen languages and proposed language set. Confirm which languages the user wants supported before making changes.

### 3. Resolve trusted servers and installation methods

1. Determine the host OS, available package managers, existing server binaries, and required language runtimes.
2. Select a maintained server for each confirmed language using official server and ecosystem documentation. Resolve the package name, supported runtime versions, installation method, and exact stdio launch command from those sources.
3. Reuse an existing compatible installation. Do not assume every server accepts `--stdio`, invent package names, or install a new package manager without separate approval.
4. If a server or platform is unsupported or cannot be verified, explain the limitation and leave that language unchanged. Offer a documented alternative when available.

### 4. Choose scope and approve the change

1. Present the available scopes and ask the user to choose:

   | Scope | Location | Effect |
   |-------|----------|--------|
   | Project | `.github/lsp.json` | Shared with repository contributors; each machine still needs the server installed |
   | User | `~/.copilot/lsp-config.json` | Applies to this user's projects on this machine |

2. Prefer the existing project configuration location when updating project settings. Check current CLI documentation before changing a legacy root-level `lsp.json`; do not create a second competing project configuration silently.
3. Explain overrides, disabled entries, and portability constraints. Keep machine-specific absolute paths and secrets out of shared configuration. Changing an intentionally disabled server requires explicit approval.
4. Show the exact installation commands and proposed configuration changes. Obtain approval before installing software, updating an existing server entry, or writing configuration. Do not modify application dependency manifests merely to install development language servers.

### 5. Install and merge configuration

1. Run only approved installation commands. On failure, report the actual error and request approval for any alternative command; do not silently switch installers or elevate privileges.
2. Confirm that the server executable is accessible in the environment that launches Copilot CLI (`command -v` on POSIX or `Get-Command` on PowerShell).
3. Re-read the destination before writing. Add or update only approved keys under `lspServers`, preserving other servers and fields. If the file changed since approval, reconcile the new content before proceeding.
4. Validate the resulting JSON and required server fields. Use the server's documented arguments and language IDs. For monorepos, set `rootUri` when the server needs a subproject root.

### 6. Reload and verify runtime behavior

1. Ask the user to run `/lsp reload` in Copilot CLI to load the updated configuration, then `/lsp` to inspect effective server status. Check `/lsp help` if the installed CLI does not support reload; restart only when required by that version.
2. Run `/lsp test SERVER-NAME` for each configured server, or ask the user to run it and provide the result. Inspect `/lsp logs` when startup fails.
3. Verify a definition or reference lookup on a known symbol in a saved source file of each configured language. If source files do not exist yet, defer this check without creating application code solely for verification. A reachable executable and valid JSON alone do not establish working code intelligence.
4. Report configuration validity, server startup results, and code-navigation verification separately. For an explicitly chosen stack without code, state that navigation verification is pending until source files exist; startup may also remain unverified if the server requires project files. Report failures and checks awaiting user execution without claiming fully working code intelligence.
5. Explain that `.memory/lsp-status.md` refreshes at the next session start. Do not treat its older snapshot as the result of `/lsp reload`.

## Configuration Shape

Use the following structure as a template, replacing placeholders with verified values:

```json
{
  "lspServers": {
    "server-name": {
      "command": "server-binary",
      "args": ["documented-stdio-argument"],
      "fileExtensions": {
        ".ext": "language-id"
      }
    }
  }
}
```

1. Use server keys containing only alphanumeric characters, underscores, and hyphens.
2. Map extensions, including the leading dot, to the server's supported language IDs. Omit `args` or use an empty array when no arguments are required.
3. Preserve optional fields such as `env`, `rootUri`, `initializationOptions`, and timeouts when merging. Follow current CLI documentation for supported fields.
4. Preserve entries such as `"server-name": { "disabled": true }` unless the user approves enabling or replacing them.
5. Consult [GitHub's LSP setup documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/add-lsp-servers) and [LSP configuration precedence](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/lsp-servers) for current client behavior.
