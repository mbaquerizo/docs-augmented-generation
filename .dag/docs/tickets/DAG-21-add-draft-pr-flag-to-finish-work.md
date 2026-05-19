---
id: DAG-21
issueType: story
status: open
tags:
  - dag
  - workflow
parent: DAG-16
blockedBy: [DAG-20]
---

# Add draft PR flag to finish-work

## Description

As a DAG orchestrator, I want `finish-work` to create draft PRs when the
branch depends on an unmerged parent branch, so that reviewers can see the
PR is part of a stacked chain and not yet mergeable.

Currently `finish-work` always creates ready-for-review PRs. Add a `DRAFT`
parameter — when `true`, pass `--draft` to `gh pr create`.

## Acceptance criteria

1. `finish-work` accepts an optional `DRAFT` boolean parameter
2. When `DRAFT=true`, `gh pr create --draft` is used
3. When `DRAFT` is not set or `false`, behavior is identical to current (ready PR)
4. The PR body includes a note that this is a stacked PR when `DRAFT=true`

## Scenarios

```gherkin
Scenario 1: Draft PR creation
  Given DRAFT=true and BASE_BRANCH is a sibling branch
  When finish-work creates a PR
  Then the PR is created as draft

Scenario 2: Ready PR (backward compatible)
  Given DRAFT is not set
  When finish-work creates a PR
  Then the PR is created as ready for review
```

## Technical notes

- `gh pr create --draft` is available in GitHub CLI 2.0+
- This pairs with DAG-20: draft PRs make sense when the base is a sibling branch
- The commit step before PR creation is unaffected

## Related docs

- ADR: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Code exploration: `.dag/docs/adr/epic-orchestration/2026-05-17-CE-code-exploration-for-epic-orchestration.md`
- Parent epic: DAG-16

---

*This ticket was created by opencode and reviewed by a human before publishing.*
