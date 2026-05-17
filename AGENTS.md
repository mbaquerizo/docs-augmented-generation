# AGENTS.md — Docs Augmented Generation (DAG)

## What this is

A monorepo of **Claude Code / OpenCode plugins** implementing the DAG workflow. All content is markdown-based skill/agent definitions — **no code, no build, no package.json, no tests**.

### The DAG idea

DAG parallels RAG: instead of retrieving arbitrary text chunks via semantic similarity, it injects curated, structured documentation (ADRs, code explorations, decision logs) as context for code generation. The goal is that every generation respects prior architectural decisions and preserves engineering context.

The pipeline enforces this: planning publishes ADRs, tickets reference them, start-work loads them as context, and commit + finish-work close the loop. Documentation isn't an afterthought — it's the input to every stage.

## Structure

```
.dag/config.json              # Pipeline adapter config (required)
plugins/
  dag/                        # Core pipeline: plan-feature, create-tickets, dag-publish,
  |                             start-work, tdd, commit, finish-work
  | agents/code-exploration.md # Read-only subagent for codebase investigation
  | skills/plan-feature/adr-template.md
  | skills/create-tickets/ticket-archetypes.md
  | skills/dag-publish/contract.md         # Publish contract spec
  | skills/dag-publish/config.schema.json  # Schema for .dag/config.json
  | skills/finish-work/pr-template.md
  | skills/commit/gitmoji.md, conventional-commit.md
  shape-up/                   # Shape Up pitch generation
  | skills/shape-up/pitch-structure.md, shape-up-methodology.md
  pair-programming/           # Navigated pair programming
    skills/navigator/
.planning/docs/               # Published ADRs, code explorations, pitches
.planning/tickets/            # Published tickets
```

### Key config files

- `.dag/config.json` — required. Configures documentation + issue-tracking adapters. Currently uses `local` adapters writing to `.planning/`.
- Per-plugin `.claude-plugin/plugin.json` — sets name, version, author, keywords.

## Pipeline

```
plan-feature → create-tickets → start-work → [commit loop] → finish-work
```

Skills are invoked via the pipeline automatically. Each stage produces structured documents consumed by the next.

## Slash commands vs auto-dispatch

Skills with `argument-hint` in frontmatter become **slash commands**: `/dag:plan-feature`, `/dag:create-tickets`, `/dag:finish-work`, `/shape-up`, `/navigator`.

Skills without `argument-hint` are **auto-dispatched** by the model when its reasoning matches their `description`: `tdd`, `commit`, `start-work`, `dag-publish`.

## Working in this repo

### No auto-commit

Never create a commit unprompted. The `finish-work` skill handles the full commit → PR flow. If a task completes outside that skill, stop and report; don't commit.

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
4. Use the **commit** skill (`/commit`) to create the release commit

Version follows independent semver per plugin. CHANGELOG.md version and
plugin.json version must always match.

Commit SHAs in changelog entries should be formatted as markdown links:
`[c033d60](https://github.com/mbaquerizo/docs-augmented-generation/commit/c033d60)`

### Validate against plugin-dev skills

When editing or creating plugin components (skills, agents, hooks, commands, MCP servers, settings), load the matching skill from the `plugin-dev` plugin (`anthropics/plugin-dev`) to validate your changes. The relevant skills are: `agent-development`, `command-development`, `skill-development`, `hook-development`, `mcp-integration`, `plugin-settings`, `plugin-structure`.

### No test/lint/typecheck suite

This is a markdown-only repo. Skip any pre-commit validation that expects code tooling. The commit skill mentions `lint/typecheck/test` — ignore those steps here.

## Commit conventions

This repo uses **gitmoji**: `<emoji> [(scope)] <description>`. See `plugins/dag/skills/commit/gitmoji.md` for the full reference.

Rules:
- Subject ≤ 50 chars, body wrapped at 72
- One emoji, one purpose, one commit
- Scope references plugin name (e.g. `dag`, `shape-up`, `pair-programming`)

The commit skill (`plugins/dag/skills/commit/SKILL.md`) handles grouping, format choice, drafting, and approval.

## Branch naming and PR workflow

Branches: `<type>/<issue-number>/<brief-description>` (e.g. `task/PROJ-6/create-changelog-and-contributing`).

PRs: `gh` CLI required. Squash-merge when approved. The `finish-work` skill handles sync, rebase, PR creation/update.

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
