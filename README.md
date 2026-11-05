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
setup, plus a few small scripts and a 🐕 border collie that watches the agents
(the sheep) for you.

## ✨ What you get

- **🧭 One layout per repo.** `pasture-layout` turns a herdr tab into shell,
  agent and lazygit. Helix is a popup (`⌃⌥E`), not a pane, so the agent keeps
  the width.
- **🐕 A collie for the flock.** A notification when an agent is done or waiting
  for you, `⌃⌥A` to land on it, a 🐕 in the sidebar until you look, `⌃⌥S` for a
  board of every agent, `⌃⌥X` to send the idle ones home.
- **👯 Writer and reviewers.** `pasture-duo` starts one writer and up to three
  read-only reviewers (any mix of the four agents) and hands the writer a
  review-loop prompt.
- **🪜 Stacked commits.** Sapling runs inside your existing git repos and
  worktrees; `⌃⌥G` shows the stack you are on.
- **📚 One set of skills for every agent.** `pasture-skills` installs the
  packs in `skills.conf` into Claude Code, Codex, Grok and Antigravity alike;
  by default [The Art of Agent Skills](https://github.com/kinhluan/skills).
- **🌐 A browser every agent can drive.** [agent-browser](https://agent-browser.dev)
  lets any agent with a shell open, click, fill and screenshot pages, including
  the JS-rendered and logged-in ones a plain fetch can't read.
- **🏷️ A sidebar that reads at a glance.** Each project is tagged with its type
  (🏗️ Bazel, ☕ Java, 🐍 Python, 🟢 Node…) and each agent with its maker
  (🟠 Anthropic, 🟢 OpenAI, ⚫ xAI, 🔵 Google), kept fresh by a herdr plugin.
- **🎨 One palette.** Ghostty's theme colors herdr, Helix, lazygit and the prompt.
- **🔄 One update command.** `pasture-update` updates herdr and every agent CLI.
- **🔒 Nothing secret inside.** Logins stay in the Keychain; the repo is safe to
  fork.

## 🚀 Install

You need macOS and [Homebrew](https://brew.sh). herdr and the agent CLIs are not
in the Brewfile because they ship their own self-updating installers:

```bash
curl -fsSL https://herdr.dev/install.sh | sh   # read it first, see Trust below
# plus whichever agents you use: claude, codex, grok, agy
```

Then clone pasture anywhere and run the setup:

```bash
git clone https://github.com/kinhluan/pasture.git
cd pasture
./setup.sh --dry-run   # show what would be linked or backed up; changes nothing
./setup.sh
```

The links point back into the clone, so keep it where it is (if you move it,
run `./setup.sh` again). `setup.sh` does, in order:

1. `brew bundle` with the [Brewfile](Brewfile), and `starpls` (the Bazel
   language server) from its GitHub release, checksum-verified.
2. Moves any existing config that would be replaced to
   `~/.pasture-backup/<timestamp>/` (owner-only). Nothing is overwritten.
3. Links every package under `home/` into `$HOME` with GNU Stow.
4. Installs herdr's integrations for the agents you have and links pasture's
   herdr plugins.
5. Installs the skill packs in [`skills.conf`](skills.conf) for every agent
   (`pasture-skills`).
6. Checks herdr's config, Helix's language servers, logins and the `.zshrc` line,
   and warns about anything missing.

`./setup.sh --unstow` removes the links and unlinks the plugins.

Once per machine:

1. Add `source ~/.config/pasture/pasture.zsh` at the **end** of `~/.zshrc`
   (see [Shell](#-shell)).
2. Log in: `gh auth login` and `glab auth login --hostname <your gitlab host>`.
3. Allow notifications for **Ghostty** in System Settings › Notifications.
4. Restart Ghostty, run `herdr`, then `pasture-layout` inside a repo.

## 📦 What the Brewfile installs

| Group | Tools |
| ----- | ----- |
| Core | `stow`, `jq`, `helix`, `lazygit`, `starship` |
| Version control | `sapling` (`sl`), `gh`, `glab` |
| Agents' tools | `agent-browser`, `sonarqube-cli` (`sonar`) |
| Editors | Visual Studio Code, Antigravity IDE (an app you already installed by hand is adopted, not reinstalled) |
| Bazel | `bazelisk` (as `bazel`; runs the version in each repo's `.bazelversion`), `buildifier` |
| Language servers | `jdtls`, `pyright`, `ruff`, `marksman`, `taplo`, `yaml-language-server`, plus `starpls` from setup.sh |
| Lint | `shellcheck` |

The editors update themselves, so `brew upgrade` leaves them alone.

## 🧑‍🌾 Daily use

| Command | Does |
| ------- | ---- |
| `herdr` | attach to the persistent session; agents keep running when Ghostty closes |
| `pasture-layout [agent]` | shell, agent and lazygit in this tab; agent is `claude` (default), `codex`, `grok` or `agy` |
| `pasture-duo [writer] [reviewer…]` | a writer and 1–3 read-only reviewers, e.g. `pasture-duo claude codex grok agy` (default: claude, codex) |
| `pasture-collie` | 🐕 the flock board; `--list` only prints it, `--jump` goes to the agent that needs you, `--sweep` quits idle agents |
| `pasture-skills` | 📚 install or update the skill packs for every agent; `--list` shows what each has |
| `pasture-stack [dir]` | 🪜 the Sapling stack of a repo |
| `pasture-icons` | re-tag the sidebar now (the plugin normally does it) |
| `pasture-update` | update herdr, Claude Code, Codex, Grok Build and Antigravity; skips missing tools, keeps going on failure |
| `pasture-update --all` | the same, plus `brew bundle` and `pasture-skills` |

`pasture-layout` takes `PASTURE_TOP` (top row height, default 0.65) and
`PASTURE_LEFT` (shell width, default 0.3). Agents and their update commands live
in [`agents.conf`](agents.conf).

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

## 🐕 The collie

The agents are the sheep; the collie watches them so you don't have to.

- **Bark.** herdr notifies you when an agent is done or needs input, through
  Ghostty. Never for the tab you are on, and not for states that flip back
  within 2 seconds.
- **Come.** Click the notification to bring Ghostty forward, then `⌃⌥A` to land
  on the first agent waiting for you, or else the first one done.
- **Mark.** The `pasture.collie` plugin puts a 🐕 next to every agent waiting for
  you in the sidebar, and removes it when the agent moves on or you focus it.
- **Herd.** `⌃⌥S` opens the board, most urgent first: ⛔ waiting, ✅ done,
  🏃 working, 💤 idle. Type a number to jump.
- **Send home.** `⌃⌥X` quits every idle agent after one y/N, using each agent's
  own quit command so its session can be resumed. It skips agents with an unread
  answer, the focused one and named ones (pasture-duo reviewers). Panes stay
  open as shells.

The collie only reads, tags and points: **it never answers an agent's prompts
or approvals for you.** A click can't jump straight to the pane because the only
notifier that runs a command on click, Homebrew's `terminal-notifier`, is
ad-hoc signed and macOS won't let it post notifications.

## 👯 Writer and reviewers

Run `pasture-duo` at the root of a repo inside herdr. The pane you are in
becomes the writer; reviewers start beside it, each read-only and named, so the
writer can reach them with `herdr agent prompt`. A review-loop prompt is copied
to your clipboard: paste it into the writer and replace `<TASK>`.

The prompt tells the writer to ask every reviewer at once, wait for all of them,
merge the findings and settle disagreements: a security, data-loss or
broken-build finding is fixed even if only one reviewer raised it; otherwise the
majority decides; a tie goes to you. Reviewers only talk to the writer, never
to each other. `PASTURE_DUO_ROUNDS` caps the rounds (default 2).

## 🪜 Stacks with Sapling

Sapling (`sl`) works inside any git repo or git worktree as it is: no `sl clone`,
nothing to migrate, and git, lazygit and starship keep working next to it. Use
it to split one task into a stack of small commits, one per merge request, and
to edit the middle of the stack without a rebase:

```bash
sl commit -m "step 1"; sl commit -m "step 2"   # build the stack
sl prev; sl amend                              # fix step 1; step 2 follows
sl absorb                                      # fold edits into the commits they belong to
sl stack                                       # just this stack (pasture alias)
sl push --to feature/PROJ-1234-step-1          # publish to a git branch
```

`⌃⌥G` shows the stack of the focused pane's repo; press `w` to open it in
Sapling's browser UI (`sl web`).

- **Detached HEAD.** `sl` leaves git's HEAD detached. Push with
  `sl push --to <branch>`; a `git commit` there, yours or an agent's, moves no
  branch.
- **GitLab.** `sl pr` (stacked pull requests) is GitHub only. On GitLab, push
  each step to its own branch and open the merge requests with `glab`.
- **Parallel work.** A stack is a sequence in one working copy. Two tasks at the
  same time still need one git worktree each.

## 📚 Skills for every agent

Skills are folders of instructions (a `SKILL.md` each) that an agent loads when
a task matches. pasture keeps one set for all agents, listed in
[`skills.conf`](skills.conf). The default pack is
**[The Art of Agent Skills](https://github.com/kinhluan/skills)**
(`kinhluan/skills`, plugin `kinhluan-skills`): software delivery, architecture
(C4, DDD, ADRs), security, product, and academic research.

```text
kinhluan/skills | kinhluan-skills@kinhluan
```

Each line is a GitHub repo and, when the repo ships one, its Claude Code
plugin. `pasture-skills` then installs every pack:

| Agent | Gets the pack as | Global folder |
| ----- | ---------------- | ------------- |
| Claude Code | the plugin (with its router hook), names like `kinhluan-skills:c4-model` | managed by `claude plugin` |
| Codex | bare skills | `~/.agents/skills` |
| Grok Build | bare skills | `~/.grok/skills` |
| Antigravity | bare skills | `~/.gemini/antigravity/skills` |

Bare skills go through the [`skills`](https://github.com/vercel-labs/skills)
CLI, run with `npx` at a pinned version (`PASTURE_SKILLS_CLI`), so Node.js is
needed. A pack without a plugin goes to Claude Code as bare skills too. The
VS Code extensions of Claude Code and Codex read the same folders. Add your own
packs as more lines; restart running agents to load new skills.

If `~/.agents` was once created with `sudo`, nothing can write there:
`sudo chown -R "$USER" ~/.agents` fixes it, and `pasture-skills` warns about it.

## 🌐 Agents and the web

A plain fetch is cheap and fine for static, public pages. For pages rendered by
JavaScript, behind a login or needing clicks, any agent can use
`agent-browser`:

```bash
agent-browser open example.com
agent-browser snapshot -i     # interactive elements only, each with a ref like @e1
agent-browser click @e1
agent-browser read            # the page's text after JavaScript has run
```

Agents learn the full tool with `agent-browser skills get core`. Pointed at a
logged-in browser profile, an agent can do anything you can on those sites;
use a separate profile for anything sensitive.

## 🎨 Colors and emoji

Ghostty's palette is the single source: Helix uses `base16_terminal`, herdr its
`terminal` theme, and lazygit and starship terminal colors, so changing
Ghostty's theme recolors everything. The one exception is agent names in the
sidebar, tinted in their maker's color in hex, because herdr's token styles
take no ANSI color names.

pasture's own decorations are emoji, not Nerd Font glyphs, so no patched font
is needed (herdr's agent-state icons still use the herdr-radar font, which
`setup.sh` checks for):

- **Prompt:** `📂 repo 🌿 branch 📝❓ ☕ v21 ⏱️ 4s` over a `🐑 ❯` input line.
- **herdr title and tab bar:** `🐑 <workspace> · <tab>` and `🐑 pasture  🕐 14:52`.
- **Pane labels** from `pasture-layout`: `🐚 shell`, `🤖 claude` (🧠 codex,
  ⚡ grok, 🪐 agy), `🌿 lazygit`.
- **Sidebar tags:** project type per workspace, maker per agent. They are herdr
  metadata, so workspace names stay plain for scripts and the window title.

## 🐚 Shell

pasture does not own `~/.zshrc`. It ships `~/.config/pasture/pasture.zsh`
(PATH, `EDITOR=hx`, completions for herdr, gh and glab, the starship prompt).
Add one line at the **end** of `~/.zshrc`, after oh-my-zsh or `compinit`:

```zsh
source ~/.config/pasture/pasture.zsh
```

Starship replaces any oh-my-zsh theme because it loads last; set `ZSH_THEME=""`
to skip loading a theme nobody sees.

## 🗂️ Layout of this repo

Each folder under `home/` is a [GNU Stow](https://www.gnu.org/software/stow/)
package that mirrors `$HOME`. `setup.sh` stows every one it finds, so adding a
package is adding a folder. `plugins/` holds herdr plugins, linked in place so
they run from this clone. The root holds `setup.sh`, `Brewfile`,
`agents.conf` and `skills.conf`.

| Package | Links to |
| ------- | -------- |
| `ghostty` | `~/.config/ghostty/config` |
| `herdr` | `~/.config/herdr/config.toml` |
| `helix` | `~/.config/helix/{config,languages}.toml` |
| `lazygit` | `~/.config/lazygit/config.yml` |
| `starship` | `~/.config/starship.toml` |
| `sapling` | `~/Library/Preferences/sapling/sapling.conf` |
| `zsh` | `~/.config/pasture/pasture.zsh` |
| `bin` | `~/.local/bin/pasture-{layout,duo,collie,stack,skills,icons,update}` |

| Plugin | Runs on | Does |
| ------ | ------- | ---- |
| `plugins/herdr-pasture` (`pasture.tags`) | herdr start, new agent, new workspace | 🏷️ project and maker tags in the sidebar |
| `plugins/herdr-collie` (`pasture.collie`) | agent state change, pane focus | 🐕 marks agents waiting for you |

## 🔒 Trust

- **No secrets in this repo.** Logins stay in the macOS Keychain (gh, glab);
  machine-specific tweaks go in git-ignored `*.local` files. Sapling takes your
  name and email from git config.
- Formulae come from `homebrew/core`, casks from `homebrew/cask`. The agent CLIs
  are signed by their vendors' Apple Developer IDs.
- **Skill packs are instructions your agents follow.** Only list repos you
  trust in `skills.conf`, and read a pack before adding it. The `skills` CLI is
  pinned so an update can't change what runs.
- `starpls` is checked against a pinned sha256 before it is unpacked; bump
  `STARPLS_VERSION` and both hashes together.
- **herdr** sees every pane's output and can type into them, yet its binary is
  unsigned and installed with `curl | sh`. Install it only from the official
  site, and review third-party herdr plugins before adding them. Theme plugins
  that write `~/.config/herdr/config.toml` are editing this repo, since it is a
  link.
- **pasture's plugins run automatically.** They only read pane and workspace
  info and write display metadata. Read them before linking.
- **Reviewers are read-only, mostly by permission.** Only Codex's
  (`--sandbox read-only`) is enforced by the OS. Claude and Grok
  (`--permission-mode plan`) and Antigravity (`--mode plan --sandbox`) ask before
  an edit, so deny it; the collie marks a reviewer that asks with a 🐕.

## 🚫 Not managed here

`~/.zshrc` itself, git config, `~/.claude`, IntelliJ, and the settings and
extensions of VS Code and Antigravity IDE (only the apps are installed). Put
machine-specific tweaks in `*.local` files.

## 🤝 Contributing

Issues and pull requests are welcome. Scripts must parse with macOS's own
`/bin/bash` 3.2 and pass `shellcheck`:

```bash
for f in setup.sh home/bin/.local/bin/* plugins/*/*.sh; do /bin/bash -n "$f"; done
shellcheck setup.sh home/bin/.local/bin/* plugins/*/*.sh
zsh -n home/zsh/.config/pasture/pasture.zsh
herdr config check
```

## 🙏 Built on

[herdr](https://herdr.dev) · [Ghostty](https://ghostty.org) ·
[Helix](https://helix-editor.com) · [lazygit](https://github.com/jesseduffield/lazygit) ·
[starship](https://starship.rs) · [Sapling](https://sapling-scm.com) ·
[agent-browser](https://agent-browser.dev) · [GNU Stow](https://www.gnu.org/software/stow/)

## 📄 License

Released under the [MIT License](LICENSE). Use it, fork it, make it your own
pasture: keep the copyright notice and the license text with any copy.

<div align="center">

<br>

Made with 🐑 by [kinhluan](https://github.com/kinhluan)

<sub>Copyright © 2026 kinhluan</sub>

</div>
