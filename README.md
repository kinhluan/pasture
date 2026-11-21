<div align="center">

# 🐑 pasture

**A calm terminal for herding coding agents on macOS.**

[![license: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
![macOS](https://img.shields.io/badge/macOS-only-lightgrey?logo=apple)

</div>

Run Claude Code, Codex, Grok and Antigravity side by side, see which one needs
you, and get there in one key. pasture is a dotfiles repo that wires
[herdr](https://herdr.dev), [Ghostty](https://ghostty.org),
[Helix](https://helix-editor.com), [lazygit](https://github.com/jesseduffield/lazygit),
[starship](https://starship.rs) and [Sapling](https://sapling-scm.com) into one
setup, plus a library of small tested commands and a 🐕 border collie that
watches the agents (the sheep) for you.

Ghostty is the terminal app. herdr runs inside it: a terminal multiplexer, like
tmux, that knows about coding agents. A herdr **workspace** holds **tabs**, a
tab holds **panes**, and each agent runs in a pane. herdr can tell which agents
are working, done or waiting for you. Sessions keep running when you detach.

| Agent | Maker | CLI |
|---|---|---|
| Claude Code | Anthropic | `claude` |
| Codex | OpenAI | `codex` |
| Grok Build | xAI | `grok` |
| Antigravity (CLI; the IDE is a separate app) | Google | `agy` |

📖 **Full documentation: [docs/](docs/README.md)**

## ✨ What you get

**Herding**

- **🧭 One layout per repo.** `pasture-layout` turns a herdr tab into shell,
  agent and lazygit. Helix is a popup (`⌃⌥E`), not a pane, so the agent keeps
  the width.
- **🐕 A collie for the flock.** A notification when an agent is done or waiting
  for you, `⌃⌥A` to land on it, a 🐕 in the sidebar until you look, `⌃⌥S` for a
  board of every agent, `⌃⌥X` to send the idle ones home and call them back
  later. [More](docs/collie.md)
- **🔎 Know what an agent left running.** `pasture agent ps` shows the dev
  servers, ports and children behind an "idle" agent; `pasture agent stop`
  ends one that won't quit, after you say yes. [More](docs/collie.md#-before-you-stop-an-agent-pasture-agent-ps)
- **🗺️ Every task's stage at a glance.** `pasture flow board` shows each
  agent's task as spawned, coding, in review, CI, mergeable or merged, and
  the tab bar shows the Mac's load and memory pressure. [More](docs/collie.md#%EF%B8%8F-where-every-task-stands-pasture-flow-board)

**Working in parallel**

- **🌱 One task, one worktree.** `pasture-task <branch> [agent]` makes a git
  worktree with [Worktrunk](https://worktrunk.dev), opens a herdr workspace in
  it and sets up the layout, so parallel agents never share a working copy;
  `pasture repo who` shows who is already in a repo. [More](docs/worktrees-and-stacks.md)
- **🪜 Stacked commits.** Sapling runs inside your existing git repos and
  worktrees; `⌃⌥G` shows the stack you are on, and `pasture stack push` turns
  it into a chain of GitLab MRs. [More](docs/worktrees-and-stacks.md#stacks-with-sapling)
- **👯 Writer and reviewers.** `pasture-duo` starts one writer and up to three
  read-only reviewers (any mix of the four agents) and hands the writer a
  review-loop prompt. `pasture doc review` reviews a doc with new, context-free
  agents from several vendors, each in a macOS sandbox. [More](docs/review.md)

**Safe by default**

- **🔑 No secret reaches a public remote.** A pre-push guard
  (`pasture git protect`) blocks a push carrying a secret when the remote is
  public or its visibility is unknown. [More](docs/security.md#-secrets-never-reach-a-public-remote)
- **🧪 Offline scans.** `pasture dep audit` runs gitleaks, semgrep and grype
  over a repo without uploading it; `pasture dep cve` checks one package or
  CVE. [More](docs/security.md#-scanning-a-repo-and-its-dependencies)
- **🛡 Pentest your own app.** `pasture sec pentest` runs Strix on a copy of
  your code or a local app, with a model the target's privacy allows. [More](docs/security.md#-pentesting-your-own-app)
- **🔒 Nothing secret inside.** Logins stay in the Keychain; the repo is safe to
  fork. Every command that touches other systems prints its plan and waits for
  `--yes`. [More](docs/security.md#-trust)

**For every agent**

- **🧰 Tested commands instead of one-off scripts.** `pasture <group> <command>`
  is a library of scripts for the local CLIs (herdr, git, Sapling, glab,
  agent-browser) that agents run instead of writing their own, each labelled
  read, write or external. [All commands](docs/commands.md)
- **📚 One set of skills for every agent.** `pasture-skills` installs the
  packs in `skills.conf` into Claude Code, Codex, Grok and Antigravity alike;
  by default [The Art of Agent Skills](https://github.com/kinhluan/skills). [More](docs/skills.md)
- **🌐 A browser every agent can drive.** [agent-browser](https://agent-browser.dev)
  lets any agent with a shell open, click, fill and screenshot pages, one
  browser per pane; [agent-desktop](https://github.com/vercel-labs/agent-desktop)
  does the same for native Mac apps, once you allow it. [More](docs/web-and-desktop.md)

**Comfort**

- **🏷️ A sidebar that reads at a glance.** Each project is tagged with its type
  (🏗️ Bazel, ☕ Java, 🐍 Python, 🟢 Node…) and each agent with its maker
  (🟠 Anthropic, 🟢 OpenAI, ⚫ xAI, 🔵 Google), kept fresh by a herdr plugin.
- **🎨 One palette.** Ghostty's theme colors herdr, Helix, lazygit and the prompt. [More](docs/customize.md)
- **🔄 One update command.** `pasture-update` updates herdr and every agent CLI.
- **☕🦀📦 Toolchains ready.** Java 21, Rust tools, Node through fnm, pnpm, bun,
  uv and Bazel, with language servers for Helix. [More](docs/languages.md)

## 🚀 Install

You need macOS and [Homebrew](https://brew.sh). herdr and the agent CLIs are not
in the Brewfile because they ship their own self-updating installers:

```bash
brew install --cask ghostty                    # the terminal, if you don't have it
curl -fsSL https://herdr.dev/install.sh | sh   # read it first, see docs/security.md › Trust
# plus whichever agents you use (table above), each from its maker's installer
```

Then clone pasture anywhere and run the setup:

```bash
git clone https://github.com/kinhluan/pasture.git
cd pasture
./setup.sh --dry-run   # show what would be linked or backed up; changes nothing
./setup.sh
```

The links point back into the clone, so keep it where it is (if you move it,
run `./setup.sh` again). Existing configs are moved to
`~/.pasture-backup/<timestamp>/`, never overwritten; `./setup.sh --unstow`
removes the links. [What setup.sh does, step by step](docs/install.md)

Once per machine:

1. Add `source ~/.config/pasture/pasture.zsh` at the **end** of `~/.zshrc`
   ([why the end](docs/install.md#-shell)).
2. Log in to the forges you use: `gh auth login` for GitHub, and
   `glab auth login --hostname <your gitlab host>` only if you use the
   `pasture mr …` commands, which are GitLab-only.
3. Allow notifications for **Ghostty** in System Settings › Notifications.
4. Restart Ghostty, run `herdr`, then `pasture-layout` inside a repo.

## 🧑‍🌾 Daily use

| Command | Does |
| ------- | ---- |
| `herdr` | attach to the persistent session; agents keep running when Ghostty closes |
| `pasture-layout [agent]` | shell, agent and lazygit in this tab; agent is `claude` (default), `codex`, `grok` or `agy` |
| `pasture-task <branch> [agent]` | 🌱 new worktree for the branch, a herdr workspace in it, the layout with the agent; `--done <branch>` closes and removes it |
| `pasture-duo [writer] [reviewer…]` | 👯 a writer and 1–3 read-only reviewers, e.g. `pasture-duo claude codex grok agy` (default: claude, codex) |
| `pasture-collie` | 🐕 the flock board; `--list` only prints it, `--jump` goes to the agent that needs you, `--sweep` quits idle agents |
| `pasture-stack [dir]` | 🪜 the Sapling stack of a repo |
| `pasture-skills` | 📚 install or update the skill packs for every agent; `--list` shows what each has |
| `pasture-icons` | 🏷️ re-tag the sidebar now (the plugin normally does it) |
| `pasture-update` | 🔄 update herdr and every agent CLI; `--all` adds `brew bundle` and `pasture-skills` |
| `pasture help` | 🧰 the command library, below |

### 🧰 The command library

Agents tend to write a fresh shell script whenever they need to drive a CLI,
each time a little differently. `pasture` gives them tested ones instead:

```bash
pasture help                         # every command, with its safety level
pasture help mr stack                # usage and details of one
pasture list --json                  # the same, for agents
```

| Group | Commands | For |
| ----- | -------- | --- |
| `agent` | `ask` · `ps` · `stop` · `sweep` | prompt another agent, see what it runs, stop it, send idle ones home |
| `repo` · `pane` · `flow` | `who` · `tail` · `board` | who is in which worktree, another pane's output, every task's stage |
| `stack` · `mr` | `push` · `attach` · `stack` · `fanout` | Sapling stacks as branches and GitLab MRs |
| `doc` | `review` | fresh-eyes review of a doc by context-free agents |
| `git` · `dep` · `sec` | `protect` · `guard` · `visibility` · `audit` · `cve` · `pentest` | secrets, dependencies, pentests |
| `web` · `sys` | `read` · `line` | a page as text, machine load for the tab bar |

**Safety levels.** `read` only reads. `write` changes local state and has
`--dry-run`. `external` touches other systems: it prints its plan and exits 3
unless given `--yes`, so an agent shows the plan and asks you first.
Every command, flag and exit code: **[docs/commands.md](docs/commands.md)**.

## ⌨️ Keys

On a Mac: ⌃ Control, ⌥ Option, ⇧ Shift, ↩ Return. ⌘ Command is left to macOS
and Ghostty. Configs write ⌥ as `alt`. Ghostty treats only the **left** Option
as Alt (`macos-option-as-alt = left`), so the right one still types `´ ∫ …`.

| Mac | Config name | Where | Action |
| --- | ----------- | ----- | ------ |
| `⌃⌥A` | `ctrl+alt+a` | herdr | 🐕 jump to the agent that needs you |
| `⌃⌥S` | `ctrl+alt+s` | herdr | 🐕 the flock board: pick an agent, jump |
| `⌃⌥X` | `ctrl+alt+x` | herdr | 💤 quit every idle agent (asks first) |
| `⌃⌥G` | `ctrl+alt+g` | herdr | 🪜 the Sapling stack of this repo |
| `⌃⌥E` | `ctrl+alt+e` | herdr, Helix | open the Helix popup; again to close it |
| `⌃⌥H` `⌃⌥J` `⌃⌥K` `⌃⌥L` | `ctrl+alt+h/j/k/l` | herdr | move to the pane left / down / up / right |
| `⌃⌥D`, `⌃⌥⇧D` | `ctrl+alt+d`, `ctrl+alt+shift+d` | herdr | split right, split down |
| `⌃⌥Z` | `ctrl+alt+z` | herdr | zoom the pane |
| `⌃⌥C`, `⌃⌥[`, `⌃⌥]` | `ctrl+alt+c`, `ctrl+alt+[`, `ctrl+alt+]` | herdr | new tab, previous tab, next tab |
| `⌃B` then `Q` | `ctrl+b` (prefix) | herdr | detach; everything keeps running |
| `⇧↩` | `shift+enter` | Ghostty | newline in Claude Code and Codex prompts |
| `⌃R` | `C-r` | Helix | reload every buffer after an agent run |
| `Space Y`, `Space P` | `space y`, `space p` | Helix | yank to, paste from the system clipboard |

Closing Helix with `⌃⌥E` ends it, so unsaved buffers block the close: `:w`
first. With VoiceOver on, ⌃⌥ is its modifier and macOS takes these keys first.

## 🤝 Contributing

Issues and pull requests are welcome. Scripts must parse with macOS's own
`/bin/bash` 3.2 and pass `shellcheck`, and the command reference must match
the commands' headers:

```bash
for f in setup.sh home/bin/.local/bin/* plugins/*/*.sh cmds/lib.sh cmds/*/* scripts/*; do /bin/bash -n "$f"; done
shellcheck -x setup.sh home/bin/.local/bin/* plugins/*/*.sh cmds/lib.sh cmds/*/* scripts/*
zsh -n home/zsh/.config/pasture/pasture.zsh
herdr config check
scripts/commands-doc --check   # after changing a command: scripts/commands-doc
```

How a command is laid out: [docs/customize.md](docs/customize.md#adding-a-command).

## 🙏 Built on

[herdr](https://herdr.dev) · [Ghostty](https://ghostty.org) ·
[Helix](https://helix-editor.com) · [lazygit](https://github.com/jesseduffield/lazygit) ·
[starship](https://starship.rs) · [Worktrunk](https://worktrunk.dev) ·
[Sapling](https://sapling-scm.com) · [Strix](https://github.com/usestrix/strix) · [agent-browser](https://agent-browser.dev) ·
[agent-desktop](https://github.com/vercel-labs/agent-desktop) · [gitleaks](https://github.com/gitleaks/gitleaks) ·
[semgrep](https://semgrep.dev) · [grype](https://github.com/anchore/grype) · [GNU Stow](https://www.gnu.org/software/stow/)

## 📄 License

Released under the [MIT License](LICENSE). Use it, fork it, make it your own
pasture: keep the copyright notice and the license text with any copy.

<div align="center">

<br>

Made with 🐑 by [kinhluan](https://github.com/kinhluan)

<sub>Copyright © 2026 kinhluan</sub>

</div>
