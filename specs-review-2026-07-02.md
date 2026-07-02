# AKIOS Specification Review — 2026-07-02

A quality-and-consistency review of the akios specification set: the phase contract
(`workflow.yml`), the command definitions (`commands/*.md`), the methodology skills
(`idea-to-spec`, `spec-to-tasks`, `task-execution`, `ios-feature-pipeline`, `just-vibes`,
`deep-brainstorm`), the operating manual (`templates/AGENTS.md`), the spec/task templates,
and the top-level docs (`README.md`, `START-HERE.md`).

**Overall:** the spec set is unusually well-written for an agentic kit — the process
discipline is thought through, the anti-patterns are explicit, and the "single source of
truth" principle is mostly honored. The issues below are real but concentrated: a handful of
**stale cross-references and drift between the machine-readable contract (`workflow.yml`) and
the human-facing docs / templates** that should be tightened, plus one broken doc pointer.

---

## Weak Points

### W1 — Dangling reference to a file that doesn't exist: `specs/pipeline.md`
`workflow.yml:6` tells the reader "See `specs/pipeline.md` §1-2." for the phase-detection and
gating rules, and `CHANGELOG.md:58` claims just-vibes is "documented in ... `specs/pipeline.md`."
That file exists nowhere in the repo, and `/akios:init` never creates it (`commands/init.md`
step 3 table, lines 66–78, has no `specs/pipeline.md` row). The single most important contract
file points readers at a spec that was never written (or was removed). Either write
`specs/pipeline.md` or delete the two references and inline the §1-2 rules into `workflow.yml`'s
own header comment.

### W2 — `templates/task.md` frontmatter is missing fields the plan skill declares mandatory
`spec-to-tasks/SKILL.md` documents the task frontmatter (lines 62–71) with **`checkpoint:`** and
**`swift_dev:`** fields, and the surrounding prose makes both mandatory ("Tag each task with its
`swift-dev` domain sub-skill", line 53; "Checkpoint order and `[major]` markers are carried on
each task's `checkpoint` field", SKILL.md line 80). But the actual `templates/task.md` frontmatter
(lines 1–8) has only `id, spec, est_tokens, runner, parallel, area` — **no `checkpoint`, no
`swift_dev`**. An agent that fills the template verbatim produces tasks that `task-execution`
can't route (it reads `swift_dev` to seed cold subagents, `task-execution/SKILL.md:87–92) or
sequence (`checkpoint` barriers). The template should carry both fields.

### W3 — Two competing, unreconciled rules for "when to use a subagent"
`templates/AGENTS.md` ("Sizing the work & subagent economy") says work **inline by default** and
reach for a subagent only when context is **≥120k tokens AND** the task is heavy/isolatable.
`task-execution/SKILL.md` (lines 82–86) and `spec-to-tasks/SKILL.md` (lines 37–39) route purely
on task size: **`≤20k → orchestrator`, `>20k → subagent`**. A 25k-token task is "dispatch to a
subagent" by the runner rule but "stay inline" by the AGENTS.md economy rule, with no note telling
the agent which wins. Add one sentence reconciling them (e.g. "the `runner` field is the *default*;
the AGENTS.md context-pressure test overrides it downward").

### W4 — Roadmap status vocabulary is defined in fragments, never in one place
The status enum is spread across files and no single spec lists the full set:
- `workflow.yml` uses only `designed / planned / done` (lines 36, 43, 50).
- `templates/AGENTS.md` says `designed/planned/in-progress/done`.
- `task-execution/SKILL.md:52` defines the monotonic order `designed < planned < in-progress < done`.
- `deep-brainstorm/SKILL.md` (Phase 5) introduces **`needs-revision`**.
- `just-vibes/SKILL.md:157` introduces **`blocked`** for parked specs.

`needs-revision` and `blocked` never appear in the monotonic ordering, so on a team-mode merge
conflict (`task-execution/SKILL.md:52`, "higher status wins") their precedence is undefined — a
`blocked` spec could be silently overwritten by a stale `designed` edit, or vice-versa. Define the
complete status set and where the two "off-ramp" states sit relative to the monotonic chain.

### W5 — `spec-format.md` leads with the wrong (non-iOS) naming convention
`idea-to-spec/references/spec-format.md:6` documents the primary spec filename as
`<project>-<block>-spec.md` (e.g. `founderlens-onboarding-spec.md`). The iOS-pipeline form
`specs/<feature>.md` — the one every other file in the kit actually uses (`workflow.yml`, all
commands, all skills, `templates/spec.md`) — is relegated to a secondary blockquote note (lines
9–12). For an "Agentic Kit for **iOS**", the default a reader sees first should be the iOS form;
the FounderLens-era convention is the exception, not the headline.

### W6 — `START-HERE.md` still references cloning to `~/akios`, coupling the plugin path to a hardcoded dir
`START-HERE.md:45–47` instructs `git clone https://github.com/Lucasdho/akios.git ~/akios` and the
script route reads `~/akios/scripts/...`. This is the manual/no-plugin path, but nothing verifies
the repo actually lives at `~/akios`; a user who cloned elsewhere gets copy-paste commands that
silently fail. Minor, but worth a one-line "adjust the path if you cloned elsewhere."

---

## Strong Points

### S1 — `workflow.yml` as a genuine single source of truth, and it's respected
The phase contract is small, machine-readable, and every command explicitly defers to it instead
of re-documenting phases (`commands/brainstorm.md:13` "don't re-document the phases here";
`commands/plan.md:12` "single source of truth — don't re-document the pass";
`ios-feature-pipeline/SKILL.md:12` "**`workflow.yml` is the single source of truth**"). This is the
right architecture and it's applied consistently — a rare discipline in agent instruction sets.

### S2 — Anti-patterns sections are concrete and failure-mode-driven
Nearly every skill ends with an "Anti-patterns" list naming the *specific* observed failure it
prevents rather than generic advice: `ios-feature-pipeline/SKILL.md:46–66` ("Staying in flow")
names the exact drift ("during brainstorm the user says 'just create the seed data' and the agent
starts hand-writing files"); `task-execution/SKILL.md:169–183` and `just-vibes/SKILL.md:193–204`
are similarly grounded. These read like they were written from real transcripts.

### S3 — The unattended (just-vibes) override contract is airtight
`just-vibes/SKILL.md:20–49` ("UNATTENDED MODE — HARD RULES") explicitly enumerates which
interactive rules in *every* sub-skill are waived and why, and each sub-skill has a matching
"Exception — under just-vibes" clause (`task-execution/SKILL.md:161–167`,
`idea-to-spec/SKILL.md:103–128`). The mode boundary is stated from both sides — the hardest part
of a dual-mode spec to get right — and it's consistent across all five files.

### S4 — Empty/loading/error state coverage is enforced end-to-end
The "document empty states" requirement is threaded through the whole pipeline as a hard rule, not
a nicety: `spec-format.md:46–54` (mandatory in the spec), `templates/spec.md:22–26` (a required
section), `spec-to-tasks/SKILL.md:44–46` (the "Designer's-eye" per-task DoD), and
`task-execution/SKILL.md:108–112` (the view test bar). One requirement, correctly propagated
across four documents.

### S5 — Priority chain is defined once and cross-referenced, not copy-pasted with drift
The "whose answer wins" priority chain appears in `templates/AGENTS.md` and
`task-execution/SKILL.md:94–102` with identical tiers and identical tie-break prose ("Concrete
shown code outranks a stated preference"). The two copies agree exactly — the good kind of
redundancy.

### S6 — Cost/model discipline is specific and actionable
`templates/AGENTS.md` ("subagent economy") and `task-execution/SKILL.md:82–92` give concrete,
non-hand-wavy routing (haiku for mechanical subtasks, sonnet for end-to-end spec work, never clone
the context window into a subagent). This is more precise guidance than most kits provide.

---

## Inconsistencies

### I1 — The kit's own skill count is stated three different ways, and none is correct
- `README.md:14` — "The kit ships **8 skills**".
- `commands/init.md:110` — lists **7** ("`swift-dev`, `idea-to-spec`, `spec-to-tasks`,
  `task-execution`, `oss-first`, `ios-feature-pipeline`, `just-vibes`").
- `START-HERE.md:50` — lists **5** ("swift-dev, idea-to-spec, spec-to-tasks, task-execution,
  oss-first").
- Actual top-level skill directories: **12** (`align-ui, deep-brainstorm, founderlens-behavior,
  handoff, idea-to-spec, ios-agentic-kit, ios-feature-pipeline, just-vibes, oss-first,
  spec-to-tasks, swift-dev, task-execution`).

Four numbers, four disagreements. At minimum `README.md:14` should be corrected; better, state the
count in one place and describe it as "N routing skills + swift-dev's domain sub-skills" so it
doesn't need re-counting on every addition.

### I2 — `README.md:47` claims "All commands are typed-only (`disable-model-invocation`)" but `handoff` isn't
Every command frontmatter carries `disable-model-invocation: true` **except**
`commands/handoff.md` (lines 1–5: `description` + `argument-hint`, no `disable-model-invocation`).
So `README.md:47`'s absolute claim is false, and `/akios:handoff` *can* auto-fire on model
invocation while the docs promise it can't. Either add the flag to `handoff.md` or soften the
README claim.

### I3 — `handoff` and `deep-brainstorm` commands are absent from the README command table
`README.md:38–45` lists only `init, brainstorm, plan, execute, just-vibes`. But
`commands/deep-brainstorm.md` and `commands/handoff.md` both exist and are user-invokable, and
`deep-brainstorm` is a documented run-style in `workflow.yml:57–71`. `handoff` appears in **no**
top-level doc at all (`README`, `START-HERE`, `workflow.yml`) — it's a fully undocumented command.
The command table should be complete.

### I4 — `workflow.yml` `bootstrap.creates` disagrees with what `/akios:init` actually creates
`workflow.yml:20–30` lists the bootstrap outputs as `CLAUDE.md, AGENTS.md, Context.md, Roadmap.md,
specs/, tasks/, archive/, code-references/`. But `commands/init.md` (step 3 table, lines 66–78, and
self-check, lines 100–105) also creates and *requires* **`Vision.md`**, **`workflow.yml`** itself,
**`.claude/rules/swift.md`**, three hooks, and the version file. `Vision.md` in particular is a
required self-check artifact (`init.md:105`) and a first-class just-vibes fuel source
(`workflow.yml:81`, `templates/AGENTS.md` artifact map) — yet the contract's own `bootstrap.creates`
list omits it. The machine-readable list should match the onboarding it describes.

### I5 — `tasks.md` (legacy single-file) is both a supported input and a forbidden output
`just-vibes/SKILL.md:93–94` (fuel precedence #3) and `112` support a legacy single-file
`tasks.md` as valid execute fuel. But `spec-to-tasks/SKILL.md:24` states the kit produces "**No
single `tasks.md`**" and lists creating one as an anti-pattern (`SKILL.md:100`); `git log` shows a
recent "Delete tasks.md" commit. The tension is defensible as read-only backward-compat, but it's
never labeled as such — a reader sees one skill forbidding the exact artifact another skill
consumes. Add a one-line "legacy, read-only; never generated" note at the just-vibes fuel entry.

### I6 — just-vibes fuel precedence has more levels than the `workflow.yml` contract it implements
`workflow.yml:78–82` defines `fuel_precedence` with **4** levels (explicit idea → `tasks/todo/` →
`specs/*.md @ designed` → Vision/Roadmap item). `just-vibes/SKILL.md:89–114` defines **6** (adds
legacy `tasks.md` and "specs present but no Roadmap"). The ordering is compatible, but the contract
and the implementing skill list different fuel sets — the contract should either enumerate all six
or explicitly say the skill refines it.

### I7 — Terminology: "brainstorm" the phase vs. "deep-brainstorm" the run-style vs. the whole-app "brainstorm"
`workflow.yml` classifies `deep-brainstorm` as a **run-style** (line 57) alongside `just-vibes`,
but `deep-brainstorm/SKILL.md:28` calls it a "**pre-execution cartography pass**" and its command
description (`commands/deep-brainstorm.md:1`) calls it "the 'zoom out first' complement to
`/akios:brainstorm`." Meanwhile `just-vibes` treats an unattended brainstorm as a *phase* it drives.
The three framings (run-style / pass / phase-complement) aren't contradictory but they aren't
aligned either — a glossary entry pinning "phase" vs "run-style" vs "pass" would remove the
ambiguity. (`workflow.yml:53–56` starts this distinction but doesn't cover `deep-brainstorm`
cleanly.)

---

## Summary

| Severity | Count | Highlights |
|---|---|---|
| Weak points | 6 | Broken `specs/pipeline.md` pointer (W1); template missing mandatory task fields (W2) |
| Strong points | 6 | `workflow.yml` single-source discipline (S1); airtight unattended override contract (S3) |
| Inconsistencies | 7 | `handoff` breaks the "all commands typed-only" claim (I2); skill count stated 3 ways (I1); bootstrap list omits `Vision.md` (I4) |

**Top 3 to fix first (highest impact, lowest effort):**
1. **W1 / I4** — resolve the `specs/pipeline.md` reference and add `Vision.md` to
   `workflow.yml bootstrap.creates`; these are the contract file pointing at something that doesn't
   exist and a contract that under-describes its own bootstrap.
2. **I2** — add `disable-model-invocation: true` to `commands/handoff.md` (or fix the README
   claim); this is a correctness gap, not just documentation.
3. **W2** — add `checkpoint:` and `swift_dev:` to `templates/task.md`; without them the template
   produces tasks the executor can't route.

The kit's architecture is sound and its process discipline is genuinely strong; every finding above
is drift/staleness in the connective tissue between files, not a flaw in the methodology itself.
</content>
</invoke>
