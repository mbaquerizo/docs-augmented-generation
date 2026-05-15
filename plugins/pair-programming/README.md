# pair-programming

Navigated pair programming. Claude acts as the navigator — explores the codebase, plans an approach, breaks work into tasks, and guides you through implementation while you drive.

## Prerequisites

- A human in the loop (this is pair programming, not automation)

## Skills

| Skill | Invocation | What it does |
|-------|------------|--------------|
| navigator | `/navigator` | Plans implementation, presents tasks one at a time, and guides you through writing the code |

## Usage

Unlike fully automated skills, navigator expects you to implement — it plans, prompts, and reviews. Useful for:

- **Onboarding and code familiarization** — the navigator explores the codebase first, helping you understand the architecture before making changes
- **Complex work** where you want AI guidance without full delegation
- **Structured pair programming sessions** where session notes preserve context between sittings

The navigator shares the same "context first" philosophy that drives DAG: understand the architecture before you change it. Better-informed decisions lead to better documentation, which feeds back into the DAG workflow.