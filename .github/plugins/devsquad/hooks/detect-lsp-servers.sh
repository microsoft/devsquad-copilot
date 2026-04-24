#!/bin/bash
# Checks whether any LSP server configuration exists for the project.
# Surfaces a warning when no config is found, so agents and users know
# that code navigation tools (search/usages, edit/rename) may be
# operating in degraded text-search mode.
# Runs as a sessionStart hook.

set -euo pipefail

LSP_STATUS=".memory/lsp-status.md"

# Check for LSP configuration files
HAS_PROJECT_CONFIG="no"
HAS_USER_CONFIG="no"

if [ -f ".github/lsp.json" ]; then
  HAS_PROJECT_CONFIG="yes"
fi

if [ -f "${HOME}/.copilot/lsp-config.json" ]; then
  HAS_USER_CONFIG="yes"
fi

mkdir -p .memory

# At least one config exists → record and exit quietly
if [ "$HAS_PROJECT_CONFIG" = "yes" ] || [ "$HAS_USER_CONFIG" = "yes" ]; then
  cat > "$LSP_STATUS" << EOF
# LSP Status

> Auto-detected each session.

Project Config (.github/lsp.json): $HAS_PROJECT_CONFIG
User Config (~/.copilot/lsp-config.json): $HAS_USER_CONFIG
EOF
  exit 0
fi

# No config at all → record and warn
cat > "$LSP_STATUS" << EOF
# LSP Status

> Auto-detected each session. No LSP configuration found.

Project Config (.github/lsp.json): no
User Config (~/.copilot/lsp-config.json): no
EOF

REASON="No LSP servers configured. Without LSP, code navigation (search/usages, edit/rename) falls back to text search with less precision and higher token usage. Run /lsp to check status or see https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/add-lsp-servers"

if command -v jq >/dev/null 2>&1; then
  jq -cn --arg reason "$REASON" '{"decision":"warn","reason":$reason}' >&2
else
  python3 -c 'import json,sys; print(json.dumps({"decision":"warn","reason":sys.argv[1]}))' "$REASON" >&2
fi

exit 0
