# AR Navigator

ARN renders AR assistance only for known, established places stored in `arn/locations.lua`. It does not scan Radar contacts. A Databank is optional and stores selected runtime settings and pins. Runtime branding is configured in `library.onStart.configuration.lua`: `applicationShortName = "SARN"` controls the controller, chat tag, warnings, and Databank namespace, while `applicationNamePrefix = "Settlers"` controls the HUD title prefix. These defaults display `Settlers AR Navigator`.

Each visible place is shown as a dot with:

- `Construct name [size]`
- `Owner: Name` when the catalog provides an owner
- Optional supporting `label`

## Setup

1. Install ARN and its packaged `liby4slots.lua` and `liby4performance.lua` dependencies:

```powershell
.\install-local.ps1
```

2. Edit `<DU Root>/Game/data/lua/arn/locations.lua` for standard locations or `locations-settlers.lua` for Settlers destinations; list custom modules in `locations-registry.lua`. Each custom module puts root locations under `nodes`, with `parentId` on each root. See `locations-example.lua` for a commented custom-catalog template and every supported node field. Each real place may retain its DU `id` and needs a `name` and semantic `type`; `coordinate`, `label`, literal `owner`, `atlasBody`, and `areaRadius` are added when applicable; planet and satellite nodes also define `radius` and `atmosphereRadius` for the limited fallback atlas. Optional `icon` overrides the type icon; `excluded = true` skips that node and its complete descendant branch during catalog loading. The registered `locations-constructs.lua` is a snapshot of the Construct Editor export; copy a newer `constructs.lua` there when refreshing player constructs. Roots without `parentId` are reported and skipped.
3. Build and paste the generated Programming Board configuration:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

No linked Radar or Core is required. A linked Databank is optional; the main-menu Save to databank action stores all Locations, HUD, and Settings menu values, plus pins, for later starts.

## Navigation behavior

`Alt+5` shows or hides ARN. Its Locations menu and quick strip share five switches: Planets, Satellites, Places of current area, Nearby areas, and Places of nearby areas. The default view shows planets, places of the current area, and nearby areas; satellites and places of nearby areas start disabled.

Nearby rendering uses the configured atmospheric or space range (5 km and 50 km by default). ARN first considers only nearby sibling areas, then checks their direct places against the real range. This keeps AR useful without recursively exposing a whole catalog.

Each catalog node derives a three-axis bounds ellipsoid from its own position/area radius and its descendants. ARN uses that calculated area to identify the current area, while AR marker visibility still follows the normal range and screen-culling rules. Coordinate-less groups with derived bounds may be rendered as areas; groups with only one descendant remain transparent organizers by default.

The HUD consists of independently configurable AR Navigator, Visible Markers, and Pinned Locations panels. Pins may additionally grant AR visibility within an optional pin-distance limit; this never prevents normal range-based visibility. A pinned HUD row is dimmed when its corresponding marker is not visible on screen.
