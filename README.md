# Claudie

A personal collection of Claude Code skills for software engineering workflows. Each skill is a reusable reference guide that helps Claude apply proven techniques consistently across projects.

## Installation

```bash
claude

/plugin marketplace add cuongpiger/claudie

claude # Now you can use the skills in this collection!
```

## Skills

Skills live in the `skills/` directory. Each skill has a `SKILL.md` with frontmatter, overview, usage guidance, and examples.

### claudie-commit

**Trigger:** Use when committing code, before staging changes.

Enforces [Conventional Commits](https://www.conventionalcommits.org/) format to produce searchable, revertible, and historically meaningful commit messages.

**Format:** `type(scope): short description`

| Type | When to Use |
|------|-------------|
| `feat` | New functionality |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace, linting |
| `refactor` | Code restructure, same behavior |
| `test` | Tests only |
| `chore` | Tooling, deps, build config |

Key principles:
- Imperative mood, lowercase, under 50 characters
- Scope must match what actually changed
- One logical change per commit — bundling unrelated changes = can't revert cleanly
- Body explains **why**, not what

See [skills/claudie-commit/SKILL.md](skills/claudie-commit/SKILL.md) for full guidance, anti-patterns, and context-specific scenarios.

---

### claudie-analyze-project

**Trigger:** Use when asked to analyze, document, or onboard someone to a project — especially when a new team member needs to understand the codebase quickly.

Turns any codebase into a structured onboarding document by working through discovery layers in sequence: README/docs → config → entry points → API layer → database → cache → external services → domain terminology.

**Output sections produced:**

| Section | What it covers |
|---------|----------------|
| Project Purpose & Objectives | What problem it solves, for whom, active goals |
| Tech Stack | Language, framework, database, cache, infra — in table form |
| Architecture Overview | Mermaid diagram showing components and communication |
| Project Structure | Directory tree with role of each folder explained |
| API Reference | Endpoints with method, path, auth, key request/response fields |
| Database Design | Mermaid ER diagram + per-table column documentation |
| Cache Layer | Redis/Memcached key patterns, TTLs, what's cached and why |
| External Services | Every third-party dependency with config key |
| Key User Flows | 2–3 mermaid sequence diagrams for core journeys |
| Deployment & Infrastructure | Packaging, environments, how-to-run-locally steps |
| Glossary | Domain terms, technical acronyms, project-specific abbreviations |

Key principles:
- Text alone is insufficient — always produce mermaid diagrams
- Assume nothing about the reader — explain domain terms
- Never skip a section without explicitly stating "N/A — this project has no [X]"
- Explain **why** things are the way they are, not just what they are

See [skills/claudie-analyze-project/SKILL.md](skills/claudie-analyze-project/SKILL.md) for the full discovery order, file prioritization guide, and common failure modes.
