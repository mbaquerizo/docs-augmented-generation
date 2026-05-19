---
id: DAG-20
issueType: story
status: open
tags:
  - dag
  - workflow
parent: DAG-16
blockedBy: []
---

# Support configurable base branch in finish-work

## Description

As a DAG orchestrator, I want `finish-work` to target a specific base branch
instead of always targeting the remote HEAD, so that stacked PRs can be
created against another feature branch rather than main.

Currently `finish-work` auto-detects the base as the remote's default branch.
Add a `BASE_BRANCH` parameter — when provided, use it as the PR base; when
omitted, fall back to the current behavior (remote HEAD).

## Acceptance criteria

1. `finish-work` accepts an optional `BASE_BRANCH` parameter
2. When `BASE_BRANCH` is set, `gh pr create --base <value>` uses that value
3. When `BASE_BRANCH` is omitted, behavior is identical to current (remote HEAD)
4. The syncing step (`git rebase <base>` / `git push`) also targets the specified base

## Scenarios

```gherkin
Scenario 1: Custom base branch
  Given BASE_BRANCH is set to "feature/epic/story-2"
  When finish-work creates a PR
  Then the PR targets "feature/epic/story-2" as its base

Scenario 2: Default base branch (backward compatible)
  Given BASE_BRANCH is not set
  When finish-work creates a PR
  Then the PR targets the remote default branch (e.g. main)
```

## Technical notes

- The current base detection uses `git rev-parse --abbrev-ref HEAD@{upstream}` with remote HEAD fallback — wrap this in a parameter check
- The `gh pr create` command needs `--base <branch>` added when custom base is provided
- The sync step (`git rebase`) should rebase onto the specified base branch

## Related docs

- ADR: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Code exploration: `.dag/docs/adr/epic-orchestration/2026-05-17-CE-code-exploration-for-epic-orchestration.md`
- Parent epic: DAG-16

---

*This ticket was created by opencode and reviewed by a human before publishing.*
