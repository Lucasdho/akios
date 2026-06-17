# Memory.md — Durable decisions

Append-only. One entry per decision/fact that survives between sessions.
Don't record what the code or git history already says. Use absolute dates.

**Format:**
```
## YYYY-MM-DD — <title>
- **Decision:** ...
- **Why:** ...
- **Applies to:** <files / area>
```

---

## (example) 2026-01-01 — Chose SQLite over Postgres for the prototype
- **Decision:** Single-file SQLite, no server.
- **Why:** Single-user PoC, zero ops; migrate if multi-user lands.
- **Applies to:** `db/`, `Context.md` stack section.
