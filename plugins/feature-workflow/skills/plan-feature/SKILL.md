---
name: plan-feature
description: Plan architectural design for a feature idea or problem. Produces a code exploration document and an Architecture Decision Record (ADR) published to the configured documentation endpoint.
argument-hint: "[feature idea or problem description]"
---

## 1. Input

Accept a feature idea, problem description, feature plan document, or a Shape Up pitch (which may contain engineering notes to feed into this session).

If a Shape Up pitch is provided, read its Engineering notes and Solution sections to understand what's already been shaped at a product level.

If no input is provided, ask.

## 2. Understand the problem

Before exploring code or proposing solutions, make sure the problem is well understood. Ask clarifying questions:

- What is the problem or opportunity?
- Who is the user or stakeholder?
- What are the success criteria?
- Are there any constraints (time, resources, compatibility)?
- Do you have any initial ideas about the solution?

Allow for back-and-forth. This is a deep planning session — be honest about tradeoffs and unknowns.

## 3. Code exploration

Invoke the **code-exploration** subagent with the feature description and problem context. The subagent will investigate the codebase and return structured findings.

Read the findings document carefully. If anything is unclear or contradicts the user's expectations, clarify before proposing solutions.

## 4. Solution proposal

Based on the problem understanding and code exploration findings, propose 2-3 viable approaches. For each option, evaluate:

| Criteria | What to assess |
|----------|----------------|
| Complexity | How much code changes, how many files affected, how many teams/systems involved |
| Impact | What improves, what degrades, side effects |
| Risk | Breaking changes, performance regressions, security concerns |
| Pattern alignment | How well it fits existing architecture and conventions |

Present the options to the user with these tradeoffs. Discuss and iterate.

## 5. Draft ADR

Once a solution is chosen, draft an Architecture Decision Record using the template in [adr-template.md](adr-template.md).

The ADR should include:
- The context that necessitated the decision
- The options considered and their tradeoffs
- The chosen option with rationale
- The consequences (what becomes easier, harder, or different)

Also draft a **code exploration document** containing the subagent's findings. The ADR should reference this doc with a link (use a placeholder if not yet published).

## 6. Review

Present both documents to the user:

1. **Code exploration** — The findings document from the subagent
2. **ADR** — The decision record with options, chosen solution, and consequences

Ask for approval before publishing. Allow revisions.

## 7. Publish

Publish using the documentation adapter with a shared `parent` value so both documents are grouped together. Follow the adapter instructions in `plugins/shared/adapters/documentation/` and the contract in `plugins/shared/adapters/contract.md`.

The adapter instructions end with "Return the output path" — capture it for each document published.

1. Determine a parent identifier: `{timestamp}-{feature-slug}` (e.g. `2026-05-14-add-user-auth`)
2. Publish the code exploration doc first:
   - `type`: `adr`, `title`: exploration doc title, `body`: findings
   - `parent`: the feature identifier
   - `metadata.docType`: `"code-exploration"`
   - Capture the returned path
3. Update the ADR body with the published code exploration path
4. Publish the ADR:
   - `type`: `adr`, `title`: ADR title, `body`: full ADR with link
   - `parent`: the same feature identifier
   - (no `docType` — defaults to ADR naming)
   - Capture the returned path
5. Report both published paths to the user

## 8. When you are done

Do not make any code changes. Do not create tickets.
