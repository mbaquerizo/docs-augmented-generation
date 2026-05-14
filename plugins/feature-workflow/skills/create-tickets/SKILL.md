---
name: create-tickets
description: Suggest ticket hierarchy for planned feature and publish tickets to user's preferred issue tracker.
argument-hint: "[feature description?]"
disable-model-invocation: true
model: sonnet
---

If we just planned a feature using the /plan-feature skill, use that as input. Otherwise use arguments: $ARGUMENTS, or if none provided, ask me what I want to create tickets for.

## Determine ticket hierarchy

Draft a ticket or group of tickets, based on the following ticket archetypes: epic, story, task, bug, spike. Do not use subtask types. Note blocking or other relationships between proposed tickets

<!--
insert ticket types, when to use, or link to a supporting document or sibling skill (issue-creation)
the supporting document should include:
- format/template for each type
  - template should include links to any relevant docs (e.g. ADR, code exploration, feature plan) produced during planning stages
  - template should include a message at bottom saying this was created by AI and reviewed by a teammate
-->

Each ticket should be a logical, PR-sized (~15 minute review by engineer) unit. Before showing me your suggested hierarchy, use the following checks to determine if any ticket or tickets are too large, and revise the proposal accordingly.

### Verb Check:
Count verbs in the suggested ticket name, if more than one, this may need be split if each verb can be split into a logical unit.
<!-- insert examples -->

### Break Check
Ensure that tickets will not introduce any breaking changes. If a blocking ticket resolves the break, this is a failure. Restructure the tickets so that upstream changes are not breaking.

<!-- iron out following example -->

Ticket A: Replace Schema
Ticket B: Update APIs to use new schema shape (blocked by A)
Ticket C: Update UI to use new API shape (blocked by C)

Check:
Ticket A: Breaks
Ticket A + B: Fixes API but breaks UI
Tickat A + B + C: Fixed, but too late because app broken between Ticket A implementation and now

Potential Fix:
Ticket A: Add new schema
Ticket B: Add new API using new schema (blocked by A)
Ticket C: Replace old API in UI with new API (blocked by B)
Ticket D: (optional) Clean up old schema/api (blocked by C)

Check:
Ticket A: OK, new schema introduced, unused
Ticket A + B: OK, new API still unused
Ticket A + B + C: OK, using new API and 

## Propose tickets

Once all checks are complete, show them to me for my approval

## Publish

On my approval, publish the tickets with any relevant tags.

## When you are done

Do not make any code changes; do not start working on any of the tickets.