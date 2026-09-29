# Dagger documentation adapter

Publishes ADRs, pitches, and explorations to Dagger via its HTTP API or
MCP server, where they become available to AI agents with full linked
context.

## Config fields

Reads from `.dag/config.json` under `adapters.documentation.config`:

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
| `type` | Dagger `type` verbatim, except code explorations (see below) |
| `title` | Dagger `title` verbatim |
| `body` | Dagger `body` verbatim (markdown) |
| `parent` | Grouping identifier only. It does not create structure in Dagger — cross-document grouping is expressed through relationship IDs returned by earlier publishes in the same session (see [Publish in dependency order](#publish-in-dependency-order)) |
| `metadata` | Dagger `metadata` object: `status`, `tags` pass through directly |

### Code explorations

Contract type `adr` with `metadata.docType: "code-exploration"` maps to
Dagger `type: "ce"`. Standard ADRs map to Dagger `type: "adr"`. Pitches
map to Dagger `type: "pitch"`. Unknown `docType` → warn, publish as
`adr`, per the [shared adapter conventions](adapter-conventions.md).

## Publish instructions

### HTTP path

1. Read `destination` and `project` from `.dag/config.json`; read
   `DAGGER_API_KEY` from the environment. Fail descriptively if any is
   missing.
2. Send the publish payload (see [Example](#example)):
   ```
   POST {destination}/api/v1/publish
   Authorization: Bearer <DAGGER_API_KEY>
   Content-Type: application/json
   ```
3. Capture `id`, `displayId`, and `url` from the response:
   ```json
   {
     "id": 128,
     "displayId": "DGR-5",
     "url": "https://api.dagger.dev/tickets/DGR-5"
   }
   ```
   Keep the internal `id` — later publishes in the same session
   reference it in `relationships`. Report `displayId` and `url` to the
   user.
4. Handle errors per the [shared adapter conventions](adapter-conventions.md):

   | Situation | Behavior |
   |-----------|----------|
   | Missing `destination`, `project`, or `DAGGER_API_KEY` | Fail naming the missing field |
   | 401 | Auth failure — report, halt. Check the key, do not retry blindly |
   | 400 (referenced ID not found) | Report, halt. Caller must fix ordering |
   | 422 (invalid payload) | Report validation errors, halt |
   | 500 | Retry with backoff, then report |

### MCP path

Use the `publish` tool when the Dagger MCP server is configured. This
requires MCP configured before the first publish — for bootstrapping a
fresh project, prefer the HTTP path.

1. Call `publish` with `type`, `title`, `body`, `project_id` (from
   config `project`), and
   optional `metadata` (`status`, `tags`).
2. Capture `id`, `displayId`, and `url` from the result exactly as in
   the HTTP path.
3. Reads use `get_doc` / `list_issues` where needed.

## Retrieval instructions

To look up an existing document by display ID (e.g. `DGR-36`):

- **HTTP path:** `GET {destination}/api/v1/agent/docs/:displayId`
  with `Authorization: Bearer <DAGGER_API_KEY>`. Returns the document
  as markdown.
- **MCP path:** `get_doc(display_id)`. Returns the same markdown.

To browse documents, use `list_issues` (MCP) and follow linked context,
or fetch a known ticket with `get_issue` and traverse its linked docs.
Dagger assigns all identifiers — capture `id` and `displayId` at
publish time; the display ID is the retrieval key.

## Publish in dependency order

Two different mechanisms — do not confuse them:

- **Doc↔doc grouping uses `parent_id`, not `relationships`.**
  To group documents from one session (e.g. an ADR plus its code
  exploration), publish a shell parent doc first, then publish each
  child with `parent_id` set to the shell's returned internal `id`.
  `parent_id` can only be set at publish time.
- **`metadata.relationships[]` targets issues only.** Each entry
  (`{target_id, type}` with `type` one of `motivates`, `implements`,
  `references`) creates a doc↔issue cross-reference row, where
  `target_id` must be an **issue** internal ID. Passing a doc ID
  writes a bogus link — there is no delete API to undo it. When in
  doubt, look the target up with `get_issue` first.

## Example

Input:
```
type: adr
title: Use PostgreSQL for event storage
body: "## Context\n\nWe need a durable event store..."
metadata:
  status: proposed
  tags:
    - database
    - infrastructure
```

HTTP payload:
```json
{
  "type": "adr",
  "title": "Use PostgreSQL for event storage",
  "body": "## Context\n\nWe need a durable event store...",
  "project_id": 1,
  "metadata": {
    "status": "proposed",
    "tags": ["database", "infrastructure"]
  }
}
```

Response: `{"id": 128, "displayId": "DGR-5", "url": "{destination}/DGR-5"}`.
Report `DGR-5` and the URL to the user; retain `128` for relationship
references.
