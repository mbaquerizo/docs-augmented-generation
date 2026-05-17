---
id: DAG-12
issueType: task
status: open
tags:
  - dag
  - infrastructure
parent: DAG-1
---

# Add blockedBy metadata field for ticket relationship tracking

## Description

The `create-tickets` workflow requires noting blocking or other relationships between tickets, but there is no metadata field to capture this. Currently the only relationship field is `parent` (epic-child grouping). Add a `blockedBy` frontmatter field to ticket archetypes and wire it through the publish pipeline so blocking relationships are captured in published tickets.

Scope:

- **`ticket-archetypes.md`**: Add `blockedBy` to the frontmatter fields table and to relevant templates. `blockedBy` is an optional list of ticket IDs (e.g. `["DAG-2"]`).
- **`issue-tracking-local.md`**: Document `blockedBy` as a supported adapter-specific metadata field. Include it in the frontmatter serialization example.
- **Shared conventions (contract with DAG-2)**: Ensure the shared conventions reference covers this field so future adapters implement it consistently.
- **`create-tickets` SKILL.md**: Update the workflow instructions to populate `blockedBy` when drafting tickets that have blocking dependencies.

## Acceptance criteria

1. `ticket-archetypes.md` documents `blockedBy` in the frontmatter fields table
2. `issue-tracking-local.md` shows `blockedBy` in the adapter-specific metadata fields and in the example output
3. DAG-2's conventions reference covers `blockedBy` as a cross-adapter convention
4. Published tickets with blocking relationships include the `blockedBy` field in their frontmatter

## Related docs

- Contract: `plugins/dag/skills/dag-publish/contract.md`
- Ticket archetypes: `plugins/dag/skills/create-tickets/ticket-archetypes.md`
- Issue-tracking adapter: `plugins/dag/skills/dag-publish/issue-tracking-local.md`
- Parent epic: DAG-1

---
*This ticket was created by opencode and reviewed by a human before publishing.*
