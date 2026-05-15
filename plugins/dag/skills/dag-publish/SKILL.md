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

If the type is not `"local"`, load the matching adapter skill by name:
- documentation type `"jira"` → load `adapter-documentation-jira` skill
- issue-tracking type `"github"` → load `adapter-issue-tracking-github` skill

The adapter skill implements the contract from `contract.md` for that
specific tool.

## After publishing

Capture the returned path and report it to the user.
