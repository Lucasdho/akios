# Context.md — How akios works

> The first thing an agent reads. This is the akios PLUGIN REPO — not an iOS app.
> Read this before doing any work here.

## What this repo is

akios is a Claude Code plugin + Codex-ready plugin + skill family for iOS/Swift development.
This repo IS the plugin — it ships skills, commands, templates, and scripts. There is no Swift
source code, no Xcode project, and no app to build or run here.

## Stack

- **Artifact types:** Markdown (`.md`), YAML (`.yml`), Bash (`.sh`), JSON (`.json`)
- **No compiler, no test runner, no build system.** There is no `xcodebuild`, no `swift test`,
  no package.json, no Makefile.
- **Version control:** git (GitHub remote at `Lucasdho/akios` or equivalent)

## Commands

- Install skills: `bash scripts/install-skills.sh`
- Smoke-test install: check that `~/.claude/skills/<skill>/SKILL.md` exists for each skill
- Validate YAML: `python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" akios/workflow.yml`
- Check for orphaned refs: `grep -ri '<old-term>' --include=*.md --include=*.sh --include=*.yml .`
- Publish (Claude plugin marketplace): handled via the `.claude-plugin/` manifest (if present)
- Validate Codex plugin manifest: `python3 /Users/lucasoliveira/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .`

## Architecture

> **Naming note:** this repo (the git project) is named `akios`; it also contains a subfolder
> literally named `akios/` — the same housekeeping folder `/akios:setup` creates in every
> consumer repo (`akios-footprint-consolidation.md`). This repo dogfoods its own convention: the
> two are not the same thing, don't conflate a reference to "the akios repo" with "the `akios/`
> folder inside it."

```
<repo root>/
├── skills/          ← one directory per skill; each has SKILL.md (+ optional references/)
├── commands/        ← one .md per /akios:<command>; thin wrappers that load the skill
├── templates/       ← scaffold files dropped into iOS projects by /akios:setup
│   └── rules/       ← .claude/rules/ templates (e.g. swift.md gate)
├── scripts/         ← install-skills.sh and other maintenance scripts
├── akios/           ← this repo's own housekeeping (akios-footprint-consolidation.md)
│   ├── Context.md       ← this file
│   ├── Roadmap.md       ← spec-level status table for akios development
│   ├── Vision.md        ← north star + wishlist for akios itself
│   ├── workflow.yml     ← phase contract (single source of truth for phases + commands)
│   ├── specs/           ← design specs for akios itself (same format as any iOS project)
│   └── tasks/           ← task backlog for building akios
│       ├── todo/        ← pending tasks (T<NNN>-<slug>.md)
│       ├── in-progress/ · review/ · done/
│       └── handoffs/    ← cross-session continuity docs
├── CHANGELOG.md     ← version history
└── VERSION          ← installed semver, compared against a consumer repo's stamped version
```

Codex support currently exposes the shared `skills/` tree via `.codex-plugin/plugin.json`.
The `/akios:*` command wrappers and setup hook wiring are still Claude-first; do not claim full
Codex command/setup parity until `.codex/`, `~/.codex/akios`, and Codex-native hook behavior are
designed and implemented.

No `archive/` or `code-references/` yet — this repo hasn't archived a completed spec or ingested
a code-reference pack, so neither directory exists on disk (they materialize under `akios/` the
first time either is needed, same as in a consumer repo).

## Conventions

- **Skill naming:** kebab-case directories, `SKILL.md` always at root of skill dir.
- **Command naming:** kebab-case `.md` files in `commands/`; mirror the skill they invoke.
- **Version bumps:** `VERSION` file (semver) + entry in `CHANGELOG.md` at every shipped change.
- **Frontmatter:** every `SKILL.md` has `name:`, `description:`, `license:`, `metadata.author`,
  `metadata.version`. Commands have `description:` and `disable-model-invocation: true`.
- **Install script:** `scripts/install-skills.sh` has a hard-coded `SKILLS=(...)` array —
  add new skill names there whenever a new skill is created.
- **Commit style:** `feat:`, `fix:`, `chore:`, `docs:` prefixes. Short imperative subject.
  `Co-Authored-By:` trailer if Claude authored or co-authored the commit.

## Gotchas

- **No Swift gates here.** `swift-dev`, `align-ui`, `xcodebuild`, `swift test` — none of these
  apply. Skip them for every task in this repo.
- **DoD verification = inspection + grep**, not a test suite. For each task, check the file
  exists, open it and confirm the content matches the spec, grep for orphaned old references.
- **install-skills.sh must be updated** whenever a new skill directory is added — forgetting
  this is the most common mistake. Always check it when adding a skill.
- **`akios/workflow.yml` is parsed by commands** — keep it valid YAML after every edit.
- **tasks.md** (root) was retired — the v0.7.0 single-file backlog (T001–T021) was fully
  migrated into `akios/tasks/todo/`. New tasks go in `akios/tasks/todo/T<NNN>-<slug>.md`.
