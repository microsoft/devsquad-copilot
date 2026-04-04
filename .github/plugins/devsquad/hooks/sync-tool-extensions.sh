#!/bin/bash
# sync-tool-extensions.sh
#
# Generates workspace agent overrides by merging plugin agents with
# consumer tool-extension YAML files.
#
# Consumer creates:  .github/devsquad/tool-extensions/<agent-id>.yaml
# Script generates:  .github/agents/<agent-id>.agent.md (workspace override)
#
# The generated override has the original agent's full content plus the
# consumer's additional tools and instructions. First-found-wins means the
# workspace override takes precedence over the plugin agent.
#
# Usage:
#   .github/plugins/devsquad/hooks/sync-tool-extensions.sh [--check]
#
# Options:
#   --check   Only report what would change, do not write files.

set -euo pipefail

PLUGIN_NAME="${DEVSQUAD_PLUGIN_NAME:-devsquad}"
EXTENSIONS_DIR=".github/${PLUGIN_NAME}/tool-extensions"
OUTPUT_DIR=".github/agents"
LOCKFILE=".github/${PLUGIN_NAME}/tool-extensions.lock"

# --- Locate plugin agent source directory ---
#
# The devsquad plugin agents can live in several locations depending on
# the client (VS Code or Copilot CLI), install method (marketplace or
# direct), and operating system. This function searches all known paths
# and returns the first directory that contains .agent.md files.
#
# Consumers can skip discovery by setting DEVSQUAD_PLUGIN_DIR to the
# directory that contains the agents/ subfolder (or the agents dir itself).

find_plugin_agents_dir() {
  # 0. Explicit override via environment variable
  if [ -n "${DEVSQUAD_PLUGIN_DIR:-}" ]; then
    local override="$DEVSQUAD_PLUGIN_DIR"
    # Accept both plugin root (with agents/ inside) and agents dir directly
    [ -d "$override/agents" ] && override="$override/agents"
    if [ -d "$override" ] && ls "$override"/*.agent.md &>/dev/null; then
      echo "$override"
      return
    fi
    echo "WARNING: DEVSQUAD_PLUGIN_DIR is set to '$DEVSQUAD_PLUGIN_DIR' but no agents found there." >&2
  fi

  # 1. In-repo plugin (development or embedded)
  if [ -d ".github/plugins/${PLUGIN_NAME}/agents" ]; then
    echo ".github/plugins/${PLUGIN_NAME}/agents"
    return
  fi

  # 2. Build OS-aware list of base directories to search
  local -a search_bases=()

  # Copilot CLI installed plugins
  search_bases+=("$HOME/.copilot/installed-plugins")
  search_bases+=("$HOME/.copilot/state/installed-plugins")

  # VS Code agent plugins (OS-dependent)
  case "$(uname -s)" in
    Darwin)
      search_bases+=("$HOME/Library/Application Support/Code/agentPlugins")
      search_bases+=("$HOME/Library/Application Support/Code - Insiders/agentPlugins")
      ;;
    Linux)
      local xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"
      search_bases+=("$xdg_config/Code/agentPlugins")
      search_bases+=("$xdg_config/Code - Insiders/agentPlugins")
      ;;
    MINGW*|MSYS*|CYGWIN*)
      if [ -n "${APPDATA:-}" ]; then
        search_bases+=("$APPDATA/Code/agentPlugins")
        search_bases+=("$APPDATA/Code - Insiders/agentPlugins")
      fi
      ;;
  esac

  # 3. Search each base for a directory matching */${PLUGIN_NAME}/agents
  #    containing .agent.md files. Uses find with limited depth to
  #    avoid scanning unrelated plugin directories.
  for base in "${search_bases[@]}"; do
    [ -d "$base" ] || continue
    local found
    found=$(find "$base" -maxdepth 8 -type d -name "agents" -path "*/${PLUGIN_NAME}/*" 2>/dev/null | while read -r dir; do
      if ls "$dir"/*.agent.md &>/dev/null; then
        echo "$dir"
        break
      fi
    done)
    if [ -n "$found" ]; then
      echo "$found"
      return
    fi
  done

  echo ""
}

# --- Parse YAML frontmatter from .agent.md ---

extract_frontmatter() {
  local file="$1"
  awk '
    /^---$/ { count++; next }
    count == 1 { print }
    count == 2 { exit }
  ' "$file"
}

extract_body() {
  local file="$1"
  awk '
    /^---$/ { count++ }
    count >= 2 && found { print }
    count == 2 && !found { found=1 }
  ' "$file"
}

extract_tools() {
  local file="$1"
  grep "^tools:" "$file" | head -1 | sed "s/^tools: *\[//;s/\] *$//" | tr ',' '\n' | sed "s/^ *'//;s/' *$//" | grep -v '^$'
}

extract_frontmatter_field() {
  local file="$1"
  local field="$2"
  extract_frontmatter "$file" | awk -v f="$field:" '
    $0 ~ "^"f { found=1; sub("^"f" *", ""); print; next }
    found && /^  / { print; next }
    found && /^[^ ]/ { exit }
  '
}

# --- Parse tool-extension YAML ---

validate_tool_name() {
  local name="$1"
  if ! echo "$name" | grep -qE '^[a-zA-Z0-9_/.:-]+$'; then
    echo "ERROR: Invalid tool name '$name'. Only alphanumeric, '_', '/', '.', ':', '-' allowed." >&2
    return 1
  fi
}

parse_extension_tools() {
  local file="$1"
  awk '
    /^tools:/ { in_tools=1; next }
    in_tools && /^  - / { sub(/^  - /, ""); print; next }
    in_tools && /^[^ ]/ { exit }
  ' "$file"
}

parse_extension_instructions() {
  local file="$1"
  awk '
    /^instructions: *\|/ { in_inst=1; next }
    in_inst && /^  / { sub(/^  /, ""); print; next }
    in_inst && /^[^ ]/ { exit }
  ' "$file"
}

# --- Build merged agent file ---

generate_overlay() {
  local plugin_agent="$1"
  local extension_file="$2"
  local output_file="$3"
  local plugin_version="$4"
  local agent_id
  agent_id=$(basename "$extension_file" .yaml)
  agent_id=$(basename "$agent_id" .yml)

  local plugin_file="$plugin_agent/${agent_id}.agent.md"
  if [ ! -f "$plugin_file" ]; then
    echo "WARNING: Plugin agent not found: $plugin_file (skipping ${agent_id})" >&2
    return 1
  fi

  # Extract plugin components
  local plugin_tools
  plugin_tools=$(extract_tools "$plugin_file")

  local ext_tools
  ext_tools=$(parse_extension_tools "$extension_file")

  # Fail fast if no tools could be parsed
  if [ -z "$ext_tools" ]; then
    echo "ERROR: No tools found in $extension_file. Check YAML syntax (expected 'tools:' with '  - namespace/tool' entries)." >&2
    return 1
  fi

  # Validate tool names
  if [ -n "$ext_tools" ]; then
    while IFS= read -r tool; do
      if ! validate_tool_name "$tool"; then
        echo "WARNING: Skipping ${agent_id} due to invalid tool name." >&2
        return 1
      fi
    done <<< "$ext_tools"
  fi

  local ext_instructions
  ext_instructions=$(parse_extension_instructions "$extension_file")

  # Merge tools (plugin + extension, deduplicated)
  local merged_tools
  merged_tools=$(printf '%s\n' "$plugin_tools" "$ext_tools" | grep -v '^$' | awk '!seen[$0]++')

  # Format tools array
  local tools_yaml
  tools_yaml=$(echo "$merged_tools" | sed "s/.*/'&'/" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')

  local body
  body=$(extract_body "$plugin_file")

  # List added tools for the header
  local added_tools
  added_tools=$(echo "$ext_tools" | grep -v '^$' | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')

  # Write the generated overlay
  # Reconstruct frontmatter by inserting merged tools at the original position.
  # This handles multi-line description and arbitrary field order.
  local frontmatter
  frontmatter=$(extract_frontmatter "$plugin_file")

  # Atomic write: build in temp file, then move into place
  local tmp_file
  tmp_file=$(mktemp "${output_file}.tmp.XXXXXX")
  trap 'rm -f "$tmp_file"' EXIT

  {
    echo "---"
    echo "$frontmatter" | awk -v tools_line="tools: [$tools_yaml]" '
      /^tools:/ { print tools_line; skip=1; next }
      skip && /^  / { next }
      skip && /^[^ ]/ { skip=0 }
      { print }
    '
    echo "---"
    echo ""
    echo "<!-- GENERATED by sync-tool-extensions.sh — do not edit manually. -->"
    echo "<!-- Plugin: ${PLUGIN_NAME} v${plugin_version} | Source: ${extension_file} -->"
    echo "<!-- Added tools: ${added_tools} -->"
    echo "<!-- Re-run: .github/devsquad/sync-tool-extensions.sh -->"
    echo ""
    echo "$body"

    if [ -n "$ext_instructions" ]; then
      echo ""
      echo "$ext_instructions"
    fi
  } > "$tmp_file"

  mv "$tmp_file" "$output_file"
  trap - EXIT
}

# --- Main ---

main() {
  local check_only=false
  if [ "${1:-}" = "--check" ]; then
    check_only=true
  fi

  if [ ! -d "$EXTENSIONS_DIR" ]; then
    echo "No tool-extensions directory found at $EXTENSIONS_DIR. Nothing to sync." >&2
    exit 0
  fi

  local extensions
  extensions=$(find "$EXTENSIONS_DIR" -name "*.yaml" -o -name "*.yml" 2>/dev/null | sort)

  if [ -z "$extensions" ]; then
    echo "No tool-extension files found in $EXTENSIONS_DIR." >&2
    exit 0
  fi

  local plugin_agents_dir
  plugin_agents_dir=$(find_plugin_agents_dir)

  if [ -z "$plugin_agents_dir" ]; then
    echo "ERROR: Cannot locate devsquad plugin agents directory." >&2
    echo "Searched in:" >&2
    echo "  - .github/plugins/devsquad/agents/ (in-repo)" >&2
    echo "  - ~/.copilot/installed-plugins/...  (Copilot CLI)" >&2
    case "$(uname -s)" in
      Darwin)  echo "  - ~/Library/Application Support/Code/agentPlugins/... (VS Code)" >&2 ;;
      Linux)   echo "  - ~/.config/Code/agentPlugins/... (VS Code)" >&2 ;;
      MINGW*|MSYS*|CYGWIN*) echo "  - %APPDATA%/Code/agentPlugins/... (VS Code)" >&2 ;;
    esac
    echo "" >&2
    echo "To specify the path manually, set DEVSQUAD_PLUGIN_DIR:" >&2
    echo "  DEVSQUAD_PLUGIN_DIR=/path/to/devsquad/agents .github/plugins/devsquad/hooks/sync-tool-extensions.sh" >&2
    exit 1
  fi

  # Check if output dir is a symlink (source repo, not consumer)
  if [ -L "$OUTPUT_DIR" ]; then
    echo "ERROR: $OUTPUT_DIR is a symlink (pointing to $(readlink "$OUTPUT_DIR"))." >&2
    echo "Tool extensions are for consumer projects, not the plugin source repo." >&2
    echo "Remove the symlink and create $OUTPUT_DIR as a regular directory." >&2
    exit 1
  fi

  mkdir -p "$OUTPUT_DIR"

  # Compute plugin version once for all agents
  local plugin_version="unknown"
  local agents_parent
  agents_parent=$(dirname "$plugin_agents_dir")
  for manifest in "$agents_parent/.github/plugin/plugin.json" \
                   ".github/plugins/${PLUGIN_NAME}/.github/plugin/plugin.json" \
                   ".github/plugin/plugin.json"; do
    if [ -f "$manifest" ]; then
      plugin_version=$(grep '"version"' "$manifest" | head -1 | sed 's/.*: *"//;s/".*//')
      break
    fi
  done

  local synced=0
  local failed=0
  local lock_entries=""

  while IFS= read -r ext_file; do
    local agent_id
    agent_id=$(basename "$ext_file" .yaml)
    agent_id=$(basename "$agent_id" .yml)
    local output_file="$OUTPUT_DIR/${agent_id}.agent.md"

    if $check_only; then
      if [ -f "$output_file" ]; then
        echo "Would update: $output_file"
      else
        echo "Would create: $output_file"
      fi
      continue
    fi

    echo "Syncing: $agent_id"

    # Overwrite protection: refuse to clobber manually-created agent overrides
    if [ -f "$output_file" ] && ! grep -q "GENERATED by sync-tool-extensions.sh" "$output_file" 2>/dev/null; then
      echo "ERROR: $output_file exists but was not generated by this script." >&2
      echo "  To protect your manual override, the sync will skip this agent." >&2
      echo "  To force overwrite, delete the file first: rm $output_file" >&2
      failed=$((failed + 1))
      continue
    fi

    if generate_overlay "$plugin_agents_dir" "$ext_file" "$output_file" "$plugin_version"; then
      synced=$((synced + 1))
      local tools_hash
      tools_hash=$(md5sum "$ext_file" 2>/dev/null | cut -d' ' -f1 || md5 -q "$ext_file" 2>/dev/null || echo "unknown")
      lock_entries="${lock_entries}  \"${agent_id}\": { \"hash\": \"${tools_hash}\", \"plugin_version\": \"${plugin_version}\" },\n"
      echo "  -> $output_file"
    else
      failed=$((failed + 1))
    fi
  done <<< "$extensions"

  if ! $check_only; then
    # Write lock file for staleness detection
    {
      echo "{"
      echo "  \"synced_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
      echo "  \"agents\": {"
      # Remove trailing comma from last entry and empty lines
      printf '%b' "$lock_entries" | grep -v '^$' | sed '$ s/,$//'
      echo "  }"
      echo "}"
    } > "$LOCKFILE"

    echo ""
    echo "Synced $synced agent(s), $failed failed."
    echo "Lock file: $LOCKFILE"
    if [ $synced -gt 0 ]; then
      echo ""
      echo "Generated agent overrides will take effect on next Copilot session."
      echo "Ensure MCP servers are configured in .vscode/mcp.json (required even"
      echo "for plugin-provided servers). See: https://microsoft.github.io/devsquad-copilot/extensibility/"
    fi
  fi
}

main "$@"
