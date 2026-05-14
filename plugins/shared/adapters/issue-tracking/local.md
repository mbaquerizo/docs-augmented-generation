# Local issue-tracking adapter

Publishes and updates tickets on the local filesystem.

## Config fields

Reads from `.docs-driven/config.json` under `adapters.issue-tracking.config`:

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `project` | yes | — | Project key used as the ID prefix (e.g. `UI` produces IDs like `UI-42`) |
| `ticketPath` | no | `./docs/tickets` | Destination directory for tickets |

## Contract mapping

| Contract field | Destination |
|----------------|-------------|
| `type` | Unused (all types go to `ticketPath`). Reserved for future use |
| `title` | File heading (`# {title}`) and slug for filename |
| `body` | Body content after frontmatter |
| `metadata` | Serialized as YAML frontmatter between `---` delimiters. Adapter-specific fields listed below |

### Adapter-specific metadata fields

| Field | Required | Description |
|-------|----------|-------------|
| `issueType` | yes | Ticket archetype: `epic`, `story`, `task`, `bug`, `spike` |

## ID and filename generation

Slugs are created from the title: lowercase, replace non-alphanumeric
characters with hyphens, collapse consecutive hyphens, trim leading
and trailing hyphens.

1. Scan `ticketPath` for existing files matching `{project}-\d+-*.md`
2. Find the highest existing ID number, increment by 1 (start at 1 if none)
3. Set `id` in metadata to `{project}-{n}`
4. Generate filename: `{project}-{n}-{slug}.md`

## Publish instructions

1. Determine next ID (see above)
2. Generate filename from `project`, ID, and `title` slug
3. Construct full output path: `{ticketPath}/{filename}`
4. Create parent directories if they don't exist: `mkdir -p "{ticketPath}"`
5. Populate `id` in metadata
6. Write the file in this format:
   ```yaml
   ---
   {metadata serialized as YAML}
   ---
   # {title}

   {body}
   ```
7. Return the output path.

## Updates

When updating an existing ticket (e.g. status change), the skill passes the
known `filename` or the adapter looks it up by ID. The adapter rewrites the
file in place at the same path.

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
```

Config `project`: `UI`
Config `ticketPath`: `./docs/tickets`
Existing files: `./docs/tickets/UI-1-initial-setup.md`, `./docs/tickets/UI-2-design-system.md`

ID generated: 3
Filename: `UI-3-add-user-login-endpoint.md`

Output: `./docs/tickets/UI-3-add-user-login-endpoint.md`

Written file:
```yaml
---
id: UI-3
issueType: story
status: open
tags:
  - auth
  - backend
---
# Add user login endpoint

## Acceptance criteria

- User can log in with email and password...
```
