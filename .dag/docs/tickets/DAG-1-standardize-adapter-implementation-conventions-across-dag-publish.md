---
id: DAG-1
issueType: epic
status: done
tags:
  - dag
  - infrastructure
---

# Standardize adapter implementation conventions across dag-publish

## Description

The dag-publish local adapters (`documentation-local.md` and `issue-tracking-local.md`) contain duplicated logic and implicit conventions that aren't documented in a shared location. This makes it harder to write new adapters and increases the risk of drift between implementations. This epic covers creating a shared conventions reference and updating existing adapters to use it.

## Scope

- **In scope**: Creating a shared conventions reference document, updating local adapters to use it
- **Out of scope**: Implementing new adapters (GitHub, Jira, etc.), changing adapter behavior

## Related docs

- Contract: `plugins/dag/skills/dag-publish/contract.md`
- ADR: (none yet)

## Stories

- Create shared adapter conventions reference for dag-publish
- Update local adapters to reference shared conventions
