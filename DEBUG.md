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

---

# Session: 2026-08-27 - Patchy Leaflet tiles in Safari

## Observations
- Screenshots show tile images flowing as ordinary page content, large empty gaps, and CARTO's `API KEY REQUIRED` watermark.
- On the live page, the first map is 1118px wide but is stretched to 2560px tall.
- Loaded tile images have the correct 256px display size and 256px grid transforms, but their computed CSS position is `static` instead of `absolute`.
- The Leaflet stylesheet link has no attached stylesheet in the browser; only the page's inline stylesheet is active.
- The downloaded Leaflet 1.9.4 CSS SHA-256 is `p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=`, while the HTML contains a different integrity value.
- OpenStreetMap's current tile policy specifies `https://tile.openstreetmap.org/{z}/{x}/{y}.png` for normal interactive browser use with visible attribution and a valid Referer.

## Hypotheses

### H1: The incorrect Leaflet CSS integrity hash causes the browser to reject the stylesheet (ROOT HYPOTHESIS)
- Supports: the live stylesheet link has no `sheet`; Leaflet panes and tiles compute to `position: static`; the declared and downloaded hashes differ.
- Conflicts: none.
- Test: compare the declared SRI value with the SHA-256 of the official Leaflet 1.9.4 CSS.

### H2: Retina CARTO tiles are intrinsically too large
- Supports: the tile images are 512px assets on a 2x display.
- Conflicts: Leaflet correctly assigns each tile a 256px inline width and height.
- Test: compare each tile's natural and rendered dimensions.

### H3: Leaflet initialized before the map containers reached their final size
- Supports: stale dimensions can produce incomplete tile coverage.
- Conflicts: `invalidateSize()` already runs and the observed 2560px height is caused by static tile flow.
- Test: compare container height with tile computed positioning after initialization.

### H4: CARTO is unsuitable without an API key
- Supports: rendered CARTO tiles contain an `API KEY REQUIRED` watermark.
- Conflicts: the HTTP image requests succeed.
- Test: inspect the returned tile imagery.

## Experiments
- Confirmed H1: the official CSS hash does not match the HTML integrity value, so SRI rejects the stylesheet; the browser exposes no stylesheet and Leaflet positioning rules are absent.
- Rejected H2: natural 512px Retina assets render at the intended 256px CSS size.
- Rejected H3: the abnormal height follows from tiles using normal document flow, not a stale Leaflet size calculation.
- Confirmed H4: CARTO tiles load but visibly require an API key.

## Root Cause
An incorrect SRI hash blocked Leaflet's CSS, causing map tiles to use static document flow; CARTO also watermarked the unauthenticated tile requests.

## Fix
Use Leaflet's official CSS integrity hash and the official OpenStreetMap raster tile URL with visible OpenStreetMap attribution.
Local browser verification showed all five maps at their intended heights, absolute-positioned 256px tiles, no console errors, and no CARTO watermark.
A regression check now guards the stylesheet hash, official tile URL, attribution, map count, and absence of CARTO URLs.
