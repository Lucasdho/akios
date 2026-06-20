# akios — Plugin Architecture
**Working spec · v1.0 · akios refactor annex**

This document captures the structural redesign of the akios plugin after dropping
two external dependencies — **axiom** (heavy, didn't guarantee code quality) and
**superpowers** (weak performance). It defines the plugin's folder layout (global +
installed-repo), the command set and phase model, the new `workflow.yml` contract,
the internal/external skill boundary, and where user preferences live. It is the
first of a 3-spec family: `plugin-architecture` → `pipeline` → `preferences-and-priority`
(plus `project-scaffolding`, deferred). Everything here is settled unless marked *open*.

Replacements at a glance: **axiom → swift-dev** (domain router, restored from pre-v0.2.0);
**superpowers → task-execution** (absorbs good execution practices, with or without subagents).

---

## 1. Guiding principles

- **No external plugin/skill dependencies.** The kit ships everything it routes to.
  `ponytail` is no longer referenced in docs (users may install it for themselves);
  `oss-first` stays (it is the author's own skill). Debugging is covered by
  `swift-dev`'s `ios-debugger-agent` sub-skill — no gap left by superpowers' removal.
- **One source of truth per concern.** Phase definitions live only in `workflow.yml`;
  prose conduct lives in skills; project facts live in `Context.md`; durable project
  decisions in native `MEMORY.md`; transferable user taste in `preferences.md`.
- **Deterministic phase handling.** Prerequisites and phase detection read a structured
  contract, not prose, so "can I run this phase?" and "what phase am I in?" have
  unambiguous answers.

---

## 2. The `workflow.yml` contract  *(Decision 1 — chose A)*

A **machine-readable phase contract** shipped with the plugin (global, stable). Each
phase declares its `command`, `prereqs` (files that must exist to run it), `outputs`
(artifacts it produces), and the `skills` it invokes.

- **Chosen because** the user explicitly required (a) checking the previous phase's
  prerequisites and (b) detecting the current phase by context. A structured contract
  delivers both deterministically: *current phase = which `outputs` already exist*;
  *phase gate = all `prereqs` exist*. Prose can't do this without ambiguity.
- **Cost accepted:** a small yml schema to maintain. Agents read yml reliably.
- **Relationship to `AGENTS.md`:** `AGENTS.md` (per-repo) stays prose and *references*
  the workflow; it does not re-document the phases. Commands become thin wrappers that
  read `workflow.yml`.
- **Declined:** *B — prose `WorkFlow.md`* (prereq/detection become "infer from prose",
  non-deterministic); *C — fold into `AGENTS.md`* (mixes stable pipeline definition with
  per-repo content, doesn't propagate on plugin update).

---

## 3. Commands & phase model  *(Decision 2 — chose A)*

Four commands. The three pipeline phases are defined in `workflow.yml`; **`init` is
bootstrap and sits outside the phases** (no spec/task prerequisite).

| Command | Role | Was |
|---|---|---|
| `init` | bootstrap a repo (see §4) | `init` (redefined) |
| `brainstorm` | idea → specs | `define` |
| `plan` | specs → sequenced tasks | `plan` |
| `execute` | create tests → run tasks | `deliver` |

- Clean break, **no aliases** for the old names (plugin is pre-1.0).
- `brainstorm`/`plan`/`execute` map 1:1 to phases in `workflow.yml`.

---

## 4. `/init` behavior  *(Decision 2 — chose A + mode flag)*

**Onboard, idempotent, with a light interview.**

- Creates the repo structure (§6): `CLAUDE.md`, `AGENTS.md`, `Context.md`, `Roadmap.md`
  and the folders `specs/ tasks/ archive/ code-references/`.
- Detects **new repo vs. existing repo** and runs a short interview to fill `Context.md`
  (stack, commands, architecture).
- **Writes the mode flag** (`new` / `one-shot` / `feature`) into `Roadmap.md`, so the
  `brainstorm` phase reads it instead of re-asking.
- Stays **idempotent / version-aware** (the v0.4.1 behavior): same version → self-check;
  older → migrate; absent → full onboard.
- **Declined:** *B — pure scaffold* (leaves `Context.md` empty; "stale/empty context is
  worse than none"); *C — auto-analyze codebase* (over-infers and gets architecture wrong
  in large existing repos).

---

## 5. Preferences & the decision-priority chain  *(Decision 3 + division)*

### 5.1 Where `preferences.md` lives — chose B
**User-global, outside the plugin:** `~/.claude/akios/preferences.md`. The plugin ships
only a **seed** (`templates/preferences.seed.md`); the live instance is copied to the
user's home on `init`.

- **Chosen because** the priority chain's top tier is "global *user* preference" — the
  concept is the user's, not the project's or the plugin's. Mechanically, the user-home
  location is the only one that **survives plugin updates** (the plugin dir is overwritten).
- **Declined:** *A — per-repo* (doesn't cross the user's projects); *C — two-tier* (faithful
  but premature complexity; promote to it later if a project must diverge).

### 5.2 `MEMORY.md` vs `preferences.md` — the division

| | `MEMORY.md` (native) | `preferences.md` (akios) |
|---|---|---|
| Scope | one project | the user, all projects |
| Content | durable decisions *of this repo* (architecture chosen here, conventions, gotchas) | the user's transferable taste/style (patterns liked, always/never rules) |
| Written by | Claude Code, natively | akios phases on observed feedback + manual curation |
| Location | `~/.claude/projects/<proj>/memory/` | `~/.claude/akios/preferences.md` |
| Answers | "what we already decided *here* — don't relitigate" | "how this user *likes* to code — anywhere" |

Rule: **project-specific fact → `MEMORY.md`; transferable user taste → `preferences.md`.**
No duplication — a preference that becomes a concrete repo decision is referenced, not recopied.

### 5.3 Decision-priority chain *(order 1→3→2→4 per user — concrete code beats stated taste)*

```
1. Project decision already made   (MEMORY.md + existing code / Context.md)
2. Sample code / Code References    (user-uploaded code or good repo code)
3. Global user preference           (preferences.md)
4. swift-dev                        (best-practice baseline)
```

- **Rationale:** a repo's established architecture isn't rewritten because the user
  *generally* prefers something else (project at top). And **shown code beats told
  preference** — concrete examples outrank an abstract stated preference, which is why
  Code References sits above `preferences.md`.
- *(Carried into `preferences-and-priority.md` for full detail — feedback-logging
  mechanism and Code References progressive disclosure are specified there.)*

---

## 6. Folder layout *(locked, with 3 normalizations)*

### 6.1 Global — plugin root
```
plugin.json                 manifest (required by Claude Code)
workflow.yml                phase contract — SSOT
START-HERE.md               onboarding
README.md / CHANGELOG.md / CREDITS.md / LICENSE
commands/   init.md · brainstorm.md · plan.md · execute.md
skills/     idea-to-spec · spec-to-tasks · task-execution · swift-dev ·
            oss-first · ios-feature-pipeline · ios-agentic-kit
scripts/    hooks + install utilities
templates/  CLAUDE.md · AGENTS.md · Context.md · Roadmap.md
            spec.md · task.md
            preferences.seed.md      (copied to ~/.claude/akios/ on init)
            (project-templates/  — DEFERRED, spec #4)
```
`preferences.md` is **not** in the plugin tree — only the seed in `templates/`.

### 6.2 Repo (created by `/init`)
```
CLAUDE.md           imports @AGENTS.md @Context.md + specs/roadmap pointer
AGENTS.md           operating manual; references workflow.yml
Context.md          project facts (filled at init)
Roadmap.md          spec states + mode flag
specs/              active specs
tasks/              state by FOLDER: tasks/todo · in-progress · review · done
archive/            archived specs + Archive.md (summary, to avoid repo scans)
code-references/     user sample swift code
.claude/
    .agentic-kit-version
    rules/swift.md  loads the swift-dev gate on any .swift read (replaces axiom)
    hooks/ · settings.json
```

**Normalizations:** (1) `Context.md` casing (consistent with existing convention);
(2) `code-references/` with no space (a spaced folder causes shell/script friction);
(3) task state as **subfolders of `tasks/`** (`todo/ in-progress/ review/ done/`) —
moving a file changes state (cheap, diff-friendly).

---

## 7. Skill boundary  *(Decision 4 — chose A for ios-feature-pipeline)*

Shipped inside the plugin:

| Skill | Role | Change |
|---|---|---|
| `idea-to-spec` | engine of `brainstorm` | — |
| `spec-to-tasks` | engine of `plan` | — |
| `task-execution` | engine of `execute`; absorbs superpowers' execution practices | expanded |
| `swift-dev` | Swift/iOS domain router (replaces axiom) | restored |
| `oss-first` | author's own skill | stays |
| `ios-agentic-kit` | self-knowledge ("what the kit is / how to set up") | **rewrite** (drop axiom/superpowers) |
| `ios-feature-pipeline` | "I want to build X" entry point → **reads `workflow.yml`** and walks the phases | **demoted to thin router** |

- `ios-feature-pipeline` chose **A (thin router)** over delete/keep-as-is: keeps the
  auto-triggered entry point for vague feature requests (user needn't memorize commands)
  while removing the phase-definition duplication that now conflicts with `workflow.yml`
  being the SSOT.

### Deliberate exclusions (kept OUT on purpose)
- **axiom** — replaced by `swift-dev`.
- **superpowers** — execution role → `task-execution`; brainstorm role → `idea-to-spec`
  (already better); debugging → `swift-dev/ios-debugger-agent`.
- **ponytail** — no longer referenced in docs; user-optional install.
- **project-templates/** — ambitious; deferred to `project-scaffolding.md` (spec #4).

---

## 8. Worked example — where artifacts land

Running a small feature ("dark-mode toggle") through the redesigned layout:

1. `/init` (existing repo, `feature` mode) → creates `specs/ tasks/ archive/ code-references/`,
   fills `Context.md`, writes `mode: feature` into `Roadmap.md`.
2. `/brainstorm` → `specs/dark-mode-toggle.md`; `Roadmap.md` registers it (status `designing`).
3. `/plan` → tasks created under `tasks/todo/` (one file per task); `Roadmap.md` → `planned`.
4. `/execute` → a task file moves `tasks/todo/ → in-progress/ → review/ → done/` as it runs;
   swift-dev loads via `.claude/rules/swift.md` on each `.swift` read; on completion the spec
   is summarized into `archive/Archive.md` and the spec file moved to `archive/`.

Empty/zero state: a freshly `init`-ed repo has empty `specs/ tasks/ archive/ code-references/`
and a `Roadmap.md` with only the mode flag — the valid "nothing designed yet" state.

---

## 9. Open / next

- **Next session:** `pipeline.md` (spec #2) — design the three phases' behavior in detail:
  the `workflow.yml` schema itself, phase-by-context detection, prereq gating, the token-cost
  routing proxy (rough estimate = total touched-file size + description), context-budget
  management (warn 120k / urgent compact 180k), subagent vs. orchestrator routing
  (≤20k-estimate → orchestrator), TDD-first execution, and the archive/summary mechanism.
- **Then:** `preferences-and-priority.md` (spec #3) — feedback-logging mechanism, Code
  References progressive disclosure, full priority-chain application.
- **Deferred risk — [EXPLICIT RISK — backlog] `project-scaffolding.md`** (spec #4):
  per-architecture base projects (MVVM / MVVM+C / TCA / Viper / Vanilla) with sample models,
  navigation, persistence (SwiftData / Supabase / JSON). Highest maintenance cost; out of scope now.
- **[TECHNICAL RISK — specify in pipeline spec] Token-cost routing** rests on a rough proxy
  (file size + description); validate it doesn't misroute large-but-simple or small-but-complex tasks.
