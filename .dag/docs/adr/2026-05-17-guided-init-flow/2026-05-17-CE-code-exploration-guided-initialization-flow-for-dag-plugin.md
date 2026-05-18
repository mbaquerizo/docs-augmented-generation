---
status: proposed
date: 2026-05-17
tags:
  - dag
  - onboarding
  - developer-experience
docType: code-exploration
---

# Code exploration: Guided initialization flow for DAG plugin

## Summary

The DAG plugin requires a `.dag/config.json` with a specific JSON shape to operate, but offers no onboarding — users hand-edit the file. The codebase uses `local` adapters reading paths like `.dag/docs/adr`, `.dag/docs/pitches`, and `.dag/docs/tickets`. No scripts directory exists in the plugin; no shell scripts exist anywhere. The schema supports only `local` adapter type. All path defaults are configurable per adapter documentation.

## Relevant files

| File | Role |
|------|------|
| `.dag/config.json` | Current working config — reference for default paths |
| `plugins/dag/skills/dag-publish/config.schema.json` | JSON Schema defining exact config shape |
| `plugins/dag/skills/dag-publish/contract.md` | Publish contract: type, title, body, parent, metadata |
| `plugins/dag/skills/dag-publish/documentation-local.md` | Local doc adapter — publishes ADRs/explorations/pitches |
| `plugins/dag/skills/dag-publish/issue-tracking-local.md` | Local issue adapter — publishes tickets with auto-increment IDs |
| `plugins/dag/skills/dag-publish/adapter-conventions.md` | Slug generation, parent grouping, timestamp format |
| `plugins/dag/skills/dag-publish/SKILL.md` | Reads `.dag/config.json`, resolves adapter type, delegates |
| `.dag/docs/pitches/2026-05-16-guided-initialization-flow-for-dag-plugin.md` | The pitch — authoritative design doc for this work |

## Current architecture

Config flows: Skills call `dag-publish` → reads `.dag/config.json` → inspects `adapters.{documentation,issue-tracking}.type` → delegates to `local` adapter (or loads cloud adapter skill by name).

Local adapters write files to configurable paths with auto-generated filenames (date-prefixed for ADRs, slug-only for pitches, `{PROJECT}-{N}-{slug}` for tickets). Parent field nests ADRs under subdirectories. All paths are relative to project root.

## Config structure

```json
{
  "adapters": {
    "documentation": {
      "type": "local",
      "config": {
        "adrPath": "./.dag/docs/adr",
        "pitchPath": "./.dag/docs/pitches"
      }
    },
    "issue-tracking": {
      "type": "local",
      "config": {
        "project": "DAG",
        "ticketPath": "./.dag/docs/tickets"
      }
    }
  }
}
```

Required: `adapters`, `documentation.type`, `issue-tracking.type`, `issue-tracking.config.project`. All other config fields are optional with adapter-internal defaults (default `project` for local adapter is set by the init script, not by the adapter).

## Patterns and conventions

- Paths are relative, no trailing slashes
- Project key is short uppercase string (ticket ID prefix), ≤10 chars
- Filenames follow: `{date}-{slug}.md` (ADR), `{slug}.md` (pitch), `{PROJECT}-{N}-{slug}.md` (ticket)
- Parent grouping: `{YYYY-MM-DD}-{feature-slug}` subdirectory
- No existing shell scripts — fresh pattern

## Constraints

- Bash 3.2+ (macOS default) — no associative arrays, no `[[ ]]`, no arrays
- POSIX-safe constructs, `read -p` for prompts
- No external deps (no `jq`, `yq`, `node`, `python`)
- Idempotent writes via `mktemp` + atomic `mv`
- Automatic `.bak` on overwrite

## Risks

1. **No JSON validation** — without `jq`, user input containing quotes/backslashes could break JSON output. Sanitize `project` field (strip spaces, uppercase, ≤10 chars).
2. **`mktemp` portability** — macOS requires template argument. Use `mktemp -t dag-init.XXXX` for cross-platform.
3. **`read -p` portability** — works in bash 3.2 on macOS but not in POSIX `sh`. Script must use `#!/usr/bin/env bash`.
4. **Documentation drift** — references to `.planning/` paths exist in `AGENTS.md` and should be updated to match the `.dag/docs/` convention.
