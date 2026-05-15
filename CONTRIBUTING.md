# Contributing

## Getting started

1. Clone the repository
2. Configure adapters in `.dag/config.json`
3. See the root README for plugin installation and usage instructions

## Commit conventions

This project uses **gitmoji** for commit messages. Every commit follows this format:

```
<gitmoji> [(scope)] <description>
```

- **gitmoji** — a Unicode emoji expressing the type of change (see the [full reference](plugins/dag/skills/commit/gitmoji.md))
- **scope** — optional noun describing the affected area in parentheses (e.g. `dag`, `shape-up`, `pair-programming`, `config`)
- **description** — brief summary in imperative present tense, capitalized

Examples from this repository:

```
🏗️ (dag) Build TDD skill and start-work integration
📝 Write root and plugin READMEs
🚚 Rebrand project from docs-driven to DAG
🎨 Unwrap all skill and adapter markdown files
```

Breaking changes should use the `💥` emoji.

## Branch naming and PR workflow

### Branch naming

Branches follow this pattern:

```
<type>/<issue-number>/<brief-description>
```

For example: `task/PROJ-6/create-changelog-and-contributing`.

### Pull requests

1. Push your branch to the remote
2. Create a PR using `gh`:

   ```
   gh pr create --title "<descriptive title>" --body "<summary of changes>"
   ```

3. Request review as needed
4. Squash-merge when approved

## Skill development conventions

### Plugin directory layout

Each plugin lives in `plugins/<name>/` with the following structure:

```
plugins/<name>/
  .claude-plugin/
    plugin.json        # Plugin metadata (name, version, author, keywords)
  agents/              # Optional: markdown-based agent definitions
  skills/              # Skills organized in subdirectories
    <skill-name>/
      SKILL.md         # Skill definition with YAML frontmatter
      <ref-files>      # Optional: reference docs used by the skill
  CHANGELOG.md         # Per-plugin changelog
  README.md            # Plugin overview and usage
```

### YAML frontmatter

All skill and agent markdown files begin with YAML frontmatter. Required fields vary by type:

- **Skills**: `name`, `description`, `trigger` (auto-dispatch description that activates the skill)
- **Agents**: `name`, `description`, `system_prompt`, `tools`, `color` (hex color for agent role display)

The `description` field in both skills and agents is critical — it controls when the model auto-dispatches to them. Be specific about when the skill or agent should be invoked.

### Slash commands vs auto-dispatch

- **Slash commands** (`/dag:plan-feature`, `/dag:create-tickets`, `/dag:finish-work`) are registered in `plugin.json` and available at any prompt. Use these for high-level workflow steps a user would explicitly request.
- **Auto-dispatched skills** (`tdd`, `commit`, `start-work`, `dag-publish`) are invoked by the model when its internal reasoning matches the skill's `description` field. These are intermediate pipeline steps, not user-facing commands.

## Changelog maintenance

Changelogs follow the [Common Changelog](https://common-changelog.org) style — a stricter subset of Keep a Changelog.

### Common Changelog rules

- File must be named `CHANGELOG.md`
- Each entry starts with a `## VERSION - YYYY-MM-DD` heading
- Categories are limited to: **Added**, **Changed**, **Removed**, **Fixed**
- Breaking changes are prefixed with `**Breaking:**`
- Each change references a commit SHA (GitHub auto-links bare 7-character hashes)
- Changes use imperative mood: "Add feature" not "Added feature"
- There is no `[Unreleased]` section — entries are written when a release is tagged

### Versioning policy

This project uses [Semantic Versioning](https://semver.org/). The marketplace bundle and individual plugins follow **independent** semver:

| Package | Current version | Semver notes |
|---|---|---|
| Marketplace (root) | 1.0.0 | Bump when the bundle ships a new set of plugin versions |
| dag | 1.0.0 | Bump per-plugin when its API or behavior changes |
| shape-up | 1.0.0 | Bump per-plugin independently of other packages |
| pair-programming | 0.1.0 | Pre-1.0: anything may change; changelog still tracks every bump |

Bumping one plugin does **not** force a marketplace bump, and vice versa.

### Cutting a release

1. Review commits since the last tagged release and draft changelog entries
2. Add a new `## VERSION - YYYY-MM-DD` heading at the top of the relevant `CHANGELOG.md`
3. Group changes into Common Changelog categories
4. Tag the release:

   ```
   git tag -a v<VERSION> -m "v<VERSION>"
   ```

   Tag names use a `v` prefix (e.g. `v1.0.0`, `v0.2.0`).

5. Push tags:

   ```
   git push --tags
   ```

### Adding entries between releases

When a commit lands on `main` that should be included in the next release:

1. Edit the relevant `CHANGELOG.md` directly — add the entry under the version heading that will contain it
2. If no version heading exists yet (e.g. you're accumulating changes before deciding the next version), add a descriptive heading like `## [1.1.0] - TBD` or coordinate with the team on the planned version
