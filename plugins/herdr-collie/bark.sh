#!/usr/bin/env bash
# Event hook for pasture.collie (pane.agent_status_changed, pane.focused):
# keep the 🐕 sidebar tag on agents that wait for you (blocked), and take it
# off as soon as they move on or you focus their pane.
#
# Notifications are herdr's own ([ui.toast] delivery = "terminal"), shown by
# Ghostty. A click raises Ghostty; ⌃⌥A (pasture-collie --jump) then lands on
# the agent. A click cannot pick the pane itself: the only notifier that runs
# a command on click, Homebrew's terminal-notifier, is ad-hoc signed and macOS
# refuses it notification permission.
#
# The event only says which pane; state comes from an authoritative
# `herdr agent get`, so a late or odd payload cannot tag the wrong thing.
set -euo pipefail
PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
[[ -n "${HERDR_BIN_PATH:-}" ]] && PATH="$(dirname "$HERDR_BIN_PATH"):$PATH"
export PATH

ev="${HERDR_PLUGIN_EVENT_JSON:-}"
[[ -n "$ev" ]] || ev='{}'
pane=$(jq -r '[.. | objects | .pane_id? // empty][0] // empty' <<<"$ev" 2>/dev/null || true)
pane="${pane:-${HERDR_PANE_ID:-}}"
[[ -n "$pane" ]] || exit 0

report() { herdr pane report-metadata "$pane" --source pasture-collie "$@" >/dev/null 2>&1 || true; }

# No agent there any more (it exited, or the pane is gone): a token would
# outlive it, so clear it. Fails harmlessly if the pane itself is gone.
if ! info=$(herdr agent get "$pane" 2>/dev/null); then
  report --clear-token alert
  exit 0
fi
IFS=$'\t' read -r status focused seq < <(jq -r '.result.agent |
  [.agent_status, (.focused // false), (.state_change_seq // 0)] | @tsv' <<<"$info")

# Hooks can finish out of order. herdr ignores a report whose --seq is not
# above the last one, so a hook that read older state cannot overwrite a newer
# verdict. Focus counts as newer than the tag for the same state (2n+1 > 2n).
order=$(( seq * 2 ))
[[ "$focused" == true ]] && order=$(( order + 1 ))

if [[ "$status" == blocked && "$focused" != true ]]; then
  report --seq "$order" --token "alert=🐕"
else
  # Moved on, or you are looking at it: call the dog off.
  report --seq "$order" --clear-token alert
fi
