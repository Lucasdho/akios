---
description: Onboard this repo to the akios kit — interview, scan, fill the context files, create the folder tree, seed preferences, and wire the gate hook.
disable-model-invocation: true
---

# /akios:setup — Onboard a repo to the kit

You are setting up the akios agentic-kit in the user's repo. A plugin cannot shell-write
into their repo, so you do this with your own file tools. Work at the **git repo root**
(`git rev-parse --show-toplevel`); fall back to the cwd if not a git repo.

Templates live in the installed plugin at `${CLAUDE_PLUGIN_ROOT}/templates/` and
`${CLAUDE_PLUGIN_ROOT}/scripts/`. Read them from there; do not invent their contents.
`setup` is **bootstrap, not a phase** (see `akios/workflow.yml` `bootstrap`).

**Narrate as you go (`init-reliability-and-ux.md` §1).** Print a one-line header the moment each
numbered step below starts (e.g. "Scanning repo…", "Materializing 12 files + folder tree…",
"Wiring hooks…", "Self-check…") — a step should never run silently. Steps §1a (skeleton copy) and
§3 (Materialize) additionally narrate **per item** as each file/action completes (e.g.
"✓ `AGENTS.md` written", "✓ `.claude/hooks/agentic-kit-inject.sh` copied + executable") — those are
the long steps that previously ran silently; the short/interactive steps don't need per-item
narration on top of their header.

## 0. Detect state (idempotency gate — do this first)
Don't re-onboard a repo that's already set up; re-running `/akios:setup` should be cheap.
Read the installed version (`${CLAUDE_PLUGIN_ROOT}/VERSION`) and the repo's recorded version
(`<root>/.claude/.agentic-kit-version`, may be absent), then branch:

- **No version file (or no `AGENTS.md`)** → fresh repo. Run the **full** flow (steps 1–6).
- **Recorded == installed** → already initialized. **Skip the interview and copies.** Run only the
  **self-check (step 6)**, repair any single missing artifact, and stop with "Already initialized
  at v<X> — nothing to do." Re-run the full flow only if the user asks to repair/reset.
- **Recorded < installed** → **migrate, don't re-interview.** Skip step 1. Refresh only the
  **always-copy** artifacts (the two hooks, `akios/workflow.yml`, the version file); leave the
  *skip-if-exists* files (`AGENTS.md`, `akios/Context.md`, `akios/Roadmap.md`, `.claude/rules/swift.md`)
  untouched. Re-verify wiring (steps 4–5). Write the new version, then **report the diff** from
  `${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md` in two or three lines, flagging anything needing a manual touch.
  Detect the **mode** here too: if the user has feature work in mind, ask `new`/`one-shot`/`feature`.
  **If a repo already onboarded before this footprint move still has a root-level
  `scripts/alva-usage-ledger.sh`** (`init-reliability-and-ux.md` §5, §8): copy it to
  `.claude/scripts/alva-usage-ledger.sh`, verify the copy landed (§3's verification discipline),
  re-point the pre-commit hook's call to the new path, and **only then** remove the old root-level
  file — never delete-then-copy. This targets that one named file only; never touch anything else
  the user may have in their own `scripts/` folder.

  **`akios/` folder migration (opt-in, `akios-footprint-consolidation.md` §8/D8 — supersedes
  `init-reliability-and-ux.md` §5 only).** Detect a pre-consolidation repo: a recorded version
  older than this spec, alongside root-level `specs/`, `tasks/`, `Context.md`, `Roadmap.md`,
  `Vision.md`, `workflow.yml` rather than an `akios/` folder. **Ask, don't silently move:**
  "This repo predates the `akios/` consolidation — migrate now? (moves `specs/ tasks/ archive/
  code-references/ Context.md Roadmap.md Vision.md workflow.yml` into `akios/`, renames the
  runtime journal `.akios/` to `akios/.local/`, updates `CLAUDE.md`'s import path. Everything
  keeps working either way — this is cosmetic, not a functional requirement.) y/n"
  - **On yes:** move file-by-file, reusing `init-reliability-and-ux.md` §2–§4's exact
    verification discipline — verify each move landed (source gone, destination present +
    non-empty) before the next, retry once on a confirmed miss, stop-and-report an itemized
    manifest on a second failure. Update `CLAUDE.md`'s `@Context.md` → `@akios/Context.md`
    import as the **last** write in the sequence, only after every file move is confirmed — a
    failed migration must never leave the import pointing at a `Context.md` that no longer
    exists at the old path.
  - **On no (or nothing stale):** leave the repo as-is — a pre-consolidation repo is not broken,
    every path still resolves for that repo's own commands/skills written against the old
    paths. Don't ask again until the user explicitly requests it (`/akios:setup --consolidate`).
  - **Name-collision check (before any write):** if the repo already has a pre-existing `akios/`
    directory unrelated to this kit (no recognizable `Context.md`/`Roadmap.md`/`specs/`/`tasks/`
    shape inside it), treat it the same as any other "file already exists and isn't ours" case
    in step 3's materialize table — surface it to the user, ask how to proceed (e.g. a
    different folder name, or abort the migration), and **never** silently write into or over
    it. This applies to both this migrate path and a fresh §3 materialize run.

## 1. Interview (short — map answers to the placeholders)
Ask in one batched pass (skip what the scan in step 2 answers confidently; confirm rather than re-ask):
- **Mode** — `new` (greenfield repo) / `one-shot` (single deliverable) / `feature` (adding to an
  existing app). Written to `akios/Roadmap.md`; `brainstorm` reads it instead of re-asking.
- **Collaboration** — `solo` (you're the only one running akios here) / `team` (multiple devs each
  run akios against this repo). Written to `akios/Roadmap.md`. Drives delivery: **solo** → just-vibes merges
  + pushes the default branch; **team** → just-vibes pushes `feature/<spec>` + opens a PR, and the
  multi-instance claim/signature etiquette is in force.
- **Posture** — `learning` (narrate the *why* behind decisions as you build) / `delivery` (ship
  quietly, default). Written to `akios/Roadmap.md`. Orthogonal to mode/collaboration; overridable for a
  single session via a command flag or a spoken switch without rewriting this default. See
  `AGENTS.md` "Operating posture" for what the flag actually changes.
- **Autonomy** — `manual` (default: just-vibes never pushes/merges/opens a PR on its own, even
  under `--force`; a finished unit stays local and shows up in the run's "Built (unshipped)"
  bucket) / `auto` (just-vibes auto-ships per the `collaboration` answer above — solo merges +
  pushes, team pushes + opens a PR). Written to `akios/Roadmap.md`. **Independent of `collaboration` —
  not inferred from it**: collaboration is about headcount, autonomy is about whether unattended
  delivery is authorized at all. Overridable per run via a command flag or a spoken switch without
  rewriting this default. See `AGENTS.md` "Delivery autonomy" / `akios/specs/collaboration-autonomy.md`.
- **Stack** — language / framework / runtime / DB (`{{LANGUAGE / FRAMEWORK / RUNTIME / DB}}`)
- **Commands** — install / run-dev / test / lint / build (`{{install}}` `{{dev}}` `{{test}}` `{{lint}}` `{{build}}`)
- **Architecture** — one paragraph: entry points, key dirs, data flow
- **Conventions** — naming, error handling, commit/branch style
- **Gotchas** — the thing that bites a newcomer or the agent
- **Project-specific gate** (AGENTS.md) — e.g. "always /security-review when touching auth"
- **House rule** (AGENTS.md `{{PROJECT_RULE}}`) — a project-specific must/never
- **Claude note** (CLAUDE.md) — any Claude-specific instruction, or drop the section

## 1a. Skeleton selection (`mode: new` only — folds into the Architecture question, no duplicate)
Architecture-keyed whole-project starters (`skeleton-library.md`). Runs **only** immediately
after `Mode` resolves to `new` in step 1 above — never for `feature`/`one-shot`, and never on a
migrate-path re-run (step 0's "Recorded < installed" branch). A skeleton is a whole file tree;
offering to drop one into a repo that may already have code risks clobbering existing files, so
the option is never even shown outside `mode: new`.

1. List the distinct `architecture:` tags found across `~/.claude/akios/skeletons/*/manifest.yml`
   (user-global only — there is no repo-local skeleton convention), plus an explicit **"none /
   default scaffold"** option. **If zero skeletons are registered anywhere, skip this entire
   step** — the free-text "Architecture" question in step 1 runs exactly as it does today, zero
   regression.
2. If exactly one skeleton matches the chosen tag, use it directly. If more than one match
   (variants, e.g. `alva-minimal` + `alva-with-supabase`), show just those by `name` for a
   second, narrower pick.
3. If the user explicitly picks **"none / default scaffold"** (even though skeletons exist),
   proceed exactly as today — a skeleton is never forced.
4. **Pre-fill, don't duplicate.** The chosen skeleton's `description:` + `stack:` pre-fill step
   1's existing "Architecture" interview answer (still user-editable) — this is not a second
   question.
5. **Copy before scan.** If a skeleton was chosen, copy its full file tree into the repo root
   **now**, before step 2 (Scan) runs and before step 3 (Materialize) writes `akios/Context.md` /
   `AGENTS.md` / etc. Copying first means the scan sees the real, chosen starting structure
   (a real `.xcodeproj`, real source dirs) instead of an empty repo — scanning after the copy
   would produce a `akios/Context.md` that describes nothing. **Narrate + verify per file
   (`init-reliability-and-ux.md` §1, §2, §4):** as each file/dir lands, print "✓ `<path>` copied"
   and re-check the destination actually exists (non-empty) before moving to the next item — don't
   assume success from a clean tool-call return. On a confirmed miss, retry that one item once;
   if the retry also fails, **stop the skeleton copy immediately** and report exactly which paths
   landed vs. which didn't, rather than continuing into the scan with a half-copied tree.
6. **A skeleton never ships akios's own meta files.** Its tree covers only the app's own source
   (Xcode project, `Router/`, `Container/`, `Foundation/`, an example `Features/` slice, or
   whatever its architecture calls for) — never `AGENTS.md`, `akios/Context.md`, `akios/Roadmap.md`,
   `akios/Vision.md`, or `.claude/`. Those always come from step 3's templates, applied after this
   copy; step 3's own skip-if-exists/always-write rules remain the single source of truth for
   those names regardless of what a skeleton's tree happens to contain.

This step does not change or duplicate the existing ALVA scaffold instructions in step 3
(`Router/ Container/ Foundation/{Design-tokens,Code-tokens}/ scratchs/`, `usage-ledger.json`) —
those run unconditionally either way; a chosen skeleton's own tree may itself already contain an
ALVA shape (if tagged `architecture: alva`), and step 3's skip-if-exists rules cover the overlap.

No ingestion path exists yet for skeletons (unlike snippets' `/akios:learn --kind snippet`) —
`~/.claude/akios/skeletons/<name>/manifest.yml` + tree is hand-assembled, manual work today.

## 2. Scan (facts win over interview; surface contradictions)
Inspect the repo to fill/verify command + stack + architecture: `.xcodeproj`/`.xcworkspace`
+ scheme, `Package.swift` (SPM deps), the `xcodebuild` test/build invocation (quote any
space-containing project/scheme), deployment target, top-level source dirs. If a scan fact
contradicts an interview answer, tell the user and ask which is right before writing.

**Target membership (fills `akios/Context.md` `## Xcode targets`).** Read the `.pbxproj` and check for
`PBXFileSystemSynchronizedRootGroup` (or `objectVersion` ≥ 77 = Xcode 16+). If present, the project
uses **synchronized groups** — record which on-disk folder maps to which target (files dropped there
auto-include, no `.pbxproj` edit). If absent, record that target membership is **manual**. Note
where test fixtures live. This is what stops the agent re-deriving "will this file be in the bundle?"
on every new file.

## 3. Materialize the context files + folder tree (never clobber existing files)
Copy each template into the repo, replacing every `{{...}}` token with the resolved value.
Placeholders to fill live in `akios/Context.md`, `AGENTS.md`, `CLAUDE.md`, and `akios/Roadmap.md` (mode).

**Narrate + verify per row, always-per-file `chmod` (`init-reliability-and-ux.md` §1-§4).** As
each row below is applied, print "✓ `<File>` written/copied" (or "skipped — already exists" per
the row's rule), then immediately re-check the result before moving to the next row: for a
copy/write, re-read/stat the destination (exists, non-empty, or content-matches-source for an
exact copy); for a "make executable" row, re-stat the permission bits to confirm the executable
bit is actually set. **Never trust a clean tool-call return as proof.** Issue every `chmod +x`
below as **one call per file, always** — never batch multiple files into a single `chmod` call,
even though they're listed together here; batching this cheap, five-file operation has no real
benefit and is a known trigger for auto-mode permission classifiers to block the call. On a
confirmed miss (verification fails after the action), retry that single action exactly once; if
the retry also fails, **stop this step immediately** — do not proceed to step 4 or step 5 — and
report an itemized manifest (confirmed landed / confirmed missing / never attempted) rather than
continuing or guessing at the repo's state.

| File | Source | Rule |
|---|---|---|
| `AGENTS.md` | `templates/AGENTS.md` | skip if it already exists |
| `akios/Context.md` | `templates/Context.md` | skip if it already exists |
| `akios/Roadmap.md` | `templates/Roadmap.md` | skip if it exists; fill the `mode:` + `collaboration:` + `posture:` + `autonomy:` lines |
| `akios/Vision.md` | `templates/Vision.md` | skip if it exists; fill the north-star + first wishlist items (just-vibes fuel) |
| `akios/workflow.yml` | `${CLAUDE_PLUGIN_ROOT}/workflow.yml` | always copy (the phase contract) |
| `CLAUDE.md` | `templates/CLAUDE.md` | if missing, create; if present, prepend whichever of `@AGENTS.md` / `@akios/Context.md` imports is missing (Context first so AGENTS ends on top) |
| `.claude/rules/swift.md` | `templates/rules/swift.md` | skip if it already exists |
| `.claude/hooks/agentic-kit-inject.sh` | `scripts/hook/agentic-kit-inject.sh` | always copy; make executable (per-file `chmod`) |
| `.claude/hooks/skill-trace.sh` | `scripts/hook/skill-trace.sh` | always copy; make executable (per-file `chmod`, optional telemetry) |
| `.claude/hooks/akios-instance.sh` | `scripts/akios-instance.sh` | always copy; make executable (per-file `chmod`; instance signature for just-vibes + claims) |
| `.claude/hooks/post-checkpoint-verify.sh` | `scripts/hook/post-checkpoint-verify.sh` | always copy; make executable (per-file `chmod`; the auto-build/test hook — `task-execution` calls it at `[major]` checkpoints; degrades to a graceful no-op if there's no build tool) |
| `.claude/.agentic-kit-version` | contents of `${CLAUDE_PLUGIN_ROOT}/VERSION` | always write |
| `.claude/scripts/alva-usage-ledger.sh` | `${CLAUDE_PLUGIN_ROOT}/scripts/alva-usage-ledger.sh` | always copy; make executable (per-file `chmod`). **Namespaced under `.claude/` (`init-reliability-and-ux.md` §5) — not a bare root-level `scripts/` folder**, which a consumer repo is likely to already own for its own scripts. |
| `.git/hooks/pre-commit` | append a call to `.claude/scripts/alva-usage-ledger.sh` | if a pre-commit hook already exists, append a line calling the script rather than overwrite it; if none exists, create one that just calls it (make executable) |

**Footprint — the three-way line (`akios-footprint-consolidation.md` §1, supersedes
`init-reliability-and-ux.md` §5).** Not everything this command writes is the same *kind* of
thing:
- **External-tool contract** — `CLAUDE.md`, `AGENTS.md`, `.claude/` — stays at repo root. A
  *different* program (Claude Code, or any AGENTS.md-reading tool) looks for these at root,
  independent of akios; not akios's call to relocate.
- **akios housekeeping** — `Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml`, `specs/`,
  `tasks/`, `archive/`, `code-references/`, the runtime journal — moves into one folder,
  **`akios/`**. Read only by akios's own skills/commands; no other tool cares where it lives.
- **User's own application source** — the ALVA scaffold (`Router/ Container/ Foundation/
  scratchs/`) — stays at root. It's the deliverable Xcode/SPM must find in a normal layout, not
  akios's paperwork.

**Create the `akios/` folder tree** (empty, with a `.gitkeep` if your tooling needs it):
```
akios/
├── Context.md
├── Roadmap.md
├── Vision.md
├── workflow.yml
├── specs/
├── tasks/
│   ├── todo/
│   ├── in-progress/
│   ├── review/
│   └── done/
├── archive/
├── code-references/
└── .local/                      # gitignored — runtime journal
```
Root, after this step, holds only: `CLAUDE.md`, `AGENTS.md`, `.claude/` (untouched), `akios/`, the
ALVA scaffold (`Router/ Container/ Foundation/ scratchs/`, untouched), and whatever the user's own
project already has (their Xcode project, `README.md`, etc. — akios never generated these).

(`akios/.local/` is created at runtime for the local journal/trace — the renamed, now-nested form
of the old sibling `.akios/` — and stays **unconditionally** gitignored — no yes/no prompt
(`init-reliability-and-ux.md` §6, reused by `akios-footprint-consolidation.md` §7): there's no
legitimate case for tracking a per-machine journal/trace/claims-cache, so a forced default beats
asking a question with only one sane answer. The rest of `akios/` is **never** offered as
gitignorable — it's committed work product a team reads and reviews. Multi-instance claims live
in **committed** files instead: task frontmatter `owner:` and the `akios/Roadmap.md` spec line.)

**Scaffold the ALVA composition root** (skip any piece that already exists):
`Router/ Container/ Foundation/Design-tokens/ Foundation/Code-tokens/ scratchs/`, plus a starter
`Foundation/usage-ledger.json` (`{"generated": null, "candidates_promote": [], "candidates_demote":
[]}`) so `.claude/scripts/alva-usage-ledger.sh` has a file to overwrite on the first commit. **Do not**
create `Features/` empty up front — a feature only gets a slice when `spec-to-tasks` decomposes
its spec; an empty `Features/` folder is dead scaffolding no one asked for yet. `scratchs/` holds
rejected `ui-variations` rounds and is excluded from the Xcode target (`akios/Context.md` gets a line
noting this, so a fresh session doesn't have to re-derive it).

Also copy the two design-token stubs into `Foundation/Design-tokens/` (skip if either already
exists): `templates/foundation/DesignSystem.swift` and `templates/foundation/RoleModifiers.swift`
— a minimal `DesignSystem` token enum + `.textStyle`/`.imageStyle` role-modifier placeholder, so
the folder isn't empty on day one. Both point back at `swift-dev`'s `swiftui-design-system` guide
for the full shape (ui-overhaul-implementation.md Phase 1.4 / Phase 4.1).

**Seed user preferences (user-global, once):** if `~/.claude/akios/preferences.md` does **not**
exist, create `~/.claude/akios/` and copy `templates/preferences.seed.md` there as
`preferences.md`. If it already exists, leave it untouched (it survives plugin updates).

Append `.akios/` to the repo's `.gitignore` (the skill trace is runtime data, not source).

## 4. Wire the hooks (idempotent)
In `<root>/.claude/settings.json` (create as `{}` if absent; use `jq` if available):
- **SessionStart gate hook** — if `agentic-kit-inject` is present, leave it. Else append to
  `.hooks.SessionStart`:
  `{ "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/agentic-kit-inject.sh\"" } ] }`
- **PostToolUse skill-trace hook** (optional) — if `skill-trace` is present, leave it. Else append to
  `.hooks.PostToolUse`:
  `{ "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/skill-trace.sh\"" } ] }`

## 5. Self-check (fail loudly)
**If step 3 (or step 1a) stopped early on a confirmed miss (§3's retry-then-stop path):** don't
run a fresh self-check as if nothing happened — report the itemized manifest that step already
produced (confirmed landed / confirmed missing / never attempted) as the result, so the state is
explicit rather than re-derived or assumed complete.

Otherwise, confirm: the `akios/` context files (incl. `akios/Vision.md`) + `akios/workflow.yml` + the folder tree exist;
`CLAUDE.md` imports both `@AGENTS.md` and `@akios/Context.md`; both hooks +
`.claude/hooks/akios-instance.sh` + `.claude/hooks/post-checkpoint-verify.sh` are present;
`akios/Roadmap.md` has a `mode:`, a `collaboration:`,
a `posture:`, **and** an `autonomy:` value; `~/.claude/akios/preferences.md` exists; **no `{{...}}` placeholder remains** in
`akios/Context.md` / `AGENTS.md` / `CLAUDE.md` / `akios/Roadmap.md` / `akios/Vision.md`; and the ALVA scaffold
(`Router/ Container/ Foundation/{Design-tokens,Code-tokens}/ scratchs/` + a valid
`Foundation/usage-ledger.json` + the pre-commit hook calling `.claude/scripts/alva-usage-ledger.sh`)
is in place. **If a skeleton was copied (step 1a):** confirm it did not overwrite `AGENTS.md`,
`akios/Context.md`, `akios/Roadmap.md`, `akios/Vision.md`, or `.claude/` — those must still be the plugin's own
templates, not skeleton-sourced files. Report any miss.

## 6. Dependencies
The kit has **no required external plugins** — everything the spine routes to (`swift-dev`,
`idea-to-spec`, `spec-to-tasks`, `task-execution`, `oss-first`, `ios-feature-pipeline`,
`just-vibes`) ships with akios. **Optional:** `ponytail` (efficiency overlay) —
`/plugin marketplace add DietrichGebert/ponytail` → `/plugin install ponytail`. The kit works
without it. No speckit needed.

Finish with: the repo is onboarded; next step is `/akios:brainstorm "<your feature idea>"`.
