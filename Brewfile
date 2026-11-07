# Installed by setup.sh via `brew bundle`.
# Agent CLIs (claude, codex, grok, agy) and herdr are NOT here: they ship
# self-updating native installers — see agents.conf and pasture-update.

brew "stow"
brew "jq"
brew "helix"
brew "lazygit"
brew "starship"   # prompt; config in home/starship
brew "sapling"    # `sl`: stacked commits inside any git repo; config in home/sapling

# Node through fnm: fast, reads .nvmrc / .node-version and switches on cd.
# setup.sh installs the newest LTS as the default; pasture-update keeps it new.
brew "fnm"

# JavaScript and Python toolchains. Caches and stores are shared by default
# (pnpm's content-addressed store, uv's cache), so ten worktrees of one repo
# don't download ten copies.
# Registry logins (~/.npmrc, private indexes) stay out of this repo: they hold
# tokens. One copy of each: setup.sh warns when another install shadows these.
brew "pnpm"
brew "uv"
brew "bun"

# Java: Eclipse Temurin 21 (LTS, free to use at work, unlike older Oracle JDK
# builds) and Maven. pasture.zsh points JAVA_HOME at 21 unless you set it, and
# `jdk 17` switches the current shell. Other versions: cask "temurin@17" etc.
# Rust is not here: rustup (https://rustup.rs) installs and updates itself;
# pasture-update runs `rustup update`, setup.sh adds rust-analyzer.
cask "temurin@21"
brew "maven"

# Rust tools around Cargo (Cargo itself comes with rustup). Prebuilt here, so
# no compiling them; none pulls in Homebrew's own Rust.
brew "sccache"          # shared compile cache: new worktrees reuse built crates
brew "cargo-nextest"    # faster test runner, compact output
brew "cargo-deny"       # advisories (RustSec), licenses, sources, duplicates
brew "cargo-edit"       # cargo upgrade: bump versions in Cargo.toml, majors too
brew "cargo-binstall"   # install other cargo tools as binaries, not from source

# Worktrunk (`wt`): one git worktree per task, so parallel agents never share
# a working copy; config in home/worktrunk, wrapped by pasture-task.
brew "worktrunk"

# Browser for agents (any of them, through bash): open, snapshot -i (compact
# @e refs), click/fill, screenshot. For pages a plain fetch can't read:
# JS-rendered, behind a login, or needing clicks. First run downloads Chrome.
brew "agent-browser"
# The same for native macOS apps, through the accessibility tree. Does nothing
# until you grant Ghostty Accessibility (and Screen Recording for screenshots);
# see README "Agents and the desktop" before you do.
brew "agent-desktop"

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

# Secret & vulnerability scanning — all four run fully offline and never upload
# the codebase (pasture is a public repo; a leaked secret is public forever).
# cargo-deny above covers Rust advisories; these cover the rest.
#   gitleaks   — secret scanning of a tree or full git history; pre-commit hook
#                wired in setup.sh so secrets are caught before they are committed
#   trufflehog — second-pass secret scan; stays offline unless --only-verified
#   semgrep    — SAST for JS/TS/Java/Python; runs the local ruleset, no cloud
#   syft       — generate a CycloneDX/SPDX SBOM from a repo or image (no network)
#   grype      — scan that SBOM (or an image) for known CVEs; pairs with syft.
#                Offline after one DB pull: `grype db update` once, then run with
#                GRYPE_DB_AUTO_UPDATE=false — no code leaves the machine either way
brew "gitleaks"
brew "trufflehog"
brew "semgrep"
brew "syft"
brew "grype"
