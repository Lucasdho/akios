---
description: Onboard this repo to the akios kit — interview, scan, fill the context files, create the folder tree, and seed preferences.
disable-model-invocation: true
---

# /akios:setup — Onboard a repo to the kit

You are setting up the akios kit in the user's repo. A plugin cannot shell-write
into their repo, so you do this with your own file tools. Work at the **git repo root**
(`git rev-parse --show-toplevel`); fall back to the cwd if not a git repo — akios works fine in a
directory that isn't under version control, so never make `git init` a precondition.

**This command only writes files.** It never commits, stages, or pushes anything it creates —
that's the user's call (see `AGENTS.md` "Git is just-vibes-only"). Mention at the end that the new
files are uncommitted, and stop there.

Templates live in the installed plugin at `${CLAUDE_PLUGIN_ROOT}/templates/`. Read them from
there; do not invent their contents. `setup` is **bootstrap, not a phase** (see
`workflow.yml` `bootstrap`).

**akios is stack-agnostic.** It installs markdown + one YAML contract, and nothing else. There
are no hooks to wire, no scripts to copy, and no `chmod` to run. Everything the kit knows about
*this* project's language, commands, and architecture lands in `akios/Context.md` during this
interview — that file is the only place a stack is ever named.

**Narrate as you go.** Print a one-line header the moment each numbered step starts (e.g.
"Scanning repo…", "Materializing 7 files + folder tree…", "Self-check…") — a step should never
run silently. Step §3 (Materialize) additionally narrates **per item** as each file/action
completes (e.g. "✓ `AGENTS.md` written") — it's the long step that would otherwise run silently.

## 0. Detect state (idempotency gate — do this first)
Don't re-onboard a repo that's already set up; re-running `/akios:setup` should be cheap.
Read the installed version (`${CLAUDE_PLUGIN_ROOT}/VERSION`) and the repo's recorded version
(`<root>/.claude/.agentic-kit-version`, may be absent), then branch:

- **No version file (or no `AGENTS.md`)** → fresh repo. Run the **full** flow (steps 1–5).
- **Recorded == installed** → already initialized. **Skip the interview and copies.** Run only the
  **self-check (step 5)**, repair any single missing artifact, and stop with "Already initialized
  at v<X> — nothing to do." Re-run the full flow only if the user asks to repair/reset.
- **Recorded < installed** → **migrate, don't re-interview.** Skip step 1. Refresh only the
  **always-copy** artifacts (`workflow.yml`, the version file); leave the
  *skip-if-exists* files (`AGENTS.md`, `akios/Context.md`, `akios/Roadmap.md`) untouched.
  Re-verify wiring (step 4). Write the new version, then **report the diff** from
  `${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md` in two or three lines, flagging anything needing a manual touch.
  Detect the **mode** here too: if the user has feature work in mind, ask `new`/`one-shot`/`feature`.

  **Leftovers from an older, heavier install.** Versions before the kit went stack-agnostic
  installed shell hooks (`.claude/hooks/agentic-kit-inject.sh`, `skill-trace.sh`,
  `post-checkpoint-verify.sh`, `akios-instance.sh`), a `.claude/scripts/` helper, and a
  `.claude/rules/` gate file. Those are no longer part of the kit. **Ask, don't silently delete:**
  list exactly which of them you found and offer to remove them plus their `settings.json` hook
  entries. On "no", leave everything alone — a stale hook is inert, not broken. Never touch
  anything in `.claude/` the user may have added themselves.

  **`workflow.yml` moved to the root.** Older installs kept the phase contract at
  `akios/workflow.yml`. If you find one there, move it to the repo root — it is an always-copy
  artifact, so just write the plugin's current copy to `workflow.yml` and delete the old one.
  This one is safe to do without asking: the file is never edited per project.

  **`akios/` folder migration (opt-in).** Detect a pre-consolidation repo: a recorded version
  older than the consolidation, alongside root-level `specs/`, `tasks/`, `Context.md`, `Roadmap.md`,
  `Vision.md` rather than an `akios/` folder. **Ask, don't silently move:**
  "This repo predates the `akios/` consolidation — migrate now? (moves `specs/ tasks/ archive/
  Context.md Roadmap.md Vision.md` into `akios/`, renames the
  runtime journal `.akios/` to `akios/.local/`, updates `CLAUDE.md`'s import path. Everything
  keeps working either way — this is cosmetic, not a functional requirement.) y/n"
  - **On yes:** move file-by-file, verifying each move landed (source gone, destination present +
    non-empty) before the next, retrying once on a confirmed miss, and stopping with an itemized
    manifest on a second failure. Update `CLAUDE.md`'s `@Context.md` → `@akios/Context.md`
    import as the **last** write in the sequence, only after every file move is confirmed — a
    failed migration must never leave the import pointing at a `Context.md` that no longer
    exists at the old path.
  - **On no (or nothing stale):** leave the repo as-is — a pre-consolidation repo is not broken.
    Don't ask again until the user explicitly requests it (`/akios:setup --consolidate`).
  - **Name-collision check (before any write):** if the repo already has a pre-existing `akios/`
    directory unrelated to this kit (no recognizable `Context.md`/`Roadmap.md`/`specs/`/`tasks/`
    shape inside it), treat it the same as any other "file already exists and isn't ours" case
    in step 3's materialize table — surface it to the user, ask how to proceed (e.g. a
    different folder name, or abort the migration), and **never** silently write into or over it.

## 1. Interview (short — map answers to the placeholders)

**Take the project on its own terms.** akios makes no assumption about what kind of thing this
repo is. It may be an application, a library, a CLI, a monorepo with three stacks, infrastructure
as code, a data pipeline, a design system, a docs site, a research notebook, a game, a
firmware image, or something with no code in it at all. Every question below is a *prompt*, not a
requirement — and "not applicable" is a first-class answer you record as such and never ask twice.

Three rules keep this open:
- **Never push the project into a shape it isn't.** If it has no test runner, no build step, no
  framework, or no single language, record that plainly. Don't invent a `test` command to fill a
  blank, and don't nudge the user toward tooling they didn't ask for — setup describes the
  project, it doesn't reform it.
- **Multiple answers are normal.** A monorepo has several stacks and several command sets. Record
  them per package/area rather than flattening to one, using the project's own names for its parts.
- **A non-code project is a supported project.** Then "tests" are whatever verification the work
  actually has — a link check, a schema validation, a lint, a human read-through, or nothing. Say
  which one it is in `## Commands`; the phases degrade to the DoD audit when there's no runner.

Ask in one batched pass (skip what the scan in step 2 answers confidently; confirm rather than re-ask):
- **Mode** — `new` (greenfield repo) / `one-shot` (single deliverable) / `feature` (adding to an
  existing project). Written to `akios/Roadmap.md`; `brainstorm` reads it instead of re-asking.
- **Posture** — `learning` (narrate the *why* behind decisions as you build) / `delivery` (ship
  quietly, default). Written to `akios/Roadmap.md`. Orthogonal to mode; overridable for a
  single session via a command flag or a spoken switch without rewriting this default. See
  `AGENTS.md` "Operating posture" for what the flag actually changes.
- **What this repo is** — one line, in the user's words. An app, a library, a monorepo, infra, a
  docs site, a dataset, notes. This frames every answer below; don't skip it because it seems obvious.
- **Stack** — language(s) / framework(s) / runtime / data store, as many as actually apply
  (`{{LANGUAGE / FRAMEWORK / RUNTIME / DB}}`). "Markdown only" and "several, per package" are both
  valid answers. Record `none` for any slot the project genuinely doesn't have.
- **Commands** — install / run-dev / test / lint / build (`{{install}}` `{{dev}}` `{{test}}` `{{lint}}` `{{build}}`).
  **This is the most load-bearing answer in the whole interview** — every downstream phase reads
  its build/test invocation from here rather than guessing one. Get the *exact* strings and verify
  at least the test command actually runs. Any slot the project doesn't have is recorded as
  `none` — an honest `none` is a good answer, and a fabricated command is the single worst
  outcome of this interview. In a monorepo, record a command set per package. Where a project has
  no runner at all, write what verification *does* exist (`validate: <schema check>`, or
  `none — verify by DoD audit`) so the phases know how to prove work correct.
- **Architecture** — one paragraph: entry points, key dirs, data flow, and the vocabulary this
  project uses for its module boundaries and its shared/common code (the words `spec-to-tasks` will
  reuse for `area:`). Also record a named architecture if the project follows one (`mvvm`,
  `hexagonal`, `layered`, …), or `none`. A flat repo with no architecture is a real answer —
  **akios never imposes one.**
- **Conventions** — naming, error handling, commit/branch style
- **Gotchas** — the thing that bites a newcomer or the agent
- **Project-specific gate** (AGENTS.md) — e.g. "always /security-review when touching auth"
- **House rule** (AGENTS.md `{{PROJECT_RULE}}`) — a project-specific must/never
- **Claude note** (CLAUDE.md) — any Claude-specific instruction, or drop the section

## 2. Scan (facts win over interview; surface contradictions)
Inspect the repo to fill/verify command + stack + architecture. Read whatever manifest this
project actually has — `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`,
`Gemfile`, a `Makefile`, a `justfile`, a CI workflow, a lockfile, a container or Nix definition —
and take the real script/target names from it rather than assuming a convention. A CI config is
usually the most honest source for the true test and build invocations. Also record top-level
source dirs and where test fixtures live.

**Scan for what's there, not for what you expected.** Find no manifest at all? That's a finding,
not a failure — record `none` and move on. Find *several* (a monorepo, a polyglot repo, a
frontend beside a service)? Record each with the path it governs; don't pick a winner. The repo
you're looking at is the authority on what kind of project it is.

If a scan fact contradicts an interview answer, tell the user and ask which is right before writing.

## 3. Materialize the context files + folder tree (never clobber existing files)
Copy each template into the repo, replacing every `{{...}}` token with the resolved value.
Placeholders to fill live in `akios/Context.md`, `AGENTS.md`, `CLAUDE.md`, and `akios/Roadmap.md` (mode).

**Narrate + verify per row.** As each row below is applied, print "✓ `<File>` written" (or
"skipped — already exists" per the row's rule), then immediately re-check the result before moving
to the next row: re-read/stat the destination (exists, non-empty, or content-matches-source for an
exact copy). **Never trust a clean tool-call return as proof.** On a confirmed miss, retry that
single action exactly once; if the retry also fails, **stop this step immediately** — do not
proceed to step 4 — and report an itemized manifest (confirmed landed / confirmed missing / never
attempted) rather than continuing or guessing at the repo's state.

| File | Source | Rule |
|---|---|---|
| `AGENTS.md` | `templates/AGENTS.md` | skip if it already exists |
| `akios/Context.md` | `templates/Context.md` | skip if it already exists |
| `akios/Roadmap.md` | `templates/Roadmap.md` | skip if it exists; fill the `mode:` + `posture:` lines |
| `akios/Vision.md` | `templates/Vision.md` | skip if it exists; fill the north-star + first wishlist items (just-vibes fuel) |
| `workflow.yml` | `${CLAUDE_PLUGIN_ROOT}/workflow.yml` | always copy (the phase contract) |
| `CLAUDE.md` | `templates/CLAUDE.md` | if missing, create; if present, prepend whichever of `@AGENTS.md` / `@akios/Context.md` imports is missing (Context first so AGENTS ends on top) |
| `.claude/.agentic-kit-version` | contents of `${CLAUDE_PLUGIN_ROOT}/VERSION` | always write |

**Footprint — the three-way line.** Not everything this command writes is the same *kind* of thing:
- **Root contracts** — `CLAUDE.md`, `AGENTS.md`, `.claude/`, `workflow.yml` — stay at repo root.
  The first three because a *different* program (Claude Code, or any AGENTS.md-reading tool) looks
  for them there, independent of akios. `workflow.yml` because it is the kit's **contract**, not
  its state: it is copied verbatim from the plugin at every setup and never edited per project, so
  it belongs beside `VERSION`, not inside the folder of things the project keeps changing.
- **akios housekeeping** — `Context.md`, `Roadmap.md`, `Vision.md`, `specs/`, `tasks/`,
  `archive/`, the runtime journal — moves into one folder, **`akios/`**.
  This is per-project state, written and rewritten as work progresses.
- **User's own source** — whatever the project's own architecture defines — stays where it is.
  It's the deliverable the toolchain must find in a normal layout, not akios's paperwork.

**Create the `akios/` folder tree** (empty, with a `.gitkeep` if your tooling needs it):
```
akios/
├── Context.md
├── Roadmap.md
├── Vision.md
├── specs/
├── tasks/
│   ├── todo/
│   ├── in-progress/
│   ├── review/
│   └── done/
├── archive/
└── .local/                      # gitignored — runtime journal
```
Root, after this step, holds only: `CLAUDE.md`, `AGENTS.md`, `.claude/` (untouched), `akios/`, and
whatever the user's own project already has (their source, `README.md`, etc. — akios never
generated these).

(`akios/.local/` is created at runtime for the local journal and stays **unconditionally**
gitignored — no yes/no prompt: there's no legitimate case for tracking a per-machine journal, so a
forced default beats asking a question with only one sane answer. The rest of `akios/` is **never**
offered as gitignorable — specs and tasks are work product a team reads and reviews.)

**Seed user preferences (user-global, once):** if `~/.claude/akios/preferences.md` does **not**
exist, create `~/.claude/akios/` and copy `templates/preferences.seed.md` there as
`preferences.md`. If it already exists, leave it untouched (it survives plugin updates).

Append `akios/.local/` to the repo's `.gitignore`.

## 4. Nothing to wire
The kit installs no hooks and no scripts. `CLAUDE.md`'s `@AGENTS.md` + `@akios/Context.md` imports
are the entire load mechanism — Claude Code reads them at session start on its own. Skip straight
to the self-check.

If the user *wants* extra automation (a formatter on save, a pre-commit gate), that's their own
`settings.json` to write — the kit installs none of it by default.

## 5. Self-check (fail loudly)
**If step 3 stopped early on a confirmed miss (its retry-then-stop path):** don't run a fresh
self-check as if nothing happened — report the itemized manifest that step already produced
(confirmed landed / confirmed missing / never attempted) as the result, so the state is explicit
rather than re-derived or assumed complete.

Otherwise, confirm: the `akios/` context files (incl. `akios/Vision.md`) + `workflow.yml` +
the folder tree exist; `CLAUDE.md` imports both `@AGENTS.md` and `@akios/Context.md`;
`akios/Roadmap.md` has a `mode:` **and** a `posture:` value;
`akios/Context.md` `## Commands` carries a real, runnable test command (not a placeholder);
`~/.claude/akios/preferences.md` exists; **no `{{...}}` placeholder remains** in
`akios/Context.md` / `AGENTS.md` / `CLAUDE.md` / `akios/Roadmap.md` / `akios/Vision.md`.
Report any miss.

## 6. Dependencies
The kit has **no required external plugins** — everything the spine routes to (`idea-to-spec`,
`spec-to-tasks`, `task-execution`, `oss-first`, `feature-pipeline`, `just-vibes`) ships with akios.

Finish with: the repo is onboarded; next step is `/akios:brainstorm "<your feature idea>"`.
