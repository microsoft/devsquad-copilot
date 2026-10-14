#!/bin/bash
# Discovers Copilot CLI configuration files, not server health or IDE services.
# Runs as a sessionStart hook.

set -euo pipefail

LSP_STATUS=".memory/lsp-status.md"
HAS_PROJECT_CONFIG="no"
HAS_USER_CONFIG="no"

if [ -f ".github/lsp.json" ]; then
  HAS_PROJECT_CONFIG="yes"
fi

if [ -f "${HOME}/.copilot/lsp-config.json" ]; then
  HAS_USER_CONFIG="yes"
fi

mkdir -p .memory

cat > "$LSP_STATUS" << EOF
# LSP Status

> Configuration file presence detected at session start.

Project Config (.github/lsp.json): $HAS_PROJECT_CONFIG
User Config (~/.copilot/lsp-config.json): $HAS_USER_CONFIG

Server configuration validity, language coverage, and runtime health: not checked.
Plugin-provided servers and VS Code language services: not checked.
In Copilot CLI, use /lsp to inspect effective servers and /lsp test SERVER-NAME to verify startup.
EOF

if [ "$HAS_PROJECT_CONFIG" = "yes" ] || [ "$HAS_USER_CONFIG" = "yes" ]; then
  exit 0
fi

REASON="No Copilot CLI project or user LSP configuration file found. Plugin-provided servers and VS Code language services are not checked by this hook. In Copilot CLI, run /lsp to inspect effective servers; use the lsp-setup skill if language support is missing. See https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/add-lsp-servers"

if command -v jq >/dev/null 2>&1; then
  jq -cn --arg reason "$REASON" '{"decision":"warn","reason":$reason}' >&2
elif command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; print(json.dumps({"decision":"warn","reason":sys.argv[1]}))' "$REASON" >&2
else
  printf '%s\n' "detect-lsp-servers: jq or python3 is required to emit the configuration warning." >&2
  exit 1
fi
