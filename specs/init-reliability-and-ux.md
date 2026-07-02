# akios — Init Reliability & UX
**Working spec · v1.0 · kit-evolution family · 2026-07-02**

Hardens `/akios:init` against three real onboarding failures reported from a friend's ("Julio")
first run: it executes its longest steps silently (no narration), it can leave the repo in an
ambiguous half-materialized state when a tool call it expected to succeed is blocked or errors,
and its own generated footprint is scattered across the repo root instead of consolidated
somewhere a user could gitignore in one line. Answers backlog **B33**, **B34**, **B35**.
Complements `commands/init.md` (the file this spec edits directly), `skeleton-library.md` (the
skeleton-copy step this spec's narration/verification rules also cover), and the lived precedent
of two real near-misses in this very build arc (§7).

> **State:** designed

> **Autonomous decision pass:** because no human was present overnight, the remaining open
> decisions in this spec were resolved **autonomously**, `/akios:just-vibes`-style — the
> recommended position was taken for each, alternatives are recorded with why they were rejected,
> and second-order consequences are noted so the user can override anything on read rather than
> re-deriving it. Nothing here is more final than any other `designed` spec; it is simply
> un-reviewed by a human yet.

---

## 1. Narration model (D1) — step headers always, per-file only where steps are long

`/akios:init` already has a named step structure (`commands/init.md` §0 Detect state, §1
Interview, §1a Skeleton selection, §2 Scan, §3 Materialize, §4 Wire hooks, §5 Self-check, §6
Dependencies). **Decided:** every step prints a one-line header as it starts (e.g. "Scanning
repo…", "Materializing 12 files + folder tree…", "Wiring hooks…", "Self-check…"), and **only** §1a
(skeleton copy) and §3 (Materialize) additionally narrate **per item** as each file/action
completes (e.g. "✓ `AGENTS.md` written", "✓ `.claude/hooks/agentic-kit-inject.sh` copied +
executable").

- **Rejected: per-file narration on every step.** §1 (Interview) and §6 (Dependencies) are already
  short/interactive or a single paragraph — narrating them per-item would add noise with nothing
  to report. B33's actual complaint is about *long, silent* steps, not every step.
  **Rejected: header-only, no per-file detail anywhere.** This is what B33 is complaining about
  today (a step runs and then just... finishes) — headers alone don't fix the "did the 12-file
  copy actually work?" anxiety that B34 separately describes.

**Decision & reason:** granularity should track where the actual pain is. §3 (Materialize) is the
step with 12 files, a folder tree, and an ALVA scaffold — the step B33's report and B34's failure
both point at. Concentrating narration there (plus the structurally identical §1a skeleton copy)
answers the complaint at its source without inflating every other step.

---

## 2. Verify after every materialization action (D2) — never trust a non-error return

**Decided:** after each copy/write action in §3 (and §1a's skeleton copy), `/akios:init`
immediately re-checks the result before moving to the next item, rather than assuming success
because the tool call didn't raise an error:

- **File copy/write:** re-read/stat the destination — confirm it exists and is non-empty (or, for
  an exact copy, that its content matches the source).
- **`chmod +x`:** re-stat the destination's permission bits — confirm the executable bit is
  actually set, not just that the `chmod` call returned without error.

**Decision & reason:** B34's own failure mode (`cp` fails, or a blocked `chmod +x` falls back to
per-file calls that *also* error) shows that "the tool call didn't throw" is not proof of a landed
change — sandboxed/auto-mode environments can silently no-op or partially apply an action. Treating
a clean return as sufficient is exactly the assumption that produces the "did it land or not"
ambiguity B34 names. **Rejected: trust the tool's return value and only re-check at the end (§5's
existing self-check).** The current self-check already exists and this failure still reaches
users — batching all verification to the end means a mid-step failure isn't caught until several
more actions have already run on top of a bad assumption, and the report at the end can't tell you
*which* action first went wrong, only that something, somewhere, is missing.

---

## 3. Chmod policy — always per-file, proactively (D3)

**Decided:** every `chmod +x` in §3 (the four hook scripts + `alva-usage-ledger.sh`) is issued as
**one call per file**, always — never batched (`chmod +x a b c`), and never as a "try batched,
fall back to per-file on failure" pattern.

- **Rejected: keep batching, add a reactive fallback to per-file on failure.** This is what B34
  describes happening today, and the report is explicit that the *fallback itself also errored* —
  a reactive recovery path is not a reliable safety net if the recovery path can fail the same way
  the primary path did. Proactively avoiding the batched call removes the failure mode instead of
  adding a second, unproven path to recover from it.
- **Reason for "always," not "only when the auto-mode classifier is active":** `/akios:init` has
  no reliable way to detect in advance whether a given environment's permission classifier will
  flag a batched `chmod` as suspicious (the report calls this an "Irreversible Local Destruction"
  -style block, i.e. a heuristic, not a fixed rule) — always issuing per-file calls costs nothing
  (five cheap syscalls instead of one) and removes the need to detect the condition at all.

---

## 4. Bounded retry, then stop-and-report on a confirmed miss (D4)

**Decided:** when §2's verification (D2) confirms an action did *not* land:

1. **Retry the single action exactly once** (not the whole step — just that one file/chmod).
2. **If the retry also fails:** stop §3 immediately (do not proceed to §4 Wire hooks or §5
   Self-check with unknown state), and report a concrete, itemized manifest: which files/perms are
   **confirmed landed**, which are **confirmed missing/wrong**, and which were **never attempted**
   because the step stopped early. Hand this manifest to the user (interactive) or record it for
   the orchestrating session (unattended) rather than guessing or silently continuing.

**Decision & reason:** this is the direct answer to B34's "ambiguous did-it-land-or-not state" —
a bounded retry absorbs simple transient failures without becoming a retry loop that masks a real
problem, and stopping with an itemized manifest on a confirmed double-failure means the next
action (human or agent) knows exactly what still needs doing instead of re-deriving it by
re-scanning the whole repo. **Rejected: unlimited retries.** Could mask a systemic block (e.g. the
whole repo is read-only) behind an ever-longer silent loop — exactly the "stuck in an ambiguous
state" B34 warns against, just slower. **Rejected: continue past a confirmed miss and note it in
the final self-check only.** Already covered by D2's reasoning — deferred detection loses the
"which action, exactly" precision a manifest needs to be useful.

---

## 5. Footprint consolidation (D5) — one real move, everything else documented as excluded

Today's akios-generated footprint in a consumer repo: five root-convention files (`AGENTS.md`,
`CLAUDE.md`, `Context.md`, `Roadmap.md`, `Vision.md`), `.claude/` (settings, hooks, rules, version
marker — already one directory, committed), `.akios/` (runtime journal/trace/claims — already one
directory, gitignored, per Session 3b's hook work), the content folders (`specs/ tasks/{todo,
in-progress,review,done}/ archive/ code-references/`), the ALVA scaffold
(`Router/ Container/ Foundation/ scratchs/`), and one root-level outlier: `scripts/alva-usage-ledger.sh`.

**Decided — the one real move:** relocate the materialized copy from `scripts/alva-usage-ledger.sh`
to **`.claude/scripts/alva-usage-ledger.sh`** — namespaced under the already-existing, already-
committed `.claude/` directory instead of a bare root-level `scripts/` folder, which is a common
name a real project is likely to already own for its *own* scripts. `commands/init.md`'s
materialize table, the pre-commit hook line it appends, and any doc referencing the old path
(`skills/task-execution/SKILL.md`, `skills/swift-dev/skills/review-doctrine/GUIDE.md`) move to the
new location as part of this spec's build.

**Decided — everything else is a deliberate, documented exclusion, not an oversight:**

- **Root-convention files** (`AGENTS.md`, `CLAUDE.md`, `Context.md`, `Roadmap.md`, `Vision.md`)
  stay at repo root. `CLAUDE.md` is where Claude Code itself looks; `AGENTS.md`/`Context.md` are
  pulled in via `CLAUDE.md`'s `@AGENTS.md`/`@Context.md` imports, which are root-relative by
  convention. Moving these into a subfolder would require redesigning the import mechanism for a
  footprint-hygiene gain that doesn't apply to them anyway — they aren't clutter, they're the
  files a session reads every single time.
- **Content folders** (`specs/ tasks/ archive/ code-references/`) stay at root. These hold the
  actual work product a user browses directly (specs to read, tasks to review, archived
  decisions) — the same category as `src/` in a normal repo, not generated housekeeping. Burying
  them under a folder would hurt the exact people B35 is trying to help.
- **The ALVA scaffold** (`Router/ Container/ Foundation/ scratchs/`) stays at root. It's the user's
  own application source, chosen by their architecture — not an akios-internal artifact.
- **`.claude/` stays as-is** (already one committed directory covering hooks/rules/settings/version
  marker) — already the right shape; nothing to consolidate further within it beyond §5's one move.

**Decision & reason:** B35 asks to "consolidate every akios-generated file under one folder" — a
literal reading would move root-convention files and content folders too, but both categories are
either an external tool convention (Claude Code's own root-file expectation) or the point of the
kit (files a person is meant to browse), not the "pollution" B35's own framing describes. The one
concrete, safe win — a bare-root script namespaced into the folder that already exists for
committed akios config — is taken; everything else is explicitly excluded with its reason on
record rather than silently left alone (which would look like the spec forgot about them).

---

## 6. `.akios/` stays unconditionally gitignored — no prompt (D6)

**Decided:** `.akios/` (runtime journal/trace/claims) remains **always** gitignored by
`/akios:init` — not offered as a yes/no choice.

- **Reason:** B35 asks to "offer the user an option to gitignore" the consolidated folder, but
  there is no legitimate case for *tracking* `.akios/`'s contents (a per-machine journal, trace
  data, and ephemeral state) — committing them would just add noise to every diff. A forced,
  correct default removes a question that only has one sane answer, rather than asking it and
  hoping the user picks the answer that's already right.
- **Rejected: literally ask "gitignore `.akios/`? y/n" at init time.** Technically satisfies B35's
  wording but adds an interview question whose "no" branch produces a worse repo for no upside —
  against this family's own instinct (`operating-modes.md`, `skeleton-library.md`) of not adding a
  question when the answer is always the same.

---

## 7. Worked example — two real near-misses from this build arc

- **B34, almost verbatim:** earlier in this v0.8.0 arc, a plain `git checkout -- .gitignore` was
  denied by the auto-mode permission classifier mid-session (an "Irreversible Local Destruction"
  block on discarding a concurrent, uncommitted edit). The orchestrating session had to stop,
  explain the block, and leave it for the human rather than silently working around it or getting
  stuck — the exact discipline §4 (D4) now writes down as policy: a blocked action gets one
  bounded retry path, then an explicit stop-and-report, never a silent workaround and never an
  infinite stall.
- **A second, related near-miss:** Session 3a separately had to work around a stray `.gitignore`
  edit that was silently causing `git add` to skip new files — another concrete "ambiguous
  did-it-land-or-not" case, just discovered after the fact via a missing file rather than a denied
  tool call. §2 (D2)'s "verify after every action, don't trust a clean return" would have caught
  this at the moment the file was supposed to land, not several steps later.

Both are cited because they are *lived*, not theorized — the same class of failure B34 describes,
observed twice in one arc, from two different proximate causes (a permission-classifier block, and
a silent gitignore interaction).

---

## 8. Empty / edge states

- **Fresh repo, zero prior akios footprint:** all of §1–§6 apply as written; nothing to migrate.
- **Already-initialized repo, `/akios:init` re-run (§0's "Recorded == installed" branch):** only
  the self-check runs — narration/verification (§1–§4) apply to any single-artifact repair it
  performs, at the same granularity as a fresh materialize.
- **Migrating an older repo** (§0's "Recorded < installed" branch) that already has
  `scripts/alva-usage-ledger.sh` at the old root path: the migrate path copies the script to
  `.claude/scripts/alva-usage-ledger.sh`, re-points the pre-commit hook line at the new path, then
  removes the old root-level file **only after** the new copy is confirmed landed (D2) — never
  delete-then-copy. This targets that one named file only; the migrate step never touches anything
  else a user might have in their own `scripts/` folder.
- **A retry (D4) succeeds:** narration reports it plainly ("`chmod +x` retried, now confirmed") —
  a recovered miss is not the same as a clean first pass, and hiding the retry would undersell that
  something did briefly go wrong.
- **Sandboxed environment where per-file `chmod` itself is blocked outright** (not just batched
  calls): §4's stop-and-report path fires exactly as designed — this spec does not add a third
  escalation tier beyond "retry once, then stop and report accurately," since a environment that
  blocks even single-file chmod calls needs a human decision, not more automated retrying.

---

## 9. Deliberate exclusions

- **No consolidation of root-convention files or content folders** (§5) — covered above with
  reasons, not silently skipped.
- **No new interactive confirmation step added to `/akios:init`'s overall flow.** Narration (§1)
  is output, not a prompt; verification (§2–§4) is automatic, not a "should I check?" question —
  adding confirmation steps would slow down the exact "cheap, idempotent re-run" property `init.md`
  §0 already optimizes for.
- **No general-purpose "verify any tool call" framework.** This spec's verification rules are
  scoped to `/akios:init`'s own materialization actions (§3, §1a) — extending the same discipline
  to `task-execution`'s file writes or other skills is out of scope here; if warranted, it's a
  separate, later spec informed by whether this one's narrower version proves useful first.
- **No retry-count configuration.** The bounded retry (D4) is fixed at exactly one attempt,
  everywhere, not a tunable — keeping it fixed avoids turning a reliability fix into a new surface
  users have to reason about.

---

## 10. Backlog placement

Registered as **B33/B34/B35** in `akios-backlog-map.md` §1 (already present, 2026-07-01 addition,
Julio's first `/akios:init` run). Answers **G10** in §3 (already registered):

| # | New spec | Answers | One-line thesis |
|---|---|---|---|
| G10 | `init-reliability-and-ux.md` | B33, B34, B35 | `/akios:init` narrates its steps as it runs, verifies each materialization step actually landed instead of assuming, avoids batched calls that trip the auto-mode classifier, and keeps its footprint in one gitignore-able folder. |

`Roadmap.md` gets a new row: `init-reliability-and-ux.md` | domain "`/akios:init` narration,
per-action verification, per-file chmod policy, bounded retry, footprint consolidation" | status
`designed` | notes "backlog B33-B35; two of the failure modes it fixes were observed live in this
same build arc (§7)."

---

## 11. Open / next

- **[CONSEQUENCE — to implement]** `commands/init.md` §3 (Materialize) and §1a (skeleton copy)
  gain per-item narration (§1), per-action verification (§2), always-per-file `chmod` (§3), and the
  bounded-retry-then-stop-and-report path (§4).
- **[CONSEQUENCE — to implement]** `commands/init.md`'s materialize table's `alva-usage-ledger.sh`
  row destination changes to `.claude/scripts/alva-usage-ledger.sh`; the pre-commit-hook-append
  instruction and §5's self-check both reference the new path.
- **[CONSEQUENCE — to implement]** Cross-references to the old `scripts/alva-usage-ledger.sh` path
  in `skills/task-execution/SKILL.md` and `skills/swift-dev/skills/review-doctrine/GUIDE.md` update
  to the new location.
- **[CONSEQUENCE — to implement]** `commands/init.md` §0's migrate-path branch gains the
  copy-then-verify-then-delete-old-file sequence for repos already onboarded before this spec.
- **[OPEN — revisit after first use]** whether the itemized stop-and-report manifest (§4) should
  also be written to a durable file (e.g. `.claude/init-last-run.log`) rather than only reported in
  the session's own output — deferred until a real double-failure happens and it's clear whether
  the in-session report was enough or a durable artifact would have helped a follow-up session.
