---
id: DAG-14
issueType: story
status: open
tags:
  - dag
  - onboarding
  - developer-experience
---

# Story: Create interactive init script for scaffolding .dag/config.json

## Description

As a new DAG plugin user, I want to run a single command that interactively scaffolds my `.dag/config.json` and `.dag/docs/` directory structure, so that I can start using the DAG pipeline without reading documentation and hand-editing JSON.

## Acceptance criteria

1. Running `bash plugins/dag/scripts/dag-init.sh` from the project root starts the interactive flow
2. If `.dag/config.json` exists, the script warns and offers to overwrite with automatic backup to `.dag/config.json.bak`
3. Adapter selection prompts for type (only `local` in v1, but structured for future types via `case` dispatch)
4. Documentation adapter config prompts for `adrPath` (default: `./.dag/docs/adr`) and `pitchPath` (default: `./.dag/docs/pitches`)
5. Issue-tracking adapter config prompts for `project` (default: `PROJ`, validated ≤10 chars, stripped/spaced/uppercased) and `ticketPath` (default: `./.dag/docs/tickets`)
6. Script previews the generated JSON and asks for confirmation before writing
7. On confirm, writes config atomically via `mktemp` + `mv` — no partial writes
8. On confirm, invokes adapter-specific `post_write` hook. For `local` adapter: creates `.dag/docs/adr/`, `.dag/docs/pitches/`, `.dag/docs/tickets/` directories with `.gitkeep` files
9. On cancel or error, exits with no side effects
10. Exit codes: 0 (success), 1 (user cancelled), 2 (error)

## Scenarios

```gherkin
Scenario 1: First-time setup
  Given no .dag/config.json exists
  When the script runs
  Then it prompts for adapter type with "local" as only option
  And then it prompts for adrPath, pitchPath, project, and ticketPath with defaults
  And then it previews the config and asks for confirmation
  When the user confirms
  Then the config is written atomically
  And the post_write hook creates the .dag/docs/ directories with .gitkeep files
  And exit code 0 is returned

Scenario 2: Existing config overwrite
  Given .dag/config.json exists
  When the script runs
  Then it warns "An existing config was found. Overwrite? [Y/n]"
  When the user answers "Y"
  Then the old config is backed up to .dag/config.json.bak
  And the script proceeds with the prompt flow
  And the new config and directories are created

Scenario 3: User cancels overwrite
  Given .dag/config.json exists
  When the script warns about existing config
  And the user answers "n"
  Then the script exits with code 1
  And no files are modified

Scenario 4: User cancels at preview
  Given the user has answered all prompts
  When the config preview is shown
  And the user answers "n" to confirmation
  Then the script exits with code 1
  And no files are modified

Scenario 5: Project key validation
  Given the script is prompting for project key
  When the user enters more than 10 characters
  Then the script rejects the input and re-prompts
  And suggests a truncated uppercase version
```

## Technical notes

### Script structure

Modular functions, no top-level execution outside `main`:

| Function | Responsible | Specific? |
|----------|-------------|-----------|
| `check_existing_config` | Warn if config exists, prompt overwrite, backup to `.bak` | No |
| `select_adapter` | Prompt for documentation adapter type. V1: `local` only | Dispatching |
| `prompt_adapter_config` | Prompts, validation, and field defaults per adapter `case` | Yes |
| `generate_config_json` | Build JSON heredoc per adapter `case` | Yes |
| `preview_config` | Show generated JSON, prompt confirm/cancel | No |
| `write_config` | `echo > "$(mktemp -t dag-init.XXXX)"` → `mv` atomically | No |
| `post_write` | Adapter-specific post-write hook | Yes |
| `print_summary` | Print created paths and next steps | No |

### Intro banner

Print this when the script starts:

```
DAG init — Set up Docs Augmented Generation for this project

Creates .dag/config.json and document directories for ADRs,
pitches, and tickets. Press Ctrl+C anytime to cancel — no
files are modified until you confirm.
```

### Universal config fields, adapter-specific meaning

Config field names are universal across adapters. What they mean depends on the adapter:

| Field | Local adapter | Future Jira adapter |
|-------|--------------|---------------------|
| `ticketPath` | Directory for ticket files (`./.dag/docs/tickets`) | Base URL (`https://domain.atlassian.net`) |
| `project` | Filename prefix (`PROJ`) | Jira project key (`PROJ`) |

The adapter at runtime interprets each field. Prompt text adapts per `case` branch to explain what the field means for that adapter. The JSON keys stay the same — only values and validations differ.

No auth secrets in config — `.dag/config.json` is committable. Auth belongs in env vars, MCP config, or adapter-specific credential stores.

### Adapter dispatch pattern

All adapter-specific behavior (prompts, JSON generation, post-write) is driven by `case` statements, not inheritance or plugins. Adding a new adapter = adding a `case` branch to each function:

```bash
prompt_adapter_config() {
  case "$ADAPTER_TYPE" in
    local)
      echo ""
      echo "=== Documentation storage ==="
      echo "ADRs and code explorations will be markdown files."
      read -p "  Directory for ADRs and explorations [.dag/docs/adr]: " adrPath
      adrPath="${adrPath:-.dag/docs/adr}"
      read -p "  Directory for pitches [.dag/docs/pitches]: " pitchPath
      pitchPath="${pitchPath:-.dag/docs/pitches}"
      echo ""
      echo "=== Ticket storage ==="
      echo "Tickets will be numbered markdown files (e.g. PROJ-1-title)."
      read -p "  Directory for tickets [.dag/docs/tickets]: " ticketPath
      ticketPath="${ticketPath:-.dag/docs/tickets}"
      prompt_project
      ;;
    # Future: jira)
    #   echo "=== Jira issue tracking ==="
    #   read -p "  Jira base URL [https://your-domain.atlassian.net]: " ticketPath
    #   read -p "  Jira project key [PROJ]: " project
    #   project="${project:-PROJ}"
    #   ;;
  esac
}

generate_config_json() {
  case "$ADAPTER_TYPE" in
    local)
      cat <<EOF
{
  "adapters": {
    "documentation": { "type": "local", "config": {
      "adrPath": "${adrPath}",
      "pitchPath": "${pitchPath}"
    }},
    "issue-tracking": { "type": "local", "config": {
      "project": "${project}",
      "ticketPath": "${ticketPath}"
    }}
  }
}
EOF
      ;;
    # Future adapters produce their own JSON shape using the same field keys
  esac
}

post_write() {
  case "$ADAPTER_TYPE" in
    local)
      mkdir -p "$adrPath" "$pitchPath" "$ticketPath"
      touch "$adrPath/.gitkeep" "$pitchPath/.gitkeep" "$ticketPath/.gitkeep"
      ;;
    # Future: jira) — nothing to do locally
  esac
}
```

### Prompt texts

Use the following as a guideline:

- **Banner**: `"DAG init — Set up Docs Augmented Generation for this project"`
- **Adapter type**: `"Documentation adapter type. 'local' writes files to your project. Cloud adapters coming later. [local]: "`
- **adrPath**: `"  Directory for ADRs and code explorations [.dag/docs/adr]: "`
- **pitchPath**: `"  Directory for pitches [.dag/docs/pitches]: "`
- **ticketPath**: `"  Directory for tickets [.dag/docs/tickets]: "`
- **Project**: `"  Short project prefix for ticket IDs — appears in filenames (e.g. PROJ-1-add-auth). Max 10 chars, uppercased. [PROJ]: "`
- **Backup warning**: `"Existing config found at .dag/config.json. Overwrite? A backup will be saved to .dag/config.json.bak. [Y/n]: "`
- **Confirm write**: `"Looks good? Write .dag/config.json and create the document directories? [Y/n]: "`
- **Success**: `"Done! Created:"` followed by bullet list of created paths

### Project key sanitization

```bash
sanitize_project() {
  local raw="$1"
  # Uppercase, strip non-alphanumeric (keep hyphens and underscores)
  local cleaned
  cleaned="$(printf "%s" "$raw" | tr '[:lower:]' '[:upper:]' | tr -cd '[:alnum:]_-')"
  # Truncate to 10 chars
  printf "%s" "$cleaned" | cut -c1-10
}
```

### Bash 3.2+ constraints (macOS default)

| Avoid (bash 4+) | Use instead |
|----------------|-------------|
| `[[ $x == $y ]]` | `[ "$x" = "$y" ]` or `case` |
| `declare -A` (assoc arrays) | `case` statements |
| `"${arr[@]}"` (arrays) | String variables, no arrays |
| `echo -e` | `printf` |
| `&>> file` | `>> file 2>&1` |
| `$((var++))` | `var=$((var + 1))` |

Script shebang: `#!/usr/bin/env bash` (not `#!/bin/sh` — `read -p` requires bash).

### Cross-platform mktemp

Linux accepts bare `mktemp`; macOS requires a template argument:

```bash
TMPFILE="$(mktemp -t dag-init.XXXX)" || { echo "Failed to create temp file" >&2; exit 2; }
```

### JSON generation

Use `cat <<EOF` heredoc (no `jq` dependency). Project key must be sanitized before insertion into the heredoc to prevent JSON-breaking characters. Path fields use heredoc substitution — safe as long as paths don't contain `"` or `$`.

## Related docs

- ADR: `.dag/docs/adr/2026-05-17-guided-init-flow/2026-05-17-guided-initialization-flow-for-dag-plugin.md`
- Code exploration: `.dag/docs/adr/2026-05-17-guided-init-flow/2026-05-17-CE-code-exploration-guided-initialization-flow-for-dag-plugin.md`
- Pitch: `.dag/docs/pitches/2026-05-16-guided-initialization-flow-for-dag-plugin.md`
- Parent epic: DAG-13

---
*This ticket was created by opencode and reviewed by a human before publishing.*
