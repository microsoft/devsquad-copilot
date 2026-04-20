#!/bin/bash
# Runs markdownlint on markdown files after edit/create.
# Runs as a postToolUse hook.
#
# Output contract: structured JSON with decision/reason/instructions/files/severity
# so the agent can self-correct without interpreting raw linter output.

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
  # Build per-violation fix instructions for the agent
  INSTRUCTIONS=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    LINE_NUM=""
    RULE_AND_DESC=""
    if echo "$line" | grep -qE ':[0-9]+'; then
      LINE_NUM=$(echo "$line" | grep -oE ':[0-9]+' | head -1 | tr -d ':')
      RULE_AND_DESC=$(echo "$line" | sed -E 's/^[^:]+:[0-9]+(:[0-9]+)? //')
    fi
    if [ -n "$LINE_NUM" ] && [ -n "$RULE_AND_DESC" ]; then
      INSTRUCTIONS="${INSTRUCTIONS}Line ${LINE_NUM}: ${RULE_AND_DESC}. "
    fi
  done <<< "$RESULT"

  if [ -z "$INSTRUCTIONS" ]; then
    INSTRUCTIONS="Review markdownlint output and fix the reported violations."
  fi

  jq -nc \
    --arg reason "Markdown lint violations found" \
    --arg instructions "$INSTRUCTIONS" \
    --arg file "$FILE" \
    '{decision:"warn", reason:$reason, instructions:$instructions, files:[$file], severity:"minor"}'
fi

exit 0
