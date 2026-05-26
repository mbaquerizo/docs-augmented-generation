---
id: DAG-34
issueType: task
status: open
tags:
  - dag
  - database
  - adapter
  - issue-tracking
parent: DAG-28
blockedBy: [DAG-29, DAG-30]
---

# Create issue-tracking-db adapter for DB-backed ticket storage

## Description

Create `plugins/dag/skills/dag-publish/adapter-issue-tracking-db.md` — a new adapter skill following the naming convention `adapter-{category}-{type}` for auto-dispatch when config has `"issue-tracking": {"type": "db"}`. Mirrors the structure of `issue-tracking-local.md` but stores tickets in SQLite using the DB adapter schema.

Handles the full ticket lifecycle: create with auto-incrementing project-prefixed IDs, parent-child relationships, typed issue-to-issue relations, and tag assignment. Seeds the `relations` table with initial relation types. Reads `dbPath` from its own config — when this matches the documentation adapter's `dbPath`, cross-referencing via `doc_issues` is available.

## Acceptance criteria

1. Adapter skill file exists with correct YAML frontmatter for skill auto-discovery
2. Initializes the DB schema idempotently (same database as documentation-db when `dbPath` matches)
3. Reads `dbPath` from `adapters.issue-tracking.config` (default `.dag/dag.db`)
4. Seeds `relations` table on first init with: `blocks`, `is_blocked_by`, `duplicates`, `is_duplicated_by`, `relates_to`, `causes`, `is_caused_by`
5. Maps contract fields to schema columns:
   - `metadata.issueType` → `issues.type` (e.g. `"epic"`, `"story"`, `"task"`)
   - `title` → `issues.title`
   - `body` → `issues.body`
   - `metadata.status` → `issues.status`
   - `parent` → `issues.parent_id` (resolved by project-prefixed ID)
6. Generates ticket IDs with project prefix: `{project}-{n}` where `n` is auto-incrementing per project
7. Stores `metadata.blockedBy` and `metadata.children` as `issue_relations` edges with appropriate relation types
8. Creates/assigns tags from `metadata.tags` in `tags` and `issue_tags` tables
9. Returns `<db>://issues/<id>` as the published location
10. Supports lookup by ticket ID for status updates
11. Does not break the existing `local` issue-tracking adapter

## Related docs

- Design doc: `.dag/docs/design/db-adapter-schema.md`
- Contract: `plugins/dag/skills/dag-publish/contract.md`
- Adapter conventions: `plugins/dag/skills/dag-publish/adapter-conventions.md`
- Local adapter reference: `plugins/dag/skills/dag-publish/issue-tracking-local.md`
- Ticket archetypes: `plugins/dag/skills/create-tickets/ticket-archetypes.md`
- SQL schema: `plugins/dag/scripts/schema.sql` (DAG-30)
- Parent epic: DAG-28

---

*This ticket was created by opencode and reviewed by a human before publishing.*
