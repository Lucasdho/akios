---
paths:
  - "**/*.swift"
---

<!-- Loads on every .swift read. Keep it a pointer, not a copy of AGENTS.md. -->

# Swift work

Before planning, writing or editing Swift:
- Route to the **`swift-dev`** master router — don't code from memory. It classifies
  the scope and dispatches the right bundled guide: `swiftui-pro` (views/layout) ·
  `swift-concurrency-pro` (async/await/actors/Sendable) · `swift-testing-pro` (Swift
  Testing) · `swiftdata-pro` (SwiftData) · `ios-accessibility` · `ios-debugger-agent`
  (run/debug) · and the performance/refactor/figma guides on demand.
- **Honor the priority chain** before applying any default: project decision
  (`MEMORY.md` + existing code) → `code-references/` (your sample code) →
  `preferences.md` → `swift-dev`. Concrete code outranks a stated preference.
- **Above all, follow `AGENTS.md`** — the gate table and full workflow live there.
