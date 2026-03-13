---
name: conventional-commits
description: Use when committing code, before staging changes — ensures messages are searchable, revertible, and provide clear history for debugging and blame
---

# Conventional Commits

## Overview

**Core principle:** Commit messages are historical records. A vague message ruins debugging, blame, and reversions for months. Conventional Commits format (type(scope): description) makes messages machine-parseable, searchable, and automatically revertible.

## When to Use

For all commits destined for shared branches (main, development, release):
- Before staging changes that will be committed
- When choosing what to bundle in a single commit
- Before writing the commit message

**Exceptions** (see below for details):
- Local-only, work-in-progress commits on feature branches can use `wip:` prefix
- Hotfix/incident commits in P1 situations can use minimal format, with details added post-incident
- Automated commits (dependency updates, generated code) follow their tool's conventions

## The Format

```
type(scope): short description

optional body explaining why
```

### Type (required)

| Type | When | Example |
|------|------|---------|
| **feat** | New functionality | `feat(auth): add two-factor authentication` |
| **fix** | Bug fix | `fix(payment): prevent duplicate charges on retry` |
| **docs** | Documentation only (no code changes) | `docs(api): clarify rate limit behavior` |
| **style** | Formatting, whitespace, linting (no logic change) | `style(formatting): run prettier on src/` |
| **refactor** | Code restructure, same behavior | `refactor(db): extract query builder functions` |
| **test** | Tests only (no code under test changes) | `test(auth): add cases for expired sessions` |
| **chore** | Tooling, deps, build config | `chore(deps): upgrade typescript to 5.2` |

### Scope (optional but recommended)

The affected component/module:
- `auth`, `payment`, `db`, `ui`, `cli`, `api`
- Use existing module names from your codebase
- **Must match what changed** — if you changed two unrelated scopes, this is a sign you should split into two commits

### Description (required)

- **Imperative mood:** "add feature" not "added feature" or "adds feature"
- **Complete sentence:** explains WHAT changed
- **Lowercase:** start with lowercase letter
- **Under 50 characters:** fits in log output, GitHub UI
- **No period:** period indicates you're done explaining — use body for details

### Body (optional, use when needed)

Explain **WHY** you made the change:
- What problem were you solving?
- What impact does it have?
- Why this approach over alternatives?

Use when the commit is non-obvious.

## Anti-Patterns

### ❌ Vague Type/Description
```
update payment module
improve authentication
fix bugs
```
**Problem:** No history. Which module? What payment thing? What bugs?

**Fix:**
```
fix(payment): prevent duplicate charge on network retry
feat(auth): add session expiry validation
fix(api): handle 5xx errors in response decoder
```

---

### ❌ Bundled Unrelated Changes
```
feat(auth): add 2FA and refactor session handler and fix database connection timeout
```
**Problem:** Can't revert just the 2FA if it breaks. Can't revert just the refactor. Blame is useless. Testing is impossible.

**Fix:** Split into three commits:
```
feat(auth): add two-factor authentication
refactor(auth): extract session handler to separate module
fix(db): handle connection timeouts in retry logic
```

---

### ❌ Missing Context in Body
```
fix(checkout): update validation
```
**Problem:** Update validation how? What was broken?

**Fix:**
```
fix(checkout): validate card expiry before charging

Prevent charges on expired cards. Was comparing expiry date
incorrectly — now uses proper date math to check MM/YY >= today.
Fixes #4521.
```

---

### ❌ Wrong Type Hiding Real Work
```
chore(cleanup): remove whitespace, refactor payment handler, add error logging
```
**Problem:** "Cleanup" hides that payment handler logic changed. Type lies about what happened.

**Fix:** Split, use accurate types:
```
style(payment): remove trailing whitespace
refactor(payment): extract charge logic to separate function
feat(payment): add detailed error logging
```

---

### ❌ Scope Doesn't Match Changes
```
refactor(auth): cleaned up code everywhere
fix(api): updated file in src/utils
```
**Problem:** Scope is meaningless if it doesn't specify what actually changed.

**Fix:**
```
refactor(auth): extract password validation to separate module
fix(utils): correct timezone handling in date formatter
```

---

### ❌ Mixing Multiple Scopes When They're Unrelated
```
feat(api): added endpoints, updated UI components, fixed database migrations
```
**Problem:** Three unrelated domains in one commit = impossible to test, revert, or blame.

**Fix:** Three commits:
```
feat(api): add /user/profile endpoint
feat(ui): add profile display component
fix(db): correct migration ordering for schema conflicts
```

## The Test: Commit Reversibility

Before committing, ask: **Can future-you revert this change cleanly?**

- **Yes?** Commit message is good.
- **No?** You bundled too much. Split into smaller commits. Change message to reflect single responsibility.

If you can't revert one change without breaking others, your commit is too large.

## Quick Reference

**Before staging:**
1. ✅ Does scope match what changed?
2. ✅ Is this one logical change or multiple?
3. ✅ Does type accurately reflect the change?
4. ✅ Would future-you understand why this change was made?

**If any answer is "no":** Split into multiple commits or improve the message.

## Context-Specific Guidance

### Scenario: Tiny incidental fix while working
"I found a typo while implementing a feature. It's 1 line. Should I split the commit?"

**Answer:** Depends on revision history value.
- **If it's a typo/formatting in the same function you're already changing:** fold it in. Total impact: 3-5 lines.
- **If it's in a different module:** split it. Use `style(module): fix typo in variable name`.
- **Rule of thumb:** If the fix would take longer to stage separately than to write the commit message for, it's small enough to fold. If writing the commit message is faster, split.

### Scenario: Team uses loose commit format already
"Our repo has 100 commits like 'fix bugs'. Should I impose conventional commits?"

**Answer:** No. Do not attempt unilateral adoption.
- **Step 1:** Use conventional format on YOUR branches. Don't judge their commits.
- **Step 2 (optional):** Pitch it to the team (share this skill, show benefits in your PRs).
- **Step 3 (if adopted):** Agree as a team. Add to CONTRIBUTING.md. Enforce in CI if useful.
- **Do NOT:** Police their commits, rewrite history, or claim they're "doing it wrong."

Each team decides their standard. This skill is a recommendation, not a law.

### Scenario: Found optimization while implementing feature
"Should I commit the optimization separately from the feature?"

**Answer:** Depends on whether it's independent value.
- **If the optimization has independent value** (could ship without the feature): split it. Let optimization land first or separately.
- **If the optimization is only needed for this feature:** include it, but explain in the commit message.
  ```
  feat(api): add pagination endpoint (with query optimization)

  Extracted index-friendly query builder to support paginated
  queries efficiently. Optimization is internal; no API change.
  ```
- **If you're unsure:** split it. Independent optimization + feature is clearer than "feature with optimization."

### Scenario: P1 hotfix / production emergency
"There's an active incident. Do I need a perfect commit message?"

**Answer:** No. Safety > clarity in emergencies.
- **During incident:** Write minimal commit. Deploy first, document second.
  ```
  fix: disable faulty cache layer (incident #4521)
  ```
- **After incident is resolved:** Create a follow-up commit with details.
  ```
  docs(incident): post-mortem for cache corruption

  [full explanation of what failed, why, timeline]
  ```
- **The rule:** Restore service first. Historical clarity second.

### Scenario: Uncertain if refactoring is correct
"I want to commit my work to avoid losing it, but I'm not sure the refactoring is right."

**Answer:** Commit locally, squash before sharing.
```bash
# Safe: commit locally (protects against crashes, lost work)
git commit -m "wip: refactoring auth module - testing approach"

# Later, after you're confident the refactoring works:
git reset HEAD~1  # Undo the wip commit
git commit -m "refactor(auth): extract session handler to separate module"

# Or use git rebase to squash with other commits:
git rebase -i HEAD~3  # Squash the wip into a proper commit
```

**Key insight:** "Commit" ≠ "Share". You can commit locally for safety without push/PR. Use `wip:` prefix for exploratory work.

## Red Flags - Stop and Fix

- [ ] Multiple unrelated changes in staging area (use `git add file` not `git add .`)
- [ ] Type doesn't match reality (`chore` when you refactored, `fix` when you added new behavior)
- [ ] Scope is missing and change affects a clear module
- [ ] Can't explain the change in one sentence
- [ ] Message uses passive voice ("bugs were fixed") instead of imperative ("fix bug")
- [ ] No idea why someone would need this commit in 6 months

## Common Rationalizations to Watch Out For

| Rationalization | Reality | What To Do |
|---|---|---|
| "It's just 1 line, don't need to split" | If 1 line = different concern, split it. If same file/function, can fold. | Use the "commit message takes longer than staging" rule. |
| "The repo never uses this format" | Precedent isn't permission. But unilateral adoption creates friction. | Use conventional format on your branches; pitch to team gradually. Don't police theirs. |
| "This is related so it belongs together" | Related ≠ same responsibility. Optimization + feature should usually split. | Ask: "Could this land independently? If yes, split it." |
| "Hotfix — there's no time for perfect messages" | Correct. But add details in a follow-up commit after incident. | Use `fix: description (incident #123)`, add post-mortem commit later. |
| "I'm not sure if this refactoring is right" | Commit locally for safety. Just don't push unfinished work. | Use `wip:` prefix locally, rebase/squash before PR. |
| "I'll break context switching if I split this" | Context switching is real. Use the "3-line threshold" heuristic. | If staging takes longer than typing the message, it's too small to split. |
| "Reviewer will reject my strict format as pedantic" | Consistency matters more than perfection. One good commit type beats vague history. | Let reviewer's feedback drive team adoption. Rigid individual compliance looks odd. |

## Common Mistakes

**"Fix" is too vague:**
- ❌ `fix(auth): fix authentication`
- ✅ `fix(auth): prevent session fixation attacks in cookie validation`

**Mixing "style" with logic changes:**
- ❌ `style(utils): cleaned up helper functions` (if logic changed, use `refactor`)
- ✅ `style(utils): remove trailing whitespace` or `refactor(utils): simplify date parsing logic`

**Refactor without explaining scope:**
- ❌ `refactor(api): improved code`
- ✅ `refactor(api): extract rate limiter to separate middleware`

**Description in all caps or with punctuation:**
- ❌ `feat(auth): ADD LOGIN ENDPOINT.`
- ✅ `feat(auth): add login endpoint`

**Scope that's too broad:**
- ❌ `fix(src): various fixes`
- ✅ `fix(validators): handle null values in email validator`

## Real-World Impact

**Bad commit:** `update code`
- 6 months later, bug in payment flow. Need to find related changes.
- `git blame` shows "update code". Useless.
- `git log --grep=payment` returns nothing.
- Must manually dig through commits to understand when payment logic changed.

**Good commit:** `fix(payment): prevent duplicate charge on network retry`
- 6 months later, same bug.
- `git blame` shows exact commit and reason.
- `git log --grep=duplicate` finds it immediately.
- Commit message explains the problem you fixed.
- Can confidently revert if this introduced regression elsewhere.

## Implementation

Use this template when committing:

```bash
git commit -m "type(scope): description" -m "Why this change was needed, context, related issues"
```

Or interactively:
```bash
git commit
# Type: fix
# Scope: payment
# Description: prevent duplicate charge on network retry
#
# Explanation: The charge handler was retrying without checking
# if a charge had already been processed. Now validates idempotency
# token before attempting retry. Fixes #4521.
```