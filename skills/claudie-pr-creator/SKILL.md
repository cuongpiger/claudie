---
name: claudie-pr-creator
description: Use when creating a GitHub pull request - analyzes branch changes, generates a structured PR with Jira-linked title, detailed description, and optional Copilot review.
---

# Role: PR Author

You create well-structured GitHub pull requests that give reviewers full context.

---

## Workflow

### Step 1: Gather Context

Run these in parallel:
- `git status` — check for uncommitted changes
- `git log --oneline main..HEAD` — list all commits on this branch
- `git diff main...HEAD --stat` — summarize changed files

If there are uncommitted changes, ask the user whether to commit first or proceed without them.

### Step 2: Determine Title

Format: `<PREFIX>: <short summary>`

**Prefix rules** (in priority order):
1. If the user provides a Jira ticket ID, use it (e.g. `ABC-1234: Add retry logic`)
2. Otherwise, infer from the nature of changes:
   - `feat` — new features or enhancements
   - `fix` — bug fixes
   - `chore` — maintenance, refactoring, config, CI
   - `docs` — documentation-only changes
   - `test` — test-only changes

Keep the title under 72 characters.

### Step 3: Generate Description

Use this template (adapt sections as needed — omit empty ones):

```markdown
## Ticket
[JIRA-ID](https://jira.example.com/browse/JIRA-ID) _(omit if no ticket)_

## Description
Brief summary of what this PR does and why.

## Approach
- Key implementation decisions
- Patterns or algorithms used
- Trade-offs considered

## Changes
- Bulleted list of notable file/module changes

## Testing
- What was tested (unit, integration, manual)
- How to verify locally

## Impact
- Performance, security, or UX considerations
- Rollback notes if applicable

## Dependencies
- New packages/services added (with versions)
```

### Step 4: Create the PR

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<generated description>
EOF
)"
```

- Target branch: `main` (unless the user specifies otherwise)
- Push the branch with `-u` if it hasn't been pushed yet

### Step 5: Post-Creation (Optional)

If GitHub Copilot CLI is available, suggest running:
```bash
gh copilot-review <PR_URL>
```

---

## Guidelines

- **Be concise.** Reviewers skim — lead with the important bits.
- **Link context.** Always link the Jira ticket when available.
- **Show what changed.** Use the diff stats to highlight high-impact files in the description.
- **Don't fabricate.** Only describe changes that actually exist in the diff. If something is unclear, ask the user.
