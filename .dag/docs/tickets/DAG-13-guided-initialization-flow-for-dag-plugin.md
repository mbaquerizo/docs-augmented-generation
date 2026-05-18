---
id: DAG-13
issueType: epic
status: open
tags:
  - dag
  - onboarding
  - developer-experience
---

# Epic: Guided initialization flow for DAG plugin

## Description

Installing the DAG plugin requires manually creating `.dag/config.json`. No guided setup, no defaults, no validation. Provide an interactive bash script (`plugins/dag/scripts/dag-init.sh`) that scaffolds the config and directory structure.

## Scope

- **In scope**: Interactive bash script, atomic write with backup, `.dag/docs/` directory scaffolding with `.gitkeep`
- **Out of scope**: Cloud adapter scaffolding, headless/CI mode, plugin installation, post-scaffold verification

## Related docs

- ADR: `.dag/docs/adr/2026-05-17-guided-init-flow/2026-05-17-guided-initialization-flow-for-dag-plugin.md`
- Code exploration: `.dag/docs/adr/2026-05-17-guided-init-flow/2026-05-17-CE-code-exploration-guided-initialization-flow-for-dag-plugin.md`
- Pitch: `.dag/docs/pitches/2026-05-16-guided-initialization-flow-for-dag-plugin.md`

## Stories

- DAG-14 — Create interactive init script for scaffolding .dag/config.json
- DAG-15 — Update documentation from .planning/ to .dag/docs/
