# ALVA integration — `knowledge-ingest`

`knowledge-ingest` is self-sufficient standalone; this file is its ALVA-architecture bridge. Read
it only when `akios/Context.md` declares `architecture: alva`. Without it, the SKILL.md body already
states the architecture-neutral fallback. Depth lives in `swift-dev`'s `alva-architecture` GUIDE
(`skills/swift-dev/skills/alva-architecture/GUIDE.md`) and `akios/specs/alva-adoption.md` — this
file does not restate the doctrine.

## `target:` field → slice folders
Under `architecture: alva`, a snippet's two `target:` classes map to concrete slice folders:

- **`Foundation/Design-tokens`** — visual, meant to be shared from day one (a card component, a
  design-system template). `task-execution` copies it once and reuses it thereafter.
- **`Features/<F>/data`** or **`.../domain`** — behavior, inherently per-feature (a repository
  template, a use case, a gateway protocol). `task-execution` copies it fresh into each feature
  that needs one, with entity names adapted per feature.

## Does not mutate the usage-ledger
The `target:` decision is made by a human at registration time (the confirm-before-live step) — it
does **not** bypass or mutate the ALVA usage-ledger's own evidence-based Foundation-promotion rules.
`task-execution`'s Foundation ledger governs everything that is **not** a registered snippet.
