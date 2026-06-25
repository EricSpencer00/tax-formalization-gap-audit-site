#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

BRANCH="${CONTINUATION_BRANCH:-main}"
REMOTE="${CONTINUATION_REMOTE:-origin}"
COMMIT_MSG="${CONTINUATION_COMMIT_MSG:-Update loop artifact from ${BRANCH} loop}"
FEATURED_MANIFEST="outputs/featured-formalizations.json"

stage_featured_tla() {
  [[ -f "$FEATURED_MANIFEST" ]] || return 0
  python3 - "$FEATURED_MANIFEST" <<'PY'
import json
import sys
from pathlib import Path

manifest = Path(sys.argv[1])
data = json.loads(manifest.read_text(encoding="utf-8"))
for stem in data.get("featured_stems", []):
  for suffix in (".tla", ".cfg"):
    path = Path(f"{stem}{suffix}")
    if path.exists():
      print(path.as_posix())
PY
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository."
  exit 1
fi

git fetch "$REMOTE" "$BRANCH" --prune
git checkout "$BRANCH"

if ! git pull --rebase "$REMOTE" "$BRANCH"; then
  echo "Pull with rebase failed."
  echo "Resolve conflicts, then run: git rebase --continue"
  exit 1
fi

if [[ "$#" -gt 0 ]]; then
  git add "$@"
else
  git add outputs/tax-formalization-exploration.md outputs/loop-checkpoint.md
  git add outputs/featured-formalizations.json
  git add README.md assets/site.css index.html .github/workflows/gh-pages.yml
  shopt -s nullglob
  mapfile -d '' NEW_FILES < <(find work -maxdepth 1 -name "TaxSection*.tla" -print0)
  if [[ ${#NEW_FILES[@]} -gt 0 ]]; then
    git add outputs/continuation/*.json
    for f in "${NEW_FILES[@]}"; do
      if [[ -n "$(git status --short --untracked-files=normal -- "$f")" ]]; then
        git add "$f"
      fi
    done
  fi
fi

while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  git add -f "$file"
done < <(stage_featured_tla)

if git diff --cached --quiet; then
  echo "No staged changes; nothing to commit."
  exit 0
fi

git commit -m "$COMMIT_MSG"

if ! git push "$REMOTE" "$BRANCH"; then
  echo "Push failed, attempting a final rebase retry..."
  git pull --rebase "$REMOTE" "$BRANCH" || {
    echo "Rebase retry failed. Check remote branch for concurrent updates before retrying."
    exit 1
  }
  git push "$REMOTE" "$BRANCH"
fi

echo "Pushed $(git rev-parse --short HEAD) to $REMOTE/$BRANCH"
