# 🔒 Security

What pasture trusts, how it keeps secrets off public remotes, how it scans
dependencies, and how it pentests your own app. Every command named here is
also in [commands.md](commands.md) with all its flags.

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
  `pasture doc review` goes further, with a macOS sandbox per reviewer
  ([review.md](review.md#what-a-reviewer-can-touch)).
- **Commands come from two places only:** `cmds/` in this clone and your own
  `~/.config/pasture/cmds.local/`. A repository you open cannot add commands,
  and group and command names cannot be paths.
- **Agents never act for you on others.** The collie never answers an agent's
  prompt or approval; `pasture agent stop` and every other `external` command
  prints its plan and waits for `--yes`, which an agent should ask you for.

## 🔑 Secrets never reach a public remote

A secret pushed to a public repo is public forever, even after a force-push.
Two hooks guard against it:

- **pre-commit (this clone only).** `setup.sh` installs a gitleaks hook in
  pasture's own clone that blocks a commit adding a secret.
- **pre-push (any repo you choose).** `pasture git protect` installs a hook
  that runs `pasture git guard` on every push. `setup.sh` installs it in this
  clone; run it in any repo of yours:

```bash
cd ~/code/my-service
pasture git protect            # add the guard; an existing pre-push hook is kept and chained
pasture git protect --remove   # put the previous hook back
```

The guard runs gitleaks over just the commits being pushed, then decides by
the remote's visibility:

| Remote is | A secret in the pushed commits |
| --------- | ------------------------------ |
| public | **blocks** the push (exit 1) |
| private or internal | warns; the push goes ahead |
| unknown (the forge could not answer) | **blocks**, unless the host is on your internal allowlist |

Visibility comes from `pasture git visibility [remote|url]`, which asks `gh`
for github.com and `glab` for GitLab, and prints `public`, `private`,
`internal` or `unknown`. It sends the GitLab token only to gitlab.com or to a
host you declared internal, never to a host named by the remote URL alone.
Declare self-hosted hosts one per line in `~/.config/pasture/internal-hosts`
(or in `PASTURE_INTERNAL_HOSTS`, space- or comma-separated); that file is
yours to write.

The hook is per repo (no global `core.hooksPath`), so husky, lefthook and other
repos' hooks are untouched. To push past a real block, the human way is
`git push --no-verify`; **an agent must not do that for you.**

## 🧪 Scanning a repo and its dependencies

```bash
pasture dep audit                       # secrets, SAST, vulnerable dependencies
pasture dep audit --history             # secrets in the whole git history too
pasture dep cve pkg:npm/lodash@4.17.20  # is this exact version vulnerable?
pasture dep cve CVE-2021-44228          # how likely is this CVE to be exploited?
```

`pasture dep audit` runs the offline scanners from the Brewfile over the
current repo and skips any that is not installed:

| Scanner | Finds |
| ------- | ----- |
| gitleaks | secrets in the working tree, or the whole history with `--history` |
| semgrep | SAST issues (`p/default`); fetches its ruleset once, then uses the cache |
| grype (with syft) | dependencies with known CVEs, catalogued from lockfiles; run `grype db update` once first |

No code leaves the machine. It prints one line per scanner and a summary, exits
1 if any reports a finding and 5 if none is installed. `--fail-on` sets grype's
severity gate (default `high`), `--json` is for agents.

`pasture dep cve` asks public advisory APIs about one thing, and only that
identifier leaves the machine:

- a **purl** (`pkg:<type>/<namespace>/<name>@<version>`, such as
  `pkg:maven/io.vertx/vertx-core@4.4.0`) goes to [OSV.dev](https://osv.dev);
- a **CVE id** gets its EPSS exploit probability from FIRST and a check
  against CISA's Known Exploited Vulnerabilities list.

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

## What goes where

| Command | What leaves the machine | To whom |
| ------- | ----------------------- | ------- |
| `pasture dep audit` | nothing (after the one-time database and ruleset pulls) | — |
| `pasture dep cve` | the purl or CVE id | OSV.dev, FIRST, CISA |
| `pasture git visibility` / `guard` | the repo path | GitHub, or a GitLab host you trust |
| `pasture doc review` | the doc and what reviewers read | the vendors the doc's visibility allows |
| `pasture sec pentest` | the copied code and what Strix sees | the model the target's privacy allows |
| `pasture web read` | the URL | that site |
