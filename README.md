<div align="center">

# 🐑 pasture

**A calm terminal for herding coding agents on macOS.**

[![license: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
![macOS](https://img.shields.io/badge/macOS-only-lightgrey?logo=apple)

Run Claude Code, Codex, Grok and Antigravity side by side, see which one needs
you, and jump to it in one key: [herdr](https://herdr.dev) keeps the flock,
[Ghostty](https://ghostty.org) is the field, [lazygit](https://github.com/jesseduffield/lazygit)
checks what they wrote, [Helix](https://helix-editor.com) is a keypress away,
and a 🐕 border collie watches the sheep for you.

</div>

```
 sidebar                 ┌ 🐚 shell ┬ 🤖 claude ─────────────────┐
 🏗️ api                  │ 📂 api   │ ● Editing auth middleware… │
   main · ↑1             │ 🌿 main  │                            │
 ⛔ 🐕 api · 2           │ 🐑 ❯     │                            │
   🟢 OpenAI · codex     ├ 🌿 lazygit ───────────────────────────┤
 🏃 api · 1              │ Files  M src/auth.ts                  │
   🟠 Anthropic · claude │        M src/auth.test.ts             │
                         └───────────────────────────────────────┘
 ⌃⌥E Helix pops up over it all · ⌃⌥A jump to the agent that needs you · ⌃⌥S the flock board
```

## ✨ What you get

- **🧭 One layout per repo:** `pasture-layout` turns a herdr tab into
  shell · agent · lazygit. Helix is a popup, not a pane, so the agent keeps the
  width; `⌃⌥E` opens it, `⌃⌥E` again puts it away.
- **🐕 A collie for the flock:** Ghostty notifies you when an agent is done or
  waiting for you; `⌃⌥A` lands on it; a 🐕 marks it in the sidebar until you
  look; `⌃⌥S` shows every agent, the ones that need you first.
- **👯 Writer + reviewer:** `pasture-duo` starts a writer next to a read-only
  reviewer (Claude · Codex by default) and hands the writer a review-loop prompt.
- **🏷️ A sidebar that reads at a glance:** each project gets its type (🏗️ Bazel,
  ☕ Java, 🐍 Python, 🟢 Node…) and each agent its maker (🟠 Anthropic, 🟢 OpenAI,
  ⚫ xAI, 🔵 Google), kept fresh automatically.
- **🎨 One palette:** Ghostty's theme colors everything: herdr, Helix,
  lazygit and the [starship](https://starship.rs) prompt.
- **🔄 One update command:** `pasture-update` updates herdr and every agent CLI;
  `--all` adds Homebrew.
- **🔒 Nothing secret inside:** logins stay in the Keychain; the repo is safe to
  fork and share.

## 🚀 Install

You need macOS and [Homebrew](https://brew.sh). herdr and the agent CLIs are not
in the Brewfile; they ship their own self-updating installers:

```bash
curl -fsSL https://herdr.dev/install.sh | sh   # read it first, see Trust below
# plus whichever agents you use: claude, codex, grok, agy
```

Then:

```bash
git clone https://github.com/kinhluan/pasture.git
cd pasture
./setup.sh --dry-run   # show what would be linked or backed up; changes nothing
./setup.sh             # install, back up, link, hook into herdr, check
```

Clone it wherever you like: the links point back at that folder, so keep it
there (move it, then run `./setup.sh` again). What `./setup.sh` does, in order:

1. `brew bundle`: the tools in the [Brewfile](Brewfile), plus `starpls` (Bazel
   LSP) from its GitHub release, checksum-verified.
2. Moves any existing config that would be replaced into the backup folder.
3. Links every package under `home/` into `$HOME` with GNU Stow.
4. Installs herdr's integrations for the agents you have, and links pasture's
   herdr plugins.
5. Checks herdr's config, Helix's language servers, logins and the `.zshrc` line.

Your existing files are moved to `~/.pasture-backup/<timestamp>/` (owner-only),
never overwritten. `./setup.sh --unstow` removes the symlinks and unlinks the
herdr plugins.

Once per machine:

1. Add `source ~/.config/pasture/pasture.zsh` at the **end** of `~/.zshrc`
   (see [Shell](#-shell)).
2. Log in: `gh auth login`, `glab auth login --hostname <your gitlab host>`.
3. Allow notifications for **Ghostty** in System Settings › Notifications.
4. Restart Ghostty, run `herdr`, then `pasture-layout` inside a repo.

`setup.sh` warns when the `.zshrc` line or a login is missing.

## 🧑‍🌾 Daily use

| Command                          | Does |
| -------------------------------- | ---- |
| `herdr`                          | attach to the persistent session (agents keep running when you close Ghostty) |
| `pasture-layout [agent]`         | shell · agent · lazygit in this tab; agent is `claude` (default), `codex`, `grok` or `agy` |
| `PASTURE_TOP=0.7 pasture-layout` | taller top row; `PASTURE_LEFT=0.2` makes the shell narrower |
| `pasture-duo [writer] [reviewer]`| writer + read-only reviewer (default claude · codex; reviewer: codex, claude or grok); the review-loop prompt is copied to the clipboard |
| `pasture-collie`                 | 🐕 the flock board; `--list` just prints it, `--jump` goes to the agent that needs you |
| `pasture-icons`                  | re-tag the sidebar now (the `pasture.tags` plugin normally does it for you) |
| `pasture-update`                 | update herdr, Claude Code, Codex, Grok Build, Antigravity; skips missing tools, keeps going on failure |
| `pasture-update --all`           | …and `brew bundle` (Helix, lazygit, language servers) |

Agents and their update commands live in [`agents.conf`](agents.conf).

## ⌨️ Keys

On a Mac: ⌃ Control, ⌥ Option, ⇧ Shift, ↩ Return. ⌘ Command is left to macOS and
Ghostty. Configs spell ⌥ as `alt` (herdr and Helix syntax), and Ghostty treats
the **left** Option as Alt (`macos-option-as-alt = left`), so the right one still
types `´ ∫ …`.

| Mac                     | Config name                  | Where         | Action |
| ----------------------- | ---------------------------- | ------------- | ------ |
| `⌃⌥A`                   | `ctrl+alt+a`                 | herdr         | 🐕 jump to the agent that needs you |
| `⌃⌥S`                   | `ctrl+alt+s`                 | herdr         | 🐕 the flock board: pick an agent, jump |
| `⌃⌥E`                   | `ctrl+alt+e`                 | herdr · Helix | open the Helix popup · close it (`:w` first; unsaved buffers block it) |
| `⌃⌥H` `⌃⌥J` `⌃⌥K` `⌃⌥L` | `ctrl+alt+h/j/k/l`           | herdr         | move to the pane left / down / up / right |
| `⌃⌥D` · `⌃⌥⇧D`          | `ctrl+alt+d` · `+shift+d`    | herdr         | split right · down |
| `⌃⌥Z`                   | `ctrl+alt+z`                 | herdr         | zoom the pane |
| `⌃⌥C` · `⌃⌥[` `⌃⌥]`     | `ctrl+alt+c` · `ctrl+alt+[ ]`| herdr         | new tab · previous / next tab |
| `⌃B` then `Q`           | `prefix` = `ctrl+b`          | herdr         | detach (everything keeps running) |
| `⇧↩`                    | `shift+enter`                | Ghostty       | newline in Claude Code / Codex prompts |
| `⌃R`                    | `C-r`                        | Helix         | reload every buffer after an agent run |
| `Space Y` · `Space P`   | `space y` · `space p`        | Helix         | yank · paste the system clipboard |

With VoiceOver on, ⌃⌥ is its modifier and macOS takes these keys first.

## 🐕 The collie

The sheep are the agents; the collie watches them so you don't have to.

- **Bark:** herdr's notification when an agent is done or needs input, shown by
  Ghostty (`[ui.toast] delivery = "terminal"`). Never for the tab you're on;
  states that flip back within 2 s are skipped.
- **Come:** click the notification to bring Ghostty forward, then **`⌃⌥A`** to
  land on the agent: the first one waiting for you, else the first one done.
- **Mark:** the `pasture.collie` plugin puts a 🐕 next to every agent waiting
  for you in the sidebar, and takes it off once it moves on or you focus it.
- **Herd:** **`⌃⌥S`** opens the board, blocked agents first; type a number to jump.

```
🐕 flock: 31 sheep · ⛔ 1 waiting on you · ✅ 2 done · 🏃 1 working

  1  ⛔  🧠 codex   api · 2      Review the auth change
  2  ✅  🤖 claude  web · 1      Add the settings page
  3  🏃  🤖 claude  api · 1      Editing auth middleware…
```

The collie only reads, tags and points: **it never answers an agent's prompts
or approvals for you.** Why a click alone can't pick the pane: the one notifier
that runs a command on click, Homebrew's `terminal-notifier`, is ad-hoc signed,
and macOS won't let it post notifications.

## 🗂️ How it is laid out

Each folder under `home/` is a [GNU Stow](https://www.gnu.org/software/stow/)
package that mirrors `$HOME`; `setup.sh` stows every one it finds, so adding a
package is just adding a folder. `plugins/` holds herdr plugins that `setup.sh`
links in place (`herdr plugin link`), so they run from this checkout. The rest of
the root is meta: `setup.sh`, `Brewfile`, `agents.conf`.

| Package    | Links to |
| ---------- | -------- |
| `ghostty`  | `~/.config/ghostty/config` |
| `herdr`    | `~/.config/herdr/config.toml` |
| `helix`    | `~/.config/helix/{config,languages}.toml` |
| `lazygit`  | `~/.config/lazygit/config.yml` |
| `starship` | `~/.config/starship.toml` |
| `bin`      | `~/.local/bin/pasture-{layout,duo,collie,icons,update}` |
| `zsh`      | `~/.config/pasture/pasture.zsh` |

| Plugin                      | Runs on | Does |
| --------------------------- | ------- | ---- |
| `plugins/herdr-pasture` (`pasture.tags`)  | herdr startup, new agent, new workspace | 🏷️ project and maker tags in the sidebar |
| `plugins/herdr-collie` (`pasture.collie`) | agent state change, pane focus | 🐕 marks agents waiting for you |

## 🎨 Colors & emoji

Ghostty's palette is the single source. Helix uses `base16_terminal`, herdr the
`terminal` theme (its default, catppuccin, would ignore Ghostty), and lazygit and
starship use terminal colors, so changing Ghostty's theme recolors everything.
The one exception: agent names in the sidebar are tinted in their maker's color,
in hex, because herdr's token styles take no ANSI color names.

pasture's own decorations are emoji, not Nerd Font glyphs, so they need no
patched font (herdr's agent-state icons still use the herdr-radar font that
`setup.sh` checks for):

- **starship prompt:** `📂 repo 🌿 branch 📝❓ ☕ v21 ⏱️ 4s` over a `🐑 ❯` input line.
- **herdr window title and tab bar:** `🐑 <workspace> · <tab>` and `🐑 pasture  🕐 14:52`.
- **pane labels and tab name** from `pasture-layout`: `🐚 shell`, `🤖 claude`
  (🧠 codex, ⚡ grok, 🪐 agy), `🌿 lazygit`.
- **sidebar tags:** project type per workspace and maker per agent. They are herdr
  metadata, so workspace names stay plain for scripts and the window title.

## 🐚 Shell

pasture does not own `~/.zshrc`. It ships `~/.config/pasture/pasture.zsh` (PATH,
`EDITOR=hx`, completions for herdr / gh / glab, the starship prompt); add one line
at the **end** of your `~/.zshrc`, after oh-my-zsh / `compinit`:

```zsh
source ~/.config/pasture/pasture.zsh
```

Starship replaces the oh-my-zsh theme because it is set up last; set
`ZSH_THEME=""` in `~/.zshrc` to skip loading a theme nobody sees.

## 🔧 Forge & quality CLIs

`gh` (GitHub), `glab` (GitLab) and `sonar` (SonarQube CLI cask) come from the
Brewfile. Logins never live in this repo; run them once per machine:

```bash
gh auth login
glab auth login --hostname <your gitlab host>
```

## 🔒 Trust

- **No secrets in this repo, ever:** logins stay in the macOS Keychain (gh, glab),
  machine-specific tweaks go in git-ignored `*.local` files.
- Brew formulae come from `homebrew/core`, `sonarqube-cli` from `homebrew/cask`.
  The agent CLIs are signed by their vendors' Apple Developer IDs.
- `starpls` is downloaded from its GitHub release and checked against a pinned
  sha256 before it is unpacked; bump `STARPLS_VERSION` and both hashes together.
- **herdr** sees every pane's output and can type into them, yet its binary is
  unsigned and installed with `curl | sh`. Install it only from the official
  site, and review third-party herdr plugins before adding them. Theme plugins
  that write `~/.config/herdr/config.toml` are editing this repo (it is a symlink).
- **pasture's own plugins run automatically** (see the table above). They only
  read pane and workspace info and write display metadata. Read them before
  linking.
- `pasture-duo` starts the reviewer read-only (Codex `--sandbox read-only`,
  Claude / Grok `--permission-mode plan`) and refuses reviewers without a
  read-only mode.

## 🚫 Not managed here

`~/.zshrc` itself, git, `~/.claude`, IntelliJ, on purpose. Put machine-specific
tweaks in `*.local` files (git-ignored).

## 🤝 Contributing

Issues and pull requests are welcome. Before sending one, check the scripts
still parse with macOS's own `/bin/bash` 3.2 and pass `shellcheck`:

```bash
for f in setup.sh home/bin/.local/bin/* plugins/*/*.sh; do /bin/bash -n "$f"; done
shellcheck setup.sh home/bin/.local/bin/* plugins/*/*.sh
zsh -n home/zsh/.config/pasture/pasture.zsh
```

## 🙏 Built on

[herdr](https://herdr.dev) · [Ghostty](https://ghostty.org) ·
[Helix](https://helix-editor.com) · [lazygit](https://github.com/jesseduffield/lazygit) ·
[starship](https://starship.rs) · [GNU Stow](https://www.gnu.org/software/stow/)

## 📄 License

[MIT](LICENSE) © kinhluan
