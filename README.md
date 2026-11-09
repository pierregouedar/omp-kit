# omp-kit

A tuned setup for [Oh My Pi (omp)](https://github.com/can1357/oh-my-pi): sensible defaults for long coding
sessions, a compact status line, a calm dark theme, strict global rules for the agent, and a few plugins.

It ships **no models, providers or API keys**: you keep your own, the installer never touches them.

## What it sets

| Area | Settings | Why |
|---|---|---|
| Reasoning | `defaultThinkingLevel: medium` | good balance of quality, speed and cost; raise it for hard tasks |
| Cost and context | `providers.cacheRetention: long`, compaction at 300k tokens and when idle | cheaper long sessions |
| Memory | `memory.backend: local` | memory between sessions stays on your machine |
| Subagents | `task.maxConcurrency: 4` | keeps the machine responsive |
| Safety | `secrets.enabled: true`; `git push`, `git reset --hard`, `git clean`, `rm -rf` always ask | secrets are masked before reaching the model |
| Code quality | LSP diagnostics after each edit, auto-repair of broken edits | errors show up immediately |
| Interface | `titanium-calme` dark theme, Nerd Font symbols, quiet startup, turn time | |
| Status line | model, mode, path, git, subagents on the left; usage, cache hits, context on the right | |

The full list is in [`settings.json`](settings.json), applied key by key with `omp config set`.

It also installs:

- **`AGENTS.md`**: global rules for every session. Never invent paths, APIs or data. Read real data before
  writing code that consumes it. Test on real examples. Work in small verified steps. Stay inside the
  project. Report what was and was not verified.
- **Plugins**:
  - [superpowers](https://github.com/obra/superpowers): brainstorming, planning, TDD and review workflows;
  - [ponytail](https://github.com/DietrichGebert/ponytail): pushes the agent towards the smallest change
    that works.

## Requirements

- omp installed and logged in to at least one provider
- `python3`
- A [Nerd Font](https://www.nerdfonts.com) in your terminal. Otherwise run
  `omp config set symbolPreset unicode` after installing.

## Install

```sh
git clone <this repo> ~/omp-kit
cd ~/omp-kit
./install.sh
```

Options:

- `--no-plugins`: settings, rules and theme only.
- `--yolo`: tools run without asking for approval. The risky commands listed above still ask. Only use it
  if you review the agent's work closely.

Then pick your models, for example:

```sh
omp config set modelRoles.default <provider/model>
```

What the installer does:

- **Backups**: your current `config.yml` and `AGENTS.md` go to `~/.omp/agent/backup-<date>/` first.
- **Settings**: applied one key at a time, so everything else in your config stays as it is.
  This includes models, providers and keys.
- **rtk**: if [rtk](https://github.com/rtk-ai/rtk) is installed, omp's own output minimizer is turned off,
  since rtk already shortens command output.

To update: `git pull && ./install.sh`.
To roll back: copy the files back from the backup folder.

## Optional extras

- **Second opinion**: give omp an advisor model from another provider, then enable it with
  `omp config set modelRoles.advisor <provider/model>` and `omp config set advisor.enabled true`.
  It costs tokens on every turn.
- **rtk**: install it and its omp integration (see its README) to save tokens on command output.
