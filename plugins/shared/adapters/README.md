# Adapters

Adapters abstract the destination for published content. There are two types:

- **documentation** — for ADRs, pitches, and code explorations
- **issue-tracking** — for tickets (epics, stories, tasks, bugs, spikes)

## Contract

Skills pass content to adapters using the shared contract defined in
[contract.md](contract.md). All adapters accept the same input fields and
return the published location.

## How it works

1. A skill reads `.docs-driven/config.json` to find the configured adapter type
   (e.g. `documentation.type: "local"`).
2. The skill reads the corresponding adapter file (e.g.
   `shared/adapters/documentation/local.md`) for publish instructions.
3. The agent constructs the content using the [contract fields](contract.md)
   and follows the adapter's instructions to publish.
4. The adapter returns the published location (path, URL, or identifier).

## Configuration

Each adapter type in `.docs-driven/config.json` specifies:
- `type` — which adapter to use (local, confluence, github, jira, etc.)
- `config` — destination parameters specific to that adapter

Per-document-type paths live inside `config`:

```json
{
  "adapters": {
    "documentation": {
      "type": "local",
      "config": {
        "adrPath": "./docs/adr",
        "pitchPath": "./docs/pitches"
      }
    },
    "issue-tracking": {
      "type": "local",
      "config": {
        "ticketPath": "./docs/tickets"
      }
    }
  }
}
```

Cloud adapters add auth fields (base URL, tokens, project keys) to `config`.

## Adding an adapter

Create a new file in the appropriate subdirectory. The file should document:
- Required `config` fields
- Publish mechanism (filesystem, API, MCP, CLI)
- Any authentication requirements
- Destination conventions
