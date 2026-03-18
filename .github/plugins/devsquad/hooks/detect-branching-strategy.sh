#!/bin/bash
# Auto-detects branching strategy from git remote branches and seeds .memory/git-config.md.
# Runs as a sessionStart hook.

set -euo pipefail

GIT_CONFIG_FILE=".memory/git-config.md"

if [ -f "$GIT_CONFIG_FILE" ]; then
  exit 0
fi

# Detect default branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "")
if [ -z "$DEFAULT_BRANCH" ]; then
  DEFAULT_BRANCH="main"
fi

# Check for develop branch
HAS_DEVELOP="no"
if git ls-remote --heads origin develop 2>/dev/null | grep -q develop; then
  HAS_DEVELOP="yes"
fi

# Check for release/* or hotfix/* branches (GitFlow pattern)
HAS_GITFLOW_BRANCHES="no"
if git branch -r 2>/dev/null | grep -qE '(release|hotfix)/'; then
  HAS_GITFLOW_BRANCHES="yes"
fi

# Determine strategy and confidence
STRATEGY=""
INTEGRATION_BRANCH=""
CONFIDENCE=""

if [ "$HAS_DEVELOP" = "yes" ] && [ "$HAS_GITFLOW_BRANCHES" = "yes" ]; then
  STRATEGY="gitflow"
  INTEGRATION_BRANCH="develop"
  CONFIDENCE="high"
elif [ "$HAS_DEVELOP" = "yes" ]; then
  STRATEGY="gitflow"
  INTEGRATION_BRANCH="develop"
  CONFIDENCE="medium"
else
  STRATEGY="trunk-based"
  INTEGRATION_BRANCH="$DEFAULT_BRANCH"
  CONFIDENCE="high"
fi

mkdir -p .memory
cat > "$GIT_CONFIG_FILE" << EOF
# Git Config

> Auto-detected from remote branches. Confidence: $CONFIDENCE.

Branching Strategy: $STRATEGY
Integration Branch: $INTEGRATION_BRANCH
EOF

exit 0
