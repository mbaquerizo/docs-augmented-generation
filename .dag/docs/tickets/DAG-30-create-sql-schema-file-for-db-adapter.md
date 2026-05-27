---
id: DAG-30
issueType: task
status: open
tags:
  - dag
  - database
  - schema
  - sql
parent: DAG-28
blockedBy: []
---

# Create SQL schema file for DB adapter

## Description

Extract the SQL schema from `db-adapter-schema.md` into a standalone `plugins/dag/scripts/schema.sql` file. This file becomes the authoritative schema source for the DB adapter — referenced by the migration script and both adapter skills. Include all CREATE TABLE and CREATE INDEX statements from the design doc, plus a `_migrations` metadata table for version tracking.

## Acceptance criteria

1. `plugins/dag/scripts/schema.sql` exists with all CREATE TABLE statements: `relations`, `tags`, `docs`, `issues`, `issue_relations`, `doc_issues`, `doc_tags`, `issue_tags`
2. All CREATE INDEX statements from the design doc are included
3. A `_migrations` table is defined for schema version tracking: `id`, `version`, `applied_at`
4. All statements use `CREATE TABLE IF NOT EXISTS` / `CREATE INDEX IF NOT EXISTS` for idempotent application
5. The schema file is self-documenting with section headers and references back to the design doc
6. Original SQL in `db-adapter-schema.md` is unchanged (schema file is a refinement, not a replacement)

## Related docs

- Design doc: `.dag/docs/design/db-adapter-schema.md`
- Parent epic: DAG-28

---

*This ticket was created by opencode and reviewed by a human before publishing.*
