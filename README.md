# Claudie

A personal collection of Claude Code skills for software engineering workflows. Each skill is a reusable reference guide that helps Claude apply proven techniques consistently across projects.

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
- One logical change per commit — bundle unrelated changes = can't revert cleanly
- Body explains **why**, not what

See [skills/claudie-commit/SKILL.md](skills/claudie-commit/SKILL.md) for full guidance, anti-patterns, and context-specific scenarios.
