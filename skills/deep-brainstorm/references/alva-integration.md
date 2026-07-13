# ALVA integration — `deep-brainstorm`

`deep-brainstorm` is self-sufficient standalone; this file is its ALVA-architecture bridge. Read it
only when `akios/Context.md` declares `architecture: alva`. Without it, the SKILL.md body already
states the architecture-neutral fallback. Depth lives in `swift-dev`'s `alva-architecture` GUIDE
(`skills/swift-dev/skills/alva-architecture/GUIDE.md`) and `akios/specs/alva-adoption.md` — this
file does not restate the doctrine.

## Slice cartography (Phase 2)
Each item that will become its own buildable domain is a future `Features/<Domain>/` slice, not a
shared layer — note this while mapping, not as an afterthought later. Two things to capture right
there:

- **Contract boundaries.** When two items on the map will need to talk to each other (e.g. "Home
  Feed" needs `User`'s auth state), mark which owns the *intention* (doctrine §5.4) and which side
  will consume the other via `contract/`. Don't resolve every cross-reference now — just flag them
  so Phase 4 doesn't have to rediscover them.
- **Foundation seeds.** Cross-cutting items from dimension 4 (Theming/Design System, shared
  utilities) are `Foundation/` candidates from day one — call them out so the spec family doesn't
  reinvent them per-domain.

## Contract & Foundation header carry-forward (Phase 4)
Each spec is the unit that `spec-to-tasks` will later decompose into an ALVA feature slice
(`Features/<Domain>/{domain,data,presentation,contract,tests}`). Carry forward the contract-boundary
and Foundation-seed notes from Phase 2 into each spec's **Contract & Foundation** header
(`idea-to-spec`'s `spec-format.md`) — this is where those flags get resolved into an actual
declaration instead of staying loose notes.
