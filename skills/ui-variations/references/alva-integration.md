# ALVA integration — `ui-variations`

`ui-variations` is self-sufficient standalone; this file is its ALVA-architecture bridge. Read it
only when `akios/Context.md` declares `architecture: alva`. Without it, the SKILL.md body already
states the architecture-neutral fallback. Depth lives in `swift-dev`'s `alva-architecture` GUIDE
(`skills/swift-dev/skills/alva-architecture/GUIDE.md`) and `akios/specs/alva-adoption.md` — this
file does not restate the doctrine.

## Inputs (what a variation is built from)
Each `#Preview` variation is built from what already exists in the slice tree: `Foundation/Design-tokens/`
tokens, promoted components, and the feature's own `presentation/<View>/components/` — plus
copy-and-adapt snippets. No external medium (Figma/Stitch/HTML) to translate from.

## Output home (where the winner graduates)
The approved variation lands directly in its final ALVA file — no translation step, because it is
already the target code:

```
Features/<Feature>/presentation/<View>/<View>View.swift        ← next to <View>Model.swift
Features/<Feature>/presentation/<View>/components/<Component>/  ← view-local components
```

Components nest **per-view**, not in a flat `Features/<Feature>/Components/`.

## This loop is `alva-adoption.md`'s A3 build-order
`ui-variations` occupies the explore→remix→graduate steps of A3 (components → `ui-variations`
dumb-screen → make-it-live). A screen cannot enter `deliver`'s make-it-live stage until a variation
has graduated here — the build-order itself is the approval gate; no separate mechanism exists.
