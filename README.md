# Claudie

A personal collection of Claude Code skills for software engineering workflows. Each skill is a reusable reference guide that helps Claude apply proven techniques consistently across projects.

## Installation

## Codex
To install the Codex version of these skills, follow these steps:
```bash
# Clone the repo
git clone https://github.com/cuongpiger/claudie.git ~/.codex/claudie --depth 1

# Create skills directory if it doesn't exist and create symlink to agents
mkdir -p ~/.agents/skills
ln -s ~/.codex/claudie/skills ~/.agents/skills/claudie
```

To upgrade to the latest version, simply pull the latest changes in the repo:
```bash
cd ~/.codex/claudie && git pull origin main
```

## Claude Code
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

---

### claudie-pr-creator

**Trigger:** Use when creating a GitHub pull request.

Analyzes branch changes and generates a well-structured PR with a Jira-linked title, detailed description, and optional Copilot review.

**Title format:** `<PREFIX>: <short summary>` (under 72 characters)

| Prefix | When to Use |
|--------|-------------|
| Jira ID | When a ticket ID is provided (e.g. `ABC-1234: Add retry logic`) |
| `feat` | New features or enhancements |
| `fix` | Bug fixes |
| `chore` | Maintenance, refactoring, config, CI |
| `docs` | Documentation-only changes |
| `test` | Test-only changes |

**Description sections produced:**

| Section | What it covers |
|---------|----------------|
| Ticket | Jira link (omitted if no ticket) |
| Description | Summary of what the PR does and why |
| Approach | Key implementation decisions and trade-offs |
| Changes | Bulleted list of notable file/module changes |
| Testing | What was tested and how to verify locally |
| Impact | Performance, security, or UX considerations |
| Dependencies | New packages/services added with versions |

Key principles:
- Reviewers skim — lead with the important bits
- Only describe changes that actually exist in the diff
- Push branch with `-u` if not yet pushed

See [skills/claudie-pr-creator/SKILL.md](skills/claudie-pr-creator/SKILL.md) for the full workflow and guidelines.

---

### claudie-writer

**Trigger:** Use when asked to write a technical design document, architecture doc, or any formal engineering document.

Prompts for a save path, researches the codebase and context, then writes a structured document using the standard design doc template.

**Workflow:**

1. Ask for output path before any research or writing
2. Explore relevant code, PRs, and configs
3. Fill every section of the template — no placeholder text
4. Save to the user-provided path

Key principles:
- Always start document status as `Draft`
- Use Mermaid syntax for all diagrams
- Do not invent facts — research the code first
- If a section does not apply, write "N/A" with a one-line explanation

See [skills/claudie-writer/SKILL.md](skills/claudie-writer/SKILL.md) for the full template and rules.
