# akios — Prototype-First Visual Workflow
**Working spec · v1.0 · UI overhaul annex (spec 1 of 3)**

Defines how akios takes a feature from "context gathered" to "a beautiful SwiftUI screen we
trust" by routing through a fast visual medium (HTML/Tailwind) instead of asking an agent to
one-shot visual beauty directly in SwiftUI. Introduces a new `design` phase, three new skills
(`prototype`, `html-to-swiftui`, `visual-grounding`), and a hard prototype-approval gate.
First of a 3-spec UI overhaul family: **`prototype-first-workflow` → `ui-first-architecture`
→ `swiftui-design-doctrine`** (designed in order C → A → B). Everything here is settled unless
marked *open*.

> **State:** designed

> **Core bet (the thesis):** agents can code complexity but cannot *infer* what is visually
> beautiful, and cannot reliably one-shot a UI without (a) original visual inspiration and
> (b) supervision during execution. So we move the "make it beautiful" step into a cheap,
> fast-feedback medium (HTML/CSS/Tailwind, live in a browser) where a human can iterate to a
> satisfying result, then translate that approved artifact to SwiftUI and *converge* the running
> app against it. Proven informally by a Gemini Pro + Antigravity run that generated a prompt and
> implemented a satisfying interface — this spec systematizes that loop.

Worked example threaded throughout: **futebol-manager** — a football-manager iOS app, designed
UI-first, that starts with `deep-brainstorm` and arrives with **3 finished UI HTML files** as
bring-it references.

---

## 1. The reference (C1) — medium-agnostic, HTML-preferred

The pipeline does **not** standardize on a single prototype format. The canonical thing is *an
approved visual reference*, which may be:

| Source | Path into the loop | Notes |
|---|---|---|
| **HTML / CSS / Tailwind** | default authoring medium | what `prototype` generates; what a `bring-it` user most often supplies; live-iterable in a browser |
| **Figma** | existing `figma-to-swiftui` MCP path | keeps its rich structured path (nodes + tokens); not rebuilt to HTML |
| **Stitch** | export → HTML or screenshot | treated as HTML or as a screenshot reference |
| **Screenshot / mockup / Dribbble** | image reference | feeds translation + grounding directly as pixels |

**Decision & reason:** standardizing on HTML alone (rejected) would force Figma — which already
has a structured MCP path that yields tokens and layout — through a lossy HTML rebuild, and a
pixels-only rule (rejected) would discard exactly the Tailwind classes / Figma tokens that make
translation accurate (spacing and tokens are where agents fail). Medium-agnostic with HTML as the
default authoring medium keeps the cheap-iteration medium where beauty is reachable, while letting
structured sources use their richest path. **Cost accepted:** two translators coexist
(`html-to-swiftui` new + `figma-to-swiftui` existing) — neutralized because they share one
downstream grounding loop and one output discipline (Block A/B references).

---

## 2. Who builds the prototype (C2) — akios generates by default; bring-it is a fast-path

**Default:** after context/specs exist, `prototype` produces HTML/Tailwind per screen, renders it
(screenshot), shows the user, and iterates *in the browser medium* until the user approves.

**Bring-it fast-path:** if the user already has a finished reference (HTML / Figma / Stitch /
screenshot), generation is skipped — straight to ingest + approve.

**Decision & reason:** the common case is that no design exists yet, and the whole "iterate to
beauty in a cheap medium under supervision" thesis only pays off if akios can *produce* that
medium. "Never generate, always bring" (rejected) abandons that workflow and strands users with no
design tool; "bring is default, generate on request" (rejected) makes the common no-design path an
opt-in every time. **Cost accepted:** akios owns a real generation/iteration loop — that loop *is*
the feature.

---

## 3. What "approved" means (C3) — hard gate + durable stored artifact

- **Hard gate:** no SwiftUI is written for a screen until its reference is **explicitly approved**
  by the user. This is the cheap-failure checkpoint — the entire reason for routing through HTML
  is to fail and iterate *here*, before the expensive SwiftUI step.
- **Durable artifact:** the approved reference is committed to the repo —
  `prototypes/<Feature>/<Screen>.{html,png}` (or a Figma/Stitch URL) — with a one-line row in
  `prototypes/manifest.md` (source · path · approved date) and a link from that screen's
  `ui-alignment` doc.
- **Unattended (`/akios:just-vibes`):** akios auto-approves its own best prototype, marks it
  `[auto]`, and records the rationale — mirroring how `align-ui` already behaves unattended.

**Decision & reason:** the stored reference is what the grounding loop *and* the next session
converge against — "specs are the memory" applies to visual design too. A soft gate (rejected)
lets the costly SwiftUI step run on an unapproved prototype — the exact waste being removed. An
ephemeral gate with nothing stored (rejected) leaves the grounding loop nothing durable to
converge against next session.

> **[OPEN — reconcile in `ui-first-architecture` (Block A)] Storage location.** Top-level
> `prototypes/<Feature>/` is the working decision. The user floated per-feature-folder storage
> (`Feature/<Screen>/prototype.html`). Whichever is chosen, the artifact must sit **outside the
> Xcode app target** so `.html` never bundles. Resolve when A fixes the per-feature structure.

---

## 4. The skill inventory (C4) — three focused new skills

| Skill | Owns | Phase |
|---|---|---|
| `prototype` | generate + iterate HTML/Tailwind to the approval gate; ingest brought references | `design` |
| `html-to-swiftui` | translate an approved HTML/Tailwind reference into SwiftUI | `execute` |
| `visual-grounding` | the convergence QA loop (screenshot running app → diff vs approved reference → fix → repeat) | `execute` |

- `figma-to-swiftui` is **left intact** as the Figma-source translator.
- `visual-grounding` is **shared**: both `html-to-swiftui` and `figma-to-swiftui` route their
  validation through it.
- **No duplicated output discipline:** the SwiftUI-output rules (dumb components via `init`,
  unified `DesignSystem`, native-first, reusable ViewModifiers, `containerRelativeFrame`) live in
  Block A (structure) + Block B (craft) references; both translators load them rather than
  restating them.

**Decision & reason:** three focused skills give clean phase separation and let the mature
`figma-to-swiftui` guide stay untouched. A unified `reference-to-swiftui` translator (rejected) is
cleaner long-term but requires refactoring a large working asset — real regression risk for
elegance (migration P1→P2 remains possible later). A single `prototype-pipeline` mega-skill
(rejected) does three jobs and prevents the Figma path from reusing grounding.

---

## 5. Convergence (C5) — agent-driven structured visual diff, no pixel gate

**Crux fact:** a SwiftUI render and an HTML render come from **different engines** (fonts,
antialiasing, layout) and will never be pixel-identical. The reference is **design intent, not a
pixel target.**

The `visual-grounding` loop:

1. Build + run the app; **screenshot the running screen** (simulator, via the existing
   `ios-debugger-agent` path; Xcode Preview snapshot as a lighter fallback).
2. Place the app screenshot beside the approved reference; the multimodal agent emits a
   **categorized diff** — `layout · spacing · color · typography · assets · missing/extra`.
3. Fix the material differences; re-screenshot; repeat under a **max-iteration cap**.
4. **Verdict:** the agent proposes "converged" when only trivial or intentional-platform diffs
   remain. Attended → the user confirms. Unattended → auto-accept with the diff report recorded.

**Decision & reason:** a perceptual pixel-diff threshold (rejected) is objective and CI-friendly
but produces constant false fails across mediums and would force the reference to *be* a SwiftUI
render — killing the cheap-HTML thesis. Agent-driven structured diff is the only method robust to
cross-engine rendering, and it reuses the structured-audit discipline `figma-to-swiftui` already
has, adding the running-app loop it lacks. **Cost accepted:** leans on the agent's visual judgment
— bounded by the iteration cap and the human verdict.

> **[OPTIONAL — per-project opt-in] Snapshot regression-lock.** After convergence, optionally
> capture a SwiftUI snapshot baseline (`swift-snapshot-testing`) so *future* edits are guarded by
> a fast pixel test against the app's own approved render (which **is** pixel-stable, unlike
> SwiftUI-vs-HTML). Not baked in; feeds the Vision wishlist "Xcode integration hooks" item.

---

## 6. Pipeline integration (C6) — a new `design` phase; `align-ui` folds in and shrinks

Pipeline becomes:

```
brainstorm  →  plan  →  design  →  execute
(specs)        (tasks)   (prototype +    (html-to-swiftui +
                          approve +        visual-grounding,
                          align-ui gaps)   per UI task)
```

- **`design` runs per spec/slice**, not whole-app: it generates + approves prototypes for that
  spec's screens (or ingests bring-it references), then hands an approved-reference set to
  `execute`.
- **`align-ui` relocates into `design` and shrinks.** The approved prototype now answers
  layout / visual hierarchy / key components (a picture beats the old Q&A decision tree), so
  `align-ui` stops being an execute-time interrogation and covers only what a static prototype
  *cannot*: **states** (empty / loading / error / success), **interactions & gestures**, and
  **navigation + data wiring**.
- **`execute`** runs `html-to-swiftui` then `visual-grounding` for each UI task.

**Decision & reason:** a distinct `design` phase matches the thesis ("make sure the UI is as
intended before progressing"), is a clean `workflow.yml` addition, and gives bring-it a natural
home. Execute-time prototyping (rejected) interleaves visual approval with coding and prevents
seeing a feature's whole UI before building. Brainstorm-time prototyping (rejected) bloats
brainstorm and couples spec-approval cadence to visual-approval cadence.

---

## 7. Worked example — futebol-manager

**Setup:** the app is mapped UI-first via `deep-brainstorm`; the developer arrives with **3
finished UI HTML files** (bring-it references). *(Files live in a separate `futebol-manager`
Developer folder; path to be supplied when the translate/ground decisions are exercised.)*

Run through the phases:

1. **brainstorm** — `deep-brainstorm` maps the whole app, bursts specs per surface area.
2. **plan** — `spec-to-tasks` produces the backlog for, say, the *Squad* screen spec.
3. **design** — the Squad screen already has a finished HTML reference → **bring-it fast-path**:
   `prototype` ingests it, the developer approves (hard gate), it's committed to
   `prototypes/Squad/Squad.html` + a `manifest.md` row + linked from `tasks/ui-alignment/Squad.md`.
   `align-ui` then resolves only the non-visual gaps: the empty squad state, the loading state
   while roster fetches, the error/offline state, row-tap navigation, and where the player data
   comes from (just-in-time model, per Block A).
4. **execute** — `html-to-swiftui` translates `Squad.html` into SwiftUI (dumb components +
   `DesignSystem` per Block A/B); `visual-grounding` builds + runs the app, screenshots the Squad
   screen, diffs it against `Squad.html`, fixes spacing/typography deltas, and converges on the
   developer's confirmation.

The other two HTML files (e.g. *Match Day*, *Player Detail*) repeat the same `design → execute`
path. Screens *without* a brought reference (e.g. a future *Settings*) take the **generate**
branch: `prototype` produces HTML/Tailwind, iterates with the developer, then the same translate +
ground steps run.

---

## 8. Empty / edge states (of the workflow itself)

- **No reference and generation declined:** the screen cannot enter `execute` for its UI task; the
  hard gate holds. akios reports the screen is blocked on an approved reference.
- **Reference approved but app won't build/run:** `visual-grounding` cannot screenshot. The loop
  reports a build/run failure (routes to `ios-debugger-agent`) rather than falsely converging.
- **Iteration cap hit without convergence:** the loop stops, records the residual categorized
  diff, and surfaces it as an open item for the developer — never silently declares "converged."
- **Bring-it reference is low-fidelity (e.g. a rough screenshot):** ingest still works; the
  categorized diff is necessarily looser, and `align-ui` carries more of the visual decisions.

---

## 9. Open / next

- **[OPEN — Block A]** Final `prototypes/` storage location (top-level vs per-feature) — §3.
- **[OPEN — Block A]** How the `design` phase orders against the UI-first build order
  (components → dumb screens → viewmodels → JIT models): does `design` produce per-component
  prototypes or per-screen, and how that maps to the per-feature folder structure.
- **[CONSEQUENCE — to implement]** `workflow.yml` + `pipeline.md` gain a 4th phase (`design`).
- **[CONSEQUENCE — to implement]** `align-ui` SKILL.md remodeled: relocates to `design`, scope
  shrinks to states/interactions/wiring.
- **[CONSEQUENCE — to implement]** `figma-to-swiftui` Step 7 ("validate on user request only")
  rewired to route validation through `visual-grounding`.
- **[CONSEQUENCE — to implement]** `just-vibes` learns the `design` phase + the auto-approval
  posture (consistent with its existing `align-ui` handling).
- **[CONSEQUENCE — to implement]** `install-skills.sh` `SKILLS=(...)` array gains `prototype`,
  `html-to-swiftui`, `visual-grounding`; three new `commands/` wrappers if commands are wanted.
- **Block B dependency:** the SwiftUI-output discipline both translators rely on is defined there
  (dumb components via `init`, unified `DesignSystem`, native-first, reusable ViewModifiers,
  `containerRelativeFrame`).
