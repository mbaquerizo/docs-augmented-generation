---
id: DAG-16
issueType: epic
status: open
tags:
  - dag
  - orchestration
  - epic
  - workflow
children: [DAG-17, DAG-18, DAG-19, DAG-20, DAG-21, DAG-22, DAG-23]
---

# Epic orchestration with parallel subagents and stacked PRs

## Description

Create a `dag-orchestrator` skill that coordinates work across an epic's
children using parallel subagents and stacked PRs. Independent children run
concurrently; dependent children use stacked branches (PR → PR nesting) so
each diff stays clean. A pre-finish-work gate detects sibling overlap before
PR creation.

This requires data model changes (`children` on epics, `parent` wired through
adapters), orchestrator-aware `start-work` mode, `finish-work` support for
configurable base branches and draft PRs, and `create-tickets` updates to
persist relationship fields.

## Scope

- **In scope**: New `dag-orchestrator` skill, orchestrator-aware `start-work`,
  base-branch and draft-PR support in `finish-work`, `children` field on
  epics, `parent` wired through the local issue-tracking adapter,
  `create-tickets` updates to persist parent/children/blockedBy
- **Out of scope**: Cloud adapter support (GitHub, Jira), PR lifecycle
  management beyond creation (rebase, merge, flip draft→ready), cleanup of
  ephemeral `blockedBy` entries

## Related docs

- ADR: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Code exploration: `.dag/docs/adr/epic-orchestration/2026-05-17-CE-code-exploration-for-epic-orchestration.md`

## Stories

- Wire parent field through local issue-tracking adapter (DAG-17)
- Add children field to epic archetype and template (DAG-18)
- Wire parent and children into create-tickets publish flow (DAG-19)
- Support configurable base branch in finish-work (DAG-20)
- Add draft PR flag to finish-work (DAG-21)
- Add orchestrator-aware mode to start-work (DAG-22)
- Create dag-orchestrator skill (DAG-23)
