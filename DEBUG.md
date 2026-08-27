---

# Session: 2026-08-27 - GitHub Pages map rendering

## Observations
- GitHub Pages served the updated `index.html` using CARTO Voyager tiles.
- A browser loaded five Leaflet map containers and 85 CARTO tile images with no console errors.
- The original direct OpenStreetMap tile host had previously returned an access-denied response.

## Hypotheses

### H1: Direct OpenStreetMap tile access was being restricted (ROOT HYPOTHESIS)
- Supports: the direct tile request returned an access-denied response; CARTO tiles loaded in the browser.
- Conflicts: none observed.
- Test: publish the same Leaflet maps with CARTO Voyager tiles and check the rendered page.

### H2: GitHub Pages had not yet published the latest commit
- Supports: an earlier live response still contained the old tile URL.
- Conflicts: the current live page contains CARTO Voyager URLs.
- Test: compare the live HTML with the pushed source.

### H3: Leaflet failed to initialize in Safari
- Supports: the initial symptom was blank maps in Safari.
- Conflicts: the published page has Leaflet map containers and no console errors.
- Test: inspect the rendered page and its console.

## Experiments
- Confirmed H1: the published CARTO tile configuration rendered 85 map tiles and no console errors.
- Rejected H2: GitHub Pages is now serving the updated configuration.
- Rejected H3 for the current page: Leaflet initializes successfully.

## Root Cause
The public direct OpenStreetMap tile host was unreliable for this Pages deployment because it returned an access-denied tile response.

## Fix
Replaced the direct OpenStreetMap tile URL with CARTO Voyager tiles, which use OpenStreetMap data and require no API key.
