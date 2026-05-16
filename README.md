# Docs Augmented Generation (DAG)

📝✨ → 🤖🎯

The context you need for good code generation exists — it's just not documented. It's in your head, in conversations you've already had, in decisions you've already made. DAG is built for that gap.

**Documentation hygiene → code generation accuracy.** Structured documents like ADRs, code explorations, and decision logs get injected as context for higher-quality code generation. Your docs are the prompt — every decision preserved, every generation informed.

DAG parallels RAG: instead of retrieving arbitrary text chunks via semantic similarity, it injects curated, structured documentation as context for code generation. The goal is that every generation respects prior architectural decisions and preserves engineering context.

This project provides a collection of plugins for **Claude Code** and **Opencode** that implement the DAG workflow.

## Plugins

The DAG workflow is implemented as a pipeline of plugins, each producing structured documents that feed the next stage:

| Plugin | What it gives you |
|--------|-------------------|
| [dag](plugins/dag/README.md) | The core DAG pipeline — plan-feature publishes ADRs and explorations, create-tickets breaks work into tracked tickets, dag-publish routes to configured adapters, start-work loads docs as context, tdd drives test-first, commit preserves decisions, finish-work wraps up |
| [shape-up](plugins/shape-up/README.md) | Shape Up pitch generation — structured documents that feed the DAG workflow with appetite-sized feature definitions |
| [pair-programming](plugins/pair-programming/README.md) | Navigated pair programming — structured session docs preserve context across sessions |

## Quickstart

### 1. Clone

```bash
git clone <repo-url>
cd docs-augmented-generation
```

### 2. Configure adapters

`.dag/config.json` is required — it tells the pipeline where to publish documents and tickets. Two adapter categories, each independently configured:

| Adapter | What it routes | Required? |
|---------|---------------|-----------|
| `documentation` | ADRs, code explorations, pitches | yes |
| `issue-tracking` | Tickets (epics, stories, tasks, bugs, spikes) | yes |

Each adapter has a `type` field that selects the backend. The built-in `local` adapter writes to the filesystem at the paths you specify. Cloud adapter support (Jira, GitHub Issues, etc.) is planned.

Edit `.dag/config.json`:

```json
{
  "adapters": {
    "documentation": {
      "type": "local",
      "config": {
        "adrPath": "./docs/adr",
        "pitchPath": "./docs/pitches"
      }
    },
    "issue-tracking": {
      "type": "local",
      "config": {
        "project": "PROJ",
        "ticketPath": "./docs/tickets"
      }
    }
  }
}
```

Fields for the `local` adapter:

| Field | Meaning |
|-------|---------|
| `adrPath` | Where ADRs and code explorations land. Each gets a date-prefixed filename like `2026-05-14-add-auth.md`. |
| `pitchPath` | Where Shape Up pitches land. |
| `project` | Ticket ID prefix used by the local adapter (produces IDs like `PROJ-1`). Cloud adapters may interpret this differently — e.g. a Jira adapter would use it as the Jira project key. |
| `ticketPath` | Path to the ticket file directory. |

All paths are relative to the project root. The `parent` field in published documents creates subdirectories for grouping related docs.

### 3. Claude Code

#### Marketplace (recommended)

Add the marketplace URL, then install plugins from within Claude Code:

```
/plugin marketplace add mbaquerizo/docs-augmented-generation
/plugin install dag@docs-augmented-generation
/plugin install shape-up@docs-augmented-generation
/plugin install pair-programming@docs-augmented-generation
```

Individual plugins can be enabled or disabled in settings.

#### Clone & run

For local development without a marketplace:

```bash
claude --plugin-dir ./plugins/dag \
  --plugin-dir ./plugins/shape-up \
  --plugin-dir ./plugins/pair-programming
```

### 4. Opencode

```bash
npx skills add ./plugins
```

This registers skills and agents from all plugin directories with your opencode installation.

Alternatively, add a root `opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["./plugins"]
  }
}
```

### 5. Verify

Start a session and try a slash command:

```
/dag:plan-feature Set up user authentication
```

The model should load the plan-feature skill and begin the planning workflow.

## Installation

See individual plugin READMEs for prerequisites:

- **dag** — requires `.dag/config.json` with adapter configuration, and `gh` CLI for the finish-work skill
- **shape-up** — requires the documentation adapter configured
- **pair-programming** — requires a human in the loop

## Usage

Skills are invoked automatically by the model when a task matches their description, or explicitly by the user:

| Syntax | Example | Scope |
|--------|---------|-------|
| `/plugin:skill` | `/dag:plan-feature` | Any skill from any installed plugin |
| `@agent-name` | `@code-exploration` | Agent invoked in conversation |
| Auto-dispatch | — | Model matches task context to skill descriptions |

Slash commands (`/dag:plan-feature`, `/dag:create-tickets`, `/dag:finish-work`)
are available at any prompt. Sub-skills like `tdd`, `commit`, `start-work`, and
`dag-publish` are invoked by higher-level skills as part of the pipeline — no
manual slash needed.

### Pipeline flow

```
User: /dag:plan-feature "Add user auth"
  → plan-feature reads config, calls code-exploration agent
  → plan-feature drafts ADR + exploration, calls dag-publish skill
  → dag-publish reads .dag/config.json, routes to configured adapter
  → Adapter writes files, returns paths

User: /dag:create-tickets
  → create-tickets drafts hierarchy, calls dag-publish
  → dag-publish writes ticket files via configured adapter

User: [start-work runs on a ticket]
  → start-work calls tdd for test-first implementation
  → cycle: implement → commit → implement → commit

User: /dag:finish-work
  → finish-work invokes commit skill, syncs, creates PR
```

## Project structure

```
.dag/
  config.json              # Adapter configuration
plugins/
  dag/                     # Core pipeline (skills + agents + publisher)
  shape-up/                # Shape Up skill
  pair-programming/        # Navigated pair programming
  adapter-*/               # Optional cloud adapter plugins (Jira, GitHub, etc.)
```