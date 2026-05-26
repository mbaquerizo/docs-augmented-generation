---
id: DAG-33
issueType: task
status: open
tags:
  - dag
  - database
  - adapter
  - documentation
parent: DAG-28
blockedBy: [DAG-29, DAG-30]
---

# Create documentation-db adapter for DB-backed documentation storage

## Description

Create `plugins/dag/skills/dag-publish/adapter-documentation-db.md` — a new adapter skill following the naming convention `adapter-{category}-{type}` for auto-dispatch when config has `"documentation": {"type": "db"}`. Mirrors the structure of `documentation-local.md` but stores ADRs, code explorations, and pitches in SQLite using the DB adapter schema.

Loaded dynamically by the dag-publish dispatch logic when it encounters `type: "db"` for the documentation adapter category. Reads `dbPath` from its own config — when this matches the issue-tracking adapter's `dbPath`, cross-referencing via `doc_issues` is available.

## Acceptance criteria

1. Adapter skill file exists with correct YAML frontmatter for skill auto-discovery
2. On first call, initializes the DB schema idempotently (delegates to migration or uses `CREATE TABLE IF NOT EXISTS`)
3. Reads `dbPath` from `adapters.documentation.config` (default `.dag/dag.db`)
4. Maps contract fields to schema columns:
   - `type` → `docs.type` (literal, e.g. `"adr"`, `"pitch"`)
   - `title` → `docs.title`
   - `body` → `docs.body`
   - `metadata.docType` → `docs.type` override when type is `"adr"` (e.g. `"code-exploration"`)
   - `metadata.status` → `docs.status`
   - `parent` → `docs.parent_id` (resolved by slug or explicit id)
5. Creates/assigns tags from `metadata.tags` in `tags` and `doc_tags` tables
6. Returns `<db>://docs/<id>` as the published location
7. Supports lookup by doc ID for updates
8. Does not break the existing `local` documentation adapter

## Related docs

- Design doc: `.dag/docs/design/db-adapter-schema.md`
- Contract: `plugins/dag/skills/dag-publish/contract.md`
- Adapter conventions: `plugins/dag/skills/dag-publish/adapter-conventions.md`
- Local adapter reference: `plugins/dag/skills/dag-publish/documentation-local.md`
- SQL schema: `plugins/dag/scripts/schema.sql` (DAG-30)
- Parent epic: DAG-28

---

*This ticket was created by opencode and reviewed by a human before publishing.*
