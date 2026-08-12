# akios Integration — plugin-specific mechanics

`idea-to-spec` is self-sufficient on its own; this file is the single bridge to the akios kit's
specifics. Read it only when this skill is running inside akios. Everything in `SKILL.md` and
`spec-format.md` already states a sensible standalone fallback without it.

## Posture flag

Read `akios/Roadmap.md`'s `posture` flag (default `delivery`; a session override — a command
flag or spoken switch — wins for this session without rewriting the Roadmap value). See
`AGENTS.md` "Operating posture" for the full teaching-surface this flag controls across every
phase.

## Spec registration

Each spec gets its own `akios/specs/<name>.md` and a row in `akios/Roadmap.md`'s `## Specs`
table the moment it's framed, so the set stays visible across the whole kit.

## Contract header (when the project has module boundaries)

If `akios/Context.md` `## Architecture` describes a project with explicit module/feature
boundaries, any spec that `spec-to-tasks` will decompose into one of those modules (i.e. it
describes a buildable feature, not a cross-cutting doctrine/process spec) opens with a short
declaration block right under the header, before §1:

```markdown
## Contract

- **Exports:** what this feature's public surface will be — the interface + data shapes other modules are expected to consume. "None yet" if this is a leaf feature.
- **Consumes:** which other modules' public surfaces, and which shared/common symbols, this feature is expected to need.
```

This is cheap to write (a few bullets, not a design pass) and pays for itself: `spec-to-tasks`
reads it to scope the boundary task, and it doubles as a cross-check when the implementation
later reaches across more boundaries than declared here — that divergence is worth a look.

Projects with no such boundaries (a flat script, a single-module app) skip this block entirely.

## Spec naming

Inside akios, prefer the simple `akios/specs/<feature>.md` form (e.g. `akios/specs/catalog.md`) —
the pipeline expects files under `akios/specs/` without a project prefix. The
`<project>-<block>-spec.md` form (see `spec-format.md`) is correct for multi-project contexts
where one repo hosts several products.
