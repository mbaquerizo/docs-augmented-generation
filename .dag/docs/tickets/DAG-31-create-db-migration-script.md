---
id: DAG-31
issueType: task
status: open
tags:
  - dag
  - database
  - migration
  - script
parent: DAG-28
blockedBy: [DAG-30]
---

# Create DB migration script

## Description

Create `plugins/dag/scripts/db-migrate.sh` — a shell script that creates a SQLite database and applies the schema from `schema.sql`. Supports initial creation and future migrations via version tracking in the `_migrations` table. Designed to be run during setup (by the init script) or lazily on first use (by adapter skills).

## Acceptance criteria

1. `plugins/dag/scripts/db-migrate.sh` exists and is executable
2. Accepts a `--db` argument for the database file path (default `.dag/dag.db`)
3. Accepts a `--schema` argument for the schema file path (default `plugins/dag/scripts/schema.sql`)
4. Creates the database file if it doesn't exist
5. Applies `schema.sql` using `sqlite3` (idempotent — `CREATE TABLE IF NOT EXISTS`)
6. Records which version of the schema was applied in `_migrations` table
7. Exits with code 0 on success, non-zero on failure with error details
8. Prints a summary of what was applied (tables created, indices created)
9. Handles the case where the DB already exists and is up to date (no-op, exit 0)
10. Fails gracefully with a message if `sqlite3` is not installed

## Related docs

- SQL schema: `plugins/dag/scripts/schema.sql` (DAG-30)
- Design doc: `.dag/docs/design/db-adapter-schema.md`
- Parent epic: DAG-28

---

*This ticket was created by opencode and reviewed by a human before publishing.*
