#!/usr/bin/env bash
# Sync the shadcn-svelte agent skill from huntabyte/shadcn-svelte.
# It copies only the Markdown files and changes nothing else.
set -euo pipefail

repo="huntabyte/shadcn-svelte"
ref="main"
skill="shadcn-svelte"
skills_dir=".agents/skills"

cd "$(dirname "$0")/.."

if [ ! -f components.json ]; then
  if [ -d "${skills_dir}/${skill}" ]; then
    # Without a terminal, read fails and the answer counts as no.
    read -r -p "No components.json found. Remove the ${skill} skill? [y/N] " answer || answer=""
    if [[ $answer == [yY] ]]; then
      rm -rf "${skills_dir:?}/${skill}"
    fi
  fi
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git clone --quiet --depth 1 --filter=blob:none --no-checkout --branch "$ref" "https://github.com/${repo}.git" "$tmp"
git -C "$tmp" sparse-checkout set --no-cone "/skills/${skill}/**/*.md"
git -C "$tmp" checkout --quiet

mkdir -p "$skills_dir"
rm -rf "${skills_dir:?}/${skill}"
cp -R "$tmp/skills/${skill}" "${skills_dir}/${skill}"
