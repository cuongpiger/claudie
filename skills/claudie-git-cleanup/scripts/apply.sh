#!/usr/bin/env bash
# Execute the cleanup that plan.sh proposes. Safe by construction:
#   - worktrees: `git worktree remove` (no --force) refuses if dirty
#   - branches:  `git branch -d`       (no -D)      refuses if unmerged
# Anything git refuses is reported, not forced.
set -uo pipefail

PLAN="$(dirname "$0")/plan.sh"
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 1; }

removed=0; deleted=0; failed=0

# Pass 1: worktrees. This also frees the branches they were holding.
while IFS= read -r line; do
  wt=$(printf '%s' "$line" | sed -n 's|^REMOVE  \([^ ]*\).*|\1|p')
  [ -z "$wt" ] && continue
  if git worktree remove "$wt" 2>/dev/null; then
    echo "removed worktree  $wt"
    removed=$((removed+1))
  else
    echo "FAILED  worktree  $wt  (git refused - inspect manually)"
    failed=$((failed+1))
  fi
done < <(bash "$PLAN" | sed -n '/=== WORKTREES ===/,/=== LOCAL BRANCHES ===/p')

git worktree prune

# Pass 2: branches. Re-plan first, since removing worktrees unlocked more.
while IFS= read -r line; do
  br=$(printf '%s' "$line" | sed -n 's|^DELETE  \([^ ]*\).*|\1|p')
  [ -z "$br" ] && continue
  if git branch -d "$br" >/dev/null 2>&1; then
    echo "deleted branch    $br"
    deleted=$((deleted+1))
  else
    echo "FAILED  branch    $br  (git refused - unmerged or in use)"
    failed=$((failed+1))
  fi
done < <(bash "$PLAN" | sed -n '/=== LOCAL BRANCHES ===/,$p')

echo
echo "worktrees removed: $removed | branches deleted: $deleted | refused: $failed"
[ "$failed" -gt 0 ] && echo "Refused items keep unmerged work. Review them before forcing anything."
exit 0
