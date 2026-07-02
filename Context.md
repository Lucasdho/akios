# Context.md — How akios works

> The first thing an agent reads. This is the akios PLUGIN REPO — not an iOS app.
> Read this before doing any work here.

## What this repo is

akios is a Claude Code plugin + skill family for iOS/Swift development. This repo IS the
plugin — it ships skills, commands, templates, and scripts. There is no Swift source code,
no Xcode project, and no app to build or run here.

## Stack

- **Artifact types:** Markdown (`.md`), YAML (`.yml`), Bash (`.sh`), JSON (`.json`)
- **No compiler, no test runner, no build system.** There is no `xcodebuild`, no `swift test`,
  no package.json, no Makefile.
- **Version control:** git (GitHub remote at `Lucasdho/akios` or equivalent)

## Commands

- Install skills: `bash scripts/install-skills.sh`
- Smoke-test install: check that `~/.claude/skills/<skill>/SKILL.md` exists for each skill
- Validate YAML: `python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" workflow.yml`
- Check for orphaned refs: `grep -ri '<old-term>' --include=*.md --include=*.sh --include=*.yml .`
- Publish (plugin marketplace): handled via the `.claude-plugin/` manifest (if present)

## Architecture

```
akios/
├── skills/          ← one directory per skill; each has SKILL.md (+ optional references/)
├── commands/        ← one .md per /akios:<command>; thin wrappers that load the skill
├── templates/       ← scaffold files dropped into iOS projects by /akios:setup
│   └── rules/       ← .claude/rules/ templates (e.g. swift.md gate)
├── scripts/         ← install-skills.sh and other maintenance scripts
├── specs/           ← design specs for akios itself (same format as any iOS project)
├── tasks/           ← task backlog for building akios (todo/ in-progress/ review/ done/)
│   └── todo/        ← pending tasks (T<NNN>-<slug>.md)
├── archive/         ← completed spec archives
├── workflow.yml     ← phase contract (single source of truth for phases + commands)
├── Vision.md        ← north star + wishlist for akios itself
├── Roadmap.md       ← spec-level status table for akios development
└── CHANGELOG.md     ← version history
```

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
- **`workflow.yml` is parsed by commands** — keep it valid YAML after every edit.
- **tasks.md** (root) is a legacy single-file backlog from the v0.7.0 refactor. Most of its
  tasks (T001–T021) are already done. New tasks go in `tasks/todo/T<NNN>-<slug>.md`.
