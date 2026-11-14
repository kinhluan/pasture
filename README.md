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
- **🌱 One task, one worktree.** `pasture-task <branch> [agent]` makes a git
  worktree with [Worktrunk](https://worktrunk.dev), opens a herdr workspace in
  it and sets up the layout, so parallel agents never share a working copy.
- **🪜 Stacked commits.** Sapling runs inside your existing git repos and
  worktrees; `⌃⌥G` shows the stack you are on.
- **📚 One set of skills for every agent.** `pasture-skills` installs the
  packs in `skills.conf` into Claude Code, Codex, Grok and Antigravity alike;
  by default [The Art of Agent Skills](https://github.com/kinhluan/skills).
- **🧰 Tested commands instead of one-off scripts.** `pasture <group> <command>`
  is a small library of scripts for the local CLIs (herdr, git, Sapling,
  glab, agent-browser) that agents run instead of writing their own, each
  labelled read, write or external.
- **🌐 A browser every agent can drive.** [agent-browser](https://agent-browser.dev)
  lets any agent with a shell open, click, fill and screenshot pages, including
  the JS-rendered and logged-in ones a plain fetch can't read.
  [agent-desktop](https://github.com/vercel-labs/agent-desktop) does the same
  for native Mac apps, once you allow it.
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
| Version control | `worktrunk` (`wt`), `sapling` (`sl`), `gh`, `glab` |
| JS and Python | `fnm` (Node), `pnpm`, `bun`, `uv` |
| Java | Eclipse Temurin 21, `maven` |
| Rust tools | `sccache`, `cargo-nextest`, `cargo-deny`, `cargo-edit`, `cargo-binstall` (Rust itself comes from rustup) |
| Agents' tools | `agent-browser`, `agent-desktop`, `sonarqube-cli` (`sonar`) |
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
| `pasture help` | 🧰 the command library: `pasture <group> <command>`, see below |
| `pasture-task <branch> [agent]` | 🌱 new worktree for the branch, a herdr workspace in it, the layout with the agent; `--done <branch>` closes and removes it |
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
  answer, the focused one and named ones (pasture-duo reviewers). Their tabs
  close too, unless another pane there still runs something (hx, a dev server,
  a build): those stay and are named. Answer `F` to also force-stop the ones
  that ignore their quit; `pasture agent sweep --tidy` closes idle tabs left
  from earlier.
  Idle agents hold memory — a few dozen push a 16GB Mac into swap — so this is
  the cheap fix; each one is written to a ledger, and
  `pasture agent sweep --recall` prints the `cd … && claude --continue` (or
  codex/grok) line to call one back. Headless: `pasture agent sweep --yes`.

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

## 🧰 The pasture command library

Agents tend to write a fresh shell script whenever they need to drive a CLI,
each time a little differently. `pasture` gives them tested ones instead:

```bash
pasture help                         # every command, with its safety level
pasture help mr stack                # usage and details of one
pasture list --json                  # the same, for agents
```

| Command | Safety | Does |
| ------- | ------ | ---- |
| `pasture pane tail <pane> [--wait REGEX]` | read | another pane's recent output, or wait until a pattern appears |
| `pasture web read <url>` | read | a page as text: plain fetch first, agent-browser when that comes back empty or walled |
| `pasture mr stack <search>` | read | open GitLab MRs as a stack: which branch sits on which, each MR's own vs visible diff, CI |
| `pasture agent ask <name> "<prompt>"` | write | prompt another agent, wait, print its answer; refuses when it is blocked on the user |
| `pasture mr fanout <branch>…` | external | move stacked branches onto the default branch (trunk-based), in a temporary worktree, force-push with lease |
| `pasture stack push <prefix> [--mr]` | external | push each commit of a Sapling stack to its own branch, optionally as a chain of MRs |
| `pasture sec pentest <dir\|url>…` | external | 🛡 Strix AI pentest of your own code or local app, on a copy, with a model the target's privacy allows |

**Safety levels.** `read` only reads. `write` changes local state and has
`--dry-run`. `external` touches other systems: it prints its plan and exits 3
unless given `--yes`, so an agent shows the plan and asks you first. Exit codes
are shared: 0 ok, 1 failed, 2 usage, 3 needs you, 4 timed out, 5 missing tool.

**Adding one.** A command is an executable file `cmds/<group>/<command>` whose
first lines declare `# summary:`, `# usage:` and `# safety:`; `cmds/lib.sh` has
the shared helpers. Commands of your own go in
`~/.config/pasture/cmds.local/<group>/<command>`, which is never committed and
wins over a built-in of the same name. Only these two places are read: a
repository you open cannot add commands.

## 🛡 Pentesting your own app

[Strix](https://github.com/usestrix/strix) runs a team of AI agents in a Docker
sandbox that read your code, run it and try real exploits, then report what
they could prove. It attacks what you point it at and sends what it sees to an
LLM, so pasture runs it through `pasture sec pentest`, which decides first:

```bash
uv tool install strix-agent                       # once; pasture-update keeps it current
export STRIX_LLM=anthropic/<model> LLM_API_KEY=…  # or a local model
pasture sec pentest ./services/api http://localhost:8080   # the plan
pasture sec pentest ./services/api http://localhost:8080 --yes
```

- **Targets.** Code (a directory inside a git repo, or a file) goes in as a
  copy in `~/.cache/pasture/pentest/<run>`, because Strix mounts targets
  writable. The copy holds what git tracks plus untracked files that are not
  ignored, so ignored `.env` files stay out, and has no symlinks. A URL must be
  loopback (`localhost`, `127.x`, `::1`, `host.docker.internal`) or a host
  listed in `~/.config/pasture/pentest-scope`. **List a host only when you own
  it or have written permission to test it**: Strix attacks it for real. That
  file is yours to write, never an agent's. Git URLs are refused; clone first.
- **Who sees it.** Code that is already public (a public repo, clean, HEAD on
  origin) may go to any model. Anything else, and any running app, only to a
  provider in `PASTURE_PRIVATE_PENTEST_PROVIDERS` (default `anthropic`) or a
  local model (`ollama`, `lm_studio`, or `LLM_API_BASE` on loopback). An
  endpoint set anywhere (`*_API_BASE` / `*_BASE_URL` in the environment or in
  Strix's saved config) counts: `anthropic/…` through a proxy is that proxy.
- **How much.** `--mode quick|standard|deep` (default quick), `--budget USD`
  (default 5). Exit 0 no findings, 1 findings or a failed run; the report stays
  in the run directory (`strix view` there opens it).
- **Not used:** `strix cloud` (uploads your code to strix.ai) and Strix's own
  skill pack, which would let an agent start a pentest without this check.

## 🌱 One task, one worktree

Two agents in one working copy step on each other: one's edits land in the
other's diff, builds and tests run on a mix. Each parallel task gets its own
git worktree instead, managed by [Worktrunk](https://worktrunk.dev) (`wt`):

```bash
pasture-task feature/PROJ-1234-login codex   # worktree + herdr workspace + layout
pasture-task feature/PROJ-1240-report        # a second task, claude by default
wt list                                      # every worktree, with status
pasture-task --done feature/PROJ-1234-login  # after it merged: close and remove
```

Worktrees go to `.worktrees/<branch>` inside the repo
(`home/worktrunk/.config/worktrunk/config.toml`). `pasture-task` adds
`.worktrees/` to the repo's local `.git/info/exclude`, so `git status` stays
clean, and warns when a Bazel repo lacks it in `.bazelignore`. The herdr
workspace is named after the branch, so the sidebar and the collie's board
show which task each agent is on.

`wt switch <branch>` jumps between worktrees in the shell (pasture.zsh loads its
shell integration). `wt merge` merges locally into the default branch; where
changes go through merge requests, push and open one instead, and run
`pasture-task --done` once it has landed: the branch is deleted only if merged.

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
  same time need a worktree each (`pasture-task`); each worktree has its own
  stack.

## 📚 Skills for every agent

Skills are folders of instructions (a `SKILL.md` each) that an agent loads when
a task matches. pasture keeps one set for all agents, listed in
[`skills.conf`](skills.conf). The default pack is
**[The Art of Agent Skills](https://github.com/kinhluan/skills)**
(`kinhluan/skills`, plugin `kinhluan-skills`): software delivery, architecture
(C4, DDD, ADRs), security, product, and academic research. Its `pasture` skill teaches
agents this setup: which pasture tool fits which task (worktrees, stacks,
herdr, the browser and desktop tools) and the shared rules, such as never
answering another agent's approval dialog.

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

## ☕ Java and 🦀 Rust

- **Java:** Homebrew installs Eclipse Temurin 21 and Maven. `pasture.zsh` sets
  `JAVA_HOME` to JDK 21 unless you set it yourself, and `jdk <version>` switches
  the current shell (`jdk` alone lists installed JDKs). For another version,
  add a cask such as `temurin@17`. Temurin is free to use at work; older Oracle
  JDK builds need a license there.
- **Rust:** install [rustup](https://rustup.rs) once; it is not in the
  Brewfile because it updates itself. `pasture-update` runs `rustup update`
  (it is listed in `agents.conf`), `setup.sh` adds the `rust-analyzer`
  component for Helix, and `pasture.zsh` puts `~/.cargo/bin` on PATH.
  Cargo manages dependencies (`cargo add`, `cargo update`, `cargo tree`);
  Homebrew adds the tools around it:

  | Tool | Use |
  | ---- | --- |
  | `sccache` | compile cache shared by every worktree and repo (`RUSTC_WRAPPER`, set in `pasture.zsh`) |
  | `cargo nextest run` | faster tests, compact output |
  | `cargo deny check` | RustSec advisories, licenses, sources and duplicate versions (configure with `deny.toml`) |
  | `cargo upgrade` | raise versions in `Cargo.toml`, majors included (`cargo update` only moves `Cargo.lock`) |
  | `cargo binstall <tool>` | install other cargo tools as prebuilt binaries |

  Commit `Cargo.lock` for applications. In a Bazel repo, Rust dependencies go
  through `rules_rust` and `crate_universe`, and Bazel does the caching.

## 📦 Node, pnpm, bun and uv

**Node** comes through [fnm](https://github.com/Schniz/fnm). `setup.sh` installs
the newest LTS as the default and `pasture-update` keeps it current. In a
project with `.nvmrc` or `.node-version` (looked up from the current directory
upwards, or `engines.node` in `package.json`), fnm switches to that version on
`cd` and offers to install it if missing. fnm is loaded after `~/.zshrc`, so it
wins over an nvm loaded there; `setup.sh` reminds you to remove nvm's lines,
which slow every new shell. Pin Node per project with a `.nvmrc` rather than
relying on the default.

pnpm, bun and uv come from Homebrew and update with `pasture-update --all`.
`pasture.zsh` puts their global bin dirs on PATH (`~/Library/pnpm` for
`pnpm add -g`, `~/.bun/bin`; uv tools land in `~/.local/bin`) and loads
completions for pnpm, uv and fnm. Their stores and caches are shared by default, so
the worktrees of one repo reuse downloads.

- **One copy of each.** A second install, such as uv's standalone installer in
  `~/.local/bin` or a pnpm from `npm i -g`, comes first on PATH and goes stale.
  `setup.sh` warns and prints the command that removes it.
- **pnpm versions per repo.** Homebrew's pnpm is the newest major. A repo that
  needs an older one should pin it in `package.json`
  (`"packageManager": "pnpm@10.28.1"`); pnpm then runs that version there.
  Check before removing an older global pnpm, since a newer pnpm may rewrite an
  old lockfile.
- **No registry logins here.** `~/.npmrc` and private Python indexes hold
  tokens; they stay on the machine, never in this repo.

## 🖥️ Agents and the desktop

[agent-desktop](https://github.com/vercel-labs/agent-desktop) is agent-browser
for native apps: it reads an app's accessibility tree (no screenshots, no
pixel matching) and acts on refs.

```bash
agent-desktop snapshot --app Finder -i   # interactive elements, each with a ref
agent-desktop click @s8f3k2p9:e8         # refs belong to that snapshot
agent-desktop skills get desktop         # the guide agents should read first
```

It does nothing until macOS allows it, and that permission goes to the app it
runs in: **Ghostty**. Granting Ghostty Accessibility (and Screen Recording, for
screenshots) lets every shell and every agent in Ghostty read and operate
every app on your Mac. Run `agent-desktop permissions --guide` only if you want
that, and consider revoking it when you are done. Snapshots can contain
private content from other apps; keep them out of logs and uploads.

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
(PATH, `EDITOR=hx`, completions for herdr, gh and glab, Worktrunk's shell
integration, the starship prompt).
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
they run from this clone, and `cmds/` holds the `pasture` command library. The
root holds `setup.sh`, `Brewfile`, `agents.conf` and `skills.conf`.

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
for f in setup.sh home/bin/.local/bin/* plugins/*/*.sh cmds/lib.sh cmds/*/*; do /bin/bash -n "$f"; done
shellcheck -x setup.sh home/bin/.local/bin/* plugins/*/*.sh cmds/lib.sh cmds/*/*
zsh -n home/zsh/.config/pasture/pasture.zsh
herdr config check
```

## 🙏 Built on

[herdr](https://herdr.dev) · [Ghostty](https://ghostty.org) ·
[Helix](https://helix-editor.com) · [lazygit](https://github.com/jesseduffield/lazygit) ·
[starship](https://starship.rs) · [Worktrunk](https://worktrunk.dev) ·
[Sapling](https://sapling-scm.com) · [Strix](https://github.com/usestrix/strix) · [agent-browser](https://agent-browser.dev) ·
[agent-desktop](https://github.com/vercel-labs/agent-desktop) · [GNU Stow](https://www.gnu.org/software/stow/)

## 📄 License

Released under the [MIT License](LICENSE). Use it, fork it, make it your own
pasture: keep the copyright notice and the license text with any copy.

<div align="center">

<br>

Made with 🐑 by [kinhluan](https://github.com/kinhluan)

<sub>Copyright © 2026 kinhluan</sub>

</div>
