---
name: dag-publish
description: Publish ADRs, pitches, and tickets to the project's configured destination. Reads .dag/config.json, resolves the adapter type, and delegates to the matching implementation.
---

# DAG Publish

When a skill needs to publish or update documents, call this skill.
It reads the project's `.dag/config.json`, resolves the configured
adapter type, and provides step-by-step publishing instructions.

## Contract

The publish contract is defined in `contract.md`. All adapters accept
the same fields (`type`, `title`, `body`, `parent`, `metadata`) and
return the published location.

## Resolution

Read `.dag/config.json`:

```json
{
  "adapters": {
    "documentation": { "type": "local", "config": { ... } },
    "issue-tracking": { "type": "local", "config": { ... } }
  }
}
```

For each adapter category, check the `type` field:

### Built-in: type is `"local"`

Follow the instructions in `documentation-local.md` (this directory)
for publishing ADRs, code explorations, and pitches.

Follow `issue-tracking-local.md` (this directory) for publishing and
updating tickets.

### External adapters (any other type)

If the type is not `"local"`, resolve the adapter doc by interpolation:
`documentation-{type}.md` (this directory) for ADRs, code explorations,
and pitches; `issue-tracking-{type}.md` for tickets — with `{type}`
replaced by the configured adapter type (e.g. type `"dagger"` →
`documentation-dagger.md`). The adapter doc implements the contract
from `contract.md` for that specific destination. If no matching doc
exists, fail naming the expected filename.

## After publishing

Capture the returned location and report it to the user (a filesystem
path for file adapters; IDs and URL for service adapters).
