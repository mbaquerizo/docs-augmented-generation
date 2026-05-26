# Documentation DB adapter

Publishes ADRs, code explorations, and pitches to a SQLite database.

## Config fields

Reads from `.dag/config.json` under `adapters.documentation.config`:

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `dbPath` | no | `.dag/dag.db` | Path to the SQLite database file. When this matches the issue-tracking adapter's `dbPath`, doc-to-issue cross-references via the `doc_issues` table are available. |

## Contract mapping

| Contract field | Destination |
|----------------|-------------|
| `type` | `docs.type` — maps to the doc type column (e.g. `"adr"`, `"pitch"`) |
| `title` | `docs.title` — the document title |
| `body` | `docs.body` — the markdown body content |
| `parent` | `docs.parent_id` — references the parent doc by its `id` |
| `metadata.status` | `docs.status` — publication status (default `"proposed"`) |
| `metadata.docType` | Overrides `docs.type` when `type` is `"adr"` (e.g. `"code-exploration"`) |
| `metadata.tags` | Inserted into `tags` table; assignments stored in `doc_tags` |

## Publish instructions

1. Read `dbPath` from `adapters.documentation.config` (default `.dag/dag.db`)
2. If the database file does not exist, initialize the schema by running:
   - `bash plugins/dag/scripts/db-migrate.sh --db "{dbPath}"`
   - Or apply `schema.sql` directly: `sqlite3 "{dbPath}" < plugins/dag/scripts/schema.sql`
3. Determine `docs.type`:
   - If `docType` is present in `metadata`, use that value
   - Otherwise use the contract `type` field (e.g. `"adr"`, `"pitch"`)
4. If `parent` is provided, resolve or create the parent doc:
   - Look up existing doc by matching `title` or explicit ID in `parent`
   - Use the resolved `id` as `parent_id`
5. Insert the doc:
   ```sql
   INSERT INTO docs (type, title, body, status, parent_id)
   VALUES ('{type}', '{title}', '{body}', '{status}', {parent_id_or_NULL});
   ```
6. Record the new doc's `id` from `last_insert_rowid()`
7. If `metadata.tags` is provided, ensure each tag exists in `tags` (insert if new), then insert into `doc_tags`:
   ```sql
   INSERT OR IGNORE INTO tags (name) VALUES ('{tag}');
   INSERT INTO doc_tags (doc_id, tag_id) VALUES ({doc_id}, (SELECT id FROM tags WHERE name = '{tag}'));
   ```
8. Return the published location as `<db>://docs/<id>`

## Retrieval instructions

To look up an existing document:

1. Open the database at `dbPath`
2. Query by doc `id`:
   ```sql
   SELECT * FROM docs WHERE id = {id};
   ```
3. To find by type and slug:
   ```sql
   SELECT * FROM docs WHERE type = '{type}' AND title LIKE '%{slug}%';
   ```

## Updates

When updating an existing document (e.g. status change), the skill passes the known `<db>://docs/<id>` location or looks it up by ID. Update the row in place:

```sql
UPDATE docs SET status = '{status}', updated_at = datetime('now') WHERE id = {id};
```

## Examples

### ADR

Input:
```
type: adr
title: Use PostgreSQL for event storage
body: "## Context\n\nWe need a durable event store..."
metadata:
  status: proposed
  date: 2026-05-24
  tags:
    - database
    - infrastructure
```

Config `dbPath`: `.dag/dag.db`

SQL executed:
```sql
INSERT INTO docs (type, title, body, status)
VALUES ('adr', 'Use PostgreSQL for event storage', '## Context...', 'proposed');
```

Output: `<db>://docs/1>`

### Code exploration

Input:
```
type: adr
title: Explore audit logging module
body: "# Findings\n\n..."
metadata:
  docType: code-exploration
  date: 2026-05-24
```

Output: `<db>://docs/2>` (type stored as `"code-exploration"`)

### With `parent`

Input with `parent: "Use PostgreSQL for event storage"`:

```sql
-- Resolve parent id
SELECT id FROM docs WHERE title = 'Use PostgreSQL for event storage';
-- Insert with parent_id
INSERT INTO docs (type, title, body, parent_id)
VALUES ('adr', 'Migration strategy', '...', {parent_id});
```

Output: `<db>://docs/3>`
