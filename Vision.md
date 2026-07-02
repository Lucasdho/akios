# Vision

> The high-level "where akios is going" — above specs. `/akios:just-vibes` reads this as
> top-tier fuel: when there's no submitted idea and no designed work left, the next wishlist
> item here becomes the next thing brainstormed → planned → built.
> Keep it short and prioritized. Specifics belong in `specs/`, not here.

## North star

akios is the agentic development kit for iOS/Swift that turns Claude Code into a disciplined
teammate: from a raw idea to shipped, reviewed, production-grade code — with the developer in
control of every decision that matters and out of the loop for everything that doesn't.

## What akios is (and isn't)

- **Is:** a plugin + skill family that installs a repeatable pipeline (brainstorm → plan → execute)
  into any iOS/Swift project, gives Claude Code domain knowledge and discipline, and lets it run
  the whole feature cycle unattended when the developer wants that.
- **Is not:** a code generator, an IDE, or an AI pair-programmer that rewrites working code.
  It augments judgment; it doesn't replace it.

## Principles

- **Specs are the memory.** A decision not written into a spec is a decision re-made every session.
- **Gates are guardrails, not walls.** Soft gates warn; only the quality gate and the push/merge
  gate are hard stops.
- **Unattended must be auditable.** Every decision made without a human present must be recorded
  with its reasoning so the human can review and override after the fact.
- **Ship less, ship right.** The smallest correct change over the cleverest full solution.
- **No external dependencies by default.** The kit ships everything its spine routes to.

## Wishlist (prioritized — top is next)

<!-- One line per desired capability, most-wanted first. just-vibes mines this top-down.
     Move an item into specs/ (status `designed`) once it's been brainstormed; delete it here. -->

> **The AKIOS backlog is now a designed spec family.** Read `specs/akios-backlog-map.md` first — it maps
> every backlog demand to its covering spec and gives the dependency-ordered build order (map §5). The items
> below are the north-star framing; the specs are the detail. Most are `designed` in `Roadmap.md`, so
> `just-vibes` will pick them up from there — the wishlist now leads only where a spec doesn't yet.

1. **Architecture adoption (ALVA) — reconcile then build.** `specs/alva-adoption.md` resolves the one open
   fork (ALVA vertical slices vs. the UI family's shared layers — map §4) and hands off an ordered backlog.
   Highest-value: it discharges the whole "architecture for agents" + "skill não organiza pastas" backlog and
   fixes the folder-structure pain for real. **One human decision (the fork) unblocks it.**
2. **UI overhaul — build it, re-homed onto the ALVA slice.** The C→A→B family is `designed`;
   `specs/ui-overhaul-implementation.md` is the backlog, now re-pointed at `presentation/` inside an ALVA
   slice (`alva-adoption.md` §2). Discharges the entire UI backlog (DesignSystem, dumb components, native-first,
   Nielsen, `containerRelativeFrame`, Figma/Stitch grounding).
3. **Kit evolution — extensibility + self-correction.** Four designed specs make akios extensible and
   self-improving: `knowledge-architecture.md` (packs + ingestion), `skill-authoring.md` (`/akios:new-skill`),
   `operating-modes.md` (learning vs delivery), `verification-and-learning-loop.md` (proofs + hurdles ledger),
   and `code-review-doctrine.md` (principled, ALVA-aware review).
4. **`just-vibes` team mode polish** — multi-instance claim + signature etiquette hardened with real
   concurrent runs; Roadmap.md conflict resolution documented. *(Still spec-less — genuine wishlist item.)*
5. **Rename the `execute` phase to `deliver`.** The 4-phase pipeline (`brainstorm → plan → design →
   execute`) already maps to the Double Diamond (Discover → Define → Develop → Deliver) — `execute`
   is the one phase name that doesn't match. Touches `workflow.yml`, `pipeline.md`,
   `commands/execute.md`, `AGENTS.md`, `README.md`, and every `/akios:execute` reference. Small,
   spine-touching, do as its own isolated pass (see `parallel-execution-scheduling.md` — don't run
   it alongside other spine-editing work). *(Spec-less — a naming nit, not new capability.)*

> **Was wishlist #3 (Xcode integration hooks)** — now designed in `verification-and-learning-loop.md` §4
> (post-execute auto build/test hook that parks on red). Tracked there, not here.

## Out of scope (for now)

- Non-Apple platforms (Android, Flutter, React Native) — akios is Apple-specialized by design.
- A hosted dashboard or web UI — the kit is terminal-first.
- Automated App Store submission — too many human judgment calls to automate safely.
