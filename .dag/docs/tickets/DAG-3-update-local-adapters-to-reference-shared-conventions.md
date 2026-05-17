---
id: DAG-3
issueType: task
status: done
tags:
  - dag
  - infrastructure
parent: DAG-1
---

# Update local adapters to reference shared conventions

## Description

Both `documentation-local.md` and `issue-tracking-local.md` currently inline their slug generation rules and filename conventions. Once the shared conventions reference exists (see DAG-2), update both adapters to remove duplicated specs and instead reference the shared document.

For example, the slug generation paragraph in both files ("lowercase, replace non-alphanumeric characters with hyphens...") becomes: "Generate the slug per the shared adapter conventions (see `adapter-conventions.md`)."

This reduces duplication and ensures future adapters automatically inherit the same conventions.

## Acceptance criteria

1. `documentation-local.md` references the shared conventions for slug generation, timestamp formatting, and parent grouping instead of inlining the spec
2. `issue-tracking-local.md` references the shared conventions for slug generation and adds explicit note about `parent` support (or documents that it is unsupported)
3. No behavior changes — the generated output must be identical
4. A reader of either adapter can find and follow the conventions reference without ambiguity

## Related docs

- Shared conventions: `plugins/dag/skills/dag-publish/adapter-conventions.md` (or wherever DAG-2 places it)
- Parent epic: DAG-1

---
*This ticket was created by opencode and reviewed by a human before publishing.*
