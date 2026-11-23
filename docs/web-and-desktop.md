# 🌐 Agents on the web and 🖥️ the desktop

Any agent with a shell can read web pages, drive a real browser, and, once you
allow it, operate native Mac apps.

## Reading a page: `pasture web read`

```bash
pasture web read https://example.com/docs        # text of the page
pasture web read https://app.example.com --browser --max-chars 5000
```

A plain fetch (curl + macOS `textutil`) comes first because it is fast and
cheap. When it errors, or returns a page that is nearly empty or a JavaScript
or bot wall, the command falls back to agent-browser, which runs JavaScript.
`--browser` skips the fetch. The first line of the output says which way was
used; the text is cut at `--max-chars` (default 20000).

Only `http(s)` URLs are accepted. Because agents run `read` commands freely,
the browser it falls back to is **never your logged-in one**: a fresh session
per call, closed afterwards, with every `AGENT_BROWSER_*` variable removed and
an empty config in place of `~/.agent-browser/config.json`. Pages that need
your login are for `agent-browser --profile …`, which you choose to run.

## Driving a browser: agent-browser

For pages rendered by JavaScript, behind a login or needing clicks, any agent
can use [agent-browser](https://agent-browser.dev):

```bash
agent-browser open example.com
agent-browser snapshot -i     # interactive elements only, each with a ref like @e1
agent-browser click @e1
agent-browser read            # the page's text after JavaScript has run
```

Agents learn the full tool with `agent-browser skills get core`. Pointed at a
logged-in browser profile, an agent can do anything you can on those sites;
use a separate profile for anything sensitive.

Each herdr pane gets its own browser: `pasture.zsh` sets
`AGENT_BROWSER_SESSION=pane-<pane id>`, so agents running side by side never
share tabs or `@e` refs. Each session is a separate Chrome, which costs memory;
`agent-browser session list` shows them and `agent-browser close --all` closes
them. Set `AGENT_BROWSER_SESSION` yourself to share one browser on purpose.

## Operating Mac apps: agent-desktop

[agent-desktop](https://github.com/vercel-labs/agent-desktop) is agent-browser
for native apps: it reads an app's accessibility tree (no screenshots, no
pixel matching) and acts on refs.

```bash
agent-desktop snapshot --app Finder -i   # interactive elements, each with a ref
agent-desktop click @s8f3k2p9:e8         # refs belong to that snapshot
agent-desktop skills get desktop         # the guide agents should read first
agent-desktop skills get platform        # then the macOS part: permissions, quirks
```

By default it acts only through the accessibility API. Hover, drag,
double-click and clicks at screen coordinates move the real mouse and need
`--headed`, so an agent has to ask for them explicitly.

**One agent at a time.** Unlike agent-browser, there is no per-pane session:
the screen, keyboard focus and mouse belong to the whole Mac. Two agents
driving apps at once steal focus from each other, so give desktop tasks to a
single agent.

> [!WARNING]
> It does nothing until macOS allows it, and that permission goes to the app it
> runs in: **Ghostty**. Granting Ghostty Accessibility (and Screen Recording, for
> screenshots) lets every shell and every agent in Ghostty read and operate
> every app on your Mac. Run `agent-desktop permissions --guide` only if you want
> that, and consider revoking it when you are done. Snapshots can contain
> private content from other apps; keep them out of logs and uploads.

## Between panes: `pasture pane tail` and `pasture agent ask`

Agents in herdr can also read each other:

| Command | Does |
| ------- | ---- |
| `pasture pane tail <pane> [--wait REGEX]` | the last lines of another pane, or block until a pattern appears (a dev server's "ready", a test's "FAIL"); exit 4 on timeout |
| `pasture agent ask <name\|pane> "<prompt>"` | prompt another agent, wait for it to settle, print its answer; waits if it is working, exits 3 if it is blocked on you |

`pasture agent ask` never answers an agent that is waiting for you: it reports
it instead.
