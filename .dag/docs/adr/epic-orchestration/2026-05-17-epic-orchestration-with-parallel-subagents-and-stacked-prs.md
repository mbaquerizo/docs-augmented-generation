---
status: proposed
date: 2026-05-17
tags:
  - dag
  - orchestration
  - epic
  - workflow
---

# ADR: Epic orchestration with parallel subagents and stacked PRs

## Context

The DAG pipeline creates tickets in a hierarchy: an epic groups multiple
stories/tasks with dependency relationships (`blockedBy`). The `start-work`
skill only handles a single ticket — there is no way to orchestrate work
across an epic's children. Users must manually run `start-work` for each
child, track dependencies themselves, and manage branches and PRs.

Three problems emerge:

1. **No parallel execution** — independent children (no `blockedBy` path)
   are worked sequentially even though they could run in parallel.
2. **No conflict detection** — parallel siblings may overlap files or
   functions, discovered only at merge time.
3. **No stacked PR workflow** — dependent children branch from main and
   include dependency code in their diff, making review harder.

A code exploration was conducted
([CE](./2026-05-17-CE-code-exploration-for-epic-orchestration.md))
to understand the existing data model (ticket archetypes, `parent`/`blockedBy`
fields), adapter constraints (local adapter serializes metadata as YAML, no
special `parent`/`children` logic), and the start-work/finish-work skill
boundaries.

Key findings from code exploration:
- `blockedBy` is being added by DAG-12 but `children` does not yet exist
- `start-work` owns worktree creation, planning discussion, implementation, and TDD
- `finish-work` owns PR creation and ticket status updates
- The local adapter preserves arbitrary metadata fields in YAML frontmatter
- No existing mechanism for parallel subagent orchestration

## Options Considered

| Option | Complexity | Impact | Risk | Notes |
|--------|------------|--------|------|-------|
| A: Extend start-work to handle epics | Medium — add epic detection + subagent spawning | Modifies existing stable skill | Medium — start-work becomes dual-purpose | Risk of breaking single-ticket flow |
| B: New orchestrate-epic skill + orchestrator-aware start-work | Medium-High — new skill + start-work changes | Clear separation of concerns | Low — start-work changes are additive (orchestrated mode) | Preferred |
| C: New standalone orchestration skill that duplicates start-work phases | Medium — new skill only | No changes to existing skills | Medium — drift risk if start-work changes | Duplicates logic, maintenance hazard |

## Decision

**Choose Option B** — create a new `orchestrate-epic` skill and make
`start-work` orchestrator-aware by accepting a pre-created worktree and
branch, skipping human-interactive phases when run in subagent mode.

### Data model changes

**Epic frontmatter** gains a `children` field:
```yaml
issueType: epic
status: open
children: [DAG-43, DAG-44, DAG-45]
```

- Enforced by `create-tickets` on epic publish
- Replaces the body-only "Stories" list with a machine-readable field

**Child frontmatter** enforces `parent` and uses `blockedBy` per DAG-12:
```yaml
issueType: story
status: open
parent: DAG-42
blockedBy: [DAG-43]
```

- `parent` was in the spec as optional — now required for epic children
- `blockedBy` set at create-tickets time (from blocking relationships)
- `blockedBy` may also be added by the orchestrator when sibling overlap
  is detected during the pre-finish-work gate

### Orchestrate-epic skill flow

1. **Load epic** — read epic from issue tracker, extract `children`
2. **Load all children** — build dependency DAG from `blockedBy`
3. **Planning gate** — orchestrator proposes file-allocation map:
   - For each child, assign distinct files (or at least distinct
     functions within files)
   - Account for `blockedBy` — dependent children get different areas
   - Human reviews and approves
4. **Execution** — topological sort, launch subagents for ready children:
   a. Orchestrator creates worktree + branch:
      - Branch: `epic/DAG-42/story/DAG-43/slug`
      - Base: main (if independent) or blocker's branch (if `blockedBy`)
      - Worktree: `.worktrees/epic-DAG-42/DAG-43/`
   b. Launch subagent with `start-work (orchestrated mode)`:
      - Passes: ticket ID, worktree path, branch name, allocated files
      - Subagent: load context → implement → test → commit
      - Returns: `{ ticketId, filesChanged, commitSha }`
   c. **Pre-finish-work gate**:
      - Compare `filesChanged` against completed siblings with no
        `blockedBy` path
      - File-level: any sibling touching same file? → function-level check
      - Function-level: same function? → overlap detected
      - Overlap → orchestrator tells subagent to reconcile by rebasing
        onto the sibling's branch and fixing the conflict
      - Subagent reconciles → re-reports
      - Orchestrator persists new dependency: adds `blockedBy` to the
        child's frontmatter
   d. **PR creation** (via finish-work on that worktree):
      - Base is main → `gh pr create --base main` → ready for review
      - Base is sibling branch → `gh pr create --base <branch> --draft`
        → draft PR
   e. Collect result, re-evaluate blocked tickets, repeat

5. **Report** — summary table:
   ```
   DAG-43  main              PR#1  ready   https://...
   DAG-44  DAG-43's branch   PR#2  draft   https://...
   DAG-45  DAG-43's branch   PR#3  draft   https://...
   ```

### Start-work orchestrator-aware mode

When invoked with `$WORKTREE_PATH`, `$BRANCH`, and `$ALLOCATED_FILES`:

| Step | Orchestrated mode | Human mode |
|------|-------------------|------------|
| Mode check | Skip | Check |
| Input | Accept ticket ID + worktree/branch | Accept ticket ID |
| Status update | Skip (orchestrator handles) | Update locally |
| Complexity | Report to orchestrator | Report to human |
| Worktree | Skip (pre-created) | Create |
| Planning (Phase 2) | Skip (done at epic level) | Human discussion |
| Implementation | Same | Same |
| Stop | Commit + return structured results | Offer `/commit` |

### What orchestrator does NOT do

- Wait for PR merges
- Rebase downstream PRs after a base merges
- Flip draft→ready
- Any PR lifecycle management beyond creation

## Consequences

**Positive:**
- Parallel execution of independent epic children — wall time = max
  implementation time, not sum
- Pre-finish-work gate catches sibling overlap before PR creation —
  cheaper than merge-conflict resolution
- Stacked PR workflow keeps dependent PR diffs clean (only the child's
  own changes)
- Draft PRs signal dependency to reviewers without blocking
- Data model is consistent: `parent` (up), `children` (down),
  `blockedBy` (dependency)
- `start-work` remains usable for non-orchestrated single-ticket sessions

**Negative:**
- Adds branch management complexity to the orchestrator (worktree
  creation, branch naming, base selection)
- Subagent reconciliation cycles add latency when overlap is detected
  (but this is bounded and cheaper than sequential execution)
- `blockedBy` field may accumulate ephemeral entries from reconciliation
  — no cleanup mechanism yet when a PR merges

**Neutral:**
- Requires DAG-12 (`blockedBy`) to be complete first
- `create-tickets` needs updates to enforce `parent` and `children`
  (outside orchestrator scope but prerequisite)
- Orchestrator creates `.worktrees/` directory — new convention in the
  repo for subagent isolation
