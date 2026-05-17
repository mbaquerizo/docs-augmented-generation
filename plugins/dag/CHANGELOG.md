# Changelog

## [1.2.0] - 2026-05-16

### Changed

- start-work skill restructured into 3 phases (Setup, Planning,
  Implementation) with worktree setup moved before planning, iterative
  planning with explicit approval gate, and complexity heuristic
  extracted to reference file (c033d60)

## [1.1.0] - 2026-05-16

### Added

- Retrieval instructions section in issue-tracking local adapter

### Changed

- start-work skill Section 2 now references adapter retrieval instructions
- finish-work skill Section 5 now references adapter retrieval instructions

## [1.0.0] - 2026-05-15

_First release._

### Added

- Publish contract and local filesystem adapters (fc3b2f00070be0d61ccf34130da5eea99cb90584, fe4d94f2f2bb1c40da3dab6ac4655c8d1a8dd520)
- Config schema with project field support (850fdb9defebf5266037eb240047db4bd52505ae)
- plan-feature skill — ADR and code exploration publishing (f47e90a1b15977e9c80cb0bedc0d0e990095e899)
- create-tickets skill — ticket hierarchy with archetypes (a04c66409af7ce1a5cb48a154ebf5a33a8718c71)
- dag-publish skill — adapter-routed publishing (c69503f47c1fc06ece66c5ef20918717b9e33984)
- start-work skill — ticket-based implementation sessions (11b08ee40f27a1f918bb68f56ffccda91d1fef00)
- tdd skill — test-driven development workflow (545c32552439dd6471be61d88ea11dd82e690ba9)
- commit skill — staged commits with gitmoji / conventional-commit references (303bbed166965705d38bbc1d8f839bad10e6b8f4)
- finish-work skill — sync, push, and PR creation (22d22f4b6667397626e24844a0ae6136fc1acd89, 9f2ed0bfa2ff7bb236ee4e8d0c4b00a912150fb9)
- code-exploration agent — read-only codebase investigation (f47e90a1b15977e9c80cb0bedc0d0e990095e899)
