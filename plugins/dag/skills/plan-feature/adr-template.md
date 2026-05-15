# ADR template

An Architecture Decision Record documents a significant architectural decision and its context. This reference defines the standard sections.

## Frontmatter

| Field | Required | Description |
|-------|----------|-------------|
| `status` | yes | One of: `proposed`, `accepted`, `deprecated`, `superseded` |
| `date` | yes | Date the ADR was published or last updated (ISO 8601) |
| `tags` | no | List of labels for categorization |

The documentation adapter generates the filename (sequential numbering + slug). The `type` field in the publish contract is set to `adr`.

## Sections

### Context

Describe the forces at play — the technical, business, and organizational context that makes this decision necessary. What problem are we solving, and why now?

**Required**: yes

---

### Options Considered

List the viable approaches that were evaluated. For each option, describe:

- What it is
- Key tradeoffs (complexity, impact, risk, pattern alignment)
- Why it was or wasn't chosen

A comparison table is recommended:

| Option | Complexity | Impact | Risk | Notes |
|--------|------------|--------|------|-------|
| Option A | ... | ... | ... | ... |
| Option B | ... | ... | ... | ... |

**Required**: yes

---

### Decision

State the chosen option and the rationale. Include:

- What was decided
- Why this option over the others
- Any conditions or caveats

**Required**: yes

---

### Consequences

Describe what becomes easier, harder, or different as a result:

- **Positive**: What improves, what becomes possible
- **Negative**: What degrades, what becomes more complex
- **Neutral**: What changes but doesn't improve or degrade

Also note any follow-up work or future ADRs this decision may trigger.

**Required**: yes

---

## Example

```markdown
---
status: proposed
date: 2026-05-14
tags:
  - database
  - infrastructure
---

# Use PostgreSQL for event storage

## Context

We need a durable event store for the new audit logging feature.
The system currently uses SQLite for local development and MySQL
in production. Audit events must be queryable, append-only, and
retained for 90 days.

## Options Considered

| Option | Complexity | Impact | Risk | Notes |
|--------|------------|--------|------|-------|
| SQLite | Low | Local-only, won't scale | Cannot support concurrent writers | Avoid |
| MySQL | Medium | Existing infrastructure | Schema migration effort | Familiar but suboptimal for append-only |
| PostgreSQL | Medium | New dependency | Team learning curve | Best feature match, strong community |

## Decision

Use PostgreSQL. Its append-only optimizations, JSONB support for
event payloads, and built-in partitioning for retention policies
align best with the requirements. The team will need time to ramp
up, but the long-term maintenance savings outweigh this.

## Consequences

Positive: Native partitioning for TTL-based retention, JSONB for
flexible event schemas, strong consistency guarantees.

Negative: Operations team needs to manage a new database service,
existing backup/restore tooling needs updates.

Neutral: Migration from MySQL will require a data export step
during the cutover.
```
