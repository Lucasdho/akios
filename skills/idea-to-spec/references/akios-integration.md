# akios Integration — plugin-specific mechanics

`idea-to-spec` is self-sufficient on its own; this file is the single bridge to the akios kit's
specifics. Read it only when this skill is running inside akios. Everything in `SKILL.md` and
`spec-format.md` already states a sensible standalone fallback without it.

## Posture flag

Read `akios/Roadmap.md`'s `posture` flag (default `delivery`; a session override — a command
flag or spoken switch — wins for this session without rewriting the Roadmap value). See
`AGENTS.md` "Operating posture" for the full teaching-surface this flag controls across every
phase; `akios/specs/operating-modes.md` for the source design.

## Spec registration

Each spec gets its own `akios/specs/<name>.md` and a row in `akios/Roadmap.md`'s `## Specs`
table the moment it's framed, so the set stays visible across the whole kit.

## Unattended runs (`/akios:just-vibes`)

Triggered by `/akios:just-vibes`, as opposed to interactive `/akios:brainstorm`. Before designing
from scratch, read `akios/archive/Archive.md` (and `MEMORY.md`, `akios/code-references/`) for
previously delivered high-quality specs and mirror their patterns and decisions — consistency
with proven work beats novelty. Resolve ties via the priority chain, then best judgment.

## Contract & Foundation header (ALVA)

Any spec that `spec-to-tasks` will decompose into an ALVA feature slice (i.e. it describes a
buildable app feature, not a cross-cutting doctrine/process spec) opens with a short declaration
block right under the header, before §1:

```markdown
## Contract & Foundation

- **Exports (`contract/`):** what this feature's public surface will be — the protocol + DTOs other features are expected to consume. "None yet" if this is a leaf feature.
- **Consumes:** which other features' `contract/`, and which `Foundation/Design-tokens` / `Foundation/Code-tokens` symbols, this feature is expected to need.
```

This is cheap to write (a few bullets, not a design pass) and pays for itself twice:
`spec-to-tasks` reads it to scope the `contract/` task and the Foundation-consult DoD line, and
it doubles as a cross-check against the usage-ledger's counted evidence (doctrine §6.4
alternative D) — if the ledger later shows heavier cross-feature use than declared here, that
divergence is worth a look, not silently trusted either way.

## Swift/iOS naming

Swift/iOS projects (with `ios-feature-pipeline`) prefer the simpler `akios/specs/<feature>.md`
form (e.g. `akios/specs/catalog.md`) — the pipeline expects files under `akios/specs/` without a
project prefix. The `<project>-<block>-spec.md` form (see `spec-format.md`) is correct for
multi-project or non-iOS contexts.
