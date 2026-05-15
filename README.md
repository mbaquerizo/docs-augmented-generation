# Docs Augmented Generation (DAG)

Ever finish a deep architectural discussion, capture it in an ADR, and then watch the next code generation session blissfully ignore it? DAG is built for that gap.

**Documentation hygiene → code generation accuracy.** Structured documents like ADRs, code explorations, and decision logs get injected as context for higher-quality code generation. Your docs are the prompt — every decision preserved, every exploration documented, every generation informed.

DAG parallels RAG, but with a different retrieval target:

| | RAG | DAG |
|---|---|---|
| **What is retrieved** | Arbitrary text chunks via semantic similarity | Curated, structured documentation |
| **Source type** | Any corpus (wikis, web, generic docs) | Authoritative documents (ADRs, exploration docs, decision logs) |
| **Retrieval logic** | "Find chunks similar to this query" | "Find architectural decisions relevant to this task" |
| **Goal** | Ground the model in facts, reduce hallucination | Ensure generated code respects prior decisions and preserves engineering context |

This project provides a collection of plugins for **Claude Code** and **Opencode** that implement the DAG workflow.

## Plugins

The DAG workflow is implemented as a pipeline of plugins, each producing structured documents that feed the next stage:

| Plugin | What it gives you |
|--------|-------------------|
| [feature-workflow](plugins/feature-workflow/README.md) | The core DAG pipeline — plan-feature publishes ADRs and explorations, create-tickets breaks work into tracked tickets, start-work loads docs as context, commit preserves decisions, finish-work wraps up |
| [shape-up](plugins/shape-up/README.md) | Shape Up pitch generation — structured documents that feed the DAG workflow with appetite-sized feature definitions |
| [tdd](plugins/tdd/README.md) | Test-driven development — documentation of code behavior through tests, complementary to DAG's doc-as-context philosophy |
| [pair-programming](plugins/pair-programming/README.md) | Navigated pair programming — structured session docs preserve context across sessions |
| [shared](plugins/shared/README.md) | The DAG plumbing — adapters that publish documentation and tickets so they're retrievable as context |

## Quickstart

```bash
# Clone the project
git clone <repo-url>
cd docs-augmented-generation

# Configure your adapter paths
# Edit .dag/config.json with your documentation and ticket directories
```

### Claude Code

```bash
claude --plugin-dir ./plugins
```

Or install via the Claude Code marketplace and enable individual plugins.

### Opencode

```bash
npx skills add ./plugins
```

This registers skills and agents from the plugin directory with your opencode installation.

Alternatively, reference the plugin directory in your `opencode.jsonc`:

```jsonc
{
  "plugins": ["./plugins"]
}
```

## Installation

See individual plugin READMEs for prerequisites:

- **feature-workflow** — requires the issue-tracking adapter configured in `.dag/config.json` and `gh` CLI for the finish-work skill
- **shape-up** — requires the documentation adapter configured
- **tdd** — requires a test framework and runner
- **pair-programming** — requires a human in the loop

## Project structure

```
.dag/
  config.json              # Adapter configuration
plugins/
  shared/                  # Shared adapter plumbing
  feature-workflow/        # Feature pipeline skills + agents
  shape-up/                # Shape Up skill
  tdd/                     # TDD skill
  pair-programming/        # Navigated pair programming
```