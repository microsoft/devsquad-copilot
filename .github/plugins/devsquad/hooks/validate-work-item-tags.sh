#!/bin/bash
# Validates work items created by Copilot agents have required tags/labels.
# Runs as a postToolUse hook after issue_write or wit_create_work_item.
#
# Output contract: structured JSON with decision/reason/instructions/files/severity
# so the agent can self-correct without interpreting raw warnings.

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

MISSING_TAGS=""
INSTRUCTIONS=""

if [ "$HAS_COPILOT_GENERATED" = false ]; then
  MISSING_TAGS="${MISSING_TAGS}copilot-generated, "
  INSTRUCTIONS="${INSTRUCTIONS}Add the 'copilot-generated' label/tag to the work item. "
fi

if [ "$HAS_AI_MODEL" = false ]; then
  MISSING_TAGS="${MISSING_TAGS}ai-model:<name>, "
  INSTRUCTIONS="${INSTRUCTIONS}Add an 'ai-model:<model-name>' label/tag to the work item (e.g., 'ai-model:gpt-4'). "
fi

if [ -n "$MISSING_TAGS" ]; then
  # Trim trailing comma and space
  MISSING_TAGS=$(echo "$MISSING_TAGS" | sed 's/, $//')
  INSTRUCTIONS="${INSTRUCTIONS}Refer to the work-item-creation skill for the full list of required tags."

  jq -nc \
    --arg reason "Work item missing required tags: ${MISSING_TAGS}" \
    --arg instructions "$INSTRUCTIONS" \
    '{decision:"warn", reason:$reason, instructions:$instructions, files:[], severity:"major"}'
fi

exit 0
