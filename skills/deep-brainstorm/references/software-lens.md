# Software Lens — the full deck for mapping an app or product

Read this when Phase 0 established the subject is **software**: an application, a service, a
platform, a product. It expands three rows of `SKILL.md` — the Discover ingredients, the six map
dimensions, and the spec grouping — into the detail that a software map actually needs. Everything
else in `SKILL.md` (the phases, the golden rules, the R-W-W audit, the unattended posture) applies
unchanged.

Nothing here is a checklist to complete. A dimension with no items is a finding; say so and move
on.

---

## Discover — the 8-ingredient product set

Replaces `SKILL.md`'s five universal ingredients plus the two "Software / product" additions, when
the subject is a product being mapped rather than an idea being validated. One per turn, using the
`idea-to-spec` decision loop.

| # | Ingredient | The question |
|---|---|---|
| 1 | **Core promise** | In one sentence, what does this do for its user? |
| 2 | **Primary persona** | Who is the single most important user today? (a concrete person, not a segment) |
| 3 | **Acute pain** | What specific pain does that person have right now that this relieves? |
| 4 | **Today's alternative** | What do they use instead today, and why is it worse? |
| 5 | **Unique advantage** | The one thing this does that no alternative does as well? |
| 6 | **Business model** | How does this sustain itself? Revenue model, who pays, what triggers payment. |
| 7 | **Distribution** | How do users first find and install it? |
| 8 | **Benchmark** | Web-search 2–3 real competitors. Key features, pricing, the open gap. Cite real names — never invent. |

**Why this differs from `founderlens-behavior`'s 10-ingredient Discover:** that skill validates one
startup idea from scratch, so it needs Frequency / Willingness-to-pay / Trigger to test whether
anyone would actually pay. This one maps domains inside an **already-chosen** product, so it drops
those three and adds Business model and Distribution instead. Different question, not drift — don't
reconcile them.

---

## The 6 map dimensions, in full

**1. Screens & flows**
Every distinct screen or major flow, grouped by section (Onboarding · Home · Detail · Settings ·
Profile). E.g. `Home Feed`, `Item Detail`, `Search`, `Settings — Notifications`,
`Onboarding — Step 1: Welcome`.

**2. Data domains**
Every major entity or model — `User`, `Post`, `Comment`, `Session`, `Notification`. Include
sync/persistence concerns where they're genuinely distinct (`LocalDraft` vs `PublishedPost`).

**3. Infrastructure & services**
Every non-UI technical concern: Auth, Networking/API, Push Notifications, Analytics, Crash
Reporting, Payments/IAP, Sync, Background Tasks, secure storage.

**4. Cross-cutting concerns**
Things that touch every screen but live in no single spec: Theming / Design System, Accessibility,
Localization (which languages?), Deep Links, Widgets or Extensions.

**5. Business logic & rules**
Non-trivial logic that is neither a screen nor a model: recommendation algorithms, pricing rules,
content moderation, permission/role logic, rate limiting, paywall gating.

**6. Integrations**
Third-party APIs, SDKs, and external services: payment processors, backends-as-a-service, search,
maps, device capabilities (camera, location, health), identity providers.

The names above are *examples of the category*, not a list to match against. Use whatever this
project actually calls its parts — `akios/Context.md` `## Architecture` records that vocabulary,
including what counts as a module boundary and what belongs in shared code.

---

## Spec grouping — typical software domains

One spec per area of related work that can be planned and built independently. The groupings that
recur:

| Domain | What it usually covers |
|---|---|
| `onboarding` | All onboarding screens + the auth flow |
| `home` | Home screen + the core feed or list |
| `<feature>-detail` | A detail screen + its related actions |
| `search` | Search UI + search infrastructure |
| `data-<entity>` | One major data model + its repository |
| `infra-auth` | The auth service, separate from onboarding UI |
| `infra-networking` | API client, error handling, retry |
| `infra-notifications` | Push setup + notification handling |
| `settings` | Settings screens |
| `design-system` | Theme, typography, shared components |

Propose the grouping in one turn — each candidate named, one line each — and ask what should be
split, merged, or renamed before writing anything.

---

## What a software spec must carry

On top of `SKILL.md`'s Phase 4 list, two things are mandatory here and easy to skip:

- **States, per screen in scope:** happy · empty · loading/in-flight · error/offline. A
  user-facing spec that omits them is incomplete — `spec-to-tasks` turns these directly into
  per-task acceptance criteria, so a gap here becomes a gap in the backlog.
- **The `## Contract` header**, when `akios/Context.md` describes a project with explicit module
  boundaries: what this domain **exports** (its public surface) and what it **consumes** (other
  modules' surfaces, shared symbols). See `idea-to-spec`'s `references/akios-integration.md`.
  Projects with no such boundaries skip it.
