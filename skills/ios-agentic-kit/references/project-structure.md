> Adapted from [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide) (MIT).

# iOS Project Structure Template

## Complete Layout

```
MyiOSApp/
├── .claude/
│   ├── commands/
│   │   ├── build.md
│   │   ├── test.md
│   │   ├── run-app.md
│   │   ├── create-view.md
│   │   ├── refactor-view.md
│   │   ├── fix-build.md
│   │   ├── implement-feature.md
│   │   ├── create-prd.md
│   │   ├── generate-spec.md
│   │   ├── generate-tasks.md
│   │   ├── plan-feature.md
│   │   ├── sandbox-build.md
│   │   └── sandbox-review.md
│   ├── agents/
│   │   ├── ios-architect.md
│   │   ├── swift-reviewer.md
│   │   ├── swiftui-specialist.md
│   │   └── ios-researcher.md
│   ├── skills/
│   │   ├── ios-testing/SKILL.md
│   │   └── swiftui-components/
│   │       ├── SKILL.md
│   │       └── templates/
│   ├── output-styles/
│   │   └── ios-mentor.md
│   ├── hooks/
│   │   ├── session-start.sh
│   │   ├── post-swift-edit.sh
│   │   └── file-protection.sh
│   ├── settings.json         ← committed
│   └── settings.local.json   ← gitignored
├── .mcp.json
├── CLAUDE.md
├── docs/
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md
│   ├── specs/
│   │   ├── template.md
│   │   └── 001-feature.md
│   └── tasks/
│       └── feature-tasks.md
├── MyApp/
│   ├── App/MyAppApp.swift
│   ├── Features/
│   │   └── [Feature]/
│   │       ├── CLAUDE.md     ← feature-level context
│   │       ├── Views/
│   │       └── ViewModels/
│   ├── Core/
│   │   ├── Extensions/
│   │   ├── Services/
│   │   └── Networking/
│   └── Resources/
├── MyAppTests/
├── MyAppUITests/
├── .swiftlint.yml
├── .swift-format
└── .gitignore
```

## Subagent Templates

### `.claude/agents/ios-architect.md`
```markdown
---
name: ios-architect
description: iOS architecture expert for system design and patterns
model: claude-opus-4-8
tools: Read, Grep, Glob
---
Expert iOS architect: MVVM/VIPER/Clean, Swift Concurrency, SwiftUI navigation,
DI, SwiftData, modular architecture. Analyze codebase, propose patterns,
provide Swift examples, consider testing implications.
```

### `.claude/agents/swift-reviewer.md`
```markdown
---
name: swift-reviewer
description: Code reviewer for Swift/SwiftUI code quality
model: claude-sonnet-4-6
tools: Read, Grep
---
Review for: Swift 6 concurrency safety, memory management, SwiftUI best practices,
API design guidelines, performance, test coverage, documentation.
Provide actionable feedback with code examples.
```

### `.claude/agents/ios-researcher.md`
```markdown
---
name: ios-researcher
description: Research iOS APIs and best practices
tools: WebSearch, WebFetch, Read
---
Research Apple docs, WWDC sessions, Swift Evolution. Summarize with code examples.
Always note iOS version requirements and cite sources.
```

## Useful Slash Command Bodies

### `create-view.md`
```markdown
---
description: Create SwiftUI view + ViewModel
argument-hint: <ViewName>
allowed-tools: Read, Write
---
1. Read existing views for style reference
2. Create $ARGUMENTS.swift in Features/
3. Create ${ARGUMENTS}ViewModel.swift as @Observable
4. Add preview
5. Follow project navigation patterns
```

### `plan-feature.md`
```markdown
---
description: Create implementation plan (read-only)
argument-hint: <feature-name>
allowed-tools: Read, Grep, Glob
model: claude-opus-4-8
---
ultrathink — comprehensive plan for: $ARGUMENTS
1. Read PRD and spec
2. Analyze codebase
3. Identify integration points
4. Step-by-step plan → docs/tasks/$ARGUMENTS-plan.md
DO NOT write code.
```

## .gitignore Additions

```gitignore
.claude/settings.local.json
.claude/*.log

!.claude/commands/
!.claude/agents/
!.claude/hooks/
!.claude/settings.json
```
