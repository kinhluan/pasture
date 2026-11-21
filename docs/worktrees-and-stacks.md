# 🌱 Worktrees and 🪜 stacks

Parallel agents each get their own working copy; one task can be split into a
stack of small commits, one merge request each.

## One task, one worktree

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
([`config.toml`](../home/worktrunk/.config/worktrunk/config.toml)).
`pasture-task` adds `.worktrees/` to the repo's local `.git/info/exclude`, so
`git status` stays clean, and warns when a Bazel repo lacks it in
`.bazelignore`. The herdr workspace is named after the branch, so the sidebar,
the collie's board and `pasture flow board` show which task each agent is on.

### Look before you code: `pasture repo who`

Before an agent starts editing a repo, `pasture repo who` shows who is
already there:

```
🌿 . (master)  ✎ 15 uncommitted
     💤 wV:p1  claude pull the latest code
🌿 .worktrees/feature-login (feature-login) ← here
     (no agent)
```

git refuses to check out one branch in two worktrees, but nothing stops a
second agent from working in a worktree another agent is already editing.
`pasture repo who --check` exits 3 when an agent other than this pane is in the
same worktree; the agent should make its own (`pasture-task <branch>`) instead.

`wt switch <branch>` jumps between worktrees in the shell (pasture.zsh loads its
shell integration). `wt merge` merges locally into the default branch; where
changes go through merge requests, push and open one instead, and run
`pasture-task --done` once it has landed: the branch is deleted only if merged.

## Stacks with Sapling

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

`⌃⌥G` (or `pasture-stack [dir]`) shows the stack of the focused pane's repo;
press `w` to open it in Sapling's browser UI (`sl web`).

- **Detached HEAD.** `sl commit` on a branch moves the branch, but `sl prev`,
  `sl next` and `sl goto` leave git's HEAD detached. Detached, a worktree no
  longer holds its branch: another worktree can check it out, and `wt list` and
  `pasture-task --done` stop finding the task. pasture's Sapling hooks run
  `pasture stack attach` after each of them, which puts HEAD back on the branch
  once you are at the top of the stack again (and fast-forwards the branch if
  you committed on top while detached). Mid-stack it stays detached until
  `sl top`. `pasture repo who` shows a detached worktree's task branch.
- **Parallel work.** A stack is a sequence in one working copy. Two tasks at the
  same time need a worktree each (`pasture-task`); each worktree has its own
  stack.

## Stacks as merge requests (GitLab)

`sl pr` (stacked pull requests) is GitHub only. On GitLab, pasture's commands
do the pushing and show the result:

| Command | Does |
| ------- | ---- |
| `pasture stack push <prefix> [--mr]` | push commit *n* of the Sapling stack, bottom first, to branch `<prefix>-<n>-<slug of its title>`; `--mr` opens a GitLab MR per branch, each targeting the branch below it |
| `pasture mr stack <search>` | open MRs as a stack: which branch sits on which, each MR's own diff vs the cumulative one, CI |
| `pasture mr fanout <branch>…` | once what they share has merged, replay each branch's own commits onto the default branch, so each MR shows only its own diff and merges on its own |

Rerun `stack push` after `sl amend` or `sl absorb`: only changed branches are
pushed. `stack push` and `mr fanout` force-push with a lease (if someone
pushed to the branch since the plan, the push is refused) and are `external`:
they print the plan and act only with `--yes`. `mr fanout` rebases in a
temporary worktree, so your checkout is untouched. `mr stack` and `--mr` need
`glab auth login`.

All flags: [commands.md](commands.md).
