---
name: swift-dev
description: |
  Master router for ALL Swift and iOS development. This skill classifies the scope of a change and loads the right specialized guides (bundled inside this skill) before any code is written.

  Trigger for:
  - Writing, editing, refactoring, or reviewing any .swift file or Xcode project
  - SwiftUI views, navigation, layout, modifiers, state management
  - Swift concurrency (async/await, actors, Sendable), SwiftData, Swift Testing
  - Debugging, running, or profiling an iOS/iPadOS/macOS/watchOS app
  - Implementing a Figma design in SwiftUI
  - Even when the user doesn't say "Swift" but the project or files are clearly Swift/Xcode-based

  Don't trigger for:
  - Other languages/platforms: Kotlin/Android, React Native, Flutter, web frontends, backend services not in Swift
  - Conceptual iOS questions with no code involved (App Store policy, app ideas, pricing)
  - Pure design work in Figma with no SwiftUI implementation requested
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.1.0"
---

# Swift Dev — Master Router

You are acting as the tech lead of a Swift codebase. This skill bundles 11 specialized guides under `skills/`, and your job before touching any code is the same as a tech lead's before delegating: understand the scope of the change, then bring in the right expertise. Code written without the matching guides ignores the project's established best practices — modern API usage, concurrency safety, accessibility — and that's exactly the class of bug that looks fine in review and breaks in production.

## Workflow

### Phase 1 — Gather context

Before classifying, look at what exists:

- **Project conventions first**: if the repo has a `CLAUDE.md`, `.cursorrules`, or similar conventions file, read it. Project rules override the bundled guides where they conflict.
- **The actual files**: skim the files the change touches. The request says "add a button"; the file may reveal async loading, SwiftData queries, or a 400-line body — each of which changes the routing.

### Phase 2 — Classify and load

Classify the scope and **read every matching guide** (Read tool, paths relative to this skill's base directory) BEFORE writing or reviewing code. Load all matches up front, not lazily mid-task. A single change often spans multiple areas.

| Scope of the change | Read this guide |
|---|---|
| Any SwiftUI view code — writing, editing, or reviewing | `skills/swiftui-pro/GUIDE.md` |
| Building NEW UI: screens, navigation, TabView, stacks/grids, custom modifiers, @State/@Binding design | `skills/swiftui-ui-patterns/GUIDE.md` |
| Native polish: spacing/typography/semantic-color systems, component sizing, grouped content, WidgetKit, or UI that "looks AI-generated" | `skills/swiftui-design-principles/GUIDE.md` |
| Refactoring EXISTING views: splitting long bodies, extracting subviews, MV vs MVVM, @Observable patterns | `skills/swiftui-view-refactor/GUIDE.md` |
| Concurrency: async/await, actors, Task, Sendable, @MainActor, data races, structured concurrency | `skills/swift-concurrency-pro/GUIDE.md` |
| Tests: writing or editing Swift Testing code (@Test, #expect, suites) | `skills/swift-testing-pro/GUIDE.md` |
| Persistence: SwiftData — @Model, ModelContext, @Query, migrations | `skills/swiftdata-pro/GUIDE.md` |
| Performance: jank, slow scrolling, high CPU/memory, excessive view updates, layout thrash | `skills/swiftui-performance-audit/GUIDE.md` |
| Accessibility: VoiceOver, Dynamic Type, labels/traits/hints, Switch Control, a11y audits | `skills/ios-accessibility/GUIDE.md` |
| Running/debugging: build & run on simulator, interact with the app, capture logs, diagnose runtime behavior | `skills/ios-debugger-agent/GUIDE.md` |
| Figma involved: a figma.com URL or design handoff to implement in SwiftUI | `skills/figma-to-swiftui/GUIDE.md` |

**Selection rules:**

- **`swiftui-pro` is the baseline**: if the change touches any SwiftUI view at all, load it, in addition to whatever more specific guide applies. Pure non-UI Swift (a parser, a network layer) doesn't need it.
- **New UI vs refactor**: creating views → `swiftui-ui-patterns`; restructuring existing views without changing behavior → `swiftui-view-refactor`. A redesign that does both loads both.
- **Native polish / WidgetKit**: load `swiftui-design-principles` when the goal is making UI look native and intentional (a new screen, a redesign, "this looks AI-generated"), or for any WidgetKit work — not for every incidental view edit. It is opinionated toward a minimal, data-focused aesthetic; apply judgment for expressive UIs.
- **Concurrency is sneaky**: if the change introduces or touches `async`, `await`, `Task {}`, an actor, or completion-handler-to-async migration — even incidentally — load `swift-concurrency-pro`. Most modern Swift bugs live here.
- **Performance and accessibility are on-demand**: load them when the user mentions the symptom (slow, janky, "VoiceOver") or asks for an audit — not for every change.
- **Don't over-load**: guides for areas the change won't touch just add noise. Three well-chosen guides beat eight.
- **Fast-path mechanical work**: if the change is a *mechanical application of a pattern already established in this repo* (mirroring an existing screen/VM, a rename, an obvious one-liner, moving code) and you've already read the precedent file, the precedent **is** your guide — proceed without loading. Reserve the guides for genuine uncertainty they'd resolve: an unfamiliar or version-sensitive API, concurrency/SwiftData/accessibility nuance, or UI with no in-repo precedent. Loading a guide to copy a pattern you can already see adds latency, not correctness.

**Common combos:**

| Scenario | Guides |
|---|---|
| New screen with remote data | swiftui-pro + swiftui-ui-patterns + swift-concurrency-pro |
| New screen, polish matters | swiftui-pro + swiftui-ui-patterns + swiftui-design-principles |
| "This view is huge, help me split it" | swiftui-pro + swiftui-view-refactor |
| "Scroll is janky" | swiftui-pro + swiftui-performance-audit |
| Local persistence + tests | swiftdata-pro + swift-testing-pro (+ swiftui-pro if views change) |
| Figma URL → screen | figma-to-swiftui + swiftui-pro + swiftui-ui-patterns |
| WidgetKit widget | swiftui-design-principles (+ swiftui-pro if it shares view code) |
| "Run the app, button doesn't work" | ios-debugger-agent first; code guides once the cause is found |

### Phase 3 — Do the work

Follow the loaded guides. Each guide points to extra files under its own folder (e.g., `references/api.md`) — resolve those paths relative to that guide's folder and read them when the guide says to. The references are the depth; the GUIDE.md is just the map.

### Adding files to an Xcode target

When a task creates a new file (a view, a test, a resource), don't agonize over whether it lands
in the target — check the project once and act:

- **Check the project's answer first.** `Context.md` should record the target-membership mechanism
  (the kit's `/akios:init` detects it). Prefer that over re-deriving.
- **Otherwise inspect the `.pbxproj`.** Grep it for `PBXFileSystemSynchronizedRootGroup` (or read
  `objectVersion` — ≥ 77 means Xcode 16+). If present, the project uses **synchronized groups**:
  any file you place on disk under a target's synchronized folder is auto-included — `.swift` gets
  compiled, other files go into the bundle as Resources. **No `.pbxproj` surgery needed**; just put
  the file in the right folder.
- **If synchronized groups are absent** (older projects), target membership is explicit: the file
  must be added to the target (a manual `.pbxproj` edit or an IDE/tool like XcodeGen/`xcodeproj`).
  Say so plainly rather than guessing the file is "probably included".
- **Tests** read fixtures from their own bundle (`Bundle(for:)` / `Bundle.module`), not the app
  bundle — place test resources in the test target's folder.

### Phase 4 — Self-review before finishing

- Re-check the routing table: if the work drifted into a new area mid-task (you ended up writing tests, or added a `Task {}` you didn't plan), load that guide now and review what you wrote against it.
- If `swiftui-pro` was loaded, do a quick pass of your own diff against its review process (deprecated API, data flow, accessibility basics) before presenting.

## What consistently goes wrong

- **Over-gating mechanical work.** The opposite failure of under-loading: routing a pattern-copy or an obvious rename through the full guide-load ritual when you already have the answer burns the user's time and tokens for no correctness gain. The router is a map to knowledge you lack — not a mandatory toll on every `.swift` touch. See the fast-path rule above; when the precedent is in the repo and you've read it, that's your guide. (The real risk a guide catches — a version-sensitive or deprecated API in code you're *writing fresh*, not copying — still warrants the baseline; judge by whether the guide would change what you ship.)
- **Classifying from the request instead of the code.** "Add a label" sounds UI-only until the file shows the label's text comes from an async fetch. Phase 1 exists because requests under-describe scope.
- **Loading the guide and ignoring its references.** GUIDE.md files are maps, deliberately thin. If the guide says "check `references/api.md` for deprecated APIs" and the task touches API choices, read it.
- **Forgetting the mid-task re-check.** Tests written as an afterthought without `swift-testing-pro` tend to come out as XCTest instead of Swift Testing.
- **Loading everything defensively.** Ten guides in context for a button change buries the relevant rules in noise. Trust the classification.

## Output

Match the response shape to the request: produce code for build/refactor tasks, findings-by-file (per swiftui-pro's format) for review tasks, diagnosis-then-fix for debugging. Respond in the user's language; keep code identifiers and comments in English.
