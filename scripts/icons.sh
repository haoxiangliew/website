#!/usr/bin/env bash
# Generates the site icons from Lucide's lambda icon. Needs resvg and magick from the nix dev shell.
set -euo pipefail

cd "$(dirname "$0")/.."

# must match the background colors in layout.css
dark="#0a0a0a"
light="#ffffff"

assets=src/lib/assets
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

paths=$(rg --no-config -o '<path[^>]*/>' node_modules/lucide-static/icons/lambda.svg | tr -d '\n')

glyph() {
  printf '<g fill="none" stroke="%s" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">%s</g>' "$1" "$paths"
}

# transparent; switches stroke color with the OS theme
cat >"$assets/favicon.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><style>@media (prefers-color-scheme: dark) { g { stroke: $light } }</style>$(glyph "$dark")</svg>
EOF

# solid tile for formats that can't follow the theme
cat >"$tmp/tile.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><rect width="32" height="32" fill="$dark"/><g transform="translate(4 4)">$(glyph "$light")</g></svg>
EOF

resvg -w 180 "$tmp/tile.svg" "$assets/apple-touch-icon.png"
for size in 16 32 48; do
  resvg -w "$size" "$tmp/tile.svg" "$tmp/$size.png"
done
# static/ so it's served at /favicon.ico, which some tools request without reading the page
magick "$tmp/16.png" "$tmp/32.png" "$tmp/48.png" static/favicon.ico
