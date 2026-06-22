# FounderLens — App Behavior (distilled from the specs)

The canonical behavior the simulator encodes. Source: the FounderLens spec family (interaction, first-diamond, develop, onboarding, devaudit, deliver-vision, product-strategy). This file is the contract the simulator must stay faithful to.

## The promise

FounderLens is a virtual co-founder for the pre-MVP strategy phase. It does **not** build the product — it generates the spec-driven prompts that build it. The backbone is the Double Diamond: Discover → Define → Develop → Deliver, with a Midpoint Validation Audit between Define and Develop, and a Development Audit between Develop and Deliver. The simulator covers the **first diamond + MVA**.

## Interaction model (applies to every screen)

- ~97% of choices are tappable widgets; free text is the quiet exception, always available.
- **Propose, then check:** each ingredient is framed in one sentence, then 2–4 coherent positions are offered, exactly one pre-marked *recommended* with its reason inline. Never decide for the user; never hide the recommendation.
- **Small portions:** one ingredient per screen.
- **Selection shows a filled checkmark.** Multiple picks → rank or merge, never silent flatten.
- **Ingredient checklist** is always visible; "done" is earned (all ingredients) not counted. Users may exit early with a warning.
- **Seams** between phases summarize what's locked, flag any tension with earlier decisions, and wait for approval. Gates are soft.
- An always-on legal/compliance guard may surface where relevant.

## Discover — 10 ingredients (diverge)

1. Pain — the central pain.
2. Who — who feels it most acutely.
3. Acuteness — how sharp/urgent.
4. Today's alternative — what they use now.
5. Why they'd switch — why our product over the alternative.
6. Frequency — how often the pain hits.
7. WTP — willingness to pay (how much, what model).
8. Trigger — the moment they go looking.
9. Where they are — channels, places, communities.
10. **Benchmark** — real competitors (key features, pricing, why they win) + the open-gap synthesis. **Web-grounded, cited, never invented.** Regulatory findings are surfaced prominently (they often become standing guards).

## Define — 5 ingredients (converge)

1. Persona — one concrete person, not a broad segment.
2. Beachhead — the smallest winnable first market.
3. Core problem — the single problem solved for that persona.
4. Positioning — against the current alternative.
5. UVP — the unique value proposition in one sentence.

## Midpoint Validation Audit (R-W-W)

Rubric, weighted, scored 0–100:

| Group | Criterion | Max |
|---|---|---|
| Real | Pain | 15 |
| Real | Reach | 15 |
| Win | Differentiation | 20 |
| Win | Distribution | 15 |
| Win | Independence | 10 |
| Worth it | WTP | 15 |
| Worth it | Feasibility | 10 |

Bands → verdict: 90–100 Excellent · 80–89 Strong · 70–79 Solid · 56–69 Promising · 41–55 Shaky · 0–40 Weak.

**Honesty guardrail:** warm framing is fine, but a score never crosses a verdict line to flatter the founder. A weak idea is told it's weak — kindly, with reasons. Always pair the verdict with **one stronger adjacent idea**, compared on the same criteria; the founder may decline it (a real, recorded decision).

## Output — the first-diamond spec

A versioned markdown doc: header + v0.1, numbered sections for Discover / Define / MVA with decisions and their reasons, and an "Open / next" section. This mirrors the spec format used across the project.

## BYOK

The real app is bring-your-own-key (Anthropic Console key in the Apple Keychain; no server inference). The simulator represents this honestly but runs AI through the artifact runtime so it works without setup.
