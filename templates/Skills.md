# Skills.md — Mandatory skill routing (Swift / iOS)

When a task matches a trigger, invoke the skill FIRST. Gates are not optional.
Process skills before implementation skills.

## Always on (every session, every task)
These three are big router skills — they redirect to the right internal skills.
- `superpowers` — process discipline (brainstorm, debug, TDD, verify).
- `ponytail` — laziness/efficiency: no over-building, no rewriting what exists.
- `swift-dev` — master router for all Swift/iOS work; loads the right guides.

## Before generating ANY code
- Enter **plan mode** OR `superpowers:brainstorming`. No code before one of these.

## Bug / failure / flake / regression
- `superpowers:systematic-debugging` OR `bug-hunt-swarm` (hairy / unknown cause)
- `swift-dev` → **ios-debugger-agent** for the iOS-specific diagnosis.

## Implementation (writing/editing code)
- `ponytail` — guarantee we don't rewrite working code or write too much.
- `swift-dev` — consult its Swift writing-standards before/while coding.
- `fewer-permission-prompts` — keep the build/test/run loop from stalling on
  permission prompts (allowlists common read-only Bash/MCP calls).

## Creating Views (SwiftUI)
- **ALWAYS build native** — native components first, no reinvented UI.
- `swiftui-design-skill` allied with the skills above (ponytail + swift-dev).

## Writing tests
- `swift-dev` → **swift-testing-pro** (its Swift Testing guide).

## swift-dev sub-skills (it auto-routes; named here for reference)
figma-to-swiftui · ios-accessibility · ios-debugger-agent · swift-concurrency-pro
· swift-testing-pro · swiftdata-pro · swiftui-performance-audit · swiftui-pro
· swiftui-ui-patterns · swiftui-view-refactor

## Before finishing
- May dispatch subagents to run:
  - `superpowers:verification-before-completion`
  - `/code-review` on the diff

## Project-specific overrides
{{e.g. "always /security-review when touching Keychain / auth / networking"}}
