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

# Lowercased host of a git URL or scp-like address (git@host:path), with an
# ssh config alias resolved to its real hostname. Empty when it can't parse a
# host. Security-sensitive: callers decide public vs private by host, so a
# missed or mis-cased host must not silently read as a different one.
remote_host() {
  local url="$1" host="" rest real
  case "$url" in
    *://*) rest="${url#*://}"; rest="${rest#*@}"; host="${rest%%[/:]*}" ;;
    *@*:*) rest="${url#*@}";   host="${rest%%:*}" ;;
    *:*)   host="${url%%:*}" ;;
    *) return 0 ;;
  esac
  # An ssh config Host alias (e.g. gh-personal) resolves to its real hostname;
  # -G only prints config, never connects. A plain hostname maps to itself.
  if command -v ssh >/dev/null 2>&1; then
    real=$(ssh -G "$host" 2>/dev/null | awk '/^hostname /{print $2; exit}')
    [[ -n "$real" ]] && host="$real"
  fi
  printf '%s' "$host" | tr '[:upper:]' '[:lower:]'
}

# Run a command with a wall-clock limit, passing its stdout straight through.
# Returns the command's exit status, or non-zero if it ran too long. Used so a
# forge lookup on an unreachable host (e.g. a company GitLab off VPN) cannot
# hang a git hook. Uses coreutils `timeout`/`gtimeout` when present, else perl's
# alarm (exec replaces perl, so the limit applies to the real process) — both
# ship on macOS or come with the tools these commands already need.
with_timeout() {
  local secs="$1"; shift
  if command -v timeout >/dev/null 2>&1; then timeout "$secs" "$@"; return; fi
  if command -v gtimeout >/dev/null 2>&1; then gtimeout "$secs" "$@"; return; fi
  if command -v perl >/dev/null 2>&1; then
    # Fork the command and, on the alarm, send it SIGTERM then SIGKILL. A plain
    # alarm sends SIGALRM, which Go binaries (gh, glab) ignore; TERM/KILL they
    # honour. The child inherits our stdout, so its output flows through.
    perl -e '
      my $s = shift @ARGV;
      my $pid = fork();
      if (!defined $pid) { exec @ARGV or exit 127; }
      if ($pid == 0) { exec @ARGV or exit 127; }
      local $SIG{ALRM} = sub { kill "TERM", $pid; sleep 1; kill "KILL", $pid; };
      alarm $s;
      waitpid($pid, 0);
      # Killed by a signal (our alarm, or anything else): exit 124 like
      # coreutils timeout. A plain $? >> 8 would read as success.
      exit(($? & 127) ? 124 : ($? >> 8));
    ' "$secs" "$@"
    return
  fi
  "$@"   # no timeout tool available: run without a limit rather than fail
}

# Is $1 a host the user has declared internal (trusted), for when a forge can't
# confirm visibility? Sources: $PASTURE_INTERNAL_HOSTS (space/comma separated)
# and ~/.config/pasture/internal-hosts (one host per line, # comments). Used so
# a self-hosted forge is only queried — and only sent a token — when the user
# has explicitly trusted it; an unlisted host stays unknown and fails closed.
is_internal_host() {
  local h="$1" f="$HOME/.config/pasture/internal-hosts" line item list="${PASTURE_INTERNAL_HOSTS:-}"
  [[ -z "$h" ]] && return 1
  for item in ${list//,/ }; do
    [[ "$(printf '%s' "$item" | tr '[:upper:]' '[:lower:]')" == "$h" ]] && return 0
  done
  [[ -f "$f" ]] || return 1
  while IFS= read -r line; do
    line="${line%%#*}"
    line=$(printf '%s' "$line" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    [[ -n "$line" && "$line" == "$h" ]] && return 0
  done < "$f"
  return 1
}
