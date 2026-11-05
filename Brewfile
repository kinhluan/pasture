# Installed by setup.sh via `brew bundle`.
# Agent CLIs (claude, codex, grok, agy) and herdr are NOT here: they ship
# self-updating native installers — see agents.conf and pasture-update.

brew "stow"
brew "jq"
brew "helix"
brew "lazygit"
brew "starship"   # prompt; config in home/starship
brew "sapling"    # `sl`: stacked commits inside any git repo; config in home/sapling

# Browser for agents (any of them, through bash): open, snapshot -i (compact
# @e refs), click/fill, screenshot. For pages a plain fetch can't read:
# JS-rendered, behind a login, or needing clicks. First run downloads Chrome.
brew "agent-browser"

# Editors whose agents (Claude Code / Codex extensions, Antigravity's agent)
# share the CLIs' skills and can reach herdr panes too. adopt: an app already
# installed by hand is taken over instead of failing "already an App". Both
# update themselves (auto_updates), so `brew upgrade` leaves them alone.
cask "visual-studio-code", args: { adopt: true }
cask "antigravity-ide", args: { adopt: true }

# Forge CLIs: GitHub (gh) and GitLab (glab). Auth stays out of this repo:
# `gh auth login`, `glab auth login --hostname <gitlab host>`.
brew "gh"
brew "glab"

# SonarQube CLI (`sonar`): code quality / security checks from the terminal
# and from agents. It installs into ~/.local/share/sonarqube-cli/bin, which
# pasture.zsh puts on PATH.
cask "sonarqube-cli"

# Bazel. bazelisk installs as `bazel` and runs the version each repo pins in
# .bazelversion (7.x, 8.x and 9.x side by side), downloading it on first use.
# Don't also install the `bazel` formula: it pins one version for every repo.
# Caches: a repo whose .bazelrc sets --disk_cache to a fixed path (e.g.
# ~/.cache/bazel) shares it across all its git worktrees.
brew "bazelisk"
brew "buildifier"   # formats/lints BUILD, .bzl, MODULE.bazel (Helix: :format)

# Language servers / formatters for Helix (starpls comes from GitHub, see setup.sh)
brew "jdtls"
brew "pyright"
brew "ruff"
brew "marksman"
brew "taplo"
brew "yaml-language-server"

# Lint our own scripts
brew "shellcheck"
