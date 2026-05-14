---
name: commit
description: Stage and commit the current changes. Use when I ask to commit or I invoke the skill directly, or when invoked by the finish-work skill.
---

## 1. Current changes

!`git diff HEAD`

## 2. Instructions

### 2.1 Pre-commit validation

Run any relevant linting, format-checking, type-checking, and testing suites configured in the project. If linting and formatting can be auto-fixed, run the auto-fixes.

If linting and formatting cannot be auto-fixed, or if testing or type-checking fail, report the failures to me. DO NOT attempt to fix code or tests yourself.

Only proceed to the next step if all checks pass, or if I explicitly permit you to.

### 2.2 Summarize and group

Summarize the changes from Section 1. If necessary, group related changes into separate commit groups. Skip changes unrelated to the current work or that should not be committed.

If there is more than one group, send me a summary table of each group before proceeding.

### 2.3 Choose format

Check my preferred commit format from context. If unknown, ask whether I want to use gitmoji or conventional commits.

Format references:
- **Gitmoji** → [gitmoji.md](gitmoji.md)
- **Conventional Commits** → [conventional-commit.md](conventional-commit.md)

### 2.4 Draft

For each group, draft a commit message using the selected format's rules. Present the summary and draft to me and wait for my approval.

### 2.5 Commit

After I approve, commit with that exact message. Do not modify the approved message.

## 3. Rules

These apply regardless of format:
- Subject line (including gitmoji, scope, and message) shall not exceed 50 characters
- Body must be wrapped at 72 character lines
- One emoji, one purpose, one commit — be atomic

## 4. When you are done

Do not push or offer to push.
