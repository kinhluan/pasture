# pasture 🐑

My dotfiles for working with coding agents on macOS:
**[herdr](https://herdr.dev)** keeps the agents, **[Helix](https://helix-editor.com)**
reads and edits code, **[Ghostty](https://ghostty.org)** is the terminal, and
**[lazygit](https://github.com/jesseduffield/lazygit)** reviews what the agents wrote.

```
┌──────────────┬──────────────┐
│  hx          │  claude      │
├──────────────┴──────────────┤
│  lazygit                    │
└─────────────────────────────┘
```

## Install

```bash
git clone <this repo> ~/Documents/code/pasture
cd ~/Documents/code/pasture
./setup.sh --dry-run   # preview the symlinks
./setup.sh             # brew bundle → backup → stow → herdr integrations → verify
```

Existing files are moved to `~/.pasture-backup/<timestamp>/`, never overwritten.
Remove the symlinks with `./setup.sh --unstow`.

## Layout

Each top-level folder is a [GNU Stow](https://www.gnu.org/software/stow/)
package that mirrors `$HOME`:

| Package   | Links to                                  |
| --------- | ----------------------------------------- |
| `ghostty` | `~/.config/ghostty/config`                |
| `herdr`   | `~/.config/herdr/config.toml`             |
| `helix`   | `~/.config/helix/{config,languages}.toml` |
| `lazygit` | `~/.config/lazygit/config.yml`            |
| `bin`     | `~/.local/bin/pasture-{update,layout}`    |
| `zsh`     | `~/.config/pasture/pasture.zsh`           |

## Daily use

| Command                  | Does                                                        |
| ------------------------ | ----------------------------------------------------------- |
| `herdr`                  | attach to the persistent session                            |
| `pasture-layout [agent]` | split the current pane into hx · agent · lazygit            |
| `pasture-update`         | update herdr, Claude Code, Codex, Grok Build, Antigravity   |
| `pasture-update --all`   | …and `brew bundle` (Helix, lazygit, language servers)       |

Agents and their update commands live in [`agents.conf`](agents.conf).

## Keys

| Keys                         | Where | Action                         |
| ---------------------------- | ----- | ------------------------------ |
| `ctrl+alt+h/j/k/l`           | herdr | move between panes             |
| `ctrl+alt+d` / `+shift+d`    | herdr | split right / down             |
| `ctrl+alt+z`                 | herdr | zoom pane                      |
| `ctrl+alt+c`, `ctrl+alt+[ ]` | herdr | new tab, previous / next tab   |
| `ctrl+b` then `q`            | herdr | detach (everything keeps running) |
| `ctrl+r`                     | Helix | reload all buffers after an agent run |
| `space y` / `space p`        | Helix | yank / paste system clipboard  |

## Colors

No theme is set anywhere. Ghostty's palette is the single source; Helix uses
`base16_terminal` and lazygit uses terminal colors, so changing Ghostty's theme
recolors everything.

## Shell

pasture does not own `~/.zshrc`. It ships `~/.config/pasture/pasture.zsh`
(PATH, `EDITOR=hx`, completions for herdr / gh / glab); add one line at the
**end** of your `~/.zshrc`, after oh-my-zsh / `compinit`:

```zsh
source ~/.config/pasture/pasture.zsh
```

## Forge & quality CLIs

`gh` (GitHub), `glab` (GitLab) and `sonar` (SonarQube CLI cask) come from the
Brewfile. Logins never live in this repo — run them once per machine:

```bash
gh auth login
glab auth login --hostname <your gitlab host>
```

`setup.sh` only warns when one of them is not logged in.

## Not managed here

`~/.zshrc` itself, git, `~/.claude`, IntelliJ — on purpose. Put machine-specific tweaks in
`*.local` files (git-ignored).
