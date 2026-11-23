# 👯 Reviews: code with `pasture-duo`, docs with fresh eyes

Two ways to get a second opinion. `pasture-duo` puts reviewers beside the agent
writing the code. `pasture doc review` starts reviewers that know nothing but
the doc in front of them.

## Writer and reviewers: `pasture-duo`

Run `pasture-duo` at the root of a repo inside herdr:

```bash
pasture-duo                          # writer claude, reviewer codex
pasture-duo claude codex grok agy    # writer claude, three reviewers
```

The pane you are in becomes the writer; reviewers start beside it, each named,
so the writer can reach them with `herdr agent prompt` (or
`pasture agent ask <name> "<prompt>"`, which waits and prints the answer).
They are meant to be read-only: Codex is held to it by its OS sandbox; Claude,
Grok and Antigravity start in plan mode, which asks you before any edit (see
[Trust](security.md#-trust)). A review-loop prompt is copied to your
clipboard: paste it into the writer and replace `<TASK>`.

The prompt tells the writer to ask every reviewer at once, wait for all of them,
merge the findings and settle disagreements: a security, data-loss or
broken-build finding is fixed even if only one reviewer raised it; otherwise the
majority decides; a tie goes to you. Reviewers only talk to the writer, never
to each other. `PASTURE_DUO_ROUNDS` caps the rounds (default 2).

## 🐠 Fresh eyes on a doc: `pasture doc review`

`pasture-duo` reviews code with agents that sit beside the writer. A design doc
needs a different reader: one with no history. `pasture doc review <file>`
starts every reviewer as a **new headless agent**. Each gets only the doc's path
and a persona brief, so it has no context **because of how it starts**, not
because it was told to ignore what it saw. It runs one per vendor, so their
blind spots differ:

```sh
pasture doc review docs/design.md --yes              # 4 personas × allowed vendors
pasture doc review README.md --personas naive-reader --vendors claude,grok --yes
```

Personas ([`cmds/doc/personas/`](../cmds/doc/personas/)):

| Persona | Asks |
| ------- | ---- |
| **zoom-out** | is this the simplest thing, does the code already have it |
| **naive-reader** | reads only the doc: where does a newcomer get lost |
| **critic** | failure modes, security, claims the code contradicts |
| **readiness** | what is still undecided before anyone can build it |

They are inspired by the [Elephant-Goldfish Model](https://egm.dev).

### What a reviewer can touch

No reviewer can change anything, or read outside what it reviews. Each runs
under a macOS sandbox (`sandbox-exec`) that refuses reading or writing
anything in your home folder except reading the tree under review and that
agent's login file. A doc that tells a reviewer to open `~/.ssh` gets
"Operation not permitted".

| Agent | Starts with |
| ----- | ----------- |
| Claude | an empty directory, no settings, hooks, plugins, MCP servers or auto-memory; only Read/Grep/Glob (the account email from your login is still in its context) |
| Grok | plan mode with only its read, list and grep tools, and an empty home of its own: no transcripts, memory, skills, plugins or MCP servers |
| Codex | no tools at all, since its own sandbox cannot run inside another: the doc goes in its prompt and it reviews the doc alone, not the code; an empty home of its own, like Grok |

### Who may see the doc

**The doc, and anything a reviewer reads, goes to every vendor used.** What
they read decides who may see it:

| The doc is… | Reviewers read | Vendors |
|---|---|---|
| in a public repo, pushed unchanged (checked with origin itself, not a local ref) | a `git archive` snapshot of origin's default branch: only what is already public | Claude, Codex, Grok |
| in any other repo, or not yet pushed | your working tree | `$PASTURE_PRIVATE_REVIEW_VENDORS` (default `claude`) |
| not in a git repo | a copy of the doc alone, never the folder around it | the same |

Widen `PASTURE_PRIVATE_REVIEW_VENDORS` only as your employer's rules allow.
Asking for a vendor the policy refuses exits 3. Like every `external` command,
it prints its plan and needs `--yes`. Findings come back sorted
⛔ blocker → 🔶 major → minor. The raw answers stay in
`~/.cache/pasture/reviews/`.
