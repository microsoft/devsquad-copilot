# Hooks

**Location**: `.github/hooks/`

Hooks automatically execute scripts at specific points in the Copilot session lifecycle.

| Hook | Type | Purpose |
|------|------|---------|
| `detect-repo-platform.sh` | `sessionStart` | Auto-creates `.memory/board-config.md` based on the remote |
| `detect-branching-strategy.sh` | `sessionStart` | Auto-creates `.memory/git-config.md` with branching strategy and integration branch |
| `validate-work-item-tags.sh` | `postToolUse` | Validates required tags after work item creation |
| `lint-markdown.sh` | `postToolUse` | Runs markdownlint on `.md` files after editing/creation |

**Benefit**: `detect-repo-platform.sh` eliminates the need for manual platform detection in each session. `detect-branching-strategy.sh` automatically detects whether the project uses trunk-based or GitFlow from the remote branches, preventing PRs targeted at the wrong branch. `validate-work-item-tags.sh` is the last line of defense against work items missing required tags (`copilot-generated`, `ai-model:<name>`).
