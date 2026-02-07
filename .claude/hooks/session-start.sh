#!/bin/bash
set -euo pipefail

# Only run in remote (web) sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install CUE if not already present
CUE_VERSION="0.15.4"
if ! command -v cue &>/dev/null || [[ "$(cue version 2>/dev/null | head -1)" != *"$CUE_VERSION"* ]]; then
  echo "Installing CUE v${CUE_VERSION}..."
  curl -sSL -o /tmp/cue.tar.gz \
    "https://github.com/cue-lang/cue/releases/download/v${CUE_VERSION}/cue_v${CUE_VERSION}_linux_amd64.tar.gz"
  tar xzf /tmp/cue.tar.gz -C /usr/local/bin cue
  rm -f /tmp/cue.tar.gz
fi

# Set up Python venv with dependencies if not already present
cd "$CLAUDE_PROJECT_DIR"
if [ ! -d ".venv" ]; then
  echo "Creating Python venv..."
  python3 -m venv .venv
fi

echo "Installing Python dependencies..."
.venv/bin/pip install -q -r requirements.txt

echo "Session setup complete: CUE $(cue version 2>/dev/null | head -1 | awk '{print $3}'), Python venv ready"
