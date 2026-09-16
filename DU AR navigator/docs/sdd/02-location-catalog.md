# 2. Location Catalog

## Source

Known places are explicitly defined in ARN Lua data catalogs installed under `<DU Root>/Game/data/lua/arn/`. The primary `locations.lua` catalog contains only DU-provided, standard, and default locations. `locations-registry.lua` registers optional custom catalogs and maps their named lists to standard parent IDs. Settlers-specific destinations belong in `locations-settlers.lua`. The high-level planet and satellite entries originate from the client atlas. Assigned Aphelia constructs are imported offline from `aphelia-construct-hierarchy.json`, which ARN does not read at runtime; the runtime atlas remains available for coordinate-conversion fallbacks. Every registered custom catalog is loaded defensively: a missing, invalid, or non-table module is skipped with one warning while the default catalog and other valid modules continue loading.

## What a location means

A real location is one navigable place with one primary coordinate. It can represent space, a star system, a celestial body, an asteroid, a zone, one construct, multiple constructs, or a large event area.

A `group` node is different: it only organizes the catalog hierarchy. It is not a physical place, does not require an `id` or coordinate, and must not be treated as a spatial `zone`. Examples include `Market Districts`, `Markets only`, `Parking spots`, and `Outposts`. A future real `zone` should have a coordinate and boundary information. After all catalog and child-module entries load, ARN recursively derives `boundsCenter`, `boundsRadiusX`, `boundsRadiusY`, `boundsRadiusZ`, and `boundsSourceCount` for every runtime node. A leaf uses its own coordinate as `boundsCenter` and its `areaRadius` for all three radii. A parent merges each direct child's calculated centre and three radii with its own coordinate and `areaRadius` sphere. No singular runtime `boundsRadius` exists. Every node uses its own coordinate as its AR display position, falling back to `boundsCenter` when no coordinate exists. A coordinate-less node with a derived centre therefore renders as one AR object with its ellipsoid rings whenever selected for display; ARN descends through a node only when it has neither a coordinate nor a bounds centre. Current-area detection uses the calculated bounds ellipsoid with a flat 75% entry expansion. Future runtime catalog changes can call `ARNLocationCatalog.recalculateBounds()` after modifying the tree.

For example, a market composed of several XL parking constructs is saved as one market location, not as every constituent construct. A large fly-in event can likewise be one location, with supporting details about its internal areas. A location may provide a bounding size or boundary later, but its coordinate remains the primary AR navigation anchor.

## Hierarchy

Locations normally form a bounded tree. Every node has a structural `type` and may contain children. Real-place nodes describe navigable space; `group` nodes only organize related children. A node without children is a leaf.

The catalog root is the coordinate-less `Known Space` group node. Its children are known star systems. `Helios System` is a spatial child centred at `::pos{0,0,0,0,0}` with a 100,000,000-metre area radius; all known planets are its children, while satellite tables are physically nested in their planets' `children` lists. The offline catalog generator derives this nesting from the source atlas's `satellites` arrays; ARN does not reconstruct celestial parenting at runtime. Only direct planet children of a system participate in the optional system-planet baseline, so satellites are never globally visible through their system.

```text
Universe / system
└─ Alioth area
   └─ Haven Moon area
      └─ Market
         └─ Parking
```

Planets, satellites, planetoids, nearby space stations, and future star systems can occupy high levels. A space station may be a child of a nearby body when that relationship is useful for navigation, or a peer of planets when it is not. The hierarchy describes navigation meaning, not strict astronomical taxonomy.

The maximum nesting depth will be decided as real catalog cases are added. Unlimited nesting is not allowed.

## Shared locations and navigation collections

The same real location may appear under more than one navigation collection. For example, `My Alioth Base` can be a child of `Alioth` and also a child of a virtual `My Bases` collection. This is useful and not a duplicate location.

Such a catalog is technically a directed acyclic graph rather than a strict tree. ARN must assign one internal runtime identity to the shared Lua table and deduplicate it before AR rendering, so it is shown only once even when reached through multiple parent paths. Cyclic parent/child references are invalid.

## Hybrid catalog loading

ARN uses inline standard trees plus registered custom attachments.

- Standard branches store their children inline as `children = { ... }`.
- `locations-registry.lua` lists each optional custom module once.
- Each registration maps a standard `parentId` to a named `sourceKey` returned by that custom module.
- Registered children are combined with the standard parent's inline children during catalog initialization.

For example, `{ parentId = 2, sourceKey = "alioth" }` attaches every node in the custom module's `alioth` list directly beneath standard Alioth. The key is only a table lookup and never becomes a runtime location node. The standard catalog contains no references to custom modules. The loader assigns `sourceId = 0` to standard nodes and sequential positive source IDs to successfully loaded registry modules. Inline descendants inherit their defining module's source ID. Registry `label` and `module` values are stored once as shared source metadata; runtime nodes retain only the numeric ID.

## Catalog entry

An entry may contain:

- `name`: player-facing location name.
- `id`: optional numeric DU identifier for the represented system, celestial body, construct, or other place. Planet and satellite nodes use their DU body ID; construct nodes use their construct ID. A group normally has no ID.
- `type`: required single node classification used for behavior and default icon selection. Structural values include `known-space`, `space`, `system`, `planet`, `satellite`, `asteroid`, `location-group`, `construct`, and `zone`; semantic place values include `market`, `base`, `mining`, `outpost`, `settlement`, `mission`, `quest`, `showroom`, `event`, `parking`, and `station`.
- `icon`: optional icon selected for the location. When absent, ARN uses the default icon configured for `type`.
- `owner`: literal player-facing owner name. Empty or `nil` means that no owner line is shown; `"unknown"` is rendered literally.
- `coordinate`: a world-space or planet-relative `::pos{...}` string; world-space `{ x, y, z }` tables remain supported. Real places should provide one. A `location-group` may omit it.
- `atlasBody`: optional `{ systemId, bodyId }` celestial-body identity. Together with the node's centre coordinate and `areaRadius`, it supports body-relative output without loading `atlas.lua`; the runtime atlas may still provide supplementary body information.
- `coreSize`: optional construct-core size when the location represents a construct.
- `size`: optional bounding-box dimensions.
- `radius`: surface radius in metres for a planet or satellite.
- `atmosphereRadius`: atmosphere boundary radius in metres for a planet or satellite; zero means no atmosphere.
- `areaRadius`: optional radius in metres describing the area governed by this location.
- `color`: optional AR RGB override.
- `label`: optional supporting information.
- `description`: optional longer text shown by expanded AR details.
- `excluded`: optional boolean. When `true`, catalog loading skips the entry and its complete descendant branch. No runtime targets, child indexes, bounds, AR objects, detailed-view rows, or active-location statistics are created for that branch.
- `children`: optional inline sub-location list.

A `locations-registry.lua` registration contains `module`, plus an `attachments` list. Each attachment contains the standard node's `parentId` and the custom module's `sourceKey`.

A registered custom module may declare `disabled = { ids = {...}, paths = {...} }`. ARN combines these rules additively across every successfully loaded module before building the runtime catalog. IDs are preferred; normalized, case-insensitive full paths support ID-less nodes. A match skips the node and its complete descendant branch before indexing, bounds calculation, rendering, or detailed-view construction. Duplicate rules are harmless, registry order does not affect the result, and one module cannot re-enable a node disabled by another.

The catalog's optional `id` preserves the source DU identifier but is not currently used for rendering or persistence. While loading, ARN separately assigns every distinct Lua location table a unique internal runtime ID for maps, AR selection, hover state, diagnostics, and deduplication. Group nodes normally omit `id`; duplicate source IDs do not invalidate entries.

Imported Aphelia hierarchy records use `type = "construct"` unless a more specific place type is assigned; the source `constructKind` distinction is not retained in runtime location nodes. Their numeric construct identifier is stored as `id`, their resolved coordinate is stored as `coordinate`, and their literal owner is `owner = "Aphelia"`. A construct assigned beneath a planet or satellite uses its `planetCoordinate`. The JSON `relationship` value is not copied, but the nesting of each `children` array is preserved recursively.

Planet and satellite nodes must retain a world-space `::pos{0,0,x,y,z}` centre coordinate even when planet-relative coordinates are available. Their `id` must match `atlasBody.bodyId`; `radius` describes the surface, `atmosphereRadius` describes the atmosphere boundary, and `areaRadius` describes the catalog area. `atlasBody` remains separate because it carries both the system and body identities required for coordinate conversion. The catalog also returns a limited offline atlas when the full client atlas is unavailable. Its additional bodies support coordinate conversion without automatically becoming AR location nodes.

Inline standard `children`, root-level `catalogModules`, and registry-driven custom attachments are implemented. Registered custom modules load during catalog initialization.

The current default catalog contains all 367 constructs assigned beneath the 21 planet and satellite records in `aphelia-construct-hierarchy.json`. All assigned records in this source revision are static constructs. Generic `Static construct` and `Space construct` labels are stored as empty strings so they do not duplicate type information in AR labels. The JSON's separate 72-construct `unparented` branch is intentionally not imported yet. The registry attaches Settlers lists to Alioth, Haven, and the Institutes construct by their standard source IDs. At Alioth, `Neon Abyss Parking` and `Settlers Honeycomb` are independent siblings of `Institutes`; only `Hadron Quantum Teleporter` remains an Institutes child. The custom Mission Alioth parking-waypoint group remains alongside the imported construct children. Haven restores two coordinate-less organizational children: `[01-10] Market Districts` contains Haven 01–10 with their existing descendants, while `[11-20] Markets only` contains Haven 11–20. Sanctuary follows the same structure: `[01-10] Market Districts` contains Sanctuary 01–10 with their Market, Shuttle, and UEF Store descendants, while `[11-20] Markets only` contains Sanctuary 11–20. Alioth Exchange groups its eight hall constructs beneath `Halls` and its four landing constructs beneath `Parking`; Center and Pillar remain direct children. Guardians of Alioth Odysseus Alpha groups its UEF Outpost Museums, Gallia Gemina Tour Palaces, and Outpost Museum stands, while its distinct landmarks remain direct children. The Settlers module contributes `Outposts` as another Haven group.

## Visibility principle

ARN normally shows a small useful set of AR objects, approximately 5–20, rather than every known location. A parent area is visible at a distance; its children remain hidden until the player is near enough or explicitly requests them. For example, a player on Haven Moon may see Alioth in the sky and the nearest market or their base, but not every sub-Alioth location or sub-point within their base.

Distance to the player, hierarchy depth, parent/child area size or boundaries, screen visibility, and rendering budget will jointly determine whether a node or its children are shown.

ARN selects the deepest eligible catalog node containing the player as the current node. Every eligible node uses its calculated bounds ellipsoid enlarged by a flat 75% for entry detection. Nodes with `type = "location-group"` are ineligible by default; the persisted `allowGroupsAsCurrentArea` setting can opt them back into selection without changing their bounds or rendering. This catalogue-wide containment scan is cached for 0.15 seconds so it does not repeat on every rendered frame. Its normal hierarchy view contains:

- planets directly beneath the active star system when `showSystemPlanets` is enabled;
- satellites directly beneath the closest planet when `showSatellites` is enabled;
- up to `maximumNearbyPlaces` non-celestial places directly inside the current area when `showCurrentAreaPlaces` is enabled;
- nearby non-celestial sibling areas when `showNearbyAreas` is enabled;
- up to `maximumNearbyPlaces` direct places of nearby sibling areas inside the active range when `showNearbyAreaPlaces` is enabled;
- the current node and, where permitted, its direct parent or parents.

The five exported visibility parameters initialize mutable runtime switches. The quick strip and Locations menu edit the same runtime values without creating pin records. Stored Databank values override the exported defaults at startup.

The current node drives HUD and context selection but does not become AR-visible merely because it is current. When the current node is non-celestial, its direct parent becomes the context root. The current node and non-celestial siblings whose centres are within `nearbyRange * 2 * 1.2` become context candidates. This first stage compares squared world-space distances. Only the direct children of those context candidates are inspected in the second stage; children within the real nearby range are globally ordered by distance, and the nearest `maximumNearbyPlaces` are selected. A sibling-area marker is eligible only when at least one of its direct places is inside that real range. Context-node markers do not consume the child limit. When the current node is celestial, nearby selection examines only its own direct children and does not inspect their descendants. This fixed two-level window prevents recursive catalogue expansion.

`areaRadius` is the catalog source sphere for a node. It participates in the recursive X/Y/Z bounds calculation together with all calculated child ellipsoids.

Current-node detection uses only the recursively calculated `boundsCenter` and three bounds radii, expanded by 75%. A node without complete calculated bounds cannot become current.

## Owner display

ARN renders the catalog's literal `owner` value as `Owner: Name`. It performs no owner-ID lookup through DU APIs. Standard celestial locations normally omit the owner, while known Aphelia constructs use `owner = "Aphelia"`.
