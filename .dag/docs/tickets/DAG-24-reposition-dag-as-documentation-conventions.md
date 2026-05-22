---
id: DAG-24
issueType: epic
status: open
tags:
  - dag
  - scope
  - pivot
children: [DAG-25, DAG-26, DAG-27]
---

# Reposition DAG as documentation conventions for AI generation

## Description

Narrow DAG's scope from a full execution pipeline to documentation conventions
for AI-assisted development. Remove execution skills (start-work, tdd, commit,
finish-work) from project docs and messaging, reject the epic-orchestration
direction, and extract pair-programming to its own repo. The ADR has already
been written — this epic covers the remaining implementation tasks.

## Scope

- **In scope:** File-level changes to AGENTS.md, READMEs, plugin.json, and
  create-tickets skill to reflect the narrowed scope. Rejecting the
  epic-orchestration ADR. Extracting pair-programming via git subtree split.
- **Out of scope:** Changes to defocused skill files themselves. Changes to
  the dag-research project.

## Related docs

- ADR: `.dag/docs/adr/2026-05-22-pivot-to-docs-input/2026-05-22-narrow-scope-to-docs-input.md`

## Stories

- Update project files to reflect narrowed DAG scope (DAG-25)
- Reject epic-orchestration ADR (DAG-26)
- Extract pair-programming plugin to own repo (DAG-27)
