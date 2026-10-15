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

SETUP_STATUS="Existing configuration discovered; runtime verification is separate."
HAS_CODE_EVIDENCE="no"

if [ "$HAS_PROJECT_CONFIG" = "no" ] && [ "$HAS_USER_CONFIG" = "no" ]; then
  if ! command -v find >/dev/null 2>&1; then
    printf '%s\n' "detect-lsp-servers: find is required to check source and build evidence." >&2
    exit 1
  fi

  # Ignore framework scaffolding, documentation, dependencies, and generated output.
  if ! CODE_EVIDENCE=$(find . \
    -type d \( -name .git -o -name .github -o -name .memory \
      -o -name docs -o -name doc -o -name documentation -o -name examples \
      -o -name templates -o -name node_modules -o -name vendor \
      -o -name third_party -o -name third-party -o -name .venv -o -name venv \
      -o -name dist -o -name build -o -name target -o -name bin -o -name obj \
      -o -name generated -o -name __generated__ -o -name __pycache__ \
      -o -name coverage -o -name .next -o -name .nuxt -o -name .svelte-kit \
      -o -name .astro -o -name .gradle -o -name .dart_tool -o -name .build \
      -o -name deps -o -name _build \) -prune -o \
    -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
      -o -name '*.mts' -o -name '*.cts' -o -name '*.mjs' -o -name '*.cjs' \
      -o -name '*.py' -o -name '*.java' -o -name '*.kt' -o -name '*.kts' \
      -o -name '*.go' -o -name '*.rs' -o -name '*.cs' -o -name '*.fs' \
      -o -name '*.c' -o -name '*.h' -o -name '*.cpp' -o -name '*.hpp' \
      -o -name '*.cc' -o -name '*.cxx' -o -name '*.rb' -o -name '*.php' \
      -o -name '*.swift' -o -name '*.scala' -o -name '*.dart' -o -name '*.lua' \
      -o -name '*.pl' -o -name '*.r' -o -name '*.R' -o -name '*.jl' \
      -o -name '*.ex' -o -name '*.exs' -o -name '*.erl' -o -name '*.zig' \
      -o -name '*.vue' -o -name '*.svelte' -o -name '*.astro' \
      -o -name '*.html' -o -name '*.css' -o -name '*.scss' -o -name '*.less' \
      -o -name '*.sh' -o -name '*.bash' -o -name '*.ps1' -o -name '*.sql' \
      -o -name '*.tf' -o -name '*.proto' \
      -o -name package.json -o -name pom.xml -o -name build.gradle \
      -o -name go.mod -o -name Cargo.toml -o -name pyproject.toml \
      -o -name requirements.txt -o -name Gemfile -o -name composer.json \
      -o -name '*.csproj' -o -name '*.fsproj' -o -name '*.vbproj' \
      -o -name CMakeLists.txt -o -name meson.build -o -name pubspec.yaml \
      -o -name build.sbt \) \
    ! -name '*.generated.*' ! -name '*_generated.*' ! -name '*.g.cs' \
    ! -name '*.pb.go' ! -name '*_pb2.py' -print -quit); then
    printf '%s\n' "detect-lsp-servers: failed to inspect source and build evidence." >&2
    exit 1
  fi

  if [ -n "$CODE_EVIDENCE" ]; then
    HAS_CODE_EVIDENCE="yes"
    SETUP_STATUS="No project or user configuration found; recognizable source or build evidence exists."
  else
    SETUP_STATUS="Deferred; no recognizable source files or build manifests found outside excluded directories. Revisit when code or manifests are added, or request setup for an explicitly chosen language."
  fi
fi

mkdir -p .memory

cat > "$LSP_STATUS" << EOF
# LSP Status

> Configuration file presence detected at session start.

Project Config (.github/lsp.json): $HAS_PROJECT_CONFIG
User Config (~/.copilot/lsp-config.json): $HAS_USER_CONFIG
Setup: $SETUP_STATUS

Server configuration validity, language coverage, and runtime health: not checked.
Plugin-provided servers and VS Code language services: not checked.
In Copilot CLI, use /lsp to inspect effective servers and /lsp test SERVER-NAME to verify startup.
EOF

if [ "$HAS_PROJECT_CONFIG" = "yes" ] || [ "$HAS_USER_CONFIG" = "yes" ] || [ "$HAS_CODE_EVIDENCE" = "no" ]; then
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
