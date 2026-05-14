# Shape Up methodology

This reference summarizes key concepts from Ryan Singer's *Shape Up* methodology (Basecamp, 2019). Use it as a coach's guide when running the shape-up skill.

## Core principle: appetite over estimate

Traditional planning asks "How long will this take?" and produces estimates. Shape Up flips this: **set a fixed timebox (appetite) first, then design a solution that fits within it.**

If the solution doesn't fit the appetite, the solution shrinks — not the appetite grows. This forces tradeoffs and prevents scope creep.

## The shaped pitch

A pitch is a lightweight proposal, not a spec. It documents:

- **What** — The problem and proposed solution
- **Why** — The opportunity or pain point
- **How much** — The appetite (timebox)
- **Boundaries** — What's in scope, what's not, what could go wrong

Pitches are shaped before they're scheduled for building. Shaping happens in a separate phase from building.

## Breadboarding

A breadboard is a fat-marker sketch of the solution. It has three elements:

### Places

A place is a screen, view, or state the user moves through. Examples: "Dashboard", "Issue Form", "Settings Page". Places are nouns.

### Affordances

An affordance is an action available in a place. Examples: "Create new issue", "Toggle filter", "Submit form". Affordances are verbs or verb phrases.

### Connections

A connection links places via affordances. Examples: "Issue List → Create new issue → Issue Form", "Issue Form → Submit → Issue Detail".

### Breadboarding tips

- Stay at the right level — don't dive into UI chrome or pixel-level detail
- Use boxes for places, arrows for connections, labels for affordances
- Multiple passes are normal: sketch rough, discuss, refine
- A breadboard should be understandable without additional explanation

## Status lifecycle

```
shaping → shaped → building → done
                 ↘ shelved
```

| Status | Meaning |
|--------|---------|
| `shaping` | In progress — sections may be incomplete, questions unresolved |
| `shaped` | Complete — all required sections done, questions resolved, ready for betting |
| `building` | Being implemented in a cycle |
| `done` | Shipped |
| `shelved` | Set aside — may be revisited later |

## Handling missing voices

If Engineering was absent from the shaping session, note it. Engineering review during the building phase may surface new rabbit holes or scope changes. The pitch should capture enough context for an engineer to review without the shaper present.

## How to run a shaping session (as the coach)

1. **Understand the problem** — Ask questions until you can state the problem back in your own words
2. **Set the appetite** — Guide the user to choose a timebox. If they start estimating tasks, redirect to appetite
3. **Sketch the solution** — Start with places (what screens/states exist), then add affordances (what can the user do), then connect them
4. **Find the edges** — Ask "what could go wrong?" (rabbit holes) and "what are we NOT doing?" (no-gos)
5. **Capture decisions** — Write down key tradeoffs and why they were made
6. **Track open questions** — Anything unresolved gets recorded and blocks `shaped` status
7. **Don't push to implementation** — The shaped pitch is handed off. It doesn't contain implementation details. Those belong in engineering notes or are figured out during building.
