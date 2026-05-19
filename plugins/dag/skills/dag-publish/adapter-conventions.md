# Adapter conventions

Shared conventions for all dag-publish adapters (local, cloud, database, etc.).
Each adapter doc references these rules and documents how it maps them to its
specific storage mechanism.

---

## 1. Slug generation

A slug is a URL-safe, human-readable identifier derived from the title.

**Rules:**
- Lowercase the title
- Replace non-alphanumeric characters (excluding hyphens) with a single hyphen
- Collapse consecutive hyphens into one
- Trim leading and trailing hyphens

**Collision handling:** Adapter-defined. Local adapters append disambiguation
suffixes; cloud adapters may rely on platform uniqueness guarantees.

---

## 2. Timestamp format

Convention: ISO 8601 date part `YYYY-MM-DD`.

- Adapters MAY use the date as a prefix, sort key, tag, or ignore it
- When `metadata.date` is absent, adapters fall back to the current date
- The date represents document creation, not last modification

---

## 3. Parent grouping

The `parent` field groups related documents under a shared scope.

- `parent` is a string identifier chosen by the caller
- Adapters map `parent` to their native grouping mechanism: directory, tag,
  folder, collection, namespace, prefix
- `parent` does not participate in identifier generation — a document's ID or
  filename is unique regardless of parent
- A document's parent MAY be used as a retrieval filter (e.g. "all docs in
  group X")

---

## 4. docType field

Extends `type: adr` for sub-types. Currently valid:

| docType | Behavior |
|---------|----------|
| default (absent) | Standard naming |
| `code-exploration` | Distinguished from standard ADRs (e.g. via prefix in identifier) |

- Unknown docType → warn, proceed with default naming
- Adapters MAY define adapter-specific docType values in their own
  documentation

---

## 5. Defaults vs explicit config

Config fields follow a consistent pattern across adapters:

- **Required fields** — runtime-critical (e.g. project key). Adapter must fail
  with a descriptive message if missing.
- **Optional fields** — have sensible defaults for common cases. Adapter
  applies the default silently when the field is absent.
- Adapters document both categories in a config table with field name,
  required/optional indicator, default value (if any), and description.

---

## 6. Error handling

| Situation | Behavior |
|-----------|----------|
| Required config missing | Fail with message naming the missing field |
| Invalid field value | Warn, apply safe fallback if possible, otherwise fail |
| Unknown docType | Warn, use default (standard ADR naming) |
| Target location unreachable | Fail with details from the storage layer |
| Metadata field mismatch | Warn, skip unrecognized fields |

Adapters must never silently drop or corrupt document content.

---

## 7. Naming

Naming produces a structured identifier for each document type. The format
varies by type but follows consistent patterns.

### ADR (`type: adr`, no `docType`)

```
{date}-{slug}
```

Example: `2026-05-14-use-postgresql-for-event-storage`

Chronological ordering, human-readable.

### Code exploration (`type: adr`, `docType: code-exploration`)

```
{date}-CE-{slug}
```

Example: `2026-05-14-CE-explore-audit-logging-module`

Differentiates explorations from ADRs in the same stream.

### Pitch (`type: pitch`)

```
{slug}
```

Example: `two-speed-process-for-billing-features`

Pitches exist outside a timeline — no date prefix.

---

## 8. Relationship metadata

Tickets reference each other through metadata fields that express hierarchy,
blocking, and grouping. These fields are cross-adapter conventions —
documentation and issue-tracking adapters should each map them to their
native storage mechanism.

| Field | Type | Description |
|-------|------|-------------|
| `parent` | string | Parent epic ID or grouping identifier. Maps to directory nesting (docs) or YAML frontmatter (issue-tracking). |
| `blockedBy` | list of strings | Ticket IDs that this ticket depends on. Issue-tracking adapters should serialize as YAML list; cloud adapters should link to the blocking issues. |
| `children` | list of strings | Child ticket IDs (epic field). Currently defined on epics for reverse lookup. |

All three fields are optional. Adapters must not fail when absent.

### Adapter-specific mapping

| Adapter type | parent | blockedBy | children |
|--------------|--------|-----------|----------|
| Local issue-tracking | YAML frontmatter | YAML frontmatter | YAML frontmatter |
| Local documentation | Directory nesting | Unused | Unused |
| Cloud (future) | Issue link or label | Issue dependency link | Issue dependency link |


