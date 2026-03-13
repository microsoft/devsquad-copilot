#!/bin/bash
# Runs markdownlint on markdown files after edit/create.
# Runs as a postToolUse hook.

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty' 2>/dev/null)

case "$TOOL_NAME" in
  editFile|createFile)
    ;;
  *)
    exit 0
    ;;
esac

FILE=$(echo "$INPUT" | jq -r '.toolInput.path // empty' 2>/dev/null)

if [ -z "$FILE" ] || [[ "$FILE" != *.md ]]; then
  exit 0
fi

if ! command -v npx &> /dev/null; then
  exit 0
fi

RESULT=$(npx --yes markdownlint "$FILE" 2>&1) || true

if [ -n "$RESULT" ]; then
  echo "{\"message\": \"Markdown lint issues:\\n$RESULT\"}"
fi

exit 0
