> Adapted from [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide) (MIT).

# PRD-Driven Workflow Templates

## CLAUDE.md Root Template

```markdown
# Project: [Your App Name]

## Quick Reference
- **Platform**: iOS 17+ / macOS 14+
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with @Observable
- **Minimum Deployment**: iOS 17.0

## XcodeBuildMCP Integration
- Build: `mcp__xcodebuildmcp__build_sim_name_proj`
- Test: `mcp__xcodebuildmcp__test_sim_name_proj`
- Clean: `mcp__xcodebuildmcp__clean`

## Coding Standards
- Swift 6 strict concurrency
- `@Observable` over `ObservableObject`
- `async/await` for all async operations
- `NavigationStack` over deprecated `NavigationView`
- `@Bindable` for bindings to @Observable objects

## Testing Requirements
- Unit tests for all ViewModels
- Use Swift Testing (`@Test`, `#expect`)
- 80%+ coverage for business logic

## DO NOT
- Use deprecated APIs
- Create monolithic views
- Use force unwrapping without justification
- Ignore Swift 6 concurrency warnings

## Memory Imports
@import docs/PRD.md
@import docs/ARCHITECTURE.md
```

---

## PRD Template (docs/PRD.md)

```markdown
# PRD: [App Name]

## Executive Summary
## Problem Statement
## Target Users
## Success Metrics

| Metric | Target |
|--------|--------|
| D7 Retention | 40% |
| App Rating | 4.5+ |
| Crash-Free | 99.5% |

## Core Features

### Feature 1: [Name]
**Priority**: P0
**User Stories**: As a [user], I want [action] so that [benefit]
**Acceptance Criteria**:
- [ ] Criterion

## Non-Functional Requirements
- Performance: launch < 2s, 60fps scrolling
- Accessibility: WCAG 2.1 AA
- Security: Keychain for credentials

## Technical Constraints
- Swift 6.0+ strict concurrency
- SwiftUI-only
- SwiftData for persistence
- Minimum iOS 17.0
```

---

## Feature Spec Template (docs/specs/template.md)

```markdown
# Feature Spec: [Name]

**Status**: Draft | In Review | Approved | In Progress | Complete
**Priority**: P0 | P1 | P2

## Overview
## User Stories
## Acceptance Criteria
## Technical Design
### Data Models
### API Endpoints
### Dependencies
## UI/UX Design
## Edge Cases
## Testing Plan
## Open Questions
```

---

## Task File Template (docs/tasks/feature-tasks.md)

```markdown
# Tasks: [Feature Name]

**Spec**: docs/specs/[feature].md
**Status**: Not Started | In Progress | Complete

## Progress
- Total: X / Completed: Y / Current: Z

## Steps

### Step 1: [Name]
- [ ] Subtask
**Notes**:

## Changes Log
| Date | Step | Changes |
|------|------|---------|
```

---

## Slash Commands for PRD Workflow

### `.claude/commands/create-prd.md`
```markdown
---
description: Create a new PRD from requirements discussion
allowed-tools: Read, Write, Edit
---
Create comprehensive PRD in docs/PRD.md. Ask clarifying questions first. Use ultrathink.
```

### `.claude/commands/generate-spec.md`
```markdown
---
description: Generate feature spec from PRD
argument-hint: <feature-name>
allowed-tools: Read, Write
---
Read docs/PRD.md and create spec for $ARGUMENTS at docs/specs/$ARGUMENTS.md. ultrathink first.
```

### `.claude/commands/generate-tasks.md`
```markdown
---
description: Break feature spec into tasks
argument-hint: <feature-name>
allowed-tools: Read, Write
---
Read docs/specs/$ARGUMENTS.md and create docs/tasks/$ARGUMENTS-tasks.md.
```

### `.claude/commands/implement-feature.md`
```markdown
---
description: Implement feature from spec
argument-hint: <feature-name>
allowed-tools: Read, Write, Edit, mcp__xcodebuildmcp__*
---
1. Read docs/specs/$ARGUMENTS.md
2. Read docs/tasks/$ARGUMENTS-tasks.md
3. Implement current uncompleted task
4. Write tests
5. Update task progress
6. Build and test
Stop after each task and wait for approval.
```
