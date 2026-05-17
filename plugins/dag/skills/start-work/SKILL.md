---
name: start-work
description: This skill should be used when the user says "start working on ticket DAG-11",
  "begin implementation for PROJ-42", "set up a worktree for this ticket",
  or wants to start a code generation session from an existing ticket. Handles
  worktree setup, iterative planning, and implementation with optional TDD.
argument-hint: "[ticket number]"
---

## Phase 1 — Setup

Preparation steps that require write access: read the ticket, update its
status, and create a dedicated worktree. After this phase the model must
stop and pause, and the user acknowledges the worktree before Phase 2.

### 1. Mode check

Check the current operating mode. If in Build, Auto, or Accept Edits mode,
note that Phase 2 (Planning) requires Plan-mode etiquette (read-only,
iterative discussion, no code). Mode switching is a tool-level operation —
the model cannot perform it.

### 2. Input

Accept a ticket ID or feature description from arguments ($ARGUMENTS).
If no ticket ID is provided, ask which ticket to work on.

Read the ticket from the issue-tracking adapter:

1. Read `.dag/config.json` to find the `project` prefix under
   `adapters.issue-tracking.config.project` and the ticket directory under
   `adapters.issue-tracking.config.ticketPath` (default: `./.planning/tickets`)
2. Follow the [retrieval instructions](plugins/dag/skills/dag-publish/issue-tracking-local.md)
   to locate and read the ticket file by its ID

For context on the ticket data model, see the
[publish contract](plugins/dag/skills/dag-publish/contract.md).

### 3. Update ticket status

Update the ticket's status from `open` to `in-progress` using the
dag-publish skill:

1. Read the current ticket file
2. Change `status: open` to `status: in-progress`
3. Rewrite the file in place
4. Report the status change to the user

### 4. Load context

Read the ticket body and any linked documents:

- ADRs and code explorations listed in Related docs
- Feature plans or Shape Up pitches
- Source files referenced in acceptance criteria or technical notes

### 5. Complexity check

Assess the work's complexity:

- **Simple** — Few files, well-understood patterns, low risk
- **Complex** — Multiple systems, new patterns, high risk

See `references/complexity.md` for the full assessment heuristic.

If the assessment lands on **Complex** and the current model's capability
(reasoning depth, context window, tool access) does not match, report this
to the user. Let them decide whether to switch to a more capable model or
continue before proceeding.

### 6. Worktree setup

Set up the working environment before any planning or implementation.
A dedicated worktree isolates changes on the main branch and prevents
in-progress work from affecting other sessions.

1. `git fetch` the latest from the default branch (usually `main`)
2. Check existing worktrees with `git worktree list`:
   - If a worktree already exists for this branch or ticket, use it
   - Otherwise create a new worktree rooted from the default branch
3. Branch naming convention: `<issue-type>/<issue-number>/<brief-description>`
   (e.g. `story/PROJ-42/add-login-endpoint`)

After the worktree is created, stop. Report its path to the user and
pause before proceeding to Phase 2.

---

## Phase 2 — Planning

Read-only phase. Do not write any code or make any changes. Adopt
Plan-mode etiquette regardless of the current operating mode: propose,
discuss, iterate. The user must explicitly approve implementation before
Phase 3 begins.

### 7. Plan

Propose an implementation approach. If the work is complex, invoke the
**code-exploration** subagent first to investigate the codebase and
return structured findings.

If code exploration was used, publish the findings document to the ticket
body so it is preserved for future reference.

Present the initial approach to the user. The goal is to converge on a
shared understanding — expect multiple exchanges:

- Propose options and tradeoffs
- Ask clarifying questions
- Refine based on feedback
- Discuss ordering or grouping of work

When the user signals agreement, stop and ask for explicit approval:

> "Ready to start implementation. Shall I proceed?"

Do not proceed to Phase 3 without this approval.

---

## Phase 3 — Implementation

Write access resumed. Execute the approved plan.

### 8.1 Detect TDD skill

Try to load the **tdd** skill. If unavailable, TDD is not available.

If TDD was set to always-on mode and detection fails, warn the user and
proceed without it.

### 8.2 TDD available — test-first implementation

1. Load the **tdd** skill with the feature ticket's acceptance criteria
   in context
2. Establish the contract: agree on test framework, runner, assertion
   style, and test file location
3. Write a failing test for the first behavior (TDD red step) — before
   any production code
4. Implement the minimum production code to pass (green)
5. Run the test suite to confirm nothing regressed
6. Refactor if needed
7. Repeat for each behavior in the acceptance criteria

After all behaviors are implemented, proceed to test verification (§9).

### 8.3 TDD not available — direct implementation

Implement per the approved plan directly, without test-first requirements.

### 9. Test verification

Run the relevant test suite. Fix any test failures introduced by the
implementation. Do not skip failing tests.

### 10. Stop

Do not commit or push. Offer to commit using `/commit` if the user
approves. Do not work on any other tickets.
