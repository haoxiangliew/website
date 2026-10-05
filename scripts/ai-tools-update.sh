#!/usr/bin/env bash
# Sync Svelte's agent skills and subagents from sveltejs/ai-tools.
# It rewrites npx calls to use `bun run` and changes nothing else.
set -euo pipefail

repo="sveltejs/ai-tools"
ref="main"
skills_dir=".agents/skills"
agents_dir=".pi/agents"

cd "$(dirname "$0")/.."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git clone --quiet --depth 1 --filter=blob:none --no-checkout --branch "$ref" "https://github.com/${repo}.git" "$tmp"
git -C "$tmp" sparse-checkout set --no-cone "/tools/skills/" "/tools/agents/"
git -C "$tmp" checkout --quiet

# rg can't edit files in place, and it exits with 1 when nothing matches.
replace() {
  local file="$1" pattern="$2" replacement="$3"
  rg --no-config --passthru --replace "$replacement" "$pattern" "$file" >"${file}.tmp" || [ $? -eq 1 ]
  mv "${file}.tmp" "$file"
}

while IFS= read -r file; do
  replace "$file" 'npx @sveltejs/mcp(@latest -y)?' 'bun run svelte-mcp'
  replace "$file" '\bnpx\b' 'bun run'
done < <(rg --no-config --files -g '*.md' "$tmp/tools/skills" "$tmp/tools/agents")

mkdir -p "$skills_dir" "$agents_dir"

for skill in "$tmp"/tools/skills/*/; do
  name="$(basename "$skill")"
  rm -rf "${skills_dir:?}/${name}"
  cp -R "$skill" "${skills_dir}/${name}"
done

cp "$tmp"/tools/agents/*.md "${agents_dir}/"
