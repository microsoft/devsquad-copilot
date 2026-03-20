#!/bin/bash
# detect-tool-extensions.sh
#
# sessionStart hook: detects tool-extension files that need syncing.
#
# Warns when:
# 1. Extension YAMLs exist but generated overrides don't (never synced)
# 2. Extension YAMLs changed since last sync (needs re-sync)
# 3. Plugin version changed since last sync (needs re-sync)

set -euo pipefail

PLUGIN_NAME="${DEVSQUAD_PLUGIN_NAME:-devsquad}"
EXTENSIONS_DIR=".github/${PLUGIN_NAME}/tool-extensions"
LOCKFILE=".github/${PLUGIN_NAME}/tool-extensions.lock"
OUTPUT_DIR=".github/agents"

# No extensions directory = nothing to do
if [ ! -d "$EXTENSIONS_DIR" ]; then
  exit 0
fi

extensions=$(find "$EXTENSIONS_DIR" -name "*.yaml" -o -name "*.yml" 2>/dev/null)
if [ -z "$extensions" ]; then
  exit 0
fi

# Case 1: Never synced (no lock file)
if [ ! -f "$LOCKFILE" ]; then
  count=$(echo "$extensions" | wc -l | tr -d ' ')
  cat >&2 << EOF
{"decision":"warn","reason":"Found ${count} tool-extension file(s) in ${EXTENSIONS_DIR} but no generated agent overrides. Run: .github/plugins/devsquad/hooks/sync-tool-extensions.sh"}
EOF
  exit 0
fi

# Case 2: Check plugin version change since last sync
locked_plugin_version=$(grep '"plugin_version"' "$LOCKFILE" 2>/dev/null | head -1 | sed 's/.*: "//;s/".*//' || echo "")
if [ -n "$locked_plugin_version" ] && [ "$locked_plugin_version" != "unknown" ]; then
  current_plugin_version="unknown"
  for manifest in ".github/plugins/${PLUGIN_NAME}/.github/plugin/plugin.json" \
                   ".github/plugin/plugin.json"; do
    if [ -f "$manifest" ]; then
      current_plugin_version=$(grep '"version"' "$manifest" | head -1 | sed 's/.*: *"//;s/".*//')
      break
    fi
  done
  if [ "$current_plugin_version" != "unknown" ] && [ "$current_plugin_version" != "$locked_plugin_version" ]; then
    cat >&2 << EOF
{"decision":"warn","reason":"Plugin updated (${locked_plugin_version} -> ${current_plugin_version}). Re-sync tool extensions: .github/devsquad/sync-tool-extensions.sh"}
EOF
    exit 0
  fi
fi

# Case 3: Check each extension for changes since last sync
stale_agents=""
while IFS= read -r ext_file; do
  agent_id=$(basename "$ext_file" .yaml)
  agent_id=$(basename "$agent_id" .yml)

  # Check if generated override exists
  if [ ! -f "$OUTPUT_DIR/${agent_id}.agent.md" ]; then
    stale_agents="${stale_agents} ${agent_id}(missing)"
    continue
  fi

  # Check if extension file changed since sync
  current_hash=$(md5sum "$ext_file" 2>/dev/null | cut -d' ' -f1 || md5 -q "$ext_file" 2>/dev/null || echo "unknown")
  locked_hash=$(grep "\"${agent_id}\"" "$LOCKFILE" 2>/dev/null | grep -o '"hash": "[^"]*"' | sed 's/"hash": "//;s/"//' || echo "")

  if [ "$current_hash" != "$locked_hash" ]; then
    stale_agents="${stale_agents} ${agent_id}(changed)"
  fi
done <<< "$extensions"

if [ -n "$stale_agents" ]; then
  cat >&2 << EOF
{"decision":"warn","reason":"Tool extensions out of sync:${stale_agents}. Run: .github/plugins/devsquad/hooks/sync-tool-extensions.sh"}
EOF
fi
