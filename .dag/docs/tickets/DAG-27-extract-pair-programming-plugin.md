---
id: DAG-27
issueType: task
status: open
tags:
  - dag
  - repo
  - extraction
parent: DAG-24
blockedBy: [DAG-25]
---

# Extract pair-programming plugin to own repo

## Description

The pair-programming plugin has no relationship to DAG's documentation
conventions scope. Extract it to its own repository via git subtree split
to preserve history, then remove from this monorepo and update AGENTS.md.

## Acceptance criteria

1. `git subtree split --prefix=plugins/pair-programming` produces a standalone
   branch with full history
2. New repository is created and the split branch is pushed (location TBD)
3. `plugins/pair-programming/` is deleted from this repo
4. AGENTS.md structure section no longer references pair-programming

## Related docs

- Plugin location: `plugins/pair-programming/`

---

*This ticket was created by opencode and reviewed by a human before publishing.*
