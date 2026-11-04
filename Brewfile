# Installed by setup.sh via `brew bundle`.
# Agent CLIs (claude, codex, grok, agy) and herdr are NOT here: they ship
# self-updating native installers — see agents.conf and pasture-update.

brew "stow"
brew "jq"
brew "helix"
brew "lazygit"

# Forge CLIs: GitHub (gh) and GitLab (glab). Auth stays out of this repo:
# `gh auth login`, `glab auth login --hostname <gitlab host>`.
brew "gh"
brew "glab"

# SonarQube CLI (`sonar`): code quality / security checks from the terminal
# and from agents. It installs into ~/.local/share/sonarqube-cli/bin, which
# pasture.zsh puts on PATH.
cask "sonarqube-cli"

# Language servers / formatters for Helix (starpls comes from GitHub, see setup.sh)
brew "jdtls"
brew "pyright"
brew "ruff"
brew "marksman"
brew "taplo"
brew "yaml-language-server"

# Lint our own scripts
brew "shellcheck"
