# Publish contract

Skills provide structured content. Adapters transform it for their destination
and return the published location.

## Input

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `type` | yes | string | One of: `adr`, `pitch`, `ticket`. Code explorations use `adr`. |
| `title` | yes | string | Display heading |
| `body` | yes | string (markdown) | Main content. Skills embed references inline as markdown links |
| `parent` | no | string | Grouping identifier for related documents. When set, the adapter nests the document under a subdirectory with this name (e.g. `{adrPath}/{parent}/{filename}`). Skills use this to group documents for a single feature. |
| `metadata` | no | object | Structured fields: `status`, `tags`, `date`, and adapter-specific fields documented per adapter |

## Output

The adapter returns the published location as a string:

- **Local adapters**: filesystem path relative to project root
- **Cloud adapters**: URL to the published page or issue

The skill uses this return value for display to the user and for passing to
downstream skills.

## Filename generation

Adapters generate filenames automatically. The skill does not control the
filename — the adapter owns document organization within its destination.

- **Documentation adapters**: generate filenames from `type`, `title`,
  and `metadata.date`. ADRs and code explorations get a date-prefixed
  filename; pitches are slug-only.
- **Issue-tracking adapters**: generate filenames from `project` prefix,
  auto-incrementing ID, and `title` slug
