# Dagger issue-tracking adapter

Publishes tickets to Dagger via its HTTP API or MCP server, including
issue-to-issue edges (`blocks`, `relates_to`, …), where they become
available to AI agents with full linked context.

## Config fields

Reads from `.dag/config.json` under `adapters.issue-tracking.config`:

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `destination` | yes | — | Dagger base URL (e.g. `https://api.dagger.dev`). Fail with a descriptive message if missing |
| `project` | yes | — | Dagger project: internal ID or slug. Dagger publish requires it — slugs resolve server-side once supported; use the ID until then. Fail with a descriptive message if missing |

The API key is read from the `DAGGER_API_KEY` environment variable —
never commit it to config. Fail with a descriptive message if it is
unset.

## Contract mapping

| Contract field | Destination |
|----------------|-------------|
| `type` | Dagger `type: "issue"` for all tickets |
| `title` | Dagger `title` verbatim |
| `body` | Dagger `body` verbatim (markdown) |
| `parent` | Grouping identifier only. Dagger-side hierarchy is expressed through `issue_relations` / `add_issue_relation` below, not this string |
| `children` | List of child ticket identifiers (epic only). Publish each child first, then link via `issue_relations` / `add_issue_relation` |

### Adapter-specific metadata fields

| Field | Required | Description |
|-------|----------|-------------|
| `issueType` | yes | Ticket archetype: `epic`, `story`, `task`, `bug`, `spike`. Dagger rejects `type: issue` without it (server-side validation) |
| `status` | no | Initial status. Defaults to `open` for issues |
| `tags` | no | Keyword list, passed through |
| `blockedBy` | no | Blocking ticket identifiers. Map to `issue_relations` (HTTP) or `add_issue_relation` calls (MCP) with relation `blocks`/`blocked_by` |
| `children` | no | Child ticket identifiers (epic only). Same mapping as `blockedBy` with the appropriate relation type |

## IDs

Dagger assigns identifiers — there is no local ID generation. Each
publish returns an internal `id` plus a human-readable `displayId`
(e.g. `DGR-42`). Retain the internal `id`: relationship references use
it, not the display ID. Report `displayId` and `url` to the user.

## Retrieval instructions

To look up an existing ticket by display ID (e.g. `DGR-42`):

- **HTTP path:** `GET {destination}/api/v1/agent/issues/:displayId`
  with `Authorization: Bearer <DAGGER_API_KEY>`. Returns the ticket
  with full linked context (parent, children, linked docs) as
  markdown. `GET {destination}/api/v1/issues?status=open` lists
  tickets with minimal metadata (no context assembly).
- **MCP path:** `get_issue(display_id)` for full context;
  `list_issues(status?)` for listings (omit `status` for all).

Dagger assigns all identifiers — capture the internal `id` (for
relationship references) and the `displayId` (the retrieval key) at
publish time. The display ID is what humans quote; the internal ID is
what relationships reference.

## Publish instructions

### HTTP path

1. Read `destination` and `project` from `.dag/config.json`; read
   `DAGGER_API_KEY` from the environment. Fail descriptively if any is
   missing.
2. Publish parents before children (see [Publish in dependency
   order](#publish-in-dependency-order)).
3. Send one call per ticket:
   ```
   POST {destination}/api/v1/publish
   Authorization: Bearer <DAGGER_API_KEY>
   Content-Type: application/json
   ```
   with `metadata.issue_relations[]` (`{target_id, relation_type}`)
   carrying the issue↔issue edges — doc↔issue links go in
   `metadata.relationships[]` (`{target_id, type}`, where `target_id`
   must be a **doc** internal ID). Both are created
   in the same transaction.
4. Capture `id`, `displayId`, and `url` from each response.
5. Handle errors per the [shared adapter conventions](adapter-conventions.md):

   | Situation | Behavior |
   |-----------|----------|
   | Missing `destination`, `project`, or `DAGGER_API_KEY` | Fail naming the missing field |
   | 401 | Auth failure — report, halt. Check the key, do not retry blindly |
   | 400 (referenced ID not found) | Report, halt. Caller must fix ordering |
   | 422 (invalid payload, e.g. missing `issueType`, unknown relation type) | Report validation errors, halt |
   | 500 | Retry with backoff, then report |

### MCP path

Use the `publish` tool when the Dagger MCP server is configured. This
requires MCP configured before the first publish — for bootstrapping a
fresh project, prefer the HTTP path.

1. Call `publish` with `type: "issue"`, `title`, `body`, `project_id`
   (from config `project`), and `metadata` (`issueType` required, plus
   `status`, `tags`).
   Doc↔issue links go in `metadata.relationships[]` in the same call
   (`target_id` must be a **doc** internal ID — look it up with
   `get_doc` first; there is no delete API for bogus links).
2. Then link issue↔issue edges with one `add_issue_relation` call per
   one-way relation (`source_id`, `target_id`, `relation_type` — each
   call writes both directions). The MCP `publish` tool does not accept
   `issue_relations` in a single call; the HTTP path does.
3. Reads use `get_issue` / `list_issues` where needed.

## Publish in dependency order

Publish epics before stories, blockers before blocked. Each publish
returns an internal `id`; reference those IDs — never display IDs — in
later `issue_relations` entries or `add_issue_relation` calls of the
same session. `issue_relations` targets must be **issue** IDs;
`relationships` targets must be **doc** IDs. The two arrays are not
interchangeable.

## Updates

Dagger supports status changes on existing issues (HTTP `PATCH`
endpoint / `update_issue_status` MCP tool). In-place body rewrites are
not supported — do not promise them. When updating status, look the
ticket up by display ID first.

## Example

Input:
```
type: ticket
title: Add user login endpoint
body: "## Acceptance criteria\n\n- User can log in with email and password..."
metadata:
  issueType: story
  status: open
  tags:
    - auth
    - backend
  blockedBy:
    - <id of "Design auth schema">
```

HTTP payload (assuming the blocker published first with `id: 5`):
```json
{
  "type": "issue",
  "title": "Add user login endpoint",
  "body": "## Acceptance criteria\n\n- User can log in with email and password...",
  "project_id": 1,
  "metadata": {
    "issueType": "story",
    "status": "open",
    "tags": ["auth", "backend"],
    "issueRelations": [
      {"targetId": 5, "relationType": "blocked_by"}
    ]
  }
}
```

MCP equivalent: `publish` with `metadata.relationships` omitted (no
doc links here), then `add_issue_relation(source_id: <new id>,
target_id: 5, relation_type: "blocked_by")`.

Response: `{"id": 6, "displayId": "DGR-42", "url": "{destination}/DGR-42"}`.
Report `DGR-42` and the URL to the user; retain `6` for further
relationship references.
