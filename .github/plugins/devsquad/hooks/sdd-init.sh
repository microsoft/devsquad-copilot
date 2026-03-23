#!/bin/bash
# Deterministic init operations for SDD Framework files.
# Replaces LLM-driven template reading with direct file comparison and copy.
#
# Usage:
#   sdd-init.sh verify              → JSON status report for all managed files
#   sdd-init.sh diff <target-path>  → unified diff between existing and template
#   sdd-init.sh create <target-path> → copy template to target (mkdir -p as needed)
#   sdd-init.sh create-missing      → create all missing files
#   sdd-init.sh update-all          → create missing + overwrite outdated
#
# Exit codes: 0 = success, 1 = usage error, 2 = file not in manifest

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# ── File manifest ──────────────────────────────────────────────────────────────
# Template files mirror target paths inside hooks/templates/.
# Format: target_path|group
MANIFEST=(
  ".github/copilot-instructions.md|config"
  ".github/instructions/adrs.instructions.md|config"
  ".github/instructions/envisioning.instructions.md|config"
  ".github/instructions/specs.instructions.md|config"
  ".github/instructions/tasks.instructions.md|config"
  ".github/instructions/migration-specs.instructions.md|config"
  ".github/instructions/migration-tasks.instructions.md|config"
  ".github/instructions/documentation-style.instructions.md|config"
  ".github/docs/coding-guidelines.md|config"
  ".markdownlint.yaml|config"
  "docs/features/TEMPLATE.md|docs"
  "docs/migrations/TEMPLATE.md|docs"
  "docs/envisioning/TEMPLATE.md|docs"
  "docs/architecture/decisions/ADR-TEMPLATE.md|docs"
)

# ── Helpers ────────────────────────────────────────────────────────────────────

get_template_file() {
  local target="$1"
  for entry in "${MANIFEST[@]}"; do
    local t="${entry%%|*}"
    if [[ "$t" == "$target" ]]; then
      echo "$target"
      return 0
    fi
  done
  return 1
}

get_group() {
  local target="$1"
  for entry in "${MANIFEST[@]}"; do
    local t="${entry%%|*}"
    if [[ "$t" == "$target" ]]; then
      echo "${entry##*|}"
      return 0
    fi
  done
  return 1
}

file_status() {
  local target="$1"
  local template_name
  template_name=$(get_template_file "$target") || return 2
  local template_path="$TEMPLATES_DIR/$template_name"

  if [[ ! -f "$template_path" ]]; then
    echo "error:template-missing"
    return 1
  fi

  if [[ ! -f "$target" ]]; then
    echo "missing"
    return 0
  fi

  if diff -q "$target" "$template_path" > /dev/null 2>&1; then
    echo "up-to-date"
  else
    local added removed
    added=$(diff "$template_path" "$target" 2>/dev/null | grep -c '^>' || true)
    removed=$(diff "$template_path" "$target" 2>/dev/null | grep -c '^<' || true)
    echo "outdated:+${added}-${removed}"
  fi
  return 0
}

# ── Commands ───────────────────────────────────────────────────────────────────

cmd_verify() {
  local first_config=1
  local first_docs=1

  echo "{"

  # Config group
  echo '  "config": ['
  for entry in "${MANIFEST[@]}"; do
    local target="${entry%%|*}"
    local group="${entry##*|}"
    [[ "$group" != "config" ]] && continue

    local status
    status=$(file_status "$target")

    [[ $first_config -eq 0 ]] && echo ","
    first_config=0

    local status_val="${status%%:*}"
    local summary="${status#*:}"
    [[ "$status_val" == "$summary" ]] && summary=""

    printf '    {"file": "%s", "status": "%s"' "$target" "$status_val"
    [[ -n "$summary" ]] && printf ', "summary": "%s"' "$summary"
    printf '}'
  done
  echo ""
  echo "  ],"

  # Docs group
  echo '  "docs": ['
  for entry in "${MANIFEST[@]}"; do
    local target="${entry%%|*}"
    local group="${entry##*|}"
    [[ "$group" != "docs" ]] && continue

    local status
    status=$(file_status "$target")

    [[ $first_docs -eq 0 ]] && echo ","
    first_docs=0

    local status_val="${status%%:*}"
    local summary="${status#*:}"
    [[ "$status_val" == "$summary" ]] && summary=""

    printf '    {"file": "%s", "status": "%s"' "$target" "$status_val"
    [[ -n "$summary" ]] && printf ', "summary": "%s"' "$summary"
    printf '}'
  done
  echo ""
  echo "  ]"

  echo "}"
}

cmd_diff() {
  local target="$1"
  local template_name
  template_name=$(get_template_file "$target") || { echo "Error: '$target' not in manifest" >&2; exit 2; }
  local template_path="$TEMPLATES_DIR/$template_name"

  if [[ ! -f "$target" ]]; then
    echo "File does not exist: $target"
    echo "Template content would be created from: $template_name"
    return 0
  fi

  diff --unified "$target" "$template_path" || true
}

cmd_create() {
  local target="$1"
  local template_name
  template_name=$(get_template_file "$target") || { echo "Error: '$target' not in manifest" >&2; exit 2; }
  local template_path="$TEMPLATES_DIR/$template_name"

  local dir
  dir=$(dirname "$target")
  [[ -n "$dir" && "$dir" != "." ]] && mkdir -p "$dir"

  cp "$template_path" "$target"
  echo "Created: $target"
}

cmd_create_missing() {
  local count=0
  for entry in "${MANIFEST[@]}"; do
    local target="${entry%%|*}"
    if [[ ! -f "$target" ]]; then
      cmd_create "$target"
      count=$((count + 1))
    fi
  done
  echo "---"
  echo "Created $count missing file(s)"
}

cmd_update_all() {
  local created=0
  local updated=0
  local skipped=0

  for entry in "${MANIFEST[@]}"; do
    local target="${entry%%|*}"
    local template_path="$TEMPLATES_DIR/$target"

    if [[ ! -f "$target" ]]; then
      cmd_create "$target"
      created=$((created + 1))
    elif ! diff -q "$target" "$template_path" > /dev/null 2>&1; then
      cmd_create "$target"
      updated=$((updated + 1))
    else
      skipped=$((skipped + 1))
    fi
  done

  echo "---"
  echo "Created: $created | Updated: $updated | Skipped (up to date): $skipped"
}

# ── Main ───────────────────────────────────────────────────────────────────────

usage() {
  echo "Usage: sdd-init.sh <command> [args]"
  echo ""
  echo "Commands:"
  echo "  verify              JSON status report for all managed files"
  echo "  diff <target-path>  Unified diff between existing file and template"
  echo "  create <target-path> Copy template to target path"
  echo "  create-missing      Create all missing files"
  echo "  update-all          Create missing + overwrite outdated"
  exit 1
}

[[ $# -lt 1 ]] && usage

case "$1" in
  verify)
    cmd_verify
    ;;
  diff)
    [[ $# -lt 2 ]] && { echo "Error: diff requires a target path" >&2; exit 1; }
    cmd_diff "$2"
    ;;
  create)
    [[ $# -lt 2 ]] && { echo "Error: create requires a target path" >&2; exit 1; }
    cmd_create "$2"
    ;;
  create-missing)
    cmd_create_missing
    ;;
  update-all)
    cmd_update_all
    ;;
  *)
    echo "Error: unknown command '$1'" >&2
    usage
    ;;
esac
