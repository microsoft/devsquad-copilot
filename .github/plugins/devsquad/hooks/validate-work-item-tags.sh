#!/bin/bash
# Validates work items created by Copilot agents have required tags/labels.
# Runs as a postToolUse hook after issue_write or wit_create_work_item.

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty' 2>/dev/null)

# Only validate work item creation tools
case "$TOOL_NAME" in
  github/issue_write|ado/wit_create_work_item)
    ;;
  *)
    exit 0
    ;;
esac

TOOL_RESULT=$(echo "$INPUT" | jq -r '.toolResult // empty' 2>/dev/null)

if [ -z "$TOOL_RESULT" ]; then
  exit 0
fi

# Check for required tags in the result
HAS_COPILOT_GENERATED=false
HAS_AI_MODEL=false

if echo "$TOOL_RESULT" | grep -qi "copilot-generated"; then
  HAS_COPILOT_GENERATED=true
fi

if echo "$TOOL_RESULT" | grep -qi "ai-model:"; then
  HAS_AI_MODEL=true
fi

WARNINGS=""

if [ "$HAS_COPILOT_GENERATED" = false ]; then
  WARNINGS="${WARNINGS}WARNING: Work item missing 'copilot-generated' tag. "
fi

if [ "$HAS_AI_MODEL" = false ]; then
  WARNINGS="${WARNINGS}WARNING: Work item missing 'ai-model:<name>' tag. "
fi

if [ -n "$WARNINGS" ]; then
  echo "{\"message\": \"${WARNINGS}See skill work-item-creation for required tags.\"}"
fi

exit 0
