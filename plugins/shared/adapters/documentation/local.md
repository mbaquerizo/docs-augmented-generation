# Local documentation adapter

Publishes ADRs, pitches, and explorations to the local filesystem.

## Config fields

Reads from `.docs-driven/config.json` under `adapters.documentation.config`:

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `adrPath` | no | `./docs/adr` | Destination directory for ADRs and code explorations |
| `pitchPath` | no | `./docs/pitches` | Destination directory for Shape Up pitches |

## Contract mapping

| Contract field | Destination |
|----------------|-------------|
| `type` | Resolves the output directory: `adr` → `adrPath`, `pitch` → `pitchPath` |
| `title` | File heading (`# {title}`) and slug for filename |
| `body` | Body content after frontmatter |
| `metadata` | Serialized as YAML frontmatter between `---` delimiters |

## Filename generation

Slugs are created from the title: lowercase, replace non-alphanumeric
characters with hyphens, collapse consecutive hyphens, trim leading
and trailing hyphens.

- **ADRs** (`type: adr`): scan `adrPath` for existing files matching
  `????-*.md`, find the highest sequential number, increment, zero-pad
  to 4 digits. Filename: `{NNNN}-{slug}.md`
- **Pitches** (`type: pitch`): no numbering. Filename: `{slug}.md`

## Publish instructions

1. Determine output directory based on `type`: `adr` → `adrPath`, `pitch` → `pitchPath`
2. Generate filename from `title` and `type` (see above)
3. Construct full output path: `{directory}/{filename}`
4. Create parent directories if they don't exist: `mkdir -p "{directory}"`
5. Write the file in this format:
   ```yaml
   ---
   {metadata serialized as YAML}
   ---
   # {title}

   {body}
   ```
6. Return the output path.

## Example

Input:
```
type: adr
title: Use PostgreSQL for event storage
body: "## Context\n\nWe need a durable event store..."
metadata:
  status: proposed
  date: 2026-05-14
  tags:
    - database
    - infrastructure
```

Config `adrPath`: `./docs/adr`
Existing files: `./docs/adr/0001-initial-schema.md`

Output: `./docs/adr/0002-use-postgresql-for-event-storage.md`

Written file:
```yaml
---
status: proposed
date: 2026-05-14
tags:
  - database
  - infrastructure
---
# Use PostgreSQL for event storage

## Context

We need a durable event store...
```
