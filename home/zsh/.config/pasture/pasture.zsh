# pasture.zsh — only what the pasture workflow needs from the shell.
# pasture does not own ~/.zshrc. Add this line at the END of it (after
# oh-my-zsh / compinit, so `compdef` exists for the completions below):
#
#   source ~/.config/pasture/pasture.zsh

# PATH: ~/.local/bin holds pasture-* and starpls; the sonarqube-cli cask puts
# `sonar` in its own bin dir. -U drops duplicate entries.
typeset -U path
path=("$HOME/.local/bin" "$HOME/.local/share/sonarqube-cli/bin" $path)

# Everything that opens an editor (git, gh, glab, Claude Code's ctrl+g) uses Helix.
export EDITOR=hx VISUAL=hx

# Completions for the CLIs pasture installs. Each prints a script that calls
# `compdef` when sourced, so this needs compinit to have run already.
if (( $+functions[compdef] )); then
  for _pasture_cli in herdr gh glab; do
    (( $+commands[$_pasture_cli] )) || continue
    case $_pasture_cli in
      herdr) source <(herdr completion zsh) ;;
      *)     source <($_pasture_cli completion -s zsh) ;;
    esac
  done
  unset _pasture_cli
fi
