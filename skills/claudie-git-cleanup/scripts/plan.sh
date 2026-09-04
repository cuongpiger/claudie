#!/usr/bin/env bash
# Report git worktrees and local branches that are safe to delete.
# Read-only: prints a plan, changes nothing.
set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 1; }

MAIN=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
if [ -z "$MAIN" ]; then
  for b in main master; do
    git show-ref --verify --quiet "refs/heads/$b" && MAIN=$b && break
  done
fi
[ -z "$MAIN" ] && { echo "no main/master branch found - aborting"; exit 1; }

CURRENT=$(git rev-parse --abbrev-ref HEAD)
ROOT=$(git rev-parse --show-toplevel)

echo "repo:  $ROOT"
echo "main:  $MAIN"
echo "HEAD:  $CURRENT"
echo

# A branch checked out in any worktree cannot be deleted while that worktree exists.
WT_BRANCHES=$(git worktree list --porcelain | sed -n 's|^branch refs/heads/||p')

# merged <ref> -> true if ref is fully contained in MAIN
merged() { git merge-base --is-ancestor "$1" "$MAIN" 2>/dev/null; }

echo "=== WORKTREES ==="
# Parse porcelain records: "worktree <path>", optional "branch <ref>", optional "prunable".
git worktree list --porcelain | awk '
  /^worktree /  { path = substr($0, 10); branch = ""; prunable = 0 }
  /^branch /    { sub("refs/heads/", "", $2); branch = $2 }
  /^prunable/   { prunable = 1 }
  /^$/          { if (path != "") print path "\t" branch "\t" prunable; path = "" }
  END           { if (path != "") print path "\t" branch "\t" prunable }
' | while IFS=$'\t' read -r wt br prunable; do
  [ "$wt" = "$ROOT" ] && continue   # never touch the primary working tree

  if [ "$prunable" = "1" ]; then
    echo "REMOVE  $wt  [prunable: directory is gone]"
  elif [ -z "$br" ]; then
    echo "KEEP    $wt  [detached HEAD - inspect manually]"
  elif [ -n "$(git -C "$wt" status --porcelain 2>/dev/null | head -1)" ]; then
    echo "KEEP    $wt  ($br)  [uncommitted changes]"
  elif merged "$br"; then
    echo "REMOVE  $wt  ($br)  [merged into $MAIN, clean, last commit $(git log -1 --format=%cs "$br")]"
  else
    echo "KEEP    $wt  ($br)  [$(git rev-list --count "$MAIN..$br") commit(s) not in $MAIN]"
  fi
done

echo
echo "=== LOCAL BRANCHES ==="
git for-each-ref --format='%(refname:short)' refs/heads | while IFS= read -r br; do
  if [ "$br" = "$MAIN" ]; then
    echo "KEEP    $br  [main]"
  elif [ "$br" = "$CURRENT" ]; then
    echo "KEEP    $br  [checked out]"
  elif printf '%s\n' "$WT_BRANCHES" | grep -qx "$br"; then
    echo "KEEP    $br  [backs a worktree - remove that worktree first]"
  elif merged "$br"; then
    echo "DELETE  $br  [merged into $MAIN, last commit $(git log -1 --format=%cs "$br")]"
  else
    echo "KEEP    $br  [$(git rev-list --count "$MAIN..$br") commit(s) not in $MAIN]"
  fi
done
