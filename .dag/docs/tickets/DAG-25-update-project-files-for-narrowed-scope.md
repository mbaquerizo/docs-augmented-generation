---
id: DAG-25
issueType: story
status: done
tags:
  - dag
  - scope
  - documentation
parent: DAG-24
---

# Update project files to reflect narrowed DAG scope

## Description

As a DAG maintainer, I want all project documentation to reflect the narrowed
scope so that users understand DAG as a documentation conventions tool, not a
full execution pipeline.

## Acceptance criteria

1. AGENTS.md no longer references execution skills in:
   - "Slash commands vs auto-dispatch" section
   - "No auto-commit" section
   - "No test/lint/typecheck suite" section
   - "Commit conventions" section
   - "Branch naming and PR workflow" section
   - Scope references (remove shape-up, pair-programming)
2. Root README.md is rewritten with new positioning, updated plugins table,
   mermaid flow diagram showing documentation pipeline only, and removal of
   execution pipeline flow
3. plugins/dag/README.md lists only active skills (plan-feature, create-tickets,
   dag-publish), removes pipeline flow and gh CLI prerequisite
4. plugins/dag/.claude-plugin/plugin.json description and keywords updated
5. plugins/dag/skills/create-tickets/SKILL.md step 1 generalized (remove
   Shape Up pitch reference)

## Scenarios

Scenario 1: User reads AGENTS.md
  Given the project is newly scoped to documentation conventions
  When a user reads AGENTS.md
  Then they see no references to start-work, tdd, commit, or finish-work
  And they see no references to shape-up or pair-programming as active plugins

## Related docs

- ADR: `.dag/docs/adr/2026-05-22-pivot-to-docs-input/2026-05-22-narrow-scope-to-docs-input.md`
