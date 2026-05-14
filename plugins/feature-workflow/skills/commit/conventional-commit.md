# Conventional Commits

Conventional Commits provide a lightweight convention for commit messages. This reference follows the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) spec.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- type: one of the types listed below
- scope: optional noun describing the code area (e.g. api, cli, config)
- description: brief summary, lowercase, imperative present tense, no trailing period
- body: optional free-form details, wrapped at 72 characters
- footer: optional metadata (BREAKING CHANGE, Closes, Refs, etc.)

## Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `build` | Changes that affect the build system or external dependencies |
| `chore` | Other changes that don't modify src or test files |
| `ci` | Changes to CI configuration files and scripts |
| `docs` | Documentation only changes |
| `style` | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.) |
| `refactor` | A code change that neither fixes a bug nor adds a feature |
| `perf` | A code change that improves performance |
| `test` | Adding missing tests or correcting existing tests |

## Breaking changes

Add `!` before the colon, or a `BREAKING CHANGE` footer:

```
feat(api)!: Remove deprecated v1 endpoints

BREAKING CHANGE: The /v1/* endpoint family has been removed.
Migrate to /v2/* before upgrading.
```

## Choosing a type

### Single intent

- Deployed a new search bar → `feat`
- Fixed sign-in redirect loop → `fix`
- Wrote tests for the payment flow → `test`
- Moved CSS to styled-components → `refactor`
- Added Prettier config → `style`
- Updated README → `docs`
- Switched to pnpm → `build`

### Multiple intents

When a commit spans multiple types, pick the type representing the primary purpose and note secondary changes in the body:

| Scenario | Primary type | Secondary in body |
|----------|-------------|-------------------|
| Bug fix + refactor | `fix` (bug was the driver) | mention refactor in body |
| Feature + its tests | `feat` (feature) | mention tests in body |
| Refactor + docs | `refactor` (structural change) | mention docs in body |
| Mix of chores | `chore` or split into separate commits |

Prefer atomic commits. If changes have different scope or intent, split them.

## Examples

```
feat: Add user registration endpoint

fix: Handle null pointer in session handler

session.token was not checked before dereference.
Add guard clause and log warning on missing token.

refactor(api): Extract pagination helper

docs: Document rate limiting behavior
```
