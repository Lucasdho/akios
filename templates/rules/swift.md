---
paths:
  - "**/*.swift"
---

<!-- Loads on every .swift read so the gates stay in context after compaction.
     Keep this short — it costs tokens on every Swift file read. -->

# Swift work

**Before writing or editing Swift, route through `swift-dev`** — don't code from
memory. It loads the guide that matches the change:

| Change touches | Guide swift-dev loads |
|---|---|
| any SwiftUI view | `swiftui-pro` |
| native look / polish / WidgetKit | `swiftui-design-principles` |
| tests | `swift-testing-pro` — Swift Testing (`@Test`/`#expect`), not XCTest |
| async / actors / `@MainActor` | `swift-concurrency-pro` |
| SwiftData (`@Model`, `ModelContext`, `@Query`) | `swiftdata-pro` |
| build / run / debug on a simulator | `ios-debugger-agent` |

While coding, hold **`ponytail`**: smallest correct diff, reuse what exists, no
speculative abstractions. A bug or unexpected behavior goes through
**`superpowers:systematic-debugging`** before any fix.

Full workflow and the rest of the gates → `AGENTS.md`.
