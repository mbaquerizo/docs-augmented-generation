# Publish contract

Skills provide structured content. Adapters transform it for their destination
and return the published location.

## Input

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `type` | yes | string | One of: `adr`, `pitch`, `ticket` |
| `title` | yes | string | Display heading |
| `body` | yes | string (markdown) | Main content. Skills embed references inline as markdown links |
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

- **Documentation adapters**: generate filenames from `type` and `title`
  (sequential numbering for ADRs, slug-only for pitches)
- **Issue-tracking adapters**: generate filenames from `project` prefix,
  auto-incrementing ID, and `title` slug
