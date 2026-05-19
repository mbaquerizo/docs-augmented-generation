---
id: DAG-19
issueType: story
status: open
tags:
  - dag
  - workflow
parent: DAG-16
blockedBy: [DAG-12, DAG-17, DAG-18]
---

# Wire parent and children into create-tickets publish flow

## Description

As a DAG user, I want tickets published by `create-tickets` to have their
relationship fields populated so that the epic has a machine-readable
`children` list and each child references its `parent` epic. When blocking
relationships are specified, `blockedBy` should also be set.

Currently `create-tickets` does not set `parent`, `children`, or `blockedBy`
on publish — the hierarchy exists only in the proposal display, not in the
published ticket frontmatter.

## Acceptance criteria

1. Epic tickets published by `create-tickets` include a `children` field listing all child IDs
2. Child tickets published by `create-tickets` include a `parent` field with the epic ID
3. Child tickets with blocking relationships include `blockedBy` with the relevant IDs
4. Tickets with no relationships omit the corresponding fields
5. The existing proposal display is preserved — this is an additive metadata change

## Scenarios

```gherkin
Scenario 1: Publish epic with children
  Given a feature plan with 3 children
  When create-tickets publishes the epic
  Then the epic frontmatter contains "children: [DAG-N, DAG-M, DAG-O]"

Scenario 2: Publish child with parent
  Given a feature plan with an epic
  When create-tickets publishes a child ticket
  Then the child frontmatter contains "parent: DAG-N"

Scenario 3: Publish blocked child
  Given 2 child tickets where story-2 is blocked by story-1
  When create-tickets publishes story-2
  Then the story-2 frontmatter contains "blockedBy: [DAG-M]"
```

## Technical notes

- Depends on DAG-17 (parent wired through adapter) to write `parent` into frontmatter
- Depends on DAG-12 (blockedBy) — `blockedBy` parsing and population was scoped there
- Depends on DAG-18 (children field definition) — the field must be declared before it's populated
- The SKILL.md publish instructions (section 5) should be updated to include `metadata.parent`, `metadata.children`, and `metadata.blockedBy` in the publish call

## Related docs

- ADR: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Code exploration: `.dag/docs/adr/epic-orchestration/2026-05-17-CE-code-exploration-for-epic-orchestration.md`
- Parent epic: DAG-16
- Ticket archetypes: `plugins/dag/skills/create-tickets/ticket-archetypes.md`

---

*This ticket was created by opencode and reviewed by a human before publishing.*
