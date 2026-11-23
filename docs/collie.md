# 🐕 The collie and the flock

The agents are the sheep; the collie watches them so you don't have to. This
page covers the collie, what an agent is really running before you stop it,
where every task stands, and how busy the Mac is.

## The collie

- **Bark.** herdr notifies you when an agent is done or needs input, through
  Ghostty. Never for the tab you are on, and not for states that flip back
  within 2 seconds.
- **Come.** Click the notification to bring Ghostty forward, then `⌃⌥A` to land
  on the first agent waiting for you, or else the first one done.
- **Mark.** The `pasture.collie` plugin puts a 🐕 next to every agent waiting for
  you in the sidebar, and removes it when the agent moves on or you focus it.
- **Herd.** `⌃⌥S` opens the board, most urgent first: ⛔ waiting, ✅ done,
  🏃 working, 💤 idle. Type a number to jump.
- **Send home.** `⌃⌥X` runs `pasture agent sweep` in a popup: it quits every
  idle agent after one y/N, typing each agent's own quit command (`/exit`,
  `/quit`) so its session can be resumed. It skips agents with an unread
  answer (✅ done), the focused one and named ones (agents started with a
  name, as `pasture-duo` starts its reviewers). Their tabs
  close too, unless another pane there still runs something (hx, a dev server,
  a build): those stay and are named. Answer `F` to also force-stop the ones
  that ignore their quit; `pasture agent sweep --tidy` closes idle tabs left
  from earlier.

Idle agents hold memory (a few dozen push a 16GB Mac into swap), so sweeping
is the cheap fix. Each swept agent is written to a ledger
(`~/.cache/pasture/swept.tsv`), and `pasture agent sweep --recall` prints the
`cd … && claude --continue` (or codex/grok) line to call one back. Headless:
`pasture agent sweep --yes`.

`pasture-collie` is the same from a shell: `--list` only prints the board,
`--jump` goes to the agent that needs you, `--sweep` quits idle agents.

The collie reads, tags and points, and stops or quits an agent only when you
press the key and answer y: **it never answers an agent's prompts or approvals
for you.** A click can't jump straight to the pane because the only
notifier that runs a command on click, Homebrew's `terminal-notifier`, is
ad-hoc signed and macOS won't let it post notifications.

## 🔎 Before you stop an agent: `pasture agent ps`

herdr's idle or done says the *agent* settled, not that it left nothing
running. `pasture agent ps <pane>` (or `--all`) joins herdr's view with the
process tree and `lsof`:

- the agent's status, worktree and branch;
- its root process and its MCP servers;
- every descendant, so a dev server it started in the background shows up;
- the TCP ports it listens on and the hosts it talks to.

A ⚠ marks a settled agent that still holds a listening port or burns CPU in a
child: the sleeping sheep that left the stove on. `--json` for agents.

## ⛔ Stopping one that won't stop: `pasture agent stop`

`pasture agent stop <pane>` ends an agent whether or not it cooperates, in
three steps: its own quit command with a deadline (`--timeout`, default 10s),
then `herdr pane close`, then `TERM` and `KILL` for whatever survives.
`--force` skips the polite step. It is `external`: it prints the plan and acts
only with `--yes`.

An agent must not stop another agent on its own (a looping or hostile one could
silence its reviewer), so this is for you to run, or for an agent to run after
you said yes. Sending a quit is not answering an approval dialog: if the agent
is blocked on one, the polite step fails and the stop escalates; it never
clicks through the dialog.

## 🗺️ Where every task stands: `pasture flow board`

With one agent per worktree per branch, "what stage is each task at" is spread
over herdr, git and the forge. `pasture flow board` infers a stage for each
agent's worktree from signals the task did not have to report:

| Stage | Means |
| ----- | ----- |
| 🌱 spawned | worktree and agent, no commit yet |
| ⌨️ coding | commits not pushed, a dirty tree, or the agent working |
| 📤 review-ready | pushed, no PR open yet |
| 👀 in-review | PR open, awaiting review |
| 🔧 changes | PR open, changes requested |
| 🔁 ci | PR open, checks running or failing |
| ✅ mergeable | PR open, approved and green |
| 🔀 merged | merged: the worktree can go (`pasture-task --done`) |
| ⛔ blocked | the agent is waiting on you (shown on top of its stage) |

PR data comes from `gh`, one call per GitHub repo, in parallel. `--no-pr`
stays offline and shows only the local stages; `--json` for agents.

## 📈 How busy the Mac is: `pasture sys line`

The right side of herdr's tab bar runs `pasture sys line` every 5 seconds:

```text
load 1.3× ▂▃▅▇  mem 61% ▃▄▆█
```

- **load** is the 1-minute load average divided by the CPU count. 1.0× means
  every core is busy; above 1 the machine is oversubscribed, the number that
  matters while several agents and builds run.
- **mem** counts active, wired and compressed memory against total RAM, so it
  tracks real pressure and swap risk rather than Activity Monitor's "used".

The sparklines are the recent trend, kept in a tiny ring buffer under
`~/.cache/pasture`. It reads `sysctl` and `vm_stat` only, so measuring adds no
load. `--load-only`, `--mem-only`, `--width N` and `--plain` fit it into other
status bars or prompts.

All flags of every command: [commands.md](commands.md).
