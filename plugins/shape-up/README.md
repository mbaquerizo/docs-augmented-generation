# shape-up

Turn feature ideas or meeting transcripts into structured Shape Up pitches. Each pitch captures the problem, appetite, solution, and risks — a DAG-ready document that feeds downstream planning.

## Prerequisites

- A documentation adapter configured in `.dag/config.json` (pitches publish via the adapter)

## Skills

| Skill | Invocation | What it does |
|-------|------------|--------------|
| shape-up | `/shape-up` | Walks through appetite sizing, breadboarding, solution shaping, and publishes a pitch with status lifecycle (shaping → shaped → building → done) |

## Reference docs

- [pitch-structure.md](skills/shape-up/pitch-structure.md) — 7-section pitch template
- [shape-up-methodology.md](skills/shape-up/shape-up-methodology.md) — Shape Up fundamentals guide

## Related

Pitches produced by this plugin can be broken into tickets using the feature-workflow plugin's `/create-tickets` skill.