# feature-workflow

The core DAG pipeline. Plan, break down, implement, commit, and finish — with structured documents flowing through every stage.

## Prerequisites

- An issue-tracking adapter configured in `.dag/config.json` (for create-tickets and start-work)
- A documentation adapter configured in `.dag/config.json` (for plan-feature)
- `gh` CLI installed and authenticated (for finish-work)

## Skills

| Skill | Invocation | What it does |
|-------|------------|--------------|
| plan-feature | `/plan-feature` | Explores the codebase, evaluates options, and publishes an ADR + code exploration doc |
| create-tickets | `/create-tickets` | Breaks a planned feature into a ticket hierarchy (epics, stories, tasks) and publishes them |
| start-work | `invoked by subagent` | Loads a ticket, assesses complexity, creates a worktree, and implements per the plan |
| commit | `invoked by finish-work` | Stages and commits changes with format selection (gitmoji or conventional commits) |
| finish-work | `/finish-work` | Commits pending changes, syncs with base branch, pushes, and creates a PR |

## Agents

| Agent | Purpose |
|-------|---------|
| code-exploration | Read-only subagent that investigates a codebase and returns structured findings (called by plan-feature) |

## Pipeline flow

```
plan-feature → create-tickets → start-work → commit → finish-work
     ↓               ↓
   ADR +           tickets
   exploration
```

Each skill feeds the next. ADRs and explorations inform ticket creation. Tickets guide implementation. Commits preserve decisions. Finish-work closes the loop.