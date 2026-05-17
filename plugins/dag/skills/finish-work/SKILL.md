---
name: finish-work
description: Ensure all work is committed, sync with base branch, push, and create or update a pull request. Use when I ask to create a PR or invoke the skill directly.
---

## 1. Pre-flight checks

Before proceeding, validate the environment:

- **Remote** — Check `git remote -v`. If no remote is configured, report: "No remote configured. Set one with `git remote add origin <url>`" and stop.
- **GitHub CLI** — Check that `gh` is installed (`gh --version`). If missing, report: "Install GitHub CLI: https://cli.github.com/" and stop.

## 2. Ensure clean working tree

Run `git status`:

- If there are unstaged or uncommitted changes, invoke the **commit** skill. Wait for the commit to complete before proceeding.
- If the working tree is clean, continue.

## 3. Sync with base branch

Detect the default base branch:

1. `git remote show origin` — extract the HEAD branch (typically `main`)
2. `git fetch origin <base>`
3. `git rebase <base>` — rebase your branch onto the latest base

**If rebase conflicts occur:**

- Run `git rebase --abort`
- Report to the user: "Rebase conflicted on: <list of conflicted files>"
- Stop. Do not force-resolve or continue.

If rebase succeeds, force-push with lease:

- `git push --force-with-lease origin <current-branch>`

## 4. Create or update PR

Check whether a PR already exists for this branch:

```
gh pr list --head <current-branch> --state open --json number,title,url
```

### If a PR already exists

Check whether there are new changes worth calling out since the last update:

- Review `git log` since the last push or PR update
- If there are meaningful new changes, draft an updated body using the PR template (`pr-template.md`) with the latest commit log and context. Present the draft to the user. After approval, update it:
  ```
  gh pr edit <number> --body "<updated body>"
  ```
- If there are no meaningful new changes, the work is complete after the push — no PR update needed.

### If no PR exists — create one

Use the PR template (`pr-template.md`) as the structure. Populate the body with:

- **Issue** — Link or reference the ticket ID
- **Summary** — Synthesized from the ticket description (in context) and `git log <base>...HEAD --oneline`
- **Changes** — Key changes derived from commit messages
- **Tests** — Note test coverage from the session context

Draft the PR and present it to the user for approval. After approval, create it:

```
gh pr create --title "<summary>" --body "<body>" --base <base>
```

Optionally add labels: `ai-authored` or `ai-assisted` if applicable.

## 5. Update ticket status

Extract the ticket ID from the branch name (e.g. `story/PROJ-4/...` → `PROJ-4`):

1. Read `.dag/config.json` to find `ticketPath` under `adapters.issue-tracking.config` (default: `./.planning/tickets`)
2. Follow the [retrieval instructions](plugins/dag/skills/dag-publish/issue-tracking-local.md) to locate the ticket file by its ID
3. Change `status: in-progress` to `status: in-review` in the frontmatter
4. Rewrite the file in place
5. Report the status change: "PROJ-4 moved to in-review"

## 6. Report

Display the PR URL:

```
gh pr view <number> --json url --jq .url
```

Print the URL to the user.

## When you are done

Do not review or merge the PR.
