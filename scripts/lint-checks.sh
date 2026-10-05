#!/usr/bin/env bash
# Checks that oxlint can't run.
set -euo pipefail

cd "$(dirname "$0")/.."

status=0

# rg exits 0 on a match, 1 on no match, and 2 on an error.
fail_on_match() {
  local message="$1"
  shift
  local code=0
  rg --no-config "$@" || code=$?
  if [ "$code" -eq 0 ]; then
    echo "$message" >&2
    status=1
  elif [ "$code" -ne 1 ]; then
    exit "$code"
  fi
}

fail_on_match "Use exact versions in package.json, without ^ or ~." \
  --line-number ': "[\^~]' package.json

fail_on_match "Add a <script> block to these files, even an empty one. oxlint skips the markup of .svelte files without one." \
  --files-without-match '<script(\s[^>]*[^/])?>' -g '*.svelte' -g '!src/lib/components/ui' src

exit "$status"
