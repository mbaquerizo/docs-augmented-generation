---
id: DAG-28
issueType: epic
status: open
tags:
  - dag
  - database
  - adapter
  - db
children: [DAG-29, DAG-30, DAG-31, DAG-32, DAG-33, DAG-34]
---

# DB adapter for dag-publish

## Description

Add a new `db` adapter type to dag-publish alongside the existing `local` adapter. The DB adapter stores documentation (ADRs, code explorations, pitches) and issues (epics, stories, tasks, bugs, spikes) in a SQLite database with typed relationships, indexed queries, and tag-based classification. Includes config schema, SQL schema file, migration script, init script update, and two adapter skill files (documentation and issue-tracking).

## Scope

- **In scope**: Config schema extension for `"db"` type; standalone SQL schema file; DB migration script; init script update offering `db` as adapter choice; documentation-db adapter skill; issue-tracking-db adapter skill; SQLite as initial database backend
- **Out of scope**: PostgreSQL adapter; team deployment tooling; UI/dashboard; `group_id` sibling grouping (deferred to v2); replacing the `local` adapter; migration from `local` to `db`

## Related docs

- Design doc: `.dag/docs/design/db-adapter-schema.md`
- Config schema: `plugins/dag/skills/dag-publish/config.schema.json`
- Contract: `plugins/dag/skills/dag-publish/contract.md`
- Adapter conventions: `plugins/dag/skills/dag-publish/adapter-conventions.md`

## Stories

- DAG-29: Extend dag-publish config schema to accept `db` adapter type
- DAG-30: Create SQL schema file for DB adapter
- DAG-31: Create DB migration script
- DAG-32: Update dag-init.sh to support `db` adapter
- DAG-33: Create documentation-db adapter for DB-backed documentation storage
- DAG-34: Create issue-tracking-db adapter for DB-backed ticket storage
