---
id: DAG-22
issueType: story
status: open
tags:
  - dag
  - orchestration
  - workflow
parent: DAG-16
blockedBy: []
---

# Add orchestrator-aware mode to start-work

## Description

As an epic orchestrator, I want `start-work` to accept a pre-created worktree,
branch, and allocated files so that subagents can be launched without
interactive planning or worktree setup.

Currently `start-work` follows a linear flow: mode check → input → status
update → complexity check → worktree creation → planning discussion →
implementation → stop. Add an orchestrated mode triggered by passing
`WORKTREE_PATH`, `BRANCH`, and `ALLOCATED_FILES` variables:

| Step | Orchestrated mode | Human mode |
|------|-------------------|------------|
| Mode check | Skip | Check |
| Input | Accept ticket ID + worktree/branch | Accept ticket ID |
| Status update | Skip (orchestrator handles) | Update locally |
| Complexity | Report to orchestrator | Report to human |
| Worktree | Skip (pre-created) | Create |
| Planning (Phase 2) | Skip (done at epic level) | Human discussion |
| Implementation | Same | Same |
| Stop | Commit + return structured results | Offer /commit |

## Acceptance criteria

1. `start-work` accepts `WORKTREE_PATH`, `BRANCH`, and `ALLOCATED_FILES` environment variables
2. When all three are set, start-work runs in orchestrated mode (skips worktree creation, status update, and planning phases)
3. In orchestrated mode, start-work returns `{ ticketId, filesChanged, commitSha }` after implementation
4. In orchestrated mode, start-work does not prompt the user and does not offer `/commit`
5. When the variables are not set, current behavior is preserved exactly
6. Branch naming convention (`epic/DAG-42/story/DAG-43/slug`) is accepted — no validation against current two-segment pattern

## Scenarios

```gherkin
Scenario 1: Orchestrated mode
  Given WORKTREE_PATH, BRANCH, and ALLOCATED_FILES are set
  When start-work runs
  Then it skips worktree creation
  And it skips planning phase
  And it commits changes automatically
  And it returns { ticketId, filesChanged, commitSha }

Scenario 2: Human mode (backward compatible)
  Given WORKTREE_PATH, BRANCH, and ALLOCATED_FILES are not set
  When start-work runs
  Then it follows the existing flow with all phases
```

## Technical notes

- Branch format changes: currently `<type>/<number>/<slug>`; orchestrated uses `epic/<epic-id>/story/<child-id>/<slug>`. Remove the two-segment validation.
- Worktree creation is in Phase 1 Step 6; when pre-created, verify the worktree exists and skip `git worktree add`
- Status update is Phase 1 Step 3; skip entirely in orchestrated mode
- The "Stop" step should use `git commit` directly (via commit skill) and return structured output
- Structured return can be done via stdout JSON or writing to a well-known path

## Related docs

- ADR: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Code exploration: `.dag/docs/adr/epic-orchestration/2026-05-17-CE-code-exploration-for-epic-orchestration.md`
- Parent epic: DAG-16

---

*This ticket was created by opencode and reviewed by a human before publishing.*
