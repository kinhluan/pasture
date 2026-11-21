# 🎨 Look, layout and your own changes

How pasture's files are organised, what colors and emoji come from, and where
your own tweaks and commands go.

## 🗂️ Layout of this repo

Each folder under `home/` is a [GNU Stow](https://www.gnu.org/software/stow/)
package that mirrors `$HOME`. `setup.sh` stows every one it finds, so adding a
package is adding a folder. `plugins/` holds herdr plugins, linked in place so
they run from this clone, and `cmds/` holds the `pasture` command library. The
root holds `setup.sh`, `Brewfile`, `agents.conf` and `skills.conf`;
`scripts/` holds tooling for working on pasture itself; `docs/` this
documentation.

| Package | Links to |
| ------- | -------- |
| `ghostty` | `~/.config/ghostty/config` |
| `herdr` | `~/.config/herdr/config.toml` |
| `helix` | `~/.config/helix/{config,languages}.toml` |
| `lazygit` | `~/.config/lazygit/config.yml` |
| `starship` | `~/.config/starship.toml` |
| `worktrunk` | `~/.config/worktrunk/config.toml` |
| `sapling` | `~/Library/Preferences/sapling/sapling.conf` |
| `zsh` | `~/.config/pasture/pasture.zsh` |
| `bin` | `~/.local/bin/pasture` and `pasture-{layout,task,duo,collie,stack,skills,icons,update}` |

| Plugin | Runs on | Does |
| ------ | ------- | ---- |
| `plugins/herdr-pasture` (`pasture.tags`) | herdr start, new agent, new workspace | 🏷️ project and maker tags in the sidebar |
| `plugins/herdr-collie` (`pasture.collie`) | agent state change, pane focus | 🐕 marks agents waiting for you |

| Config file | Holds |
| ----------- | ----- |
| [`agents.conf`](../agents.conf) | each tool `pasture-update` updates: name, version command, update command |
| [`skills.conf`](../skills.conf) | the skill packs `pasture-skills` installs ([skills.md](skills.md)) |
| [`Brewfile`](../Brewfile) | everything Homebrew installs ([install.md](install.md#-what-the-brewfile-installs)) |

## 🧭 The layout of a tab

`pasture-layout [agent]` turns a herdr tab into shell, agent and lazygit.
Helix is a popup (`⌃⌥E`), not a pane, so the agent keeps the width. Two
variables size it:

| Variable | Default | Sets |
| -------- | ------- | ---- |
| `PASTURE_TOP` | `0.65` | height of the top row |
| `PASTURE_LEFT` | `0.3` | width of the shell |

## 🎨 Colors

Ghostty's palette is the single source: Helix uses `base16_terminal`, herdr its
`terminal` theme, and lazygit and starship terminal colors, so changing
Ghostty's theme recolors everything. The one exception is agent names in the
sidebar, tinted in their maker's color in hex, because herdr's token styles
take no ANSI color names.

## 🐑 Emoji

pasture's own decorations are emoji, not Nerd Font glyphs, so no patched font
is needed (herdr's agent-state icons still use the herdr-radar font, which
`setup.sh` checks for):

- **Prompt:** `📂 repo 🌿 branch 📝❓ ☕ v21 ⏱️ 4s` over a `🐑 ❯` input line.
- **herdr title and tab bar:** `🐑 <workspace> · <tab>` and
  `load 1.3× ▂▃▅▇  mem 61% ▃▄▆█  🐑 pasture  🕐 14:52`
  ([`pasture sys line`](collie.md#-how-busy-the-mac-is-pasture-sys-line)).
- **Pane labels** from `pasture-layout`: `🐚 shell`, `🤖 claude` (🧠 codex,
  ⚡ grok, 🪐 agy), `🌿 lazygit`.
- **Sidebar tags:** project type per workspace (🏗️ Bazel, ☕ Java, 🐍 Python,
  🟢 Node…), maker per agent (🟠 Anthropic, 🟢 OpenAI, ⚫ xAI, 🔵 Google). They
  are herdr metadata, so workspace names stay plain for scripts and the window
  title. The plugin keeps them fresh; `pasture-icons` re-tags now.

## ✏️ Your own changes

- **Machine-specific tweaks** go in `*.local` files, which git ignores.
- **Your own commands** go in `~/.config/pasture/cmds.local/<group>/<command>`.
  That folder is never committed and wins over a built-in command of the same
  name. Only it and this clone's `cmds/` are read: a repository you open cannot
  add commands.

### Adding a command

A command is an executable file `cmds/<group>/<command>`. Its first lines
declare what `pasture help`, `pasture list --json` and
[commands.md](commands.md) show:

```bash
#!/usr/bin/env bash
# summary: One line: what it does
# usage:   pasture <group> <command> <args> [--yes]
# safety:  read | write | external
#
# Free text: how it works, what it refuses, what it exits with.
set -euo pipefail
. "$PASTURE_DIR/cmds/lib.sh"
need git          # exit 5 when a tool is missing
```

`cmds/lib.sh` has the shared helpers (`need`, `usage`, `with_timeout`…). Keep
the safety contract: `write` supports `--dry-run`; `external` prints its plan
and exits 3 without `--yes`. Use the shared exit codes: 0 ok, 1 failed,
2 usage, 3 needs you, 4 timed out, 5 missing tool.

For a command in this repo, run `scripts/commands-doc` afterwards to update
[commands.md](commands.md); see [Contributing](../README.md#-contributing).
