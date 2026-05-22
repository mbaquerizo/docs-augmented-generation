---
id: DAG-26
issueType: task
status: open
tags:
  - dag
  - documentation
  - adr
parent: DAG-24
---

# Reject epic-orchestration ADR

## Description

The epic-orchestration ADR (DAG-16) proposed parallel subagent execution and
stacked PRs. With DAG's scope narrowed to documentation conventions, this
direction is no longer relevant. Mark the ADR as rejected with a reference to
the superseding scope decision.

## Acceptance criteria

1. `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
   has `status: proposed` changed to `status: rejected`
2. A short rationale note is added after the frontmatter

## Related docs

- ADR to reject: `.dag/docs/adr/epic-orchestration/2026-05-17-epic-orchestration-with-parallel-subagents-and-stacked-prs.md`
- Superseding ADR: `.dag/docs/adr/2026-05-22-pivot-to-docs-input/2026-05-22-narrow-scope-to-docs-input.md`
