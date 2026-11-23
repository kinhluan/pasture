# ☕ Java, 🦀 Rust, 📦 Node, pnpm, bun and uv

The toolchains pasture installs and how `pasture.zsh` sets them up.

## ☕ Java

Homebrew installs Eclipse Temurin 21 and Maven. `pasture.zsh` sets
`JAVA_HOME` to JDK 21 unless you set it yourself, and `jdk <version>` switches
the current shell (`jdk` alone lists installed JDKs). For another version,
add a cask such as `temurin@17`. Temurin is free to use at work; older Oracle
JDK builds need a license there.

## 🦀 Rust

Install [rustup](https://rustup.rs) once; it is not in the Brewfile because it
updates itself. `pasture-update` runs `rustup update` (it is listed in
`agents.conf`), `setup.sh` adds the `rust-analyzer` component for Helix, and
`pasture.zsh` puts `~/.cargo/bin` on PATH. Cargo manages dependencies
(`cargo add`, `cargo update`, `cargo tree`); Homebrew adds the tools around it:

| Tool | Use |
| ---- | --- |
| `sccache` | compile cache shared by every worktree and repo (`RUSTC_WRAPPER`, set in `pasture.zsh`) |
| `cargo nextest run` | faster tests, compact output |
| `cargo deny check` | RustSec advisories, licenses, sources and duplicate versions (configure with `deny.toml`) |
| `cargo upgrade` | raise versions in `Cargo.toml`, majors included (`cargo update` only moves `Cargo.lock`) |
| `cargo binstall <tool>` | install other cargo tools as prebuilt binaries |

Commit `Cargo.lock` for applications. In a Bazel repo, Rust dependencies go
through `rules_rust` and `crate_universe`, and Bazel does the caching.

## 📦 Node

Node comes through [fnm](https://github.com/Schniz/fnm). `setup.sh` installs
the newest LTS as the default and `pasture-update` keeps it current. In a
project with `.nvmrc` or `.node-version` (looked up from the current directory
upwards, or `engines.node` in `package.json`), fnm switches to that version on
`cd` and offers to install it if missing. fnm is loaded after `~/.zshrc`, so it
wins over an nvm loaded there; `setup.sh` reminds you to remove nvm's lines,
which slow every new shell. Pin Node per project with a `.nvmrc` rather than
relying on the default.

## pnpm, bun and uv

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

## Bazel

`bazelisk` installs as `bazel` and runs the version each repo pins in its
`.bazelversion`; `buildifier` formats `BUILD`, `.bzl` and `MODULE.bazel`
files, and `starpls` gives Helix a Starlark language server. `pasture-task`
warns when a Bazel repo does not list `.worktrees/` in `.bazelignore`.
