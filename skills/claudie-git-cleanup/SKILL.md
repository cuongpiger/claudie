---
name: claudie-git-cleanup
description: Clean up stale git worktrees and merged local branches in a local repo. Use whenever the user wants to tidy up git state — "clean my worktrees", "remove old worktrees", "delete merged branches", "delete all branches except main", "my repo is cluttered with branches", "prune worktrees", or after finishing and merging a batch of feature work. Always shows a dry-run plan and waits for approval before deleting anything.
---

# Git Cleanup: Worktrees and Local Branches

Removes git worktrees you're done with and local branches already merged into main. Deletion is irreversible-ish (reflog helps, but only for a while), so this skill is built so that the *worst* possible outcome is "nothing happened."

## Two scripts

- `scripts/plan.sh` — read-only. Classifies every worktree and local branch as REMOVE/DELETE or KEEP, with the reason. Changes nothing.
- `scripts/apply.sh` — executes what the plan proposed. Uses only `git worktree remove` and `git branch -d`, never their forcing variants, so git itself is the final safety net.

## Workflow

Run the plan, show it, get approval, apply. Don't collapse these steps — the plan is the whole point.

```bash
bash skills/claudie-git-cleanup/scripts/plan.sh
```

Present the output to the user roughly as-is; it's already grouped and annotated. Then summarize in a line or two: how many worktrees and branches would go, and call out anything in the KEEP list that looks like it needs a human decision (detached HEAD, dirty worktrees, branches with unmerged commits).

Wait for explicit approval. Then:

```bash
bash skills/claudie-git-cleanup/scripts/apply.sh
```

Report what actually happened, including anything git refused.

If the user asks only about branches or only about worktrees, still run the full plan — the two are entangled (see below) — but present only the section they asked about.

## What counts as safe to delete

A **worktree** is removed when it is either prunable (its directory is already gone) or on a branch fully merged into main *and* has no uncommitted changes.

A **branch** is deleted when it is fully merged into main. "Merged" means `git merge-base --is-ancestor branch main` — the branch's tip is genuinely contained in main's history. This is stricter and more reliable than parsing `git branch --merged`.

Main is detected from `origin/HEAD`, falling back to a local `main` then `master`. If none exists the scripts abort rather than guess, since every decision here is relative to main.

## What is never touched

- The primary working tree.
- The branch currently checked out.
- Main itself.
- Any worktree with uncommitted changes, or a branch with commits not in main.
- Detached-HEAD worktrees — reported for manual review, since there's no branch to reason about.

The user asked for "all local branches except main," and merged branches are exactly that minus the ones git physically cannot delete. Two categories survive regardless, and that's deliberate: a branch holding unmerged commits is unpushed work, and the checked-out branch can't be deleted from under you. If the user really wants one of those gone, they should say so by name — don't reach for `-D` or `--force` on your own initiative. Losing a commit to save a step is never the right trade.

## Why worktrees come first

Git won't delete a branch that any worktree has checked out. So a merged branch sitting in a worktree shows up as KEEP ("backs a worktree") on the first pass and only becomes deletable once that worktree is gone. `apply.sh` handles this by removing worktrees, running `git worktree prune`, then re-planning before it touches branches. If you're ever running the steps by hand, keep that order.

## Reading the plan output

```
=== WORKTREES ===
REMOVE  /path/to/wt1  (feature-x)  [merged into main, clean, last commit 2026-08-02]
KEEP    /path/to/wt2  (feature-y)  [uncommitted changes]
REMOVE  /path/to/wt3  [prunable: directory is gone]

=== LOCAL BRANCHES ===
DELETE  old-feature    [merged into main, last commit 2026-07-19]
KEEP    wip-refactor   [3 commit(s) not in main]
KEEP    main           [main]
```

Last-commit dates are there to catch the case where something is technically merged but you were working on it this morning — worth a second look before approving.

## When the plan is empty

Say so plainly and stop. A repo with nothing to clean is the common case after the first run, and inventing work to do here means deleting something the rules protected.
