#!/bin/bash
# Auto-detects repo platform from git remote and seeds .memory/board-config.md.
# Does NOT assume board platform — that requires user confirmation via board-config skill.
# Runs as a sessionStart hook.

set -euo pipefail

BOARD_CONFIG=".memory/board-config.md"

if [ -f "$BOARD_CONFIG" ]; then
  exit 0
fi

REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")

REPO_PLATFORM="unknown"
if echo "$REMOTE_URL" | grep -qi "github.com"; then
  REPO_PLATFORM="github"
elif echo "$REMOTE_URL" | grep -qi "dev.azure.com\|visualstudio.com"; then
  REPO_PLATFORM="azdo"
fi

if [ "$REPO_PLATFORM" != "unknown" ]; then
  mkdir -p .memory
  cat > "$BOARD_CONFIG" << EOF
# Board Config

> Auto-detected from remote. Board platform needs confirmation.

Repo Platform: $REPO_PLATFORM
Board Platform:
Azure DevOps URL:
Process Template:
EOF
fi

exit 0
