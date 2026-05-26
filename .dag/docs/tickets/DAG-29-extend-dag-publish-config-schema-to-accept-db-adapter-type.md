---
id: DAG-29
issueType: task
status: open
tags:
  - dag
  - config
  - schema
  - adapter
parent: DAG-28
blockedBy: []
---

# Extend dag-publish config schema to accept `db` adapter type

## Description

Update `plugins/dag/skills/dag-publish/config.schema.json` to add `"db"` as a valid type for both documentation and issue-tracking adapters. Define DB-specific config fields: `dbPath` for the SQLite file location (default `.dag/dag.db`) and optionally `connectionString` for future PostgreSQL support.

When both documentation and issue-tracking use the `db` adapter, their `dbPath` values should point to the same SQLite file to enable cross-referencing via the `doc_issues` join table.

## Acceptance criteria

1. `"db"` is an accepted value for `adapters.documentation.type` and `adapters.issue-tracking.type`
2. `adapters.documentation.config.dbPath` is an optional string field, default `.dag/dag.db`
3. `adapters.issue-tracking.config.dbPath` is an optional string field, default `.dag/dag.db`
4. Existing `"local"` configuration continues to validate without errors
5. Example config `{"documentation": {"type": "db", "config": {}}, "issue-tracking": {"type": "db", "config": {}}}` passes validation

## Related docs

- Design doc: `.dag/docs/design/db-adapter-schema.md`
- Config schema: `plugins/dag/skills/dag-publish/config.schema.json`
- Parent epic: DAG-28

---

*This ticket was created by opencode and reviewed by a human before publishing.*
