#!/usr/bin/env bash
# Event/startup hook for pasture.tags. The logic lives in pasture-icons; this
# only picks the scope and makes sure its tools are on PATH, since the herdr
# server may have been started from a shell without ~/.local/bin or Homebrew.
set -euo pipefail
PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
# Prefer the herdr binary that launched us over whatever PATH finds.
if [[ -n "${HERDR_BIN_PATH:-}" ]]; then
  PATH="$(dirname "$HERDR_BIN_PATH"):$PATH"
fi
export PATH

ws="${HERDR_WORKSPACE_ID:-}"
if [[ -z "$ws" && -n "${HERDR_PLUGIN_EVENT_JSON:-}" ]]; then
  ws=$(jq -r '.. | objects | .workspace_id? // empty' <<<"$HERDR_PLUGIN_EVENT_JSON" | head -n 1)
fi

case "${HERDR_PLUGIN_EVENT:-startup}" in
  startup) exec pasture-icons ;;          # everything
  *)       exec pasture-icons ${ws:+"$ws"} ;;  # one workspace + all agents
esac
