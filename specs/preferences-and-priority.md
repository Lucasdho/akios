# akios — Preferences & Priority
**Working spec · v1.0 · akios refactor annex**

Defines how the kit learns and applies user taste: the feedback-logging mechanism that maintains
`~/.claude/akios/preferences.md`, the Code References progressive-disclosure mechanism, and the
concrete application of the decision-priority chain. Closes the active 3-spec family
(`plugin-architecture` → `pipeline` → this). Complements `plugin-architecture.md` §5 (where
preferences live + the `MEMORY.md` division + the chain order) and `pipeline.md` (the phases that
do the logging and consult the chain). Everything here is settled unless marked *open*.

Worked example threaded throughout: the **dark-mode toggle** (continued from the sibling specs).

---

## 1. Feedback logging  *(Decision 1 — chose A: observe → confirm → append)*

Phases watch for preference signals and maintain `~/.claude/akios/preferences.md` (user-global;
the plugin ships only `templates/preferences.seed.md`, copied on `init`).

- **Two triggers:**
  - **Explicit** — a stated preference ("prefiro X", "sempre/nunca …"): propose to remember
    immediately.
  - **Implicit** — a repeated behavior (the user undoes/corrects the same kind of change): propose
    **from the 2nd occurrence**. A single correction reads as context, not a rule.
- **Observe → confirm → append:** at a natural pause, the phase proposes *"want me to remember:
  <preference>?"* before writing. Never auto-writes silently.
- **Deduplicated, append-only:** check against existing entries before adding; refine an existing
  entry rather than duplicating.
- **What a preference looks like:** one transferable, cross-project taste — coding style, an
  architecture pattern liked, an always/never rule. Project-specific facts go to `MEMORY.md`, not
  here (division in `plugin-architecture.md` §5.2).
- **Declined:** *B — silent auto-log* (pollutes; user loses control; records one-off context as a
  rule); *C — manual only* (misses the passive "behavior changes" capture the requirement asked for).

---

## 2. Code References — progressive disclosure  *(Decision 2 — chose A: indexed, load-on-demand)*

`code-references/` holds Swift code the user uploaded — patterns they like (tier 2 of the chain).
"Open disclosure" means **never load it all**; index it, open the relevant file on demand.

- **`code-references/INDEX.md`** maps each file/folder → a one-line "what pattern it shows" + **domain
  tags** (`swiftui` / `data` / `concurrency` / `testing` / …).
- **Phases read only the INDEX.** When a task's domain matches a tag, load **that** reference file —
  nothing else.
- **Index maintenance:** generated at `init` (if the folder already has content) and **refreshed when
  `execute` notices a new file** in the folder. No dedicated command.
- **Declined:** *B — auto-scan every run* (re-reads and spends tokens each time; partly defeats
  progressive disclosure); *C — manual pointer only* (loses automatic surfacing).

---

## 3. Priority-chain application  *(Decision 3 — chose A: cascade)*

The order (locked in `plugin-architecture.md` §5.3):

```
1. Project decision already made   (MEMORY.md + existing code / Context.md)
2. Sample code / Code References    (matching INDEX tag → loaded file)
3. Global user preference           (preferences.md)
4. swift-dev                        (best-practice baseline / floor)
```

- **Cascade resolution:** for any code decision (pattern, naming, architecture), consult top-down.
  The **first tier that has a relevant answer wins, and resolution stops**; lower tiers fill only
  where higher tiers are silent. A lower tier never overrides a higher one. `swift-dev` is the floor
  that always answers.
- **Conflict = order decides:** project (TCA) beats a generic "prefiro MVVM"; a tagged Code Reference
  beats a generic preference; a preference beats the swift-dev default.
- **Where enforced:** `AGENTS.md` states the chain as a house rule; the `swift-dev` router consults it
  **before** applying its baseline; a dispatched subagent's prompt restates it (cold start — it does
  not inherit the rule).
- **Declined:** *B — weighted blend* (ambiguous, non-deterministic); *C — top-only override* (loses the
  explicit ordering between tiers 2 and 3).

---

## 4. Worked example — dark-mode toggle

- **Logging:** during `execute`, the user rejects a generated `ObservableObject` theme store with
  "prefiro `@Observable`". Explicit signal → phase proposes *"remember: prefer `@Observable` over
  `ObservableObject`?"* → on yes, appended to `preferences.md` (dedup: none existing).
- **Code References:** `code-references/INDEX.md` has `ThemeManager.swift — @Observable theme store
  [swiftui, data]`. Task `01-theme-store` (domain swiftui/data) matches → that one file is loaded;
  the store is written to mirror its pattern.
- **Cascade:** naming the persistence key — tier 1 silent (new feature), tier 2 silent (no ref tag),
  tier 3 `preferences.md` says "namespace UserDefaults keys by feature" → applied, resolution stops;
  swift-dev's generic default never consulted.

---

## 5. Empty / zero states

- **No `preferences.md` yet (first install):** seed copied to `~/.claude/akios/preferences.md` with a
  header and no entries → cascade tier 3 is simply silent; behaves as "fall through to swift-dev."
- **Empty `code-references/`:** no `INDEX.md` (or an empty one) → tier 2 always silent; cascade skips it.
- **No project decisions yet (fresh repo):** tier 1 silent → first real answer comes from tiers 2–4.

---

## 6. Deliberate exclusions

- **No silent writes to `preferences.md`** — every entry is user-confirmed (Decision 1-B declined).
- **No weighted/probabilistic merging** of tiers — strict cascade only (Decision 3-B declined).
- **No bulk-loading of `code-references/`** — INDEX-gated, per-task (Decision 2-B declined).
- **Project-specific facts never go to `preferences.md`** — they belong in `MEMORY.md`.

---

## 7. Open / next

- **Active family complete:** `plugin-architecture` + `pipeline` + `preferences-and-priority` are
  written. Next operational step is `/akios:plan` over these specs to produce the refactor's tasks,
  or implement by hand.
- **[DEFERRED] `project-scaffolding.md`** (spec #4) — per-architecture base projects
  (MVVM / MVVM+C / TCA / Viper / Vanilla) with sample models, navigation, and persistence
  (SwiftData / Supabase / JSON). Highest maintenance cost; consciously out of scope for this family.
- **[PROCESS RISK — revisit after first real use] Logging threshold:** the "2nd occurrence" rule for
  implicit signals is a heuristic; tune if it under- or over-captures in practice.
