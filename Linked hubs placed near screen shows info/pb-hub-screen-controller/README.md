# PB Hub Screen Controller

Version 0.1.83 renders a 3-row by 5-column production overview on a Dual
Universe Screen. Hub positions are orthographically projected onto the actual
Screen plane, so the Screen may be mounted vertically, horizontally, or at an
arbitrary angle.

## What it does

- Discovers nearby Container Hubs through a linked Core Unit, or uses only Hubs
  linked directly to the Programming Board when no Core is available.
- Projects every Hub onto the Screen and selects the closest Hub when multiple
  Hubs occupy the same grid cell.
- Reads products from linked Industry Units through the Core.
- Reads container contents only from Container Hubs linked directly to the PB.
- Combines and sorts product quantities, chooses the largest quantity as the
  prime product, and displays remaining products as secondary entries.
- Stores fingerprints and dirty state in the Databank.
- Sends at most one dirty cell to the Screen every 0.2 seconds. The Screen keeps
  previously received cell data in its RenderScript state.

## Required links

Link the Programming Board to:

- one Screen Unit;
- one Databank;
- either a Core Unit, one or more Container Hubs, or both.

A Core discovers nearby Hubs and Industry links. A direct Hub link provides
container inventory contents and also allows that Hub to work without a Core.
The Screen cannot read the Databank directly; the PB reads stored records and
sends Screen configuration or cell updates.

## Build and install

Run from this directory:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

The builder reads the Lua source files, creates the complete PB slot/filter
schema, writes `pb-hub-screen-controller.generated.json`, and copies the JSON
when `-CopyToClipboard` is supplied. It never reads
`pb-hub-screen-controller.json` or another exported configuration template.

Paste the result through **Paste Lua configuration from clipboard** on the PB,
verify the physical links, and start the PB.

To write elsewhere without copying:

```powershell
.\build-lua-configuration.ps1 -OutputPath C:\temp\hsc.json
```

## Source files

| File | PB filter and responsibility |
| --- | --- |
| `library.onStart.lua` | Discovery, projection, Industry and container processing |
| `library.onStart.storage.lua` | Databank records and dirty-state handling |
| `library.onStart.screen.lua` | Screen configuration, per-cell payloads, and embedded renderer |
| `unit.onStart.lua` | Starts the controller |
| `unit.onTimer.hubWaypoint.lua` | Delivers one dirty cell on `hscScreenDelivery` |
| `unit.onTimer.containerRefresh.lua` | Refreshes container data on `hscContainerRefresh` |

The legacy `hubWaypoint` filename no longer creates waypoints.
`screen.onMouseDown.lua` is not used by the generated configuration because the
RenderScript handles Screen input internally.

## Runtime flow

1. Discover the Screen, Databank, optional Core, and available Hubs.
2. Project Hubs into grid cells and keep one closest Hub per cell.
3. Collect Industry products and available direct-container products.
4. Compare each Hub fingerprint with its Databank record and mark changed
   records dirty.
5. Send the Screen configuration once, then send one dirty cell per delivery
   timer tick.
6. Clear a Hub's persisted dirty marker only after its cell update is sent.
7. Request container contents in a staggered cycle while respecting the game's
   per-container update cooldown.

## Main exported parameters

| Parameter | Default | Purpose |
| --- | ---: | --- |
| `hscRows` / `hscColumns` | `3` / `5` | Grid dimensions |
| `hscGridMarginLeftMeters` / `RightMeters` | `0.3` / `0.3` | Horizontal physical margins |
| `hscGridMarginTopMeters` / `BottomMeters` | `1` / `0.5` | Vertical physical margins |
| `hscSearchRadiusMeters` | `20` | Maximum planar Hub distance from Screen center |
| `hscMaxDepthMeters` | `5` | Maximum distance from the Screen plane |
| `hscScreenPollSeconds` | `0.2` | Dirty-cell delivery interval |
| `hscHubContentRefreshSeconds` | `30` | Minimum content request interval per Hub |
| `hscContainerRefreshSeconds` | `5` | Staggered container refresh timer |
| `hscScreenInputMaxCharacters` | `1024` | Maximum Screen input size |

`hscReverseColumns` and `hscReverseRows` reverse grid mapping when desired.
Title, reserved text area, font size, click polling, and debounce settings are
also exported at the top of `library.onStart.lua`.

## Debug controls

All debug options default to `false`:

- `hscDebugScreen`: Screen input markers and click diagnostics.
- `hscDebugElements`: projected Hub dots, coordinates, and projection logs.
- `hscDebugIndustries`: Industry discovery and product logs.
- `hscDebugContainers`: container request, event, capacity, and content logs.
- `hscDebugDatabank`: Databank reads, writes, and dirty-state changes.

## Databank records

Records are namespaced by Screen local ID:

- `hsc:v2:projection:<screenId>` stores the current Screen configuration.
- `hsc:v3:cells:<screenId>` stores the projected Hub/cell map.
- `hsc:v4:cell:<screenId>:<hubId>` stores each Hub fingerprint, timestamp, and
  persisted dirty marker.
- `hsc:v5:renderCell:<screenId>:<column>:<row>` stores the latest render payload
  for each cell.

The Databank preserves dirty work across PB restarts. The Screen itself retains
the cell payloads it has already received while its RenderScript remains active.
