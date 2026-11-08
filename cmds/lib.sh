# shellcheck shell=bash
# Shared helpers for pasture commands. Source it: . "$PASTURE_DIR/cmds/lib.sh"
# Bash 3.2 compatible (macOS /bin/bash).

PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
[[ -n "${HERDR_BIN_PATH:-}" ]] && PATH="$(dirname "$HERDR_BIN_PATH"):$PATH"
export PATH

# Exit codes every command uses, so agents can branch on them:
#   0 ok · 1 failed · 2 bad usage · 3 needs the user (blocked, approval, --yes)
#   4 timed out · 5 missing tool or not in the right place
die()   { echo "pasture: $*" >&2; exit 1; }
usage() { echo "usage: $*" >&2; exit 2; }
need()  { local t; for t in "$@"; do command -v "$t" >/dev/null || { echo "pasture: '$t' is not installed" >&2; exit 5; }; done; }
in_git() { git rev-parse --git-dir >/dev/null 2>&1 || { echo "pasture: not inside a git repo" >&2; exit 5; }; }

# The remote's default branch, e.g. master or main.
default_branch() {
  local b
  b=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) && { echo "${b#origin/}"; return; }
  b=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
  echo "${b:-main}"
}

# Nearest branch under refs/remotes/origin that the given ref is stacked on:
# an ancestor of it, not yet in base, with the most commits since base.
# Prints "origin/<base>" when it sits directly on base.
stack_parent() {
  local ref="$1" base="$2" best="$2" best_n=0 c n
  while read -r c; do
    [[ -z "$c" || "$c" == "$ref" || "$c" == "$base" || "$c" == origin/HEAD ]] && continue
    [[ "$(git rev-parse "$c")" == "$(git rev-parse "$ref")" ]] && continue
    n=$(git rev-list --count "$base..$c")
    (( n > best_n )) && { best="$c"; best_n=$n; }
  done < <(git for-each-ref --format='%(refname:short)' --merged "$ref" --no-merged "$base" refs/remotes/origin)
  echo "$best"
}

# Character-safe slug for branch names.
slug() { tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//' | cut -c1-40 | sed 's/-$//'; }

# Every descendant pid of $1 (recursive), one per line. Catches a server an
# agent started in the background — still its child — that a pane's foreground
# process group would miss. (A process reparented to launchd is not found.)
pdescendants() {
  local kid
  for kid in $(pgrep -P "$1" 2>/dev/null); do
    echo "$kid"; pdescendants "$kid"
  done
}

# The pids belonging to one agent pane: the agent's own process plus every
# descendant. $1 = pane_id, $2 = agent name. The root is the foreground process
# whose argv0 is the agent (claude/codex/grok/agy); with no match, falls back to
# every foreground pid herdr reports for the pane. Needs herdr + jq.
agent_pidset() {
  local pane="$1" agent="$2" fg root
  fg=$(herdr pane process-info --pane "$pane" 2>/dev/null \
       | jq -r '.result.process_info.foreground_processes[]? | [.argv0,.pid]|@tsv' 2>/dev/null)
  [[ -n "$fg" ]] || return 0
  root=$(awk -F'\t' -v a="$agent" '$1==a{print $2; exit}' <<<"$fg")
  if [[ -z "$root" ]]; then awk -F'\t' '{print $2}' <<<"$fg"; return 0; fi
  echo "$root"; pdescendants "$root"
}
