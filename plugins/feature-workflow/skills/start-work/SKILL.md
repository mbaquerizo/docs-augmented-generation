---
name: start-work
description: Set up a code generation session from an existing ticket. Creates a worktree, assesses complexity, plans the approach, and implements on approval with optional TDD-first workflow.
argument-hint: "[ticket number]"
---

## 1. Mode check

Check your current operating mode. If you are in Build, Auto, or Accept Edits mode, stop and ask the user to switch to Plan mode before continuing. Mode switching is a tool-level operation — you cannot perform it yourself.

## 2. Input

Accept a ticket ID or feature description from arguments ($ARGUMENTS). If no ticket ID is provided, ask which ticket to work on.

Read the ticket from the issue-tracking adapter: use the project prefix and ID to locate the file in `ticketPath`, then read it.

## 3. Update ticket status

Update the ticket's status from `open` to `in-progress`. Follow the update instructions in `plugins/shared/adapters/issue-tracking/` and the contract in `plugins/shared/adapters/contract.md`:

1. Read the current ticket file
2. Change `status: open` to `status: in-progress`
3. Rewrite the file in place
4. Report the status change to the user

## 4. Load context

Read the ticket body and any linked documents:

- ADRs and code explorations listed in Related docs
- Feature plans or Shape Up pitches
- Source files referenced in acceptance criteria or technical notes

## 5. Complexity check

Assess the complexity of the work based on the ticket scope, acceptance criteria, and linked documents:

- **Simple** — Few files, well-understood patterns, minimal risk of breaking changes. A lightweight approach is sufficient.
- **Complex** — Multiple systems, new patterns, significant refactoring, or high risk. Deep reasoning and code exploration are needed.

If the current model's capability (reasoning depth, context window, tool access) does not match the recommended complexity, report this to the user. Let them decide whether to switch to a more capable model or continue with the current one before proceeding.

## 6. Plan

Propose an implementation approach. If the work is complex, invoke the **code-exploration** subagent first to investigate the codebase and return structured findings.

If code exploration was used, publish the findings document to the ticket body so it is preserved for future reference.

Present the plan to the user and ask for approval before proceeding.

## 7. Worktree setup

Once the plan is approved, set up the working environment:

1. `git fetch` the latest from the default branch (usually `main`)
2. Check existing worktrees with `git worktree list`:
   - If a worktree already exists for this branch or ticket, use it
   - Otherwise create a new worktree rooted from the default branch
3. Branch naming convention: `<issue-type>/<issue-number>/<brief-description>` (e.g. `story/PROJ-42/add-login-endpoint`)

## 8. Implementation

### 8.1 Detect TDD skill

Try to load the **tdd** skill via the `skill` tool. If the tool fails or the skill is unavailable, fall back to checking whether the file exists at `plugins/tdd/skills/tdd/SKILL.md`. If neither succeeds, TDD is not available.

If TDD was set to always-on mode and the detection fails, warn the user and proceed without it.

### 8.2 TDD available — test-first implementation

1. Load the **tdd** skill with the feature ticket's acceptance criteria in context
2. Establish the contract: agree on test framework, runner, assertion style, and test file location
3. Write a failing test for the first behavior (TDD red step) — this is done **before** any production code
4. Implement the minimum production code to pass (green)
5. Run the test suite to confirm nothing regressed
6. Refactor if needed
7. Repeat for each behavior in the acceptance criteria

After all behaviors are implemented, proceed to test verification (section 9).

### 8.3 TDD not available — direct implementation

Implement per the approved plan directly, without test-first requirements.

## 9. Test verification

Run the relevant test suite. Fix any test failures introduced by the implementation. Do not skip failing tests.

## 10. When you are done

Do not commit or push. Offer to commit using `/commit` if the user approves. Do not work on any other tickets.
