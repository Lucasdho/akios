---
paths:
  - "**/*.swift"
---

# Swift work — invoke the gates

This rule loads whenever Claude reads a `.swift` file, so the Swift workflow is
in context even mid-session, after compaction, or when AGENTS.md scrolled off.

When touching any Swift file:
- Invoke **`swift-dev`** (master router) — it loads the right guides: `swiftui-pro`
  for any view, `swiftui-design-principles` for native-feeling UI / WidgetKit,
  `swift-testing-pro` for tests, `swift-concurrency-pro` for async, etc.
- Apply **`ponytail`**: smallest correct change, no rewriting working code.
- Bugs → `superpowers:systematic-debugging` + `swift-dev`→ios-debugger-agent.

Full gate table and the rest of the workflow live in `AGENTS.md`.
