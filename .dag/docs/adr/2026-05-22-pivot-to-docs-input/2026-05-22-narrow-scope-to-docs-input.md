---
status: accepted
date: 2026-05-22
tags:
  - dag
  - scope
  - pivot
---

# ADR: Narrow DAG scope to documentation conventions for AI generation

## Context

DAG started as a full-cycle feature pipeline: plan → ticket → implement →
commit → PR. The pipeline produced structured docs (ADRs, code explorations,
tickets) at each stage, but it also imposed an opinionated workflow:
`start-work` created worktrees, `tdd` enforced test-first, `commit` formatted
messages, `finish-work` managed PRs and rebases.

Two problems emerged:

1. **Adoption friction** — teams already have workflows, commit conventions,
   and PR processes. DAG's execution skills compete with existing tooling
   rather than complement it.
2. **Scope creep** — the proposed epic-orchestration feature (parallel
   subagents, stacked PRs, conflict detection) would have pushed DAG further
   into territory already covered by dedicated tools.

The core thesis — curated, structured docs are better input for AI
generation than RAG or raw prompts — was being diluted by the execution
overhead.

## Options Considered

| Option | Complexity | Impact | Risk |
|--------|------------|--------|------|
| A: Keep full workflow pipeline | None (status quo) | Continues to bundle docs + execution | Low adoption; execution skills compete with user's existing habits |
| B: Documentation conventions only | Medium — docs + messaging cleanup | Clear scope, easy to adopt independently | Loses closed loop between docs and generated code |
| C: Documentation + structured output | Medium — keep commit/finish-work | Partial pullback, keeps PR/commit formatting | Boundary still fuzzy — git operations dressed as docs |

## Decision

**Choose Option B** — DAG narrows to documentation conventions for AI
generation.

What DAG owns:
- Producing structured docs (ADRs, code explorations, tickets)
- Defining conventions for what makes those docs effective for AI generation
- Publishing those docs to where teams read them

What DAG does not own:
- Implementation workflow (branches, worktrees, commits, PRs)
- Test-driven development cycles
- Git or GitHub lifecycle management

Execution skills (`start-work`, `tdd`, `commit`, `finish-work`) remain in
the repository as defocused files — they work if found but are no longer
maintained or documented as active capabilities. The pair-programming
plugin is extracted to its own repository. The shape-up plugin is
defocused — pitch input is no longer treated as the ideal precursor.

## Consequences

**Positive:**
- Clear, defensible scope — documentation conventions for AI generation
- No workflow imposition — users adopt only the docs layer
- Smaller surface area to maintain
- Issue tracking (tickets) stays in scope as documentation input, but
  archetypes may evolve as findings accumulate

**Negative:**
- Loses the closed-loop feedback (ticket → implementation → PR review →
  status update) that the full pipeline provided
- No built-in mechanism to verify that docs were actually consumed or
  followed during generation

**Neutral:**
- Defocused skills remain in the repo as passive files — no deletion, no
  deprecation notice
- Plugin version will bump to 2.0.0 to reflect the scope change
