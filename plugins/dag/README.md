# dag

Core DAG plugin — plan features, break into tickets, publish documentation.

## Prerequisites

- An issue-tracking adapter configured in `.dag/config.json`
- A documentation adapter configured in `.dag/config.json`

## Skills

| Skill | Usage | Description |
|-------|-------|-------------|
| plan-feature | `/dag:plan-feature` | ADR + code exploration |
| create-tickets | `/dag:create-tickets` | Ticket hierarchy |
| dag-publish | (invoked by other skills) | Publishing dispatcher — routes to the configured adapter |

## Agents

| Agent | Description |
|-------|-------------|
| code-exploration | Read-only subagent called by plan-feature |

## Adapters

This plugin includes built-in `local` adapters for documentation and
issue-tracking. Cloud adapters (Jira, Linear, GitHub Issues, Notion)
are available as separate plugins and are configured via `.dag/config.json`.
