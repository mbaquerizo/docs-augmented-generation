---
id: DAG-2
issueType: task
status: done
tags:
  - dag
  - infrastructure
parent: DAG-1
---

# Create shared adapter conventions reference for dag-publish

## Description

There is duplicated logic across the local adapters (`documentation-local.md` and `issue-tracking-local.md`) and implicit conventions that aren't documented anywhere. Create a shared reference document (either a new file like `adapter-conventions.md` or extend `contract.md`) that codifies:

- **Slug generation rules**: character set, max length, collision handling — currently duplicated verbatim in both adapters
- **Timestamp format convention**: ISO 8601 date part `YYYY-MM-DD`, when date prefixes are used vs. not, how fallback to today works — currently only in documentation-local
- **Parent grouping behavior**: how `parent` maps to subdirectory nesting, what it means for ID generation (currently undocumented in issue-tracking-local despite being in the contract)
- **docType field conventions**: what values are valid (`code-exploration`), how they affect filenames, extensibility for future values
- **Defaults vs. explicit configuration**: which config fields have defaults and what they are, which must be explicit, why
- **Error handling**: what happens when required config is missing, when the adapter should fail vs. warn

The reference should be the single source of truth that all adapters (local and future) point to.

## Acceptance criteria

1. A new or extended reference document exists in the dag-publish skill directory
2. All six convention areas are documented
3. The document is structured for easy consumption by future adapter implementations
4. Existing adapter descriptions remain correct (no behavior changes)

## Related docs

- Contract: `plugins/dag/skills/dag-publish/contract.md`
- Parent epic: DAG-1

---
*This ticket was created by opencode and reviewed by a human before publishing.*
