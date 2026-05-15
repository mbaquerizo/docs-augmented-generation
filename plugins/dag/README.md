# dag

The core DAG pipeline. Plan, break down, implement, commit, and finish —
with structured documents flowing through every stage.

## Prerequisites

- An issue-tracking adapter configured in `.dag/config.json`
- A documentation adapter configured in `.dag/config.json`
- `gh` CLI installed and authenticated (for finish-work)

## Skills

| Skill | Usage | Description |
|-------|-------|-------------|
| plan-feature | `/dag:plan-feature` | ADR + code exploration |
| create-tickets | `/dag:create-tickets` | Ticket hierarchy |
| dag-publish | (invoked by other skills) | Publishing dispatcher — routes to the configured adapter |
| start-work | (invoked by subagent) | Loads ticket, implements |
| tdd | (invoked by start-work) | Test-driven development |
| commit | (invoked by finish-work) | Stages and commits |
| finish-work | `/dag:finish-work` | PR creation |

## Agents

| Agent | Description |
|-------|-------------|
| code-exploration | Read-only subagent called by plan-feature |

## Pipeline flow

```
plan-feature → create-tickets → start-work → commit → finish-work
```

## Adapters

This plugin includes built-in `local` adapters for documentation and
issue-tracking. Cloud adapters (Jira, Linear, GitHub Issues, Notion)
are available as separate plugins and are configured via `.dag/config.json`.
