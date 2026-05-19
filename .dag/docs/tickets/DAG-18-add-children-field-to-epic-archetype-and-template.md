---
id: DAG-18
issueType: task
status: open
tags:
  - dag
  - infrastructure
parent: DAG-16
blockedBy: []
---

# Add children field to epic archetype and template

## Description

The ADR specifies that epics gain a `children` field for machine-readable
child ticket references. Currently children only exist as a plain markdown
list in the epic body. Add `children` to the frontmatter fields table in
`ticket-archetypes.md`, add it to the epic template, and document it in the
shared adapter conventions reference.

This is a documentation / model-definition change only — no adapter or
publish logic changes are needed (the adapter serializes arbitrary metadata
fields as YAML frontmatter).

## Acceptance criteria

1. `ticket-archetypes.md` frontmatter fields table includes `children` (optional, list of strings)
2. Epic template in `ticket-archetypes.md` shows `children` in frontmatter
3. Shared adapter conventions (from DAG-2) document `children` as a cross-adapter metadata field
4. `blockedBy` is NOT part of this ticket (handled by DAG-12)

## Related docs

- ADR: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Code exploration: `.dag/docs/adr/epic-orchestration/2026-05-17-CE-code-exploration-for-epic-orchestration.md`
- Parent epic: DAG-16
- Ticket archetypes: `plugins/dag/skills/create-tickets/ticket-archetypes.md`
- Shared conventions: `plugins/dag/skills/dag-publish/adapter-conventions.md`

---

*This ticket was created by opencode and reviewed by a human before publishing.*
