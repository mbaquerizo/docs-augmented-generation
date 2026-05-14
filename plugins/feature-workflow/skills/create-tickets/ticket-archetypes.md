# Ticket archetypes

A reference for choosing the right ticket type when breaking down feature work. Each archetype has a specific purpose, size expectation, and template.

## Frontmatter fields (all tickets)

| Field | Required | Description |
|-------|----------|-------------|
| `id` | auto | Assigned by the issue-tracking adapter on publish |
| `issueType` | yes | One of: `epic`, `story`, `task`, `bug`, `spike` |
| `status` | yes | One of: `open`, `in-progress`, `in-review`, `done` |
| `tags` | no | List of labels for categorization |
| `parent` | no | Parent epic ID or grouping identifier |

## Archetypes

### Epic

A large body of work that spans multiple stories. Epics are placeholders for
coordination — they track progress across several PR-sized units.

**When to use**: The work cannot be delivered in a single PR (~15 min review).
Epics group stories that share a common goal, feature area, or theme.

**Size**: Multiple sprints or cycles. Break into stories before starting work.

**Template**:

```markdown
---
issueType: epic
status: open
tags:
  - area
---

# {Epic Title}

## Description

Summary of the feature or goal this epic encompasses.

## Scope

- **In scope**: {list of what this epic covers}
- **Out of scope**: {explicit non-goals}

## Related docs

- ADR: {link}
- Code exploration: {link}
- Feature plan: {link}

## Stories

- {story title} ({ID})
- {story title} ({ID})
```

---

### Story

A vertical slice of user-valuable functionality. Stories should be
PR-sized: implementable, testable, and reviewable in ~15 minutes.

**When to use**: You can describe the work from a user's perspective ("As a...,
I want..., So that..."). If the work doesn't have a clear user benefit, it
may be a task instead.

**Size**: 1 PR (~15 minute review). If it feels larger, split it.

**Template**:

````markdown
---
issueType: story
status: open
tags:
  - area
---

# {Story Title}

## Description

{As a... I want... So that...}

## Acceptance criteria

1. {condition 1}
2. {condition 2}

## Scenarios

```gherkin
Scenario: {scenario name}
  Given {precondition}
  When {action}
  Then {expected outcome}
```

Add one `Scenario` block per covered case. Omit `Scenario Outline` and `Examples:` — list scenarios flatly.

## Technical notes

{optional implementation guidance from ADR or exploration}

## Related docs

- ADR: {link}
- Code exploration: {link}
- Parent epic: {link}

---
*Created by AI, reviewed by a teammate.*
````

---

### Task

A concrete piece of work that doesn't deliver direct user value but is
necessary for the project. Tasks are often technical or operational.

**When to use**: Configuration changes, dependency updates, tooling,
refactoring, CI setup, documentation.

**Size**: 1 PR (~15 minute review). If a task grows beyond that, split
into subtasks or reconsider whether it's a story.

**Template**:

```markdown
---
issueType: task
status: open
tags:
  - area
---

# {Task Title}

## Description

What needs to be done and why. Include any research or context.

## Acceptance criteria

1. {completion criterion 1}
2. {completion criterion 2}

## Related docs

- ADR: {link}
- Code exploration: {link}

---
*Created by AI, reviewed by a teammate.*
```

---

### Bug

An defect or regression in existing functionality.

**When to use**: Something is broken, behaves incorrectly, or produces
unexpected results compared to the specification.

**Size**: 1 PR, but investigation time may vary. If a bug requires a
design decision to fix, pair it with a spike first.

**Template**:

```markdown
---
issueType: bug
status: open
tags:
  - area
---

# {Bug Title}

## Description

What is the unexpected behavior?

## Steps to reproduce

1. {step 1}
2. {step 2}
3. {step 3}

## Expected behavior

What should happen instead?

## Environment

- Browser/OS/version: {relevant environment details}

## Related docs

- ADR: {link}

---
*Created by AI, reviewed by a teammate.*
```

---

### Spike

A timeboxed investigation to reduce uncertainty. Spikes produce a
recommendation or findings document, not production code.

**When to use**: The team needs to evaluate an approach, research a
library, explore a migration path, or reproduce an intermittent issue.
Spikes should always have a clear output goal.

**Size**: Timeboxed (hours to days). If the investigation stretches,
reassess whether more structure is needed.

**Template**:

```markdown
---
issueType: spike
status: open
tags:
  - area
---

# {Spike Title}

## Goal

What question is being answered, or what decision is being informed?

## Approach

How will the investigation be conducted?

## Output

What will be produced (doc, recommendation, ADR, prototype)?

## Timebox

{estimated duration}

## Related docs

- Code exploration: {link}

---
*Created by AI, reviewed by a teammate.*
```

## Archetype selection guide

| When work is... | Use |
|-----------------|-----|
| Large, spans multiple PRs | Epic |
| User-valuable, fits in one PR | Story |
| Technical/operational, no direct user value | Task |
| Defect in existing functionality | Bug |
| Uncertain — needs investigation first | Spike |

Do not use `subtask` as an issue type. Use parent-child relationships
(epic → story/task/bug/spike) instead.

---
*This reference was created by AI and reviewed by a teammate.*
