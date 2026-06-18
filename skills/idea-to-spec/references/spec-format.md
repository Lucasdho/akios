# Spec Format — the versioned markdown spec

Every closed block of the design becomes (or updates) one of these files. The format is deliberately consistent so a family of specs reads as one system.

## File naming

`<project>-<block>-spec.md` — e.g. `founderlens-onboarding-spec.md`, `founderlens-devaudit-spec.md`. Vision documents that capture ambition before detailed design use `-vision` instead of `-spec`. Strategy/roadmap decisions: `-product-strategy`. Free-form idea capture: `-feature-ideas`.

## Header block

```markdown
# <Project> — <Block Name>
**Working spec · vX.Y · project annex**

One short paragraph: what this document captures, what it complements,
and what comes next. The settled-vs-open contract is stated here:
"Everything here is settled unless marked *open*."
```

On updates, bump the version and add a changelog callout right under the header:

```markdown
> **vX.Y changelog:** one line per meaningful change — what was added,
> what was reversed, where it lives (§ refs).
```

## Body conventions

- **Numbered sections** (`## 1.`, `## 2.` …) separated by `---`. Sub-points as
  bullets with **bold lead-ins**.
- **Decisions carry their reasons.** Not "we chose X" but "we chose X because Y;
  the cost is Z, accepted because W." Declined alternatives worth remembering are
  recorded *with the reason they were declined* — a deliberate "no" is as much a
  decision as a "yes".
- **Tables** for ingredient lists, rubrics, band/verdict maps, wiring
  (signal → what it personalizes), and benchmark data.
- **Origin notes** when a design reversed course: a short quote-block telling the
  story ("the brainstorm had 3 dev-centric dimensions; rethinking from scratch
  flipped the unit from scoring the person to mapping where to help").
- **Cross-references** to sibling specs by filename and section
  ("see founderlens-product-strategy.md §4").
- **Deliberate exclusions get a section.** What was kept OUT on purpose, and where
  it lives instead ("domain familiarity → asked at project start, not global
  onboarding"). Prevents future sessions from re-adding what was consciously removed.
- **Empty states are always documented.** Every spec that defines a screen, list,
  feed, or data-backed view states its empty/zero-data state explicitly: what the
  user sees before any data exists, after they clear all data, and on first run.
  Cover the empty, loading, and error variants where they apply. This is mandatory,
  not optional — the UI is built from these states, so an undocumented empty state
  is a missing requirement.

## The worked-example section

Every spec that defines process behavior includes the living example's run through
that block: the actual answers given, scores produced, refinements applied. Real
data (from grounding) appears with its sources. This section is what makes the spec
testable against reality instead of aspirational.

## Risks are marked, not buried

Open items that are *risks* (not just future work) get explicit markers in the
open section:

```markdown
- **[TECHNICAL RISK — specify before implementing] Dependency graph:** ...
- **[EXPLICIT RISK — priority backlog] Prompt templates:** ...
```

## The closing section

Always end with `## N. Open / next`:
- what the next session should tackle,
- what stayed undecided (and who owns it, if anyone),
- risks carried forward with their markers.

## Writing the file

For long markdown with tables and special characters, write via heredoc
(`cat > path << 'EOF' ... EOF`) and verify with `wc -l` after. Present the file
to the user when done, with a short summary of what it captures — not a re-read
of the whole content.
