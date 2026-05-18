---
docType: code-exploration
date: 2026-05-17
---

# Code exploration for epic orchestration

## 1. Ticket data model

**File:** `plugins/dag/skills/create-tickets/ticket-archetypes.md`

### Frontmatter fields (all tickets)

| Field | Required | Description | Currently used? |
|-------|----------|-------------|-----------------|
| `id` | auto | Adapter-assigned on publish | Yes |
| `issueType` | yes | `epic`, `story`, `task`, `bug`, `spike` | Yes |
| `status` | yes | `open`, `in-progress`, `in-review`, `done` | Yes |
| `tags` | no | List of labels | Yes |
| `parent` | no | Parent epic ID or grouping identifier | Documented but not wired through publish |

### Key finding: `parent` exists, `blockedBy` and `children` do NOT

- **`parent`** is documented in the frontmatter fields table as optional. It is a **string** — a ticket can have at most one parent.
- **`blockedBy`** is NOT in the frontmatter fields table. Ticket DAG-12 was opened to add it and is still `open`.
- **`children`** does NOT exist anywhere. Epics infer children only from the `## Stories` section in their body template, which is plain markdown text — not a metadata field.

### Epic vs story structure

Epics are distinguished solely by `issueType: epic`. No structural fields differentiate them beyond that. Children point **up** via `parent` (conceptually, not yet in practice), but there is no automated `children` aggregation at the data level.

---

## 2. create-tickets flow

**File:** `plugins/dag/skills/create-tickets/SKILL.md`

### Does it set `parent` on child tickets?

**No.** The publish step instructs:

```
metadata.issueType: <archetype>
metadata.status: open
metadata.tags: <tags>
```

There is **no instruction** to set `parent` on child tickets when publishing. The hierarchy is presented to the user in the proposal as a flat list under the epic, but the parent-child relationship is **not persisted** in published ticket files — it exists only in the proposal display.

### Does it set `children` on epics?

**No.** The `children` field does not exist. The epic's body template lists stories as plain markdown text, not metadata.

---

## 3. start-work skill

**File:** `plugins/dag/skills/start-work/SKILL.md`

### Phases

| Phase | Steps | Write access | Pauses? |
|-------|-------|-------------|---------|
| **Phase 1 — Setup** | Mode check, Input (read ticket), Update status (open → in-progress), Load context, Complexity check, Worktree setup | Yes | Yes — after worktree creation |
| **Phase 2 — Planning** | Code exploration, Plan proposal, Iterative discussion, User approval | No (read-only) | Yes — for explicit approval |
| **Phase 3 — Implementation** | TDD detection, TDD cycle or direct implementation, Test verification | Yes | Stops |

### Worktree creation

Worktree is created in Phase 1 Step 6: `git worktree add` from the default branch. Branch naming: `<issue-type>/<issue-number>/<brief-description>`.

### What would need to change for pre-created worktree support

- Step 2 (Input): Accept an optional `worktreePath` parameter alongside the ticket ID.
- Step 6 (Worktree): If worktree path is provided, verify it and skip `git worktree add`.
- Branch naming: Orchestrator-created branches use a wider convention (`epic/DAG-42/story/DAG-43/slug`). start-work would need to accept any branch name, not just the two-segment pattern.
- Status update: If the orchestrator handles status, start-work should skip Phase 1 Step 3.

---

## 4. finish-work skill

### How it creates PRs

1. Pre-flight checks (remote, `gh` CLI)
2. Commit pending changes via the commit skill
3. Sync with base: `git rebase <base>`, force-push with lease
4. Create/update PR: `gh pr create --title "..." --body "..." --base <base>`
5. Update ticket status: extract ticket ID from branch name, change `in-progress` to `in-review` in frontmatter

### Can it target a non-main base branch?

**Not currently.** The base branch is auto-detected as the remote's HEAD branch (typically `main`). There is no parameter for specifying a different base.

### Does it support draft PRs?

**No.** The `gh pr create` command does not include `--draft`.

---

## 5. dag-publish contract

**File:** `plugins/dag/skills/dag-publish/contract.md`

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `type` | yes | string | `adr`, `pitch`, or `ticket` |
| `title` | yes | string | Display heading |
| `body` | yes | string (markdown) | Main content |
| `parent` | no | string | Grouping identifier for related documents |
| `metadata` | no | object | Structured fields: `status`, `tags`, `date`, and adapter-specific fields |

The `parent` field has different meaning by adapter:
- **Documentation**: nests files in subdirectories (structural grouping).
- **Issue-tracking (local)**: **Unsupported. Silently ignored.**
- **Issue-tracking (future cloud)**: Not yet defined.

No `blockedBy` or `children` exists in the contract.

---

## 6. Local issue-tracking adapter

**File:** `plugins/dag/skills/dag-publish/issue-tracking-local.md`

### Metadata handling

The contract mapping table:

| Contract field | Destination |
|----------------|-------------|
| `type` | Unused (reserved for future) |
| `title` | File heading and slug for filename |
| `body` | Body content after frontmatter |
| `parent` | **Unsupported. Silently ignored.** |
| `metadata` | Serialized as YAML frontmatter |

Only adapter-specific field: `issueType` (required).

### `parent`, `children`, `blockedBy` support

- **`parent`**: Unsupported. Silently ignored. Does not get written into the file.
- **`children`**: Not supported. Not documented.
- **`blockedBy`**: Not supported. DAG-12 (open) specifies adding it.

### Ticket ID generation

1. Scan `ticketPath` for `{project}-\d+-*.md`
2. Find highest existing ID, increment by 1
3. Set `id` in metadata
4. Generate filename: `{project}-{n}-{slug}.md`

---

## 7. Local documentation adapter

**File:** `plugins/dag/skills/dag-publish/documentation-local.md`

### ADR publishing with `parent` grouping

The `parent` field is **fully supported**:

> "If `parent` is provided, append it: `{directory}/{parent}`"

For example, with `parent: epic-orchestration`:
- ADR: `{adrPath}/epic-orchestration/{date}-{slug}.md`
- Code exploration: `{adrPath}/epic-orchestration/{date}-CE-{slug}.md`

### Filename patterns

| Document type | Pattern |
|---------------|---------|
| ADR | `{YYYY-MM-DD}-{slug}.md` |
| Code exploration | `{YYYY-MM-DD}-CE-{slug}.md` |
| Pitch | `{slug}.md` |

---

## 8. DAG-12 — `blockedBy` field

**Status:** `open` (NOT done)

**Specified scope:**
1. `ticket-archetypes.md`: Add `blockedBy` to frontmatter fields table and templates
2. `issue-tracking-local.md`: Document as supported adapter-specific metadata field
3. Shared conventions: Cover `blockedBy` for cross-adapter consistency
4. `create-tickets` SKILL.md: Populate `blockedBy` when drafting tickets

---

## Summary of gaps for epic orchestration

| Capability | Current state | Needed for |
|-----------|--------------|------------|
| `parent` on tickets | Documented but **not wired** through create-tickets publish flow | Epic → child metadata linking |
| `blockedBy` | **Not implemented** (DAG-12) | Dependency ordering across stories |
| `children` on epics | **Does not exist** | Reverse lookup of epic's children |
| Issue-tracking adapter `parent` support | **Silently ignored** | Persisting parent-child in ticket files |
| Branch targeting in finish-work | Always targets remote HEAD | Feature-branch or stacked-branch PRs |
| Draft PR support | Not supported | Stacked PR dependency signaling |
| Pre-created worktree acceptance | Not supported | Epic-level worktree setup |
| `parent` in create-tickets publish step | **Not set** | Persisting which epic a ticket belongs to |
| Epic body `## Stories` section | Static markdown text | Auto-populated child ticket list |
