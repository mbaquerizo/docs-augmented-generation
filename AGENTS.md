# AGENTS.md — Docs Augmented Generation (DAG)

## What this is

A monorepo of **Claude Code / OpenCode plugins** implementing the DAG workflow. All content is markdown-based skill/agent definitions — **no code, no build, no package.json, no tests**.

### The DAG idea

DAG parallels RAG: instead of retrieving arbitrary text chunks via semantic similarity, it injects curated, structured documentation (ADRs, code explorations, decision logs) as context for code generation. The goal is that every generation respects prior architectural decisions and preserves engineering context.

The documentation pipeline: planning publishes ADRs, tickets reference them, and dag-publish distributes them to configured destinations. Documentation isn't an afterthought — it's the input to every stage.

## Structure

```
.dag/config.json              # Pipeline adapter config (required)
plugins/
  dag/                        # Core pipeline: plan-feature, create-tickets, dag-publish
  | agents/code-exploration.md # Read-only subagent for codebase investigation
  | skills/plan-feature/adr-template.md
  | skills/create-tickets/ticket-archetypes.md
  | skills/dag-publish/contract.md         # Publish contract spec
  | skills/dag-publish/config.schema.json  # Schema for .dag/config.json
.planning/docs/               # Published ADRs, code explorations
.planning/tickets/            # Published tickets
```

### Key config files

- `.dag/config.json` — required. Configures documentation + issue-tracking adapters. Currently uses `local` adapters writing to `.planning/`.
- Per-plugin `.claude-plugin/plugin.json` — sets name, version, author, keywords.

## Slash commands vs auto-dispatch

Skills with `argument-hint` in frontmatter become **slash commands**: `/dag:plan-feature`, `/dag:create-tickets`.

Skills without `argument-hint` are **auto-dispatched** by the model when its reasoning matches their `description`: `dag-publish`.

## Working in this repo

### No auto-commit

Never create a commit unprompted. If a task completes, stop and report; don't commit.

### Changelog and versioning

Changelogs are maintained per-plugin and updated on release, not per commit.
Update them only when the user explicitly asks to release or bump a version.

Release workflow:

1. Collect commits since the last release tag or changelog entry using
   `git log <last-version-tag>...HEAD --oneline` or similar
2. Categorize changes per [Common Changelog](https://common-changelog.org):
   Added, Changed, Removed, Fixed. Breaking changes get a `**Breaking:**` prefix.
3. Bump the `version` field in the plugin's `.claude-plugin/plugin.json`
   and add a matching entry to its `CHANGELOG.md`
4. Create a release commit with the version bump

Version follows independent semver per plugin. CHANGELOG.md version and
plugin.json version must always match.

Commit SHAs in changelog entries should be formatted as markdown links:
`[c033d60](https://github.com/mbaquerizo/docs-augmented-generation/commit/c033d60)`

### Validate against plugin-dev skills

When editing or creating plugin components (skills, agents, hooks, commands, MCP servers, settings), load the matching skill from the `plugin-dev` plugin (`anthropics/plugin-dev`) to validate your changes. The relevant skills are: `agent-development`, `command-development`, `skill-development`, `hook-development`, `mcp-integration`, `plugin-settings`, `plugin-structure`.

### No test/lint/typecheck suite

This is a markdown-only repo. Skip any pre-commit validation that expects code tooling.

## Branch naming

Branches: `<type>/<issue-number>/<brief-description>` (e.g. `task/PROJ-6/create-changelog-and-contributing`).

## Plugin development conventions

Each plugin under `plugins/<name>/`:
```
.claude-plugin/plugin.json   # metadata (name, version, author, keywords)
agents/                       # agent markdown files
skills/<name>/SKILL.md        # skill definition
CHANGELOG.md                  # Common Changelog style
README.md
```

### Required YAML frontmatter

Every skill and agent `.md` file starts with YAML frontmatter. This controls how the model discovers and dispatches the component:

- **Skills**: `name`, `description`, plus either `trigger` (auto-dispatch keyword) or `argument-hint` (enables as a slash command like `/dag:plan-feature`). The `description` is critical — it's what the model matches against when deciding which skill to invoke.
- **Agents**: `name`, `description`, `system_prompt`, `tools` (comma-separated), `color` (hex for display).

If you're editing or creating a skill/agent file, these fields must be present and accurate.
