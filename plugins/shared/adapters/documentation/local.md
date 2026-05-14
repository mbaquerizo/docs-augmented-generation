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
| `parent` | Appended to the output directory as a subdirectory: `{basePath}/{parent}` |
| `metadata` | Serialized as YAML frontmatter between `---` delimiters |

## Filename generation

Slugs are created from the title: lowercase, replace non-alphanumeric characters with hyphens, collapse consecutive hyphens, trim leading and trailing hyphens.

Filenames use a date prefix from `metadata.date` (ISO 8601 date part), or today's date if not set:

- **ADRs** (`type: adr`, no `docType`): `{YYYY-MM-DD}-{slug}.md`
- **Code explorations** (`type: adr`, `metadata.docType: "code-exploration"`): `{YYYY-MM-DD}-CE-{slug}.md`
- **Pitches** (`type: pitch`): `{slug}.md`

## Publish instructions

1. Determine output directory based on `type`: `adr` → `adrPath`, `pitch` → `pitchPath`
2. If `parent` is provided, append it: `{directory}/{parent}`
3. Generate filename from `title` and `type` (see above)
4. Construct full output path: `{directory}/{filename}`
5. Create parent directories if they don't exist: `mkdir -p "{directory}"`
6. Write the file in this format:
   ```yaml
   ---
   {metadata serialized as YAML}
   ---
   # {title}

   {body}
   ```
7. Return the output path.

## Examples

### ADR

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

Output: `./docs/adr/2026-05-14-use-postgresql-for-event-storage.md`

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

---

### Code exploration

Input:
```
type: adr
title: Explore audit logging module
body: "# Findings\n\n..."
metadata:
  docType: code-exploration
  date: 2026-05-14
```

Config `adrPath`: `./docs/adr`

Output: `./docs/adr/2026-05-14-CE-explore-audit-logging-module.md`

---

### With `parent`

ADR input with `parent: 2026-05-14-audit-logging`:

Output: `./docs/adr/2026-05-14-audit-logging/2026-05-14-use-postgresql-for-event-storage.md`

A code exploration published with the same `parent`:

Output: `./docs/adr/2026-05-14-audit-logging/2026-05-14-CE-explore-audit-logging-module.md`

Both documents are grouped under the same parent directory.
