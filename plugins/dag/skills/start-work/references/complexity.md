# Complexity assessment reference

## Heuristic

Assess complexity by evaluating the ticket's scope, acceptance criteria, and
linked documents against these dimensions:

| Dimension | Simple | Complex |
|-----------|--------|---------|
| Files touched | 1-3 files, well-understood | 4+ files, across modules |
| Patterns | Existing, well-documented | New patterns or significant refactoring |
| Risk | Localized, low breakage risk | Cross-cutting, high regression risk |
| Dependencies | No new dependencies | New libraries, services, or APIs |
| Data changes | None | Schema migrations, data backfills |

## When to recommend more capable model

If the assessment lands on **Complex** but the current model lacks:

- **Reasoning depth** — Deep multi-step logic
- **Context window** — Cannot hold all relevant files
- **Tool access** — Missing specific tools needed

Report the mismatch and let the user decide.
