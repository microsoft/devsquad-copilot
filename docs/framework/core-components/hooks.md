# Hooks

**Location**: `.github/hooks/`

Hooks automatically execute scripts at specific points in the Copilot session lifecycle. They provide deterministic, code-driven automation that cannot be bypassed by prompt variations.

## Supported Events

| Event | When it fires | Used by framework |
|-------|---------------|-------------------|
| `sessionStart` | First prompt of new session | Yes (3 hooks) |
| `postToolUse` | After tool completes | Yes (2 hooks) |
| `preToolUse` | Before agent invokes any tool | Not yet |
| `stop` | Agent session ends | Not yet |
| `subagentStart` | Subagent is spawned | Not yet |
| `subagentStop` | Subagent completes | Not yet |
| `userPromptSubmit` | User submits a prompt | Not yet |
| `preCompact` | Before context compaction | Not yet |

## Framework Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `detect-repo-platform.sh` | `sessionStart` | Auto-creates `.memory/board-config.md` based on the remote |
| `detect-branching-strategy.sh` | `sessionStart` | Auto-creates `.memory/git-config.md` with branching strategy and integration branch |
| `detect-tool-extensions.sh` | `sessionStart` | Warns when tool-extension files need syncing |
| `validate-work-item-tags.sh` | `postToolUse` | Validates required tags after work item creation |
| `lint-markdown.sh` | `postToolUse` | Runs markdownlint on `.md` files after editing/creation |

## How Hooks Interact

When multiple hooks target the same event, all execute. For `preToolUse` hooks, the most restrictive permission decision wins: `deny` overrides `ask`, which overrides `allow`. Plugin hooks run alongside workspace hooks.

## Extension

Consumer projects can add hooks by creating `.json` files in `.github/hooks/` (e.g., `.github/hooks/security.json`). Use `devsquad.extend` for guided hook creation covering all 8 lifecycle events.
