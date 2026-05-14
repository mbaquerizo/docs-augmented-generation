---
name: create-tickets
description: Suggest ticket hierarchy for planned feature and publish tickets to the configured issue tracker.
argument-hint: "[feature description]"
---

## 1. Input

If we just planned a feature using the `/plan-feature` skill, use the resulting
ADR and code exploration as input. Otherwise use the provided arguments. If
neither is available, ask what feature to create tickets for.

Read any linked ADR, code exploration, or feature plan documents to understand
the scope, architecture decisions, and implementation approach.

## 2. Determine ticket hierarchy

Use the archetypes in [ticket-archetypes.md](ticket-archetypes.md) to draft
a group of tickets:

- Start with a single **epic** that groups all work for this feature
- Break the epic into **stories** (user-valuable, PR-sized units)
- Add **tasks** for technical/operational work
- Add **bugs** if the feature fixes existing defects
- Add **spikes** if any implementation details need investigation

Each ticket should be PR-sized (~15 minute review). Note blocking or other
relationships between tickets (e.g. "blocked by", "related to").

## 3. Validate

### Verb check

For each ticket (excluding epics and spikes), examine the title:

1. Count the verbs in the ticket title
2. If there is more than one verb AND each verb could form a logical unit on
   its own, split the ticket

**Examples**:

| Title | Verbs | Verdict |
|-------|-------|---------|
| Add user login endpoint | 1 (add) | OK |
| Create database schema and migrate data | 2 (create, migrate) | Split |
| Add user login and update profile page | 2 (add, update) | Split |
| Implement search with filters | 1 (implement) | OK |
| Set up CI pipeline and configure deployment | 2 (set up, configure) | Split |
| Replace schema, update APIs, and update UI | 3 (replace, update, update) | Split |

When splitting, ensure each resulting ticket is independently valuable where
possible.

### Break check

Ensure that no single ticket introduces a breaking change. If a ticket would
break existing functionality, and a downstream ticket resolves the break, the
grouping is wrong — restructure so upstream changes are never breaking at any
point.

**Example**:

```
Ticket A: Replace Schema
Ticket B: Update APIs to use new schema shape (blocked by A)
Ticket C: Update UI to use new API shape (blocked by B)
```

Check:
- Ticket A alone: Break — old API consumers will fail
- Ticket A + B: Still broken — old UI consumers will fail
- Ticket A + B + C: Fixed, but too late — app is broken between A and B+C

**Restructured**:

```
Ticket A: Add new schema (non-breaking addition)
Ticket B: Add new API using new schema (blocked by A, still unused)
Ticket C: Replace old API in UI with new API (blocked by B)
Ticket D: Clean up old schema and API (blocked by C, optional)
```

Check:
- Ticket A: OK — new schema added, nothing uses it yet
- Ticket A + B: OK — new API exists, still unused
- Ticket A + B + C: OK — UI uses new API, old API and schema still exist
- With D: Cleanup — old code removed, all consumers have migrated

Apply this pattern to your ticket hierarchy. If any sequence of tickets (in
implementation order) would leave the app in a broken state, restructure.

## 4. Propose tickets

Present the full hierarchy to the user. For each ticket, show the
drafted markdown using its archetype template so the user can review
the full content before approving:

- List every ticket with its archetype, title, acceptance criteria,
  scenarios, and relationship notes
- Show each ticket as formatted markdown (the full template output)
- Explain the rationale for any significant splits or restructuring
- Ask for approval

Allow revisions to the hierarchy, titles, descriptions, or any
ticket detail.

## 5. Publish

On approval, publish each ticket using the issue-tracking adapter.
Follow the adapter instructions in `plugins/shared/adapters/issue-tracking/`
and the contract in `plugins/shared/adapters/contract.md`.

The adapter instructions end with "Return the output path" — capture it
for each ticket published.

1. Read `.docs-driven/config.json` to find the enabled issue-tracking adapter
2. Publish each ticket individually:
   - `type`: `ticket`
   - `title`: ticket title
   - `body`: full ticket description including acceptance criteria,
     scenarios, technical notes, and links to planning documents.
     Replace `{model}` in the footer with the current tool name
     (e.g. "Claude Code", "opencode")
   - `metadata.issueType`: the archetype (`epic`, `story`, `task`, `bug`, `spike`)
   - `metadata.status`: `open`
   - `metadata.tags`: relevant tags from planning
   - Capture the returned path
3. After all tickets are published, present a summary table:
   ```
   {ID}  {archetype}  {title}  →  {published path}
   ```

## 6. When you are done

Do not make any code changes; do not start working on any of the tickets.
