# SARN

SARN scans linked Radar contacts and skips dynamic constructs. It keeps construct IDs, names, core sizes, physical bounding-box sizes, world coordinates, owner IDs, and resolved owner names only in Lua memory for the current PB session. SARN does not read or write a Databank.

Per-construct AR drawing is currently disabled while radar discovery and CPU usage are profiled. The generic open-corner AR drawing code remains available but is not called by the renderer. The HUD reports ready constructs plus counts for XS/S/M/L/XL/XXL.

Radar does not expose the facing axes or local bounding-box centre of a remote construct. Remote AR boxes therefore use local gravity as vertical and the current construct's forward direction projected onto the gravity horizon. In space, SARN falls back to the active camera axes. This keeps boxes upright but cannot reproduce each remote construct's true rotation.

## Setup

Install `liby/liby4slots.lua` from `../linked slot-elements/src/du lua library` and `liby/liby4performance.lua` from `../HUD AR performance adjustor/src/du lua library` into the DU client `Game/data/lua` directory. Link the PB to an Atmospheric Radar. A Construct Core or Databank link is optional and appears only in the linked-element report. Then run:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

Paste the generated JSON into the PB and restart it. SARN reads only the radar ID list at startup and refreshes that list every five seconds. New IDs become lightweight memory objects and enter a deduplicated queue; already processed IDs are not queued again. A separate worker enriches a CPU-adaptive batch every 0.25 seconds, skipping dynamic constructs before requesting name, size, position, and owner data. It starts at three records, increases by one after a completed tick below 60% CPU, holds between 60% and 70%, caps at 50, and halves the batch after a completed tick above 70%. Completed records remain in memory after leaving radar range, but are lost when the PB stops or Lua reloads.

HUD/AR rendering uses the performance library's bounded 2 Hz Unit timer and does not install a per-frame `system.onUpdate` handler. The HUD reports ID, queue, processing, AR, and size statistics. Chat diagnostics are emitted whenever the detected ID count changes and after every 50 processed records or when the work queue drains.

The HUD also reports the adaptive detail batch and the last successfully completed instruction-budget percentage for rendering, radar-ID refresh, and detail enrichment, plus the highest completed percentage. These values use `system.getInstructionCount()` and `system.getInstructionLimit()`; a handler that hard-overloads cannot record its unfinished final sample.

## Exported settings

- `adaptArRedrawFrequencyToFps` and `maximumArRedrawPercentOfFps` remain available to the performance library, but timer-only rendering currently runs at 2 Hz.
