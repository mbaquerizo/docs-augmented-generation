---
id: DAG-17
issueType: task
status: open
tags:
  - dag
  - infrastructure
parent: DAG-16
blockedBy: []
---

# Wire parent field through local issue-tracking adapter

## Description

The `parent` field in the dag-publish contract is currently silently ignored
by the local issue-tracking adapter (`issue-tracking-local.md`). For epic
orchestration, children must reference their parent epic. Update the adapter
to write the `parent` value into the YAML frontmatter of published tickets.

Currently the adapter maps `parent` as "Unsupported. Silently ignored."
Change this to serialize `parent` as a frontmatter field alongside `id`,
`issueType`, `status`, and `tags`.

## Acceptance criteria

1. `issue-tracking-local.md` no longer lists `parent` as "Silently ignored"
2. Published tickets with a `parent` value include it in their YAML frontmatter
3. Published tickets without a `parent` value omit it from frontmatter
4. The documentation adapter (`documentation-local.md`) is NOT affected — its `parent` behavior (subdirectory nesting) stays unchanged

## Related docs

- ADR: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Code exploration: `.dag/docs/adr/epic-orchestration/2026-05-17-CE-code-exploration-for-epic-orchestration.md`
- Parent epic: DAG-16
- Contract: `plugins/dag/skills/dag-publish/contract.md`

---

*This ticket was created by opencode and reviewed by a human before publishing.*
