---
id: DAG-15
issueType: task
status: open
tags:
  - dag
  - documentation
  - onboarding
---

# Task: Update documentation references from .planning/ to .dag/docs/

## Description

The repo's `AGENTS.md` references `.planning/` paths (e.g. `.planning/docs/`, `.planning/tickets/`). These are outdated — the actual config and init script default to `.dag/docs/`. Update all references to match current convention.

## Acceptance criteria

1. `AGENTS.md` no longer references `.planning/` paths except where historically relevant
2. Any other documentation files referencing `.planning/` are updated or flagged
3. The README mentions the init script as the recommended setup path

## Related docs

- ADR: `.dag/docs/adr/2026-05-17-guided-init-flow/2026-05-17-guided-initialization-flow-for-dag-plugin.md`
- Parent epic: DAG-13

---
*This ticket was created by opencode and reviewed by a human before publishing.*
