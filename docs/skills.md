# 📚 Skills for every agent

Skills are folders of instructions (a `SKILL.md` each) that an agent loads when
a task matches. pasture keeps one set for all agents, listed in
[`skills.conf`](../skills.conf). The default pack is
**[The Art of Agent Skills](https://github.com/kinhluan/skills)**
(`kinhluan/skills`, plugin `kinhluan-skills`): software delivery, architecture
(C4, DDD, ADRs), security, product, and academic research. Its `pasture` skill
teaches agents this setup: which pasture tool fits which task (worktrees,
stacks, herdr, the browser and desktop tools, the command library) and the
shared rules, such as never answering another agent's approval dialog.

```text
kinhluan/skills | kinhluan-skills@kinhluan
```

Each line is a GitHub repo and, when the repo ships one, its Claude Code
plugin. `pasture-skills` then installs every pack (`--list` shows what each
agent has):

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

Skill packs are instructions your agents follow: list only repos you trust and
read a pack before adding it ([security.md](security.md#-trust)).

If `~/.agents` was once created with `sudo`, nothing can write there:
`sudo chown -R "$USER" ~/.agents` fixes it, and `pasture-skills` warns about it.
