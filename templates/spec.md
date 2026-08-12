# {{Project}} — {{Block / Feature Name}}
**Working spec · v1.0**

<!-- One short paragraph: what this document captures, what it complements, what
     comes next. State the settled-vs-open contract here:
     "Everything here is settled unless marked *open*." -->

<!-- No `State:` line and no tier here — spec status and priority tier live only in
     akios/Roadmap.md's `## Specs` table. -->

## Contract
<!-- Only when akios/Context.md "Module boundaries" describes a project that HAS module
     boundaries, and only for a buildable-feature spec (not a doctrine/process spec).
     spec-to-tasks reads this to scope the boundary task. Delete this whole section for a
     flat project or a cross-cutting spec. -->
- **Exports:** {{this feature's public surface — the interface + data shapes other modules
  are expected to consume. "None yet" if this is a leaf feature.}}
- **Consumes:** {{which other modules' public surfaces, and which shared/common symbols,
  this feature is expected to need.}}

---

## 1. {{Section}}
- **{{bold lead-in}}** — decision *and its reason*: "we chose X because Y; the cost
  is Z, accepted because W." Record a deliberate "no" too, with why it was declined.

## 2. {{Section}}
...

---

## States
<!-- Mandatory for any spec defining a screen, list, feed, or data-backed view — an
     undocumented empty state is a missing requirement, not a small gap. Delete this
     section entirely when the domain has no interactive or data-backed surface. -->
- **Happy:** {{what it looks like with normal data}}
- **Empty:** {{before any data exists, after the user clears it all, on first run}}
- **Loading / in-flight:** {{what shows while data is on its way}}
- **Error / offline:** {{what shows when it fails, and what the user can do about it}}

## Worked example
<!-- For process specs: the living example's run through this block. -->

## {{N}}. Open / next
- what the next session should tackle
- what stayed undecided (and who owns it)
- risks carried forward, marked: `[TECHNICAL RISK — ...]`, `[EXPLICIT RISK — ...]`
