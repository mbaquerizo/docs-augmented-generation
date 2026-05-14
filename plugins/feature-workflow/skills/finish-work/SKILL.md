---
name: finish-work
description: Stage and commit any uncommitted work, sync, push, and create or update a pull request. Use when I ask to create a PR or invoke the skill directly.
---

## Context
- Status: !`git status`
- Log: !`git log --oneline -10`

## Instructions

If there are any unstaged or uncommitted changes, determine if they should be committed and commit using the commit skill

Ensure up to date with base branch, rebase/merge if needed

Push to remote

Draft a PR using the template in .github/PULL_REQUEST_TEMPLATE.md. If one does not exist, use the pr template in [pr-template.md](pr-template.md)

Ask for PR draft approval

After approval, create the PR with "ai-authored" or "ai-assisted" tags if applicable.

## When you are done

Do not review or merge the PR.