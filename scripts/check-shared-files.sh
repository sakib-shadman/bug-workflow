#!/usr/bin/env bash
# Each skill ships its own copy of the shared workflow rules so it works when
# installed standalone (for example with `npx skills add`). This check fails if
# the copies drift from the canonical one.
set -euo pipefail
cd "$(dirname "$0")/.."
canonical=skills/investigate-bug/references/workflow-rules.md
status=0
for copy in skills/fix-bug/references/workflow-rules.md; do
  if ! diff -u "$canonical" "$copy"; then
    echo "error: $copy differs from $canonical. Copy the canonical file over it." >&2
    status=1
  fi
done
[ "$status" -eq 0 ] && echo "Shared files are in sync."
exit "$status"
