# Issue-tracking DB adapter

Publishes and updates tickets in a SQLite database with typed relations and tag-based classification.

## Config fields

Reads from `.dag/config.json` under `adapters.issue-tracking.config`:

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `project` | yes | — | Issue-tracking project identifier. Used as the ticket ID prefix (e.g. `UI` produces IDs like `UI-42`) |
| `dbPath` | no | `.dag/dag.db` | Path to the SQLite database file. When this matches the documentation adapter's `dbPath`, doc-to-issue cross-references via the `doc_issues` table are available. |

## Contract mapping

| Contract field | Destination |
|----------------|-------------|
| `type` | Unused (all types go to `issues` table). Reserved for future use. |
| `title` | `issues.title` |
| `body` | `issues.body` |
| `parent` | `issues.parent_id` — resolved by project-prefixed ticket ID (e.g. `"UI-3"` maps to the issue with that identifier) |
| `metadata.issueType` | `issues.type` — one of `epic`, `story`, `task`, `bug`, `spike` |
| `metadata.status` | `issues.status` — defaults to `"open"` |
| `metadata.tags` | Inserted into `tags` table; assignments stored in `issue_tags` |

### Adapter-specific metadata fields

| Field | Description |
|-------|-------------|
| `blockedBy` | List of blocking ticket IDs. Stored as `issue_relations` edges with `"is_blocked_by"` relation. |
| `children` | List of child ticket IDs (epic only). Stored as `issue_relations` edges with `"relates_to"` relation. |

## Initialization

On first call, initialize the database schema if it does not exist:

1. Run `bash plugins/dag/scripts/db-migrate.sh --db "{dbPath}"`
2. Seed the `relations` table with initial types:
   ```sql
   INSERT OR IGNORE INTO relations (name) VALUES ('blocks');
   INSERT OR IGNORE INTO relations (name) VALUES ('is_blocked_by');
   INSERT OR IGNORE INTO relations (name) VALUES ('duplicates');
   INSERT OR IGNORE INTO relations (name) VALUES ('is_duplicated_by');
   INSERT OR IGNORE INTO relations (name) VALUES ('relates_to');
   INSERT OR IGNORE INTO relations (name) VALUES ('causes');
   INSERT OR IGNORE INTO relations (name) VALUES ('is_caused_by');
   ```

## ID generation

1. Determine the next ticket number:
   ```sql
   SELECT COALESCE(MAX(CAST(SUBSTR(id, INSTR(id, '-') + 1) AS INTEGER)), 0) + 1
   FROM issues WHERE id LIKE '{project}-%';
   ```
2. Set the identifier: `{project}-{n}` (e.g. `UI-3`)

## Publish instructions

1. Read `project` and `dbPath` from `adapters.issue-tracking.config`
2. Initialize the database and seed relations (see above)
3. Determine the next ticket ID (see above)
4. Set `issues.status` from `metadata.status` (default `"open"`)
5. If `parent` is provided, resolve the parent issue's `id`:
   ```sql
   SELECT id FROM issues WHERE identifier = '{parent}';
   ```
6. Insert the issue:
   ```sql
   INSERT INTO issues (type, title, body, status, parent_id)
   VALUES ('{issueType}', '{title}', '{body}', '{status}', {parent_id_or_NULL});
   ```
7. Record the new `id` as `{project}-{n}`
8. If `metadata.blockedBy` is provided, create edges:
   ```sql
   INSERT INTO issue_relations (source_issue_id, relation_id, target_issue_id)
   VALUES ({new_id}, (SELECT id FROM relations WHERE name = 'is_blocked_by'), {blocking_id});
   ```
   For each blocking ticket ID, resolve the issue `id` first.
9. If `metadata.children` is provided (epic only), create edges:
   ```sql
   INSERT INTO issue_relations (source_issue_id, relation_id, target_issue_id)
   VALUES ({new_id}, (SELECT id FROM relations WHERE name = 'relates_to'), {child_id});
   ```
10. If `metadata.tags` is provided, ensure each tag exists in `tags` (insert if new), then insert into `issue_tags`:
    ```sql
    INSERT OR IGNORE INTO tags (name) VALUES ('{tag}');
    INSERT INTO issue_tags (issue_id, tag_id)
    VALUES ({issue_id}, (SELECT id FROM tags WHERE name = '{tag}'));
    ```
11. Return the published location as `<db>://issues/{project}-{n}>`

## Retrieval instructions

To look up an existing ticket by ID (e.g. `UI-3`):

```sql
SELECT * FROM issues WHERE id = 'UI-3';
```

Alternatively, search by project prefix:

```sql
SELECT * FROM issues WHERE id LIKE 'UI-%' ORDER BY id;
```

## Updates

When updating an existing ticket (e.g. status change), pass the known `<db>://issues/{id}>` location or look it up by ID. Update the row in place:

```sql
UPDATE issues SET status = '{status}', updated_at = datetime('now') WHERE id = '{id}';
```

Tag and relation changes can be applied by clearing and re-inserting.

## Example

Input:
```
type: ticket
title: Add user login endpoint
body: "## Acceptance criteria\n\n- User can log in with email and password..."
metadata:
  issueType: story
  status: open
  parent: UI-1
  tags:
    - auth
    - backend
  blockedBy: [UI-2]
```

Config `project`: `UI`
Config `dbPath`: `.dag/dag.db`

SQL executed:
```sql
INSERT INTO issues (type, title, body, status, parent_id)
VALUES ('story', 'Add user login endpoint', '## Acceptance criteria...', 'open', {parent_id});
INSERT INTO issue_relations (source_issue_id, relation_id, target_issue_id)
VALUES ({new_id}, (SELECT id FROM relations WHERE name = 'is_blocked_by'), {UI-2_id});
INSERT INTO issue_tags (issue_id, tag_id)
VALUES ({new_id}, (SELECT id FROM tags WHERE name = 'auth'));
```

Output: `<db>://issues/UI-3>`
