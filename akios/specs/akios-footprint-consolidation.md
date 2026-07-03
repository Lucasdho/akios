# akios — Footprint Consolidation (the `akios/` folder)
**Working spec · v1.0 · kit-evolution family · 2026-07-02**

Reopens **B35** and supersedes `init-reliability-and-ux.md` §5 (D5). That spec shipped one real
move (`scripts/alva-usage-ledger.sh` → `.claude/scripts/`) and declared everything else a
*deliberate exclusion* — root-convention files, the content folders, and the ALVA scaffold all
stayed at repo root. Seeing `/akios:setup` actually run on a fresh repo (§9's worked example)
shows that exclusion under-delivered on B35's own framing ("doesn't pollute the person's repo"):
a brand-new repo gets **15 top-level items** before the user has written a line of their own code.
This spec draws a sharper line — genuine akios housekeeping moves into one `akios/` folder;
only what an *external tool* requires at root, or what is the user's own application source,
stays there. Everything here is settled unless marked *open*.

> **Autonomous decision pass:** decided without a human turn-by-turn (background session, auto
> mode) — the recommended position was taken for each question, alternatives are recorded with why
> they were rejected, and consequences are flagged so the user can override anything on read.
> Nothing here is more final than any other `designed` spec.

---

## 1. The line: external-tool contract vs. akios housekeeping (D1)

Not everything currently at repo root is the same *kind* of thing, even though it all landed there
via `/akios:setup`. Three categories, three different rules:

| Category | Examples | Rule |
|---|---|---|
| **External tool contract** — a *different* program looks for this file/dir at repo root, independent of akios | `CLAUDE.md`, `AGENTS.md`, `.claude/` | Stays at root. Not akios's call to relocate. |
| **akios housekeeping** — read only by akios's own skills/commands; no other tool cares where it lives | `Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml`, `specs/`, `tasks/`, `archive/`, `code-references/`, the runtime journal | Moves into `akios/`. |
| **User's own application source** — the ALVA scaffold akios generates *as a starting point*, but which the user's build tool (Xcode) must find in a normal location | `Router/`, `Container/`, `Foundation/`, `scratchs/` | Stays at root. It's the deliverable, not akios's paperwork. |

D5's mistake was treating the middle category the same as the first: it argued content folders
"hold work product a user browses directly, the same category as `src/`" — true, but browsability
survives being one directory deeper, and the screenshot shows the actual cost of *not* nesting them
is a repo root that reads as noise before the user has done anything. The first and third
categories have a *harder* reason to stay (a different program's discovery contract; a compiler's
project layout) — that's the distinction D5 didn't draw.

---

## 2. `CLAUDE.md` and `AGENTS.md` stay at root — grounded, not assumed (D2)

**Decided:** both files that currently anchor the operating-manual import chain stay exactly where
they are.

- **`CLAUDE.md`** — Claude Code auto-loads a repo-root `CLAUDE.md` at session start (and re-injects
  it after `/compact`); a copy anywhere else is inert. Non-negotiable, akios has no say here.
- **`AGENTS.md`** — this is not merely "an akios file `CLAUDE.md` happens to import." AGENTS.md is
  an **open, cross-tool standard**: formalized as a spec in August 2025 by OpenAI with Google,
  Cursor, and Factory, donated to the Linux Foundation's Agentic AI Foundation in December 2025, and
  read at repo root by Claude Code, Cursor, Codex, Copilot, Devin, Windsurf, and Gemini CLI. A user
  who also runs any of those tools loses their context file the moment `AGENTS.md` isn't at root —
  that's a stronger constraint than D5 gave it credit for (D5's reasoning was purely "pulled in via
  `CLAUDE.md`'s import," implying it could move if the import path changed). It can't move.

**Consequence:** `CLAUDE.md`'s import line for `Context.md` updates from `@Context.md` to
`@akios/Context.md` (one line). Its `@AGENTS.md` import is unchanged. `AGENTS.md`'s own content is
unchanged — it stays the full operating manual at root, not thinned into a pointer, because
non-Claude tools read it as-is with no import mechanism of their own.

**Rejected: thin both files to pointers, park the real content under `akios/`.** Works for
`CLAUDE.md` (Claude Code will follow the import) but silently breaks for every other tool listed
above, which read `AGENTS.md` verbatim and don't know what `@akios/AGENTS.md` means. Rejected
outright once grounded — this isn't a style preference, it's a compatibility break.

*Sources: [AGENTS.md Complete Guide 2026](https://codersera.com/blog/agents-md-complete-guide-2026/), [The Agent-Native Repo: Why AGENTS.md is the New Standard](https://www.harness.io/blog/the-agent-native-repo-why-agents-md-is-the-new-standard)*

---

## 3. The `akios/` tree (D3)

**Decided — new layout for everything in the "akios housekeeping" row of §1's table:**

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
└── .local/                      # gitignored — see D5
    ├── trace.jsonl
    └── just-vibes-journal.md
```

Root, after this spec, holds only: `CLAUDE.md`, `AGENTS.md`, `.claude/` (settings/hooks/rules,
untouched — see D4), the ALVA scaffold (`Router/ Container/ Foundation/ scratchs/`, untouched —
see D6), and whatever the user's own project already has (their Xcode project, `README.md`, etc.
— akios never generated these and doesn't touch them).

**Consequence [large, mechanical]:** every path literal referencing `specs/`, `tasks/`,
`Context.md`, `Roadmap.md`, `Vision.md`, or `workflow.yml` across the kit's own commands, skills,
and templates needs the `akios/` prefix. A grep at spec-design time found **~108 files** in this
repo alone with at least one such reference — this is real rewrite surface, not a detail. This spec
locks the *shape*; the rewrite is implementation work for a follow-up `/akios:plan` → deliver
pass, tracked in §11, not done here.

---

## 4. `.claude/` stays at root, unmoved (D4)

**Decided:** no change from D5's original reasoning, restated because §1 now makes *why* explicit:
`.claude/settings.json` and `.claude/hooks/` are **Claude Code's own convention** — the tool looks
for them at repo root, the same class of external constraint as `CLAUDE.md` itself. This isn't an
akios housekeeping folder that happens to already be tidy; it's the same "not akios's call"
category as §2.

---

## 5. The runtime journal moves inside the new folder, renamed (D5)

**Decided:** the existing hidden `.akios/` (gitignored runtime journal: skill trace, the
just-vibes journal) is renamed to **`akios/.local/`** — nested *inside* the new visible folder
instead of sitting next to it as a same-named, dot-prefixed sibling.

- **Reason:** a visible `akios/` and a hidden `.akios/` as siblings at root is a near-collision a
  human eye will misread — two folders whose names differ by exactly one character, one of which
  is invisible in a plain `ls`. Nesting the gitignored slice inside the committed one removes the
  ambiguity: there is exactly **one** akios entry at root, and its git-ignored subset is a single
  documented line in `.gitignore` (`akios/.local/`) rather than a second top-level dotfile.
- **Rejected: leave `.akios/` where it is, only add the new `akios/` alongside it.** Technically
  simpler (no rename) but reproduces the exact naming confusion this spec exists to avoid, and
  fails the user's literal ask ("all the generated files... into an akios folder" — a sibling
  `.akios/` is not "into" the folder).
- **Mixing committed and gitignored content in one folder is not unusual** — the same pattern as
  `build/` inside a tracked `src/`, or `node_modules/` inside a tracked project root. One
  `.gitignore` line scopes it precisely; no ambiguity for git or for a reader.

---

## 6. Deliberate exclusion: the ALVA scaffold stays at root (D6)

**Decided:** `Router/`, `Container/`, `Foundation/{Design-tokens,Code-tokens}/`, and `scratchs/`
are **not** touched by this spec. They are the user's own compiled Swift source — Xcode (or SPM)
needs to find them in a normal project layout, and burying application code inside a metadata
folder would be backwards: `akios/` is where the *kit's* paperwork lives, not where the user's app
lives. The screenshot that motivated this spec visually conflates the two (they're interleaved
alphabetically in Finder), which is worth saying plainly so a reader doesn't assume all 15 root
items were "akios mess" — roughly a third of them are the app scaffold itself, doing exactly what
it's supposed to do by living at root.

`Foundation/usage-ledger.json` (generated by `.claude/scripts/alva-usage-ledger.sh`) stays with the
scaffold for the same reason — it's evidence about the *app's* source, not about akios's own
bookkeeping.

**`README.md`** is out of scope entirely: no akios template creates it (verified against
`commands/setup.md`'s materialize table). Whatever a fresh repo's `README.md` contains came from
elsewhere (git hosting default, prior `git init`) — not this spec's concern.

---

## 7. No whole-folder gitignore prompt (D7) — resolves B35's "offer to gitignore" ask

B35 also asked to "offer the user an option to gitignore all of it." **Decided:** no such prompt,
for the same reason `init-reliability-and-ux.md` §6 (D6) already gave for the old `.akios/` —
except now split by what's actually gitignore-*able*:

- **`akios/.local/`** (runtime journal/trace) — always gitignored, no prompt. Same reasoning as
  the original D6: there's no legitimate case for tracking a per-machine journal.
- **The rest of `akios/`** (`specs/`, `tasks/`, `Roadmap.md`, `Vision.md`, `Context.md`,
  `workflow.yml`, `archive/`, `code-references/`) — **never** offered as gitignorable. This is
  committed work product a team reads and reviews (specs to approve, tasks to track, roadmap
  status other teammates' akios instances read to coordinate — see `AGENTS.md` "Working alongside
  teammates"). Gitignoring it would silently break multi-instance coordination for any repo running
  `collaboration: team`, and would throw away exactly the artifacts B35's own complaint ("keeping
  akios files together") implies the user wants to *keep*, not hide.

**Rejected: ask "gitignore `akios/`? y/n" at setup time, literally satisfying B35's wording.** A
"yes" answer produces a broken multi-instance setup and an unreadable spec trail — not a real
choice, an attractive-looking footgun. Consolidating so the *option* to gitignore is at least
structurally sound (one line, one folder) already answers the spirit of B35; offering the
literal option where "yes" actively harms the repo is not a service to the user.

---

## 8. Migration path for already-onboarded repos (D8)

**Decided:** this is **opt-in**, not automatic, on `/akios:setup`'s "Recorded < installed"
(migrate) branch.

1. Detect the old scattered footprint: a recorded version predating this spec, alongside root-level
   `specs/`, `tasks/`, `Context.md` (etc.) rather than an `akios/` folder.
2. **Ask, don't silently move**: "This repo predates the `akios/` consolidation — migrate now?
   (moves `specs/ tasks/ archive/ code-references/ Context.md Roadmap.md Vision.md workflow.yml`
   into `akios/`, renames `.akios/` to `akios/.local/`, updates `CLAUDE.md`'s import path.
   Everything keeps working either way — this is cosmetic, not a functional requirement.) y/n"
3. **On yes:** move file-by-file using the exact discipline `init-reliability-and-ux.md` §2–§4
   already established for this command — verify each move landed (source gone, destination
   present + non-empty) before the next, retry once on a confirmed miss, stop-and-report an
   itemized manifest on a second failure. Update `CLAUDE.md`'s `@Context.md` → `@akios/Context.md`
   import as the last step, only after every file move is confirmed.
4. **On no (or no answer needed because nothing's stale):** leave the repo as-is. A pre-consolidation
   repo is not broken — every path still resolves for that repo's own commands/skills, since a
   repo's own copy of the kit's instructions was written against the old paths at the version it
   last ran. Don't ask again until the user explicitly requests it (`/akios:setup --consolidate`).

**Decision & reason:** moving committed root files/folders in a live repo is more invasive than
this command's other idempotent repairs — it touches git history's working tree, any IDE tabs open
on the old paths, and muscle memory. The kit's existing philosophy (`operating-modes.md`,
`skeleton-library.md`) is "don't ask when the answer is always the same" — but here the answer
genuinely isn't always the same (a team mid-sprint may not want a footprint-shuffling commit
today), so this is the one migration in the family that *should* ask.

**Rejected: migrate silently on any version-bump re-run**, matching how the two *always-copy*
artifacts (hooks, `workflow.yml`) already refresh with no prompt. Those are single-file overwrites
with no path-reference consequences elsewhere; a folder-shape change ripples into every path a
teammate or IDE might have open, so it doesn't qualify for the same "just refresh it" treatment.

---

## 9. Worked example — the screenshot that motivated this spec

`/akios:setup` on a fresh repo named "Portifolio" produced, at repo root:

```
workflow.yml  Vision.md  tasks/  specs/  scratchs/  Router/  Roadmap.md
README.md  Foundation/  Context.md  Container/  code-references/
CLAUDE.md  archive/  AGENTS.md
```

15 top-level entries, no visual grouping — akios housekeeping (9 items: `workflow.yml`, `Vision.md`,
`tasks/`, `specs/`, `Roadmap.md`, `Context.md`, `code-references/`, `archive/`) interleaved
alphabetically with the ALVA app scaffold (3 items: `scratchs/`, `Router/`, `Foundation/`,
`Container/` — 4 actually) and the two files that must stay at root (`CLAUDE.md`, `AGENTS.md`),
plus the pre-existing `README.md`.

**After this spec**, the same fresh `/akios:setup` run produces, at repo root:

```
CLAUDE.md  AGENTS.md  akios/  Router/  Container/  Foundation/  scratchs/  README.md  .claude/
```

9 top-level entries instead of 15: the two required root files, one folder for every bit of akios
housekeeping, the four ALVA scaffold entries (unchanged, they're the app), `.claude/` (unchanged,
Claude Code's own), and the user's own pre-existing `README.md`. The akios-vs-app-source split is
now visually legible — everything the kit generated as *its own bookkeeping* is one folder;
everything that's the user's compiled source is still exactly where Xcode expects it.

---

## 10. Empty / edge states

- **Fresh repo, this spec already implemented:** `/akios:setup` materializes directly into
  `akios/...` — no scattered intermediate state, nothing to migrate.
- **Already-onboarded repo, same version (no migration needed):** `/akios:setup` re-run only
  self-checks; §8 doesn't fire.
- **Already-onboarded repo, older version, user declines migration:** repo stays on the old
  scattered layout indefinitely — fully functional, just not consolidated. `/akios:setup` doesn't
  re-ask on every future re-run, only on explicit request.
- **Mid-migration failure (§8 step 3's stop-and-report):** the itemized manifest names exactly
  which files landed in `akios/`, which are still at the old root path, and which were never
  attempted — the repo is left in a documented mixed state rather than a silently half-moved one.
  `CLAUDE.md`'s import is the *last* write in the sequence specifically so a failed migration never
  leaves the import pointing at a `Context.md` that no longer exists at the old path.
- **A repo with its own pre-existing `akios/` directory unrelated to this kit** (name collision):
  `/akios:setup` must detect this before writing — treated the same as any other "file already
  exists and isn't ours" case elsewhere in the materialize table (surface it, ask, never silently
  overwrite). Flagged as an open risk in §11, not resolved here.

---

## 11. Deliberate exclusions (recap)

- **No change to `CLAUDE.md`/`AGENTS.md` content or the fact they live at root** (§2) — grounded
  in an external, cross-tool standard, not an akios preference.
- **No change to `.claude/`** (§4) — Claude Code's own convention.
- **No move of the ALVA scaffold** (§6) — it's the user's application, not akios's paperwork.
- **No whole-`akios/`-folder gitignore option** (§7) — offered only for the truly per-machine
  `akios/.local/` slice; the rest is committed work product by design.
- **No automatic/silent migration for existing repos** (§8) — opt-in, asked once, not repeated.

---

## 12. Backlog placement

Reopens **B35** in `akios-backlog-map.md` §1 (previously marked answered by `init-reliability-and-
ux.md`'s one-move-plus-exclusions decision, D5) and supersedes that spec's §5 specifically —
§§1–4 and §6–11 of `init-reliability-and-ux.md` (narration, verify-after-action, chmod policy,
bounded retry, the `.akios/`-always-gitignored default reasoning reused in this spec's §7) are
**unaffected** and remain in force.

`akios-backlog-map.md` gets a new row:

| # | New spec | Answers | One-line thesis |
|---|---|---|---|
| G13 | `akios-footprint-consolidation.md` | B35 (reopened) | Draws a three-way line — external-tool-contract files, akios housekeeping, user app source — and moves only the middle category into one `akios/` folder, instead of the one-narrow-move-plus-exclusions D5 originally chose. |

`Roadmap.md` gets a new row: `akios-footprint-consolidation.md` | domain "Consolidates akios's
generated housekeeping (`Context.md`/`Roadmap.md`/`Vision.md`/`workflow.yml`/`specs/`/`tasks/`/
`archive/`/`code-references/`/the runtime journal) into one root-level `akios/` folder; reopens and
narrows `init-reliability-and-ux.md`'s footprint-consolidation decision (D5)" | status `done` |
notes "reopens B35; supersedes init-reliability-and-ux.md §5 only, §§1-4/6-11 there stand."

---

## 13. Open / next

- **[CONSEQUENCE — to implement, large]** `commands/setup.md`'s materialize table (§3) rewrites
  every destination path with the `akios/` prefix; `workflow.yml`'s own `bootstrap.creates` list
  and every phase's `prereqs`/`outputs` path literals update to match; the ~108-file grep surface
  across skills/templates gets the same treatment. This is the mechanical build this spec's design
  work unblocks — tracked as its own `/akios:plan` pass, not done inline with the spec.
- **[CONSEQUENCE — to implement]** `commands/setup.md` §0's migrate-path branch gains §8's
  ask-then-move-then-repoint sequence, reusing `init-reliability-and-ux.md`'s D2-D4 verification
  discipline rather than inventing a second one.
- **[CONSEQUENCE — to implement]** `.gitignore`'s `.akios/` line becomes `akios/.local/`.
- **[OPEN — revisit before implementation] Name-collision detection** (§10's last bullet): what
  exactly `/akios:setup` does if a repo already has an unrelated `akios/` directory. Not designed
  here — flagged so the implementation pass doesn't skip it.
- **[OPEN — low priority] Whether `~/.claude/akios/` (the user-global preferences/skeletons home,
  already named `akios`, already outside any single repo) should be mentioned alongside this
  spec's repo-local `akios/` to avoid a reader conflating the two** — they don't collide in
  practice (one is `~/.claude/akios/`, global; the other is `<repo>/akios/`, per-project) but the
  shared name is worth a one-line disambiguation somewhere central (candidate: `AGENTS.md`'s
  artifact-map table) when the implementation pass touches that table anyway.
