---
id: DAG-11
issueType: task
status: done
tags:
  - infrastructure
  - documentation
parent: EPIC-1
---

# Improve ticket retrieval instructions in start-work skill

## Description

The start-work skill's Section 2 (Input) gives vague instructions for
locating and reading a ticket. It should be as explicit as the
finish-work skill's equivalent: reference the adapter instructions,
the config file, and specify the lookup strategy (scan frontmatter
by ID, match filename prefix).

## Acceptance criteria

1. Section 2 of start-work/SKILL.md references `.dag/config.json` to find
   `ticketPath` and `project` fields
2. Instructions specify scanning `ticketPath` for a file whose YAML
   frontmatter `id` matches the requested ticket ID
3. Instructions link to the issue-tracking adapter instructions and
   contract for context
4. The section retains the existing behavior of asking for a ticket ID
   if none is provided

## Related docs

- `plugins/feature-workflow/skills/start-work/SKILL.md` (current)
- `plugins/feature-workflow/skills/finish-work/SKILL.md` (reference for the explicit pattern)
- `plugins/shared/adapters/issue-tracking/local.md` (adapter instructions)
- `plugins/shared/adapters/contract.md` (publish contract)

---
*This ticket was created by opencode and reviewed by a human before publishing.*
