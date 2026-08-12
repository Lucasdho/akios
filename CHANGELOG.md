# Changelog

## 1.0.0 (2026-08-11)

**akios is now stack-agnostic.** The entire Swift/iOS layer is removed and the kit is reduced to
the part that applies everywhere: spec-driven development, structured brainstorming, autonomous
execution, and the meta-skills that maintain it. This is a breaking change for anyone using akios
as an iOS kit — v0.9.1 remains available in git history and via the `v0.9.1` tag.

### Removed — the iOS/Swift layer
- **`swift-dev`** and its entire bundled tree (~900K): `swiftui-pro`, `swiftdata-pro`,
  `swift-testing-pro`, `swift-concurrency-pro`, `swiftui-ui-patterns`, `swiftui-performance-audit`,
  `ios-debugger-agent`, `ios-accessibility`, `swiftui-design-principles`, `swiftui-design-system`,
  `swiftui-view-refactor`, `figma-to-swiftui`, `alva-architecture`, `review-doctrine`.
- **The `design` phase**, with `ui-variations` and `align-ui` — both were SwiftUI `#Preview`-native
  and had no meaning outside it. The spine is now `brainstorm → plan → deliver`.
- **ALVA** in every form: the architecture doctrine, the `architecture: alva` signal, the
  `Foundation/` usage ledger and its script, the slice scaffold in `/akios:setup`, and the
  per-skill `references/alva-integration.md` files.
- **`data-modeling-canvas`** and the `artifacts/` tree — the kit no longer ships runnable apps,
  and with it goes the only npm/build dependency in the repo.
- **`templates/rules/swift.md`** and **`templates/foundation/`** (the design-token stubs).

### Removed — all shell scripts
`scripts/` is gone in full: `install.sh`, `install-skills.sh`, `install-artifacts.sh`,
`register-skill.sh`, `check-update.sh`, `test-kit.sh`, `alva-usage-ledger.sh`, and the three hooks
(`agentic-kit-inject.sh`, `skill-trace.sh`, `post-checkpoint-verify.sh`).
- **Installation is plugin-only.** The manifest exposes `skills/` directly, so there is no
  hardcoded `SKILLS=()` array to keep in sync — the kit's most-cited historical footgun no longer
  exists.
- **`/akios:setup` installs no hooks and no scripts.** `CLAUDE.md`'s `@AGENTS.md` +
  `@akios/Context.md` imports are the entire load mechanism. Setup's migrate path detects
  leftovers from an older install and *offers* to remove them; it never deletes silently.
- The auto-build/test hook is replaced by `task-execution` running the project's own recorded
  `Test:` command from `akios/Context.md`.

### Changed — akios never writes to git
The kit runs no git command that changes anything: no commits, no branches, no `git add`, no
pushes, no merges, no tags — in **any** mode, `/akios:just-vibes` included. Running unattended
removes the questions, not the human's ownership of their history. Every run now ends the same
way: changed files in the working tree and a report of what changed, for the user to review and
commit however they like. Approving the *work* is explicitly not approving a *commit*; akios
doesn't even offer. Reading git (`status`, `diff`, `log`) is unaffected.

Everything that existed only to serve git went with it:
- **`collaboration: solo | team`** and **`autonomy: manual | auto`** — both flags did nothing
  except decide *how* to ship. Removed from `workflow.yml`, `templates/Roadmap.md`, the setup
  interview, and `AGENTS.md`. `mode` is the only Roadmap flag left.
- **The multi-instance claim protocol** (`owner:` on tasks, claim commits, push-rejection as the
  lock) — it was git-as-a-lock-server, and there is no git to lock with. The `owner:` field is
  gone from the task template and `spec-to-tasks`.
- **Branch-per-spec** in `task-execution` — with nothing being committed, an isolation branch
  isolates nothing. It now works in place and checks `git status` first, reporting an
  already-dirty tree instead of tangling changes silently.
- **just-vibes' SHIP step** — replaced by RECORD: mark the spec `done`, move the task files, leave
  the diff. The run report's "Shipped"/"Built (unshipped)" split collapsed into one "Built" bucket.

### Removed — `/akios:review`
The code-review doctrine it wrapped (single-responsibility drift, evidence-based duplication,
boundary conformance, spec conformance, data integrity) still lives in `task-execution` and still
runs at every task's review step and at finish. The command was a way to invoke that pass on
demand; the built-in `/code-review` covers the on-demand case.

### Changed — every command works without `/akios:setup`
No command treats setup as a prerequisite any more. Each one creates the folders it needs, asks
only the questions it actually depends on, and offers `/akios:setup` at the end — never as a gate.
`/akios:brainstorm` and `/akios:deep-brainstorm` need nothing at all; `/akios:deliver` asks for the
test command if none is recorded; `/akios:just-vibes` falls back to the documented default
(`delivery`) and degrades the build/test proof to the DoD audit rather than guessing an invocation.

### Changed — `/akios:setup` takes any project on its own terms
The interview no longer presumes an application with one language and a five-command lifecycle. It
opens by asking *what this repo is*, accepts "not applicable" as a first-class answer, records
several stacks and command sets for a monorepo instead of flattening them, and treats a non-code
project (docs, infra, a dataset, notes) as fully supported — "tests" become whatever verification
the work actually has. An honest `none` in `## Commands` is now explicitly the right answer, and a
fabricated invocation is named as the worst possible outcome of the interview. The scan widened to
`justfile`/container/Nix definitions and reports "no manifest" as a finding rather than a failure.
`git init` is no longer a precondition, and setup never stages or commits the files it writes.

### Removed — `akios/code-references/`
Tier 2 of the priority chain is gone entirely; the chain is now three tiers — **project decision →
user preference → the model's general knowledge**. What the repo already does *is* a project
decision even when nobody wrote it down, so a separate curated-references folder was a second way
to say the same thing. The **hurdles ledger** that lived inside it (`hurdles.md`) moved to native
auto-memory, which is loaded every session anyway — one memory mechanism instead of a file that
had to be indexed, tagged, and remembered about.

### Removed — knowledge packs
`knowledge-ingest` (`/akios:learn`) and `skill-author` (`/akios:new-skill`) are gone, along with the
`pack.yml` / `INDEX.md` / `kind: snippet` machinery they fed and `task-execution`'s snippet
copy-adapt-prune section. The `pack:` and `refs:` task fields went with them: a task points at the
in-repo file it should mirror, in its `## Files` section, and nothing else needs curating.

### Removed — the `agentic-kit` meta-skill
It was documentation *about* the kit, and every load-bearing part of it already had a canonical
home elsewhere: the priority chain and the gate table in `AGENTS.md`, the install manifest in
`/akios:setup`, the spine in `workflow.yml`, the pitch in `README.md`. Its own text conceded the
duplication ("this is the portable version for repos without the kit installed"). Its
`references/sandbox.md` (permission templates) went with it — the kit installs no permission
config, so the doc had no consumer.

### Changed — `workflow.yml` moved to the repo root
The phase contract is a **contract**, not state: it is copied verbatim from the plugin at every
setup and never edited per project. It now sits beside `VERSION` at the root, in the plugin and in
every consumer repo, while `akios/` is left holding only per-project state (Context, Roadmap,
Vision, specs, tasks). `/akios:setup` relocates it automatically on upgrade — no prompt, since the
file is never hand-edited. It is also now `version: 2`: the `design` phase is gone and no phase
names a language, framework, or build tool.

### Changed — renamed
- `ios-feature-pipeline` → **`feature-pipeline`**
- The plugin name (`akios`) and the `/akios:*` command namespace are unchanged — existing
  installs keep working.

### Changed — anti-drift moved into `AGENTS.md`
`feature-pipeline`'s "Staying in flow" section — *WHAT is not HOW*, and the four-step reflex for
routing a build need that surfaces mid-design instead of executing it inline — is generic agent
behavior, not pipeline conduct. It now lives in the installed `templates/AGENTS.md`, so it is
loaded every session rather than only when the orchestrator skill happens to fire.
`feature-pipeline` points at it instead of restating it.

### Changed — stack-agnostic by construction
- **`akios/Context.md` is the only place a language, framework, or command may be named.** Every
  phase now reads its build/test invocation from `## Commands` instead of carrying one. Guessing
  or hardcoding an invocation is an explicit anti-pattern in `task-execution`.
- **The floor of the priority chain is now the agent's own general knowledge**, not a shipped
  baseline pack. The kit deliberately ships no domain floor; a project raises it by recording the
  decision (in `akios/Context.md`, a spec, or auto-memory) so it becomes tier 1 next session.
- **`task-execution`**: the three proofs become **two** (the visual proof went with the design
  phase); the Foundation reuse gate and the UI gate are gone; the code-review doctrine is now a
  short inline checklist (single-responsibility drift, evidence-based duplication, boundary
  conformance, spec conformance, data integrity) instead of a `swift-dev` guide.
- **`spec-to-tasks`**: `area:` and build-order now follow whatever `akios/Context.md` records; the
  `swift_dev:` and `pack:` task fields are dropped.
- **`templates/Context.md`** gained `## Module boundaries` and `## Shared / common code` — the
  vocabulary downstream skills reuse in place of a hardcoded folder shape — and `## Xcode targets`
  became a generic `## Build & packaging notes`.
- `just-vibes` drops the retired legacy `tasks.md` fuel tier.

### Removed — the `posture` flag
`posture: learning | delivery` is gone from all 14 files that carried it: `workflow.yml`, the
Roadmap template, `AGENTS.md`'s teaching-surface table, the `/akios:setup` interview, the
`--learning`/`--delivery` override paragraph in four commands, and the per-phase section in
`idea-to-spec`, `spec-to-tasks`, `task-execution`, `just-vibes`, and `deep-brainstorm`. By its own
definition it changed *only* narration and never what got built — roughly 120 lines to pick a tone
of voice, which the user can ask for in plain language at any moment. The journal's conditional
"Lessons" subsection went with it.

### Changed — `deep-brainstorm` maps any subject, not just an app
The session was written around a software product: an "app map" of screens, data domains, and
integrations, with Discover ingredients asking for business model, distribution, and competitors.
It now opens by naming **what kind of thing** the subject is, and carries **lens decks** —
software, game, creative work, inquiry/research, course, business, personal system — for both the
Discover ingredients and the map dimensions, with deriving a new deck from the subject as the
normal case rather than an exception. Three rules keep it open: take the subject on its own terms,
treat the decks as starting points rather than schemas, and drop a dimension that doesn't apply
instead of filling it. The R-W-W rubric is reworded for any domain, and the `## States` section is
now conditional on the domain actually having an interactive surface.

The software depth is **kept in full**, not compressed away: `references/software-lens.md` carries
the 8-ingredient product Discover (with the note on why it differs from `founderlens-behavior`'s
10), the six map dimensions written out with their candidates, the recurring spec groupings
(`onboarding` / `infra-auth` / `design-system` …), and the two things a software spec must carry
(per-screen states, the `## Contract` header). `SKILL.md` points at it from the Discover table, the
dimension deck, and the grouping section, and instructs the agent to work from it rather than the
compressed rows. It loads only when the subject is software — mapping a novel never pays for it.

### Changed — trimmed
- **`CHANGELOG.md`** keeps 1.0.0 only. Everything at 0.9.1 and below documented the iOS kit; it
  stays in git at tag `v0.9.1`.
- **`START-HERE.md` removed.** Its job — first-time setup and what the pipeline does — is the
  README's, and two entry documents drift apart.
- **`README.md`** rewritten for the current scope: the two rules that define the kit (never assume
  the stack, never write to git), the command table, the spine, the priority chain.
- **`oss-first`** cut roughly in half, and its evaluation reference trimmed to the judgment calls
  that aren't already in the skill.

### Fixed — orphan references swept
Everything the removals above left dangling: `refs:` in four files, the `design` phase in
`handoff` and `just-vibes`, `packs` in `templates/task.md` and `preferences.seed.md`, the
four-tier priority chain in the preferences seed, "Only `/akios:just-vibes` commits" and "branch
per spec" in `/akios:deliver`, the `main`/`master` anti-pattern in `task-execution`, `/speckit`
and a phantom spec citation in `.gitignore`, `knowledge-ingest`/`skill-author` in `CREDITS.md`,
and `workflow.yml`'s stale `akios/` row in the artifact map. The version marker is renamed
`.claude/.agentic-kit-version` → `.claude/.akios-version`, with the old name read as a fallback.

A second audit pass before release caught what the first sweep left:

- **`/verify` was never a real command.** It was cited in ten places as half the quality gate, and
  `CREDITS.md` claimed it shipped with the Claude Code CLI. It doesn't. Every site now names the
  proof that actually exists — `task-execution`'s **two proofs**: the project's own recorded
  `Test:` / `Build:` command from `akios/Context.md` (degrading to the DoD audit where there's no
  runner), plus `/code-review`. Without this, `/akios:just-vibes` could mark a spec `done` on a
  code review alone.
- **Three paths sent the agent to the wrong place.** `archive/` resolved outside `akios/` in six
  places; `/akios:setup`'s materialize table read its templates from a relative `templates/`
  (which resolves in the *consumer's* repo, not the plugin) in six rows; and `deep-brainstorm`
  wrote its R-W-W report to `akios/specs/rww-audit.md`, where `just-vibes`' fuel detection would
  pick it up and try to *build* it. The report moved to `akios/rww-audit.md`, and fuel detection
  now skips discovery documents (`founderlens-*.md`) and reports-about-specs explicitly.
- **Spec status had two owners.** `deep-brainstorm` wrote `Status:` and `Priority tier:` into each
  spec file while `templates/spec.md` and `AGENTS.md` both declared `akios/Roadmap.md` the single
  source. The Roadmap's `## Specs` table gains a **`Tier`** column, and the spec file carries
  neither.
- **`templates/spec.md` now carries what the skills lint for**: the conditional `## Contract` block
  (exports/consumes, for projects with module boundaries) and the `## States` section (happy ·
  empty · loading · error). `idea-to-spec`'s "Contract & Foundation header" lost its dead half —
  `Foundation/` went out with ALVA.
- **`/akios:handoff`** was the one command missing `disable-model-invocation`, contradicting the
  README. The README also over-promised: commands never auto-fire, but the *skills* are
  model-invocable by design, and it now says so.
- **`workflow.yml`'s `bootstrap.creates`** was missing `.claude/.akios-version`, `akios/.local/`,
  and the user-global preferences seed — all three written by setup and checked by its own
  self-check. `akios/tasks/handoffs/` joined the folder tree it was already in the artifact map.
- `.idea/` is gitignored and untracked.

### Removed — stale docs and the v0.x backlog
- `docs/` (the architecture snapshot and the plugin audit map) — both described the iOS kit and
  duplicated `README.md` + `agentic-kit`.
- `akios/specs/` and `akios/tasks/` are reset to empty. The v0.x spec family and its ~70 completed
  tasks described a product that no longer exists; they are preserved in git history at `v0.9.1`.

---

Versions 0.9.1 and earlier documented akios as a Swift/iOS kit — a product this release replaces
wholesale. That history is preserved in git at tag `v0.9.1`.
