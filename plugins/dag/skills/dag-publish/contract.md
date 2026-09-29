# Publish contract

Skills provide structured content. Adapters transform it for their destination and return the published location.

## Input

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `type` | yes | string | One of: `adr`, `pitch`, `ticket`. Code explorations use `adr`. |
| `title` | yes | string | Display heading |
| `body` | yes | string (markdown) | Main content. Skills embed references inline as markdown links |
| `parent` | no | string | Grouping identifier for related documents. Adapters map it to their native grouping mechanism (file adapters: subdirectory; service adapters: native links or hierarchy). See the adapter's doc and the [shared adapter conventions](adapter-conventions.md). Skills use this to group documents for a single feature. |
| `metadata` | no | object | Structured fields: `status`, `tags`, `date`, and adapter-specific fields documented per adapter |

## Output

The adapter returns the published location:

- **File adapters**: filesystem path relative to project root
- **Service adapters**: assigned IDs and URL as defined in the adapter's doc

The skill uses this return value for display to the user and for passing to downstream skills.

## Identifier generation

Adapters assign identifiers automatically. The skill does not control the identifier — the adapter owns document organization within its destination.

- **Documentation adapters**: derive identity from `type`, `title`, and `metadata.date`. File adapters generate date-prefixed filenames (ADRs, code explorations) or slug-only filenames (pitches); service adapters assign IDs server-side.
- **Issue-tracking adapters**: file adapters generate filenames from `project` prefix, auto-incrementing ID, and `title` slug; service adapters assign IDs server-side.
