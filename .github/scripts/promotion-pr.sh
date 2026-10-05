#!/usr/bin/env bash

set -euo pipefail

: "${GITHUB_REPOSITORY:?}"
: "${GITHUB_REPOSITORY_OWNER:?}"

repo="repos/${GITHUB_REPOSITORY}"

commits="$(gh api "${repo}/compare/master...staging" \
  --jq '.commits[] | "- \(.sha) \(.commit.message | split("\n")[0])"')"
if [[ -z ${commits} ]]; then
  echo "staging has nothing to promote"
  exit 0
fi

failed=0
plan="$(bun run alchemy:plan prod --no-input 2>&1)" || failed=1
plan="$(sed -E 's/^\[[0-9:.]+\] [A-Z]+ \(#[0-9]+\): //' <<<"${plan}")"
summary="$(grep -m1 -E '^(Plan:|Planning failed)' <<<"${plan}" || echo "No plan output")"

body="$(mktemp)"
{
  echo "Merging this deploys staging to prod."
  echo
  echo "### Commits"
  echo
  echo "${commits}"
  echo
  echo "<details><summary><b>prod</b>: ${summary}</summary>"
  echo
  echo '```'
  echo "${plan}"
  echo '```'
  echo
  echo "</details>"
} >"${body}"

number="$(gh api "${repo}/pulls?base=master&head=${GITHUB_REPOSITORY_OWNER}:staging&state=open" \
  --jq '.[0].number // empty')"
if [[ -n ${number} ]]; then
  gh api --method PATCH "${repo}/pulls/${number}" -F "body=@${body}" >/dev/null
else
  gh api "${repo}/pulls" -f title="Promote staging to prod" -f head=staging -f base=master \
    -F "body=@${body}" >/dev/null
fi

exit "${failed}"
