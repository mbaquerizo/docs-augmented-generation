---
id: DAG-32
issueType: task
status: open
tags:
  - dag
  - init
  - script
  - adapter
parent: DAG-28
blockedBy: [DAG-29]
---

# Update dag-init.sh to support `db` adapter

## Description

Extend `plugins/dag/scripts/dag-init.sh` to offer `"db (SQLite database)"` as a selectable adapter type alongside the existing `"local (writes to filesystem)"` option. When `db` is selected, prompt once for a database file path and set both `adapters.documentation.config.dbPath` and `adapters.issue-tracking.config.dbPath` to that same value. Optionally run the migration script after config is written.

## Acceptance criteria

1. The adapter selection screen offers `"db (SQLite database)"` as a second option
2. When `db` is selected, prompts once for a database file path (default `.dag/dag.db`) and sets both `adapters.documentation.config.dbPath` and `adapters.issue-tracking.config.dbPath` to that value
3. Generates `config.json` with `"type": "db"` and `"config": {"dbPath": "..."}` for both adapters
4. After config is written, optionally runs `db-migrate.sh --db <path>` to initialize the database
5. Existing `local` adapter flow is completely unchanged
6. All previous init features (backup, project prefix, directory creation) continue to work when `local` is selected

## Related docs

- Design doc: `.dag/docs/design/db-adapter-schema.md`
- Init script: `plugins/dag/scripts/dag-init.sh`
- Migration script: `plugins/dag/scripts/db-migrate.sh` (DAG-31)
- Parent epic: DAG-28

---

*This ticket was created by opencode and reviewed by a human before publishing.*
