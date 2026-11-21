# 🚀 Install, update, remove

The short version is in the [README](../README.md#-install). This page has
what `setup.sh` does step by step, what the Brewfile installs, the shell line,
and what pasture leaves alone.

## Before you start

You need macOS and [Homebrew](https://brew.sh). herdr and the agent CLIs are not
in the Brewfile because they ship their own self-updating installers:

```bash
brew install --cask ghostty                    # the terminal, if you don't have it
curl -fsSL https://herdr.dev/install.sh | sh   # read it first, see security.md › Trust
# plus whichever agents you use, each from its maker's installer;
# pasture-update keeps them current afterwards (agents.conf)
```

| Agent | Maker | CLI |
|---|---|---|
| Claude Code | Anthropic | `claude` |
| Codex | OpenAI | `codex` |
| Grok Build | xAI | `grok` |
| Antigravity (CLI; the IDE is a separate app) | Google | `agy` |

## What `setup.sh` does

```bash
git clone https://github.com/kinhluan/pasture.git
cd pasture
./setup.sh --dry-run   # show what would be linked or backed up; changes nothing
./setup.sh
```

The links point back into the clone, so keep it where it is (if you move it,
run `./setup.sh` again). In order:

1. `brew bundle` with the [Brewfile](../Brewfile); `starpls` (the Bazel
   language server) from its GitHub release, checksum-verified; the newest
   Node LTS through fnm when there is none (the skills step below needs it);
   and rust-analyzer when rustup is installed.
2. Moves any existing config that would be replaced to
   `~/.pasture-backup/<timestamp>/` (owner-only). Nothing is overwritten. If
   stow then fails, the moved configs are put back.
3. Links every package under `home/` into `$HOME` with GNU Stow.
4. Installs herdr's integrations for the agents you have and links pasture's
   herdr plugins.
5. Installs two git hooks in **this clone only** (pasture's remote is public):
   a gitleaks pre-commit hook that blocks a commit adding a secret, and the
   pre-push secret guard (`pasture git protect`, see
   [security.md](security.md#-secrets-never-reach-a-public-remote)). An
   existing pre-commit hook is left alone, with a warning.
6. Installs the skill packs in [`skills.conf`](../skills.conf) for every agent
   (`pasture-skills`).
7. Checks herdr's config, Helix's language servers, logins and the `.zshrc` line,
   and warns about anything missing.

`./setup.sh --unstow` removes the links and unlinks the plugins.

## Once per machine

1. Add `source ~/.config/pasture/pasture.zsh` at the **end** of `~/.zshrc`
   (see [Shell](#-shell)).
2. Log in to the forges you use: `gh auth login` for GitHub, and
   `glab auth login --hostname <your gitlab host>` only if you use the
   `pasture mr …` commands, which are GitLab-only.
3. Allow notifications for **Ghostty** in System Settings › Notifications.
4. Restart Ghostty, run `herdr`, then `pasture-layout` inside a repo.
5. Optional: `grype db update` once, so `pasture dep audit` can check
   dependencies offline.

## 📦 What the Brewfile installs

| Group | Tools |
| ----- | ----- |
| Core | `stow`, `jq`, `helix`, `lazygit`, `starship` |
| Version control | `worktrunk` (`wt`), `sapling` (`sl`), `gh`, `glab` |
| JS and Python | `fnm` (Node), `pnpm`, `bun`, `uv` |
| Java | Eclipse Temurin 21, `maven` |
| Rust tools | `sccache`, `cargo-nextest`, `cargo-deny`, `cargo-edit`, `cargo-binstall` (Rust itself comes from rustup) |
| Agents' tools | `agent-browser`, `agent-desktop`, `sonarqube-cli` (`sonar`) |
| Security scanners | `gitleaks`, `trufflehog`, `semgrep`, `syft`, `grype`: none uploads your code (grype and semgrep fetch their database or ruleset once) |
| Editors | Visual Studio Code, Antigravity IDE (an app you already installed by hand is adopted, not reinstalled) |
| Bazel | `bazelisk` (as `bazel`; runs the version in each repo's `.bazelversion`), `buildifier` |
| Language servers | `jdtls`, `pyright`, `ruff`, `marksman`, `taplo`, `yaml-language-server`, plus `starpls` from setup.sh |
| Lint | `shellcheck` |

The editors update themselves, so `brew upgrade` leaves them alone.
[Strix](security.md#-pentesting-your-own-app) is installed separately with
`uv tool install strix-agent`.

## 🔄 Updating

| Command | Updates |
| ------- | ------- |
| `pasture-update` | herdr, Claude Code, Codex, Grok Build, Antigravity, Rust (rustup), the default Node LTS (fnm), Strix; skips missing tools, keeps going on failure |
| `pasture-update --all` | the same, plus `brew bundle` and `pasture-skills` |
| `git pull && ./setup.sh` | pasture itself, with any new links and hooks |

The tools and their update commands live in [`agents.conf`](../agents.conf).

## 🐚 Shell

pasture does not own `~/.zshrc`. It ships `~/.config/pasture/pasture.zsh`
(PATH, `EDITOR=hx`, completions for herdr, gh and glab, Worktrunk's shell
integration, the starship prompt, a per-pane agent-browser session, and the
Java, Rust and Node setup described in [languages.md](languages.md)).
Add one line at the **end** of `~/.zshrc`, after oh-my-zsh or `compinit`:

```zsh
source ~/.config/pasture/pasture.zsh
```

Starship replaces any oh-my-zsh theme because it loads last; set `ZSH_THEME=""`
to skip loading a theme nobody sees.

## 🚫 Not managed here

`~/.zshrc` itself, git config, `~/.claude`, IntelliJ, and the settings and
extensions of VS Code and Antigravity IDE (only the apps are installed). Put
machine-specific tweaks in `*.local` files.
