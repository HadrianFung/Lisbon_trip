#!/bin/sh
set -eu

page="$(dirname "$0")/../index.html"

grep -Fq 'sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=' "$page"
grep -Fq 'https://tile.openstreetmap.org/{z}/{x}/{y}.png' "$page"
grep -Fq 'OpenStreetMap</a> contributors' "$page"

if grep -Fq 'basemaps.cartocdn.com' "$page"; then
  echo "CARTO tile URL must not be present" >&2
  exit 1
fi

map_count="$(grep -c 'class="leaflet-map' "$page")"
test "$map_count" -eq 5

echo "Map configuration checks passed"
