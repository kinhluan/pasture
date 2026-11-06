# pasture.zsh — only what the pasture workflow needs from the shell.
# pasture does not own ~/.zshrc. Add this line at the END of it (after
# oh-my-zsh / compinit, so `compdef` exists for the completions below):
#
#   source ~/.config/pasture/pasture.zsh

# PATH: ~/.local/bin holds pasture-* and starpls; the sonarqube-cli cask puts
# `sonar` in its own bin dir. -U drops duplicate entries.
# pnpm's and bun's global installs (`pnpm add -g`, `bun add -g`) go to their own
# bin dirs, put on PATH here.
typeset -U path
export PNPM_HOME="$HOME/Library/pnpm"
path=("$HOME/.local/bin" "$HOME/.local/share/sonarqube-cli/bin" "$PNPM_HOME" "$HOME/.bun/bin"
      "$HOME/.cargo/bin" $path)

# Java: JDK 21 unless JAVA_HOME is already set; `jdk <version>` switches this
# shell (`jdk` alone lists what is installed).
if [[ -z "${JAVA_HOME:-}" ]] && /usr/libexec/java_home -v 21 >/dev/null 2>&1; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 21)"
fi
jdk() {
  if [[ -z "${1:-}" ]]; then /usr/libexec/java_home -V; return; fi
  local home
  home="$(/usr/libexec/java_home -v "$1")" || return
  export JAVA_HOME="$home"
  java -version 2>&1 | head -1
}

# Everything that opens an editor (git, gh, glab, Claude Code's ctrl+g) uses Helix.
export EDITOR=hx VISUAL=hx

# Completions for the CLIs pasture installs. Each prints a script that calls
# `compdef` when sourced, so this needs compinit to have run already.
if (( $+functions[compdef] )); then
  for _pasture_cli in herdr gh glab pnpm uv; do
    (( $+commands[$_pasture_cli] )) || continue
    case $_pasture_cli in
      herdr) source <(herdr completion zsh) ;;
      pnpm)  source <(pnpm completion zsh) ;;
      uv)    source <(uv generate-shell-completion zsh) ;;
      *)     source <($_pasture_cli completion -s zsh) ;;
    esac
  done
  unset _pasture_cli
fi

# Worktrunk: `wt switch` changes this shell's directory, which a binary can't
# do on its own; the init defines a `wt` function (and completions) for that.
# Instead of `wt config shell install`, which would edit ~/.zshrc.
(( $+commands[wt] )) && eval "$(wt config shell init zsh)"

# Prompt: starship replaces the oh-my-zsh theme. Sourced last, so it wins over
# ZSH_THEME; set ZSH_THEME="" in ~/.zshrc to skip loading the unused theme.
(( $+commands[starship] )) && eval "$(starship init zsh)"
