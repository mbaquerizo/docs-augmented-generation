---
name: start-work
description: Code generation
argument-hint: "[ticket number]"
---

Retrieve the ticket and any supporting documentation

complexity check: if simple task, use a lightweight/fast model. More complicated -> use a deeper reasoning model. If the current model's capability does not match the recommended complexity, report to the user, stop, and allow them to either switch or keep before continuing.

Assume branching from the default branch (usually `main`) unless the user specifies otherwise.

Start a new git worktree. Pull the latest from the base first. Create the issue branch, branch name should be `<issue-type>/<issue-number>/<brief-description>`

Start in Plan mode. If further code exploration is needed, go ahead, and then publish results to the ticket description. Propose the plan to the user.

Compose with the /tdd skill.
<!-- insert guidance on how to use /tdd, when are tests needed, not needed. ultimately should follow a red -> implement -> green flow -->

On approval of the plan, start the implementation.

Verify that related tests all pass before handing off to the user.

## When you are done

Do not commit or push. Do not work on any other tickets. You may offer to commit and if approved, use the /commit skill.