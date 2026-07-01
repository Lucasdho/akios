# Akios Specification Review — 2026-07-01

**Scope reviewed:** the akios-authored specification/contract set — `workflow.yml` (the declared
"single source of truth"), the 7 `commands/*.md`, the core `skills/*/SKILL.md` and their key
`references/`, the `templates/`, and the top-level docs (`README.md`, `START-HERE.md`,
`CHANGELOG.md`). The vendored `swift-dev/skills/**` domain guides (accessibility, concurrency,
SwiftData, etc.) are third-party bundled knowledge, not akios-authored contract, and were skimmed
for cross-references only.

**Overall:** the spec set is unusually well-written for an agentic kit — a real single-source-of-truth
discipline, a priority chain repeated verbatim across files, and strong anti-pattern sections. The
issues below are mostly **drift between related documents** (numbers, counts, status vocabularies,
dangling references) rather than fundamental design flaws. None block the kit from working; several
would mislead an agent or a reader.

---

## Weak Points

### W1. Dangling reference to `specs/pipeline.md` in the contract file
`workflow.yml:6` and `CHANGELOG.md:58` both cite `specs/pipeline.md §1-2` as the authority for
phase detection and prereq gating. **No `specs/pipeline.md` exists in the repo.** (The `specs/`
folder is created at runtime in the *user's* project, so this reference can never resolve from the
kit itself.) The machine-readable contract points at documentation that isn't shipped — an agent
told to "see specs/pipeline.md" will find nothing.

### W2. Dangling reference to a `founderlens-sim` skill
`skills/founderlens-behavior/SKILL.md` (frontmatter `description` and line 18) tells the reader
"For the HTML/React simulator version, use the companion skill `founderlens-sim`." **No
`founderlens-sim` skill ships in this repo.** `references/app-behavior.md` further describes "the
simulator" throughout as if it exists. Either the sim skill was removed and references weren't
cleaned, or it was never added.

### W3. CHANGELOG is behind the shipped version
`VERSION` and `.claude-plugin/plugin.json` are both `0.7.4`, but the newest `CHANGELOG.md` entry is
`## 0.7.3`. There is **no 0.7.4 entry**, so the migration path `/akios:init` promises to "report the
diff from CHANGELOG.md" (`commands/init.md:29`) has nothing to report for the current version.

### W4. `ios-feature-pipeline` invoked as a slash command that doesn't exist
`skills/ios-agentic-kit/SKILL.md:35` says "start with `/ios-feature-pipeline`", and
`templates/AGENTS.md` uses the same slashed form. But `ios-feature-pipeline` is a **skill**, not a
command — there is no `commands/ios-feature-pipeline.md`, and all real commands are namespaced
`/akios:*`. The `/ios-feature-pipeline` notation implies an invocable command that isn't there.

### W5. Ambiguous "up to 3" vs "2–4" positions across the design skills
`idea-to-spec/SKILL.md` golden rule #2 and the decision loop are emphatic: **"up to 3 (2–3; never
pad to a fourth)."** But `founderlens-behavior/SKILL.md:28` and
`references/app-behavior.md:12` say **"2–4 positions."** Both describe the same "propose, then
check" mechanic; a reader can't tell whether the ceiling is 3 or 4.

### W6. Vague `est_tokens` estimation with no worked example
The `est_tokens ≈ Σ touched-file sizes + description weight` proxy
(`templates/task.md:4`, `spec-to-tasks/SKILL.md:33`) is defined but never demonstrated. For **new**
files it's "estimate from the spec description (acknowledged as rough)" — with no anchor for what a
"14k" task looks like, the `≤20k orchestrator / >20k subagent` routing rests on an unguided guess.

### W7. Dual state tracking (spec/task file `State:` line vs `Roadmap.md`)
`templates/spec.md:8` and `templates/task.md:12` each embed a `> **State:**` line, with a comment to
"mirror this into Roadmap.md." Meanwhile `templates/AGENTS.md` insists spec state "lives **only** in
`Roadmap.md`." Two places hold the same status, which is exactly the drift the single-source rule
exists to prevent. (Task state is at least self-justifying — it equals the folder — but the spec
`State:` line has no such anchor.)

---

## Strong Points

### S1. The priority chain is genuinely single-sourced
The 4-tier chain (project decision → code-references → user preferences → swift-dev) appears
**verbatim and identically ordered** in `templates/AGENTS.md`, `skills/task-execution/SKILL.md:94`,
`skills/ios-agentic-kit/SKILL.md:58`, and `templates/rules/swift.md:16`. This is the hardest thing
to keep consistent across a doc set and it's done well.

### S2. `workflow.yml` as a real contract, referenced not re-documented
The commands and phase skills consistently defer to `workflow.yml` ("don't re-document the phases
here" — `commands/brainstorm.md:14`, `plan.md:12`, `execute.md:12`, `ios-feature-pipeline/SKILL.md:12`).
The discipline of one machine-readable contract + thin wrappers is followed almost everywhere.

### S3. Empty/loading/error states are mandated end-to-end
The "document every empty state" rule is threaded coherently from design to execution:
`spec-format.md:49-54` → `templates/spec.md:22` → `idea-to-spec/SKILL.md:169` →
`spec-to-tasks/SKILL.md:6` (designer's-eye DoD) → `templates/task.md:27` (happy·empty·loading·error)
→ `align-ui/SKILL.md` states section. Same four states, same insistence, at every stage.

### S4. Multi-instance / team coordination is impressively consistent
The git-as-lock model — claim-before-work, `Akios-Instance` signatures, monotonic Roadmap status
(`designed < planned < in-progress < done`, higher wins on conflict), edit-only-your-line — is
described compatibly across `workflow.yml:82-84`, `templates/AGENTS.md`,
`task-execution/SKILL.md:29-52`, `just-vibes/SKILL.md:170-178`, and `templates/Roadmap.md:20-25`.
No contradictions in a genuinely subtle concurrency protocol.

### S5. Clear, actionable anti-pattern sections
Nearly every skill closes with a concrete "Anti-patterns" list (`idea-to-spec`, `spec-to-tasks`,
`task-execution`, `just-vibes`, `deep-brainstorm`, `swift-dev`). They name real failure modes with
the fix, not platitudes.

### S6. `START-HERE.md` and `oss-first` are exemplary
`START-HERE.md` is a genuinely plain-language onboarding path (paste-one-block, answer-questions).
`oss-first/SKILL.md` is thorough: activation signals, an explicit "do NOT trigger" list, a fixed
comparison-table output format, and three worked examples including one that correctly *doesn't*
trigger.

---

## Inconsistencies

### I1. `align-ui` under just-vibes: "skipped" vs "runs in auto mode" (contradiction)
The single most confusing conflict in the set. Whether `align-ui` **runs** under just-vibes is
stated three incompatible ways:
- `task-execution/SKILL.md:64` — "[UI gate] … run align-ui **(skip under just-vibes)**"
- `task-execution/SKILL.md:171` (anti-pattern) — "Implementing a UI task without running align-ui
  first — **except under just-vibes**" → reads as *not run*
- `task-execution/SKILL.md:77-78` — "Under just-vibes the gate is skipped; **align-ui auto-decides
  and writes the alignment doc**" → *does run*
- `just-vibes/SKILL.md:145` — "**run align-ui in auto-decide mode**" → *does run*
- `align-ui/SKILL.md:18` — "**Skipped:** under /akios:just-vibes" then `:108-116` "skip the
  grilling loop entirely. Instead: … **Write the same** `tasks/ui-alignment/<ScreenName>.md`" → *does run*

The actual intent is "the interactive **grilling** is skipped, but align-ui still runs and writes the
doc with `[auto]` markers." As written, "skip under just-vibes" and "except under just-vibes" flatly
say the opposite. **Fix:** replace every bare "skip align-ui under just-vibes" with "run align-ui in
auto-decide mode (grilling skipped)".

### I2. Two different R-W-W rubrics, one claims to be the other
`CHANGELOG.md:6-9` says deep-brainstorm's audit rubric is "adapted from FounderLens MVA," but the
two disagree on both weights and bands:

| | deep-brainstorm (`SKILL.md:210-216`) | FounderLens MVA (`app-behavior.md:44-54`) |
|---|---|---|
| Real | 30 | 30 (Pain 15 + Reach 15) |
| Win | **40** | **45** (Diff 20 + Distribution 15 + Independence 10) |
| Worth It | **30** | **25** (WTP 15 + Feasibility 10) |
| Bands | **3**: 71–100 Green / 41–70 Yellow / 0–40 Red | **6**: 90 Excellent … 41–55 Shaky / 0–40 Weak |

deep-brainstorm labels Yellow (41–70) as `[audit: shaky]`, borrowing FounderLens's "Shaky" name but
with a **different range** (FounderLens Shaky = 41–55). Two rubrics that are documented as the same
one should either be reconciled or explicitly noted as intentionally different.

### I3. Discover phase has 8 ingredients in one skill, 10 in the other
`deep-brainstorm/SKILL.md:63-72` runs a **Discover phase of 8 ingredients**; `founderlens-behavior`
(`app-behavior.md:19-30`) defines Discover as **10 ingredients**. deep-brainstorm explicitly
delegates the "first-diamond run" to `founderlens-behavior` (`commands/deep-brainstorm.md:16-18`,
`deep-brainstorm/SKILL.md:54-57`), so the same "Discover" produces different ingredient sets
depending on which path fires. (E.g. FounderLens has Frequency/WTP/Trigger; deep-brainstorm drops
those and adds Business model/Distribution.)

### I4. `objectVersion` for "Xcode 16+ synchronized groups": 77 vs 90
Three files say `objectVersion ≥ 77` = Xcode 16+ (`commands/init.md:56`, `swift-dev/SKILL.md:90`,
`CHANGELOG.md:130`). But the `templates/Context.md:20` placeholder text hard-codes
"**objectVersion 90**." 90 is inconsistent with the ≥77 threshold the rest of the kit uses (and
doesn't match a released Xcode value). An agent filling Context.md from init's detection logic will
record a number that contradicts its own detection rule.

### I5. `AGENTS.md` misquotes task-execution's context-warn line (110k → 120k)
`templates/AGENTS.md:73-74` says a subagent is warranted at "**≥120k tokens** … (this is the same
**120k "warn" line** `task-execution` watches)." But `task-execution/SKILL.md:137` warns at **110k**
(urgent at 135k), and `commands/execute.md:21` + `CHANGELOG.md:46` confirm 110k. AGENTS.md conflates
the 120k *subagent-dispatch pressure* line with task-execution's 110k *context-warn* line and states
they're identical — they aren't.

### I6. Runner routing (`>20k → subagent`) contradicts the subagent-economy rule
`task-execution/SKILL.md:83` and `spec-to-tasks/SKILL.md:33` route any task with `est_tokens > 20k`
to a subagent unconditionally (the `runner` field). But `templates/AGENTS.md:70-77` ("Sizing the
work") says dispatch a subagent **only** when the session is "≥120k tokens **and** the task is heavy
and isolatable," and otherwise "just do it inline." A 25k-token task is "subagent" by its `runner`
field but "inline" by the economy rule. The per-task threshold and the session-pressure threshold
give conflicting dispatch answers.

### I7. `needs-revision` / `blocked` statuses aren't in the status vocabulary they extend
`just-vibes/SKILL.md` and `deep-brainstorm/SKILL.md:237` introduce Roadmap status `needs-revision`,
and `task-execution/SKILL.md:165` + `just-vibes/SKILL.md:157` introduce `blocked`. But the canonical
status enum everywhere else is only `designed → planned → in-progress → done`
(`templates/Roadmap.md:21`, `workflow.yml` `roadmap:` fields, `templates/spec.md:9`). Neither
`Roadmap.md` nor `workflow.yml` lists `needs-revision`/`blocked`, and the **monotonic ordering** that
team-mode conflict resolution depends on (`designed < planned < in-progress < done`) is **undefined**
for these two extra statuses — a real gap given "higher status wins" is the arbitration rule.

### I8. Three different enumerations of "the skills the kit ships"
- `README.md:14` — "The kit ships **8 skills**."
- Actual top-level authored skills — **12** dirs (align-ui, deep-brainstorm, founderlens-behavior,
  handoff, idea-to-spec, ios-agentic-kit, ios-feature-pipeline, just-vibes, oss-first, spec-to-tasks,
  swift-dev, task-execution).
- `ios-agentic-kit/SKILL.md:101-112` "Skills the kit ships" table — lists **7** authored, and
  **omits** just-vibes, deep-brainstorm, align-ui, handoff, founderlens-behavior.
- `START-HERE.md:50` / `commands/init.md:110` list yet different subsets of "what the spine routes
  to" (5 vs 7).

No two agree. The `ios-agentic-kit` "ships" table and the README count are the most clearly stale.

### I9. `just-vibes` fuel precedence has 6 sources; the "contract" has 4
`just-vibes/SKILL.md:89-114` lists **6** fuel sources, including a **legacy `tasks.md`** single-file
format and a "specs present but no Roadmap.md" case. But `workflow.yml:78-81`
(`fuel_precedence`, part of the declared single-source contract) and `commands/just-vibes.md:18-19`
list only **4** — neither mentions the legacy `tasks.md` path or the needs-revision filter. The
contract file is silent on behavior the skill treats as important.

### I10. `README.md` command table omits two shipped commands
`README.md:38-45` documents 5 commands (init, brainstorm, plan, execute, just-vibes). The repo ships
**7** — `commands/deep-brainstorm.md` and `commands/handoff.md` are undocumented in the README (both
appear in `CHANGELOG.md` 0.7.1/0.7.2, so they're intentional, just not surfaced on the front page).

---

## Summary

| Severity | Items |
|---|---|
| **Contradiction (fix first)** | I1 (align-ui skip vs run), I6 (runner routing vs subagent economy), I5 (110k vs 120k) |
| **Data/number drift** | I4 (objectVersion 77/90), I2 (R-W-W rubrics), I8 (skill counts), W3 (CHANGELOG behind VERSION) |
| **Missing vocabulary / contract gap** | I7 (needs-revision/blocked status), I9 (fuel precedence), I3 (Discover 8 vs 10) |
| **Dangling references** | W1 (specs/pipeline.md), W2 (founderlens-sim), W4 (/ios-feature-pipeline) |
| **Minor / polish** | W5, W6, W7, I10 |

The kit's core architecture is sound and its hardest-to-maintain invariants (priority chain,
multi-instance protocol, empty-state mandate) are held consistently. The recurring failure mode is
**numbers and enumerations drifting between files as features were added** (align-ui rename,
deep-brainstorm's audit, just-vibes' extra statuses) without a sweep of the documents that reference
them. A single pass reconciling I1–I9 against `workflow.yml` and `AGENTS.md` as the two authorities
would resolve most of the report.
