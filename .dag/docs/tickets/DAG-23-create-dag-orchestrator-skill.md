---
id: DAG-23
issueType: story
status: open
tags:
  - dag
  - orchestration
  - workflow
parent: DAG-16
blockedBy: [DAG-12, DAG-17, DAG-18, DAG-19, DAG-20, DAG-21, DAG-22]
---

# Create dag-orchestrator skill

## Description

As a DAG user, I want to run `/dag:dag-orchestrator <epic-id>` and have the
system parallelize work across all children with proper dependency ordering
and stacked PRs, so that I don't have to manually run `start-work` for each
child.

The skill implements the ADR's Option B: a new `dag-orchestrator` skill +
orchestrator-aware `start-work` (DAG-22).

## Acceptance criteria

1. A new `dag-orchestrator` skill exists at `plugins/dag/skills/dag-orchestrator/SKILL.md`
2. Loading the epic reads `children` from frontmatter and `blockedBy` from each child
3. The planning gate proposes a file-allocation map for human review
4. Topological sort orders children by `blockedBy` dependencies
5. Ready children launch as subagents with orchestrator-aware `start-work`
6. Pre-finish-work gate detects sibling file/function overlap and triggers reconciliation
7. PRs are created via `finish-work` with correct base (main or sibling branch) and draft flag
8. Summary report is displayed with ticket IDs, base branches, PR URLs, and statuses

## Scenarios

```gherkin
Scenario 1: Orchestrate independent children
  Given an epic with 2 children that have no blockedBy
  When dag-orchestrator runs
  Then both children execute in parallel subagents
  And each gets a PR against main

Scenario 2: Orchestrate dependent children
  Given an epic with child-2 blockedBy child-1
  When dag-orchestrator runs
  Then child-1 starts first
  And child-2 starts after child-1 completes
  And child-2's PR targets child-1's branch as draft

Scenario 3: Sibling overlap detected
  Given 2 parallel children touching the same file
  When child-1 finishes and pre-finish-work gate checks child-2
  Then overlap is detected
  And the orchestrator instructs child-2 to rebase onto child-1's branch
  And blockedBy is updated on child-2

Scenario 4: No overlap
  Given 2 parallel children touching different files
  When pre-finish-work gate checks sibling files
  Then no reconciliation is needed
  And both PRs proceed as ready (or draft if stacked)
```

## Technical notes

- YAML frontmatter with `argument-hint: "<epic-id>"` for slash command usage
- Skill file structure: `plugins/dag/skills/dag-orchestrator/SKILL.md`
- Requires DAG-22 for subagent orchestration
- Requires DAG-20 + DAG-21 for proper PR creation
- Requires DAG-19 + DAG-12 for properly formatted tickets
- `.worktrees/epic-<epic-id>/` convention for subagent isolation
- Branch convention: `epic/<epic-id>/<child-type>/<child-id>/<slug>`
- No PR lifecycle management beyond creation (no waiting for merges, no rebasing downstream PRs, no draft→ready flipping)

## Related docs

- ADR: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Code exploration: `.dag/docs/adr/epic-orchestration/2026-05-17-CE-code-exploration-for-epic-orchestration.md`
- Parent epic: DAG-16

---

*This ticket was created by opencode and reviewed by a human before publishing.*
