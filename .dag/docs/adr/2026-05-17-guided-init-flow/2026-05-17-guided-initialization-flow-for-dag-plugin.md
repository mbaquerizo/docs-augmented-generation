---
status: proposed
date: 2026-05-17
tags:
  - dag
  - onboarding
  - developer-experience
---

# ADR: Guided initialization flow for DAG plugin

## Context

Installing the DAG plugin requires users to manually create `.dag/config.json` with the correct structure. No guided setup, no defaults, no validation. First experience is "go read the README and hand-edit JSON." Friction scales with each new adapter type.

The team shaped a pitch (see [pitch](../2026-05-16-guided-initialization-flow-for-dag-plugin.md)) scoping this as a bounded 1-2 week effort: an interactive bash script that scaffolds config and directory structure. A code exploration was conducted (see [CE](./2026-05-17-CE-code-exploration-guided-initialization-flow-for-dag-plugin.md)) to understand the config schema, adapter conventions, and platform constraints.

Key findings from code exploration:
- Config schema requires `adapters.documentation.type`, `adapters.issue-tracking.type`, and `adapters.issue-tracking.config.project`
- Only `local` adapter type exists in v1
- No shell scripts exist in the plugin — this is a new file type
- Must target bash 3.2+ (macOS) with no external dependencies

## Options Considered

| Option | Complexity | Impact | Risk | Notes |
|--------|------------|--------|------|-------|
| A: Pure bash script | Low — single file, ~100 lines | Terminal only, tool-agnostic | Minimal — no existing code changed | Prescribed by pitch |
| B: Bash script + slash command | Medium — script + command definition | AI tools can invoke directly | Low — script is same either way | Easier onboarding in Claude Code sessions |
| C: AI-native skill only | Low — markdown only | Only works inside AI tools | Medium — partial write risk, not idempotent | Violates tool-agnostic constraint |

## Decision

**Choose Option A** — a pure bash script at `plugins/dag/scripts/dag-init.sh`, built as a standalone interactive scaffolder.

Rationale:
- Matches the pitched spec exactly — no AI orchestration, no slash command
- Tool-agnostic — works identically in Claude Code, OpenCode, or bare terminal
- Lowest risk profile — no existing code changes, no breaking changes

The script is structured with Option B in mind (future slash command wrapper):
- Exit codes: 0 (success), 1 (user cancelled), 2 (error)
- Output to stdout, diagnostics to stderr
- Modular functions for each step — easy to invoke programmatically

Default paths follow existing repo convention: `./.dag/docs/adr`, `./.dag/docs/pitches`, `./.dag/docs/tickets`.

### Universal config fields, adapter-specific meaning

Config field names (`project`, `ticketPath`, `adrPath`, `pitchPath`) are universal. Their interpretation depends on the adapter type at runtime — `ticketPath` is a local directory for the `local` adapter, a base URL for a future `jira` adapter. Each adapter's `case` branch owns its prompt text, validation, JSON generation, and post-write hook. No inheritance or plugin system — just `case` dispatch on the adapter type in each function.

### No auth in config

`.dag/config.json` is committable. Authentication credentials (API tokens, OAuth) belong in env vars, MCP server config, or adapter-specific credential stores — never in the config file.

### Adapter dispatch scope

All adapter-specific behavior is scoped to `case` branches in three functions:
- `prompt_adapter_config` — prompts, validation, defaults per adapter
- `generate_config_json` — JSON shape per adapter (same field keys, different values)
- `post_write` — post-write side effects (local adapter creates directories + .gitkeep)

Adding a new adapter = adding a `case` branch to each function. No structural changes needed.

### Project field

- Local adapter defaults to `PROJ` (neutral, ≤10 chars)
- Future cloud adapters define their own project key prompts or API-driven defaults

## Consequences

**Positive:**
- First-time users get guided setup with sensible defaults and validation
- Existing config is safely backed up before overwrite
- `.gitkeep` files ensure scaffolding directories are tracked in git
- Atomic writes prevent partial/corrupt config files
- `case`-based adapter dispatch makes adding new adapters a mechanical change (add a branch) with no structural refactoring
- Config is committable — no auth secrets leaked into version control

**Negative:**
- Interactive only — no headless/CI mode in v1
- No JSON validation of user input (no `jq` dependency)
- Validates character limits on project key but can't enforce schema compliance

**Neutral:**
- Introduces `plugins/dag/scripts/` directory — new file type in the plugin
- `mktemp` invocation differs slightly between macOS and Linux (handled via `-t` flag)
- Documentation referencing `.planning/` paths should be updated to match `.dag/docs/` convention
- Universal field names mean `ticketPath` means "directory on disk" for local and "URL" for Jira — the adapter owns the interpretation
