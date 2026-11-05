#!/usr/bin/env bash
# setup.sh — install pasture on macOS. Safe to re-run.
#
#   ./setup.sh            install packages, back up conflicts, stow, verify
#   ./setup.sh --dry-run  show what stow would link, change nothing
#   ./setup.sh --unstow   remove pasture's symlinks and unlink its herdr plugins
#                         (backups stay in ~/.pasture-backup)
set -euo pipefail

cd "$(dirname "$0")"
PASTURE_DIR="$PWD"
# Every directory under home/ is a stow package that mirrors $HOME.
# Discovered, not listed, so a new package can't be forgotten here.
STOW_DIR="$PASTURE_DIR/home"
PACKAGES=()
for _dir in "$STOW_DIR"/*/; do PACKAGES+=("$(basename "$_dir")"); done
unset _dir
(( ${#PACKAGES[@]} > 0 )) || { echo "setup.sh: no packages in $STOW_DIR" >&2; exit 1; }
BACKUP_DIR="$HOME/.pasture-backup/$(date +%Y%m%d-%H%M%S)"
# Ghostty on macOS also reads this file, and it wins over ~/.config/ghostty.
GHOSTTY_MAC_CONFIG="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
STARPLS_VERSION="v0.1.22"

say() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# --no-folding: link files, never whole directories. Otherwise ~/.config/helix
# would become a symlink and Helix would write grammars/runtime into this repo.
stow_cmd() { stow --no-folding --dir "$STOW_DIR" --target "$HOME" "$@"; }

backup() {
  local target="$1"
  # Backups are copies of personal config: keep them owner-only.
  mkdir -p "$HOME/.pasture-backup" && chmod 700 "$HOME/.pasture-backup"
  mkdir -p "$BACKUP_DIR/$(dirname "${target#"$HOME"/}")"
  mv "$target" "$BACKUP_DIR/${target#"$HOME"/}"
  warn "backed up $target → $BACKUP_DIR"
}

conflicts_in() {
  # Print package-relative paths (e.g. .config/herdr/config.toml) whose target
  # in $HOME is a real file, i.e. something stow would refuse to replace.
  local pkg_dir="$STOW_DIR/$1" file rel
  while IFS= read -r file; do
    rel="${file#"$pkg_dir"/}"
    if [[ -e "$HOME/$rel" && ! -L "$HOME/$rel" ]]; then echo "$rel"; fi
  done < <(find "$pkg_dir" -type f)
}

backup_conflicts() {
  # Move aside any real file that sits where a pasture symlink should go.
  local pkg rel
  for pkg in "${PACKAGES[@]}"; do
    while IFS= read -r rel; do backup "$HOME/$rel"; done < <(conflicts_in "$pkg")
  done
  if [[ -f "$GHOSTTY_MAC_CONFIG" && ! -L "$GHOSTTY_MAC_CONFIG" ]]; then
    backup "$GHOSTTY_MAC_CONFIG"
  fi
}

dry_run() {
  # Simulate a real run: files that backup_conflicts would move aside are
  # reported here and hidden from stow (--ignore), so stow plans the rest
  # instead of aborting on a CONFLICT that a real run never hits.
  local pkg rel
  local -a ignore
  say "dry run — nothing is changed"
  for pkg in "${PACKAGES[@]}"; do
    ignore=()
    while IFS= read -r rel; do
      warn "BACKUP+LINK: ~/$rel (moved to $BACKUP_DIR, then linked)"
      # stow anchors --ignore regexes at the end of the path; escape the dots.
      # shellcheck disable=SC2016  # `$` is a literal regex char for sed here
      ignore+=("--ignore=$(printf '%s' "$rel" | sed 's/[][\.*^$()+?{}|]/\\&/g')")
    done < <(conflicts_in "$pkg")
    # Drop stow's per-call "in simulation mode" notice; `|| true` because grep
    # exits 1 when nothing is left, and pipefail would report that as failure.
    stow_cmd --no --verbose=1 "${ignore[@]+"${ignore[@]}"}" "$pkg" 2>&1 \
      | { grep -v 'in simulation mode' || true; }
  done
  if [[ -f "$GHOSTTY_MAC_CONFIG" && ! -L "$GHOSTTY_MAC_CONFIG" ]]; then
    warn "BACKUP: $GHOSTTY_MAC_CONFIG (it overrides ~/.config/ghostty/config)"
  fi
}

install_starpls() {
  command -v starpls >/dev/null && return
  say "installing starpls $STARPLS_VERSION (Starlark/Bazel LSP) into ~/.local/bin"
  local arch sha
  arch=$(uname -m)
  # Pinned to the GitHub release asset digests for $STARPLS_VERSION; bump both
  # together (`gh api repos/withered-magic/starpls/releases/tags/<tag>`).
  case "$arch" in
    arm64)  sha=15320c409f55f50ac052221a29eed269a3278ed67de7c5b2462f58bfae07a3fa ;;
    x86_64) arch=amd64; sha=5a939eadd7a4aebe30ae4a384b614ebdbfb51b4ef0baca74e46a741cdb5d2b4e ;;
    *) warn "starpls: unsupported arch $arch, skipping"; return ;;
  esac
  local url="https://github.com/withered-magic/starpls/releases/download/$STARPLS_VERSION/starpls-darwin-$arch.tar.gz"
  local tmp; tmp=$(mktemp -d)
  # Download, verify, then extract: never pipe an unverified archive into tar.
  if curl -fsSL -o "$tmp/starpls.tgz" "$url" \
     && echo "$sha  $tmp/starpls.tgz" | shasum -a 256 -c --status; then
    mkdir -p "$HOME/.local/bin"
    tar -xzf "$tmp/starpls.tgz" -C "$HOME/.local/bin" starpls
  else
    warn "starpls download failed or checksum mismatch — not installed"
  fi
  rm -rf "$tmp"
}

install_integrations() {
  command -v herdr >/dev/null || { warn "herdr not found: curl -fsSL https://herdr.dev/install.sh | sh"; return; }
  local name integration
  while IFS='|' read -r name _ _ integration; do
    name=$(echo "$name" | xargs); integration=$(echo "${integration:-}" | xargs)
    [[ -z "$name" || "$name" == \#* || -z "$integration" || "$integration" == - ]] && continue
    if command -v "$name" >/dev/null; then
      herdr integration install "$integration" || warn "herdr integration $integration failed"
    fi
  done < agents.conf
}

plugin_ids() {
  # Top-level `id = "..."` of each plugins/*/herdr-plugin.toml; stop at the
  # first [section] so action ids (also `id = ...`) are not picked up.
  local manifest
  for manifest in "$PASTURE_DIR"/plugins/*/herdr-plugin.toml; do
    [[ -f "$manifest" ]] && sed -n '/^\[/q; s/^id = "\(.*\)"$/\1/p' "$manifest"
  done
}

unlink_plugins() {
  # Otherwise their hooks keep running from (or break without) this checkout.
  # An already-unlinked plugin is a success ("removed": false), so a nonzero
  # exit is a real failure: report it and fail, never claim "unstowed".
  command -v herdr >/dev/null || return 0
  local id failed=0
  while IFS= read -r id; do
    [[ -n "$id" ]] || continue
    if ! herdr plugin unlink "$id" >/dev/null; then
      warn "herdr plugin unlink $id failed; its hooks are still registered"
      failed=1
    fi
  done < <(plugin_ids)
  return "$failed"
}

link_plugins() {
  # Our own herdr plugins live in plugins/<name>/. `link` (not `install`) keeps
  # them running from this checkout, and re-linking is a no-op.
  command -v herdr >/dev/null || return
  local dir
  for dir in "$PASTURE_DIR"/plugins/*/; do
    [[ -f "$dir/herdr-plugin.toml" ]] || continue
    herdr plugin link "${dir%/}" >/dev/null || warn "herdr plugin link ${dir%/} failed"
  done
}

verify() {
  say "verifying"
  herdr config check || warn "herdr config check failed"
  hx --health java starlark python markdown toml yaml | grep -E '^(Language|java|starlark|python|markdown|toml|yaml|✘|  )' || true
  # Forge CLIs: report auth, never log in for the user.
  gh auth status >/dev/null 2>&1 || warn "gh not logged in: gh auth login"
  glab auth status >/dev/null 2>&1 || warn "glab not logged in: glab auth login --hostname <gitlab host>"
  [[ -x "$HOME/.local/share/sonarqube-cli/bin/sonar" ]] || warn "sonar (sonarqube-cli) missing: brew install --cask sonarqube-cli"
  grep -qs 'pasture/pasture.zsh' "$HOME/.zshrc" \
    || warn "add to the end of ~/.zshrc: source ~/.config/pasture/pasture.zsh"
  local fonts=("$HOME"/Library/Fonts/*[Hh]erdr*)
  if ! fc-list 2>/dev/null | grep -q "Herdr Agent Icons Max" && [[ ! -e "${fonts[0]}" ]]; then
    warn "font 'Herdr Agent Icons Max' missing — install the herdr-radar plugin or agent icons render as boxes"
  fi
}

case "${1:-}" in
  --dry-run) dry_run; exit ;;
  --unstow)  stow_cmd --delete "${PACKAGES[@]}"; unlink_plugins || exit 1; say "unstowed"; exit 0 ;;
  "") ;;
  *) echo "usage: $0 [--dry-run|--unstow]" >&2; exit 2 ;;
esac

command -v brew >/dev/null || { warn "Homebrew is required: https://brew.sh"; exit 1; }
say "brew bundle"
brew bundle --file="$PASTURE_DIR/Brewfile"
install_starpls

say "linking configs"
backup_conflicts
stow_cmd --restow "${PACKAGES[@]}"
command -v herdr >/dev/null && herdr server reload-config >/dev/null 2>&1 || true

say "herdr integrations"
install_integrations
link_plugins

say "skill packs (skills.conf)"
"$PASTURE_DIR/home/bin/.local/bin/pasture-skills" \
  || warn "some skill packs failed; rerun pasture-skills"

verify
say "done — open Ghostty, run \`herdr\`, then \`pasture-layout\` inside a repo"
