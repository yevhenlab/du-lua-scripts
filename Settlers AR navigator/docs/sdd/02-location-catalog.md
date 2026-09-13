# 2. Location Catalog

## Source

Known places are explicitly defined in SARN Lua data catalogs installed under `<DU Root>/Game/data/lua/sarn/`. The primary `locations.lua` catalog contains DU-provided, standard, and default locations. Settlers-specific destinations belong in `locations-settlers.lua`. The primary catalog can name additional independent files through `catalogModules` or keyed child modules. The high-level planet and satellite entries originate from the client atlas. Assigned Aphelia constructs are imported offline from `aphelia-construct-hierarchy.json`, which SARN does not read at runtime; the runtime atlas remains available for coordinate-conversion fallbacks.

## What a location means

A real location is one navigable place with one primary coordinate. It can represent space, a star system, a celestial body, an asteroid, a zone, one construct, multiple constructs, or a large event area.

A `group` node is different: it only organizes the catalog hierarchy. It is not a physical place, does not require an `id` or coordinate, and must not be treated as a spatial `zone`. Examples include `Institutes`, `Market Districts`, `Markets only`, `Parking spots`, and `Outposts`. A future real `zone` should have a coordinate and boundary information.

For example, a market composed of several XL parking constructs is saved as one market location, not as every constituent construct. A large fly-in event can likewise be one location, with supporting details about its internal areas. A location may provide a bounding size or boundary later, but its coordinate remains the primary AR navigation anchor.

## Hierarchy

Locations normally form a bounded tree. Every node has a structural `type` and may contain children. Real-place nodes describe navigable space; `group` nodes only organize related children. A node without children is a leaf.

The catalog root is the coordinate-less `Known Space` group node. Its children are known star systems. `Helios System` is a spatial child centred at `::pos{0,0,0,0,0}` with a 100,000,000-metre area radius; all known planets are its children, while satellite tables are physically nested in their planets' `children` lists. The offline catalog generator derives this nesting from the source atlas's `satellites` arrays; SARN does not reconstruct celestial parenting at runtime. Only direct planet children of a system participate in the optional system-planet baseline, so satellites are never globally visible through their system.

```text
Universe / system
└─ Alioth area
   └─ Haven Moon area
      └─ Market
         └─ Parking
```

Planets, moons, planetoids, nearby space stations, and future star systems can occupy high levels. A space station may be a child of a nearby body when that relationship is useful for navigation, or a peer of planets when it is not. The hierarchy describes navigation meaning, not strict astronomical taxonomy.

The maximum nesting depth will be decided as real catalog cases are added. Unlimited nesting is not allowed.

## Shared locations and navigation collections

The same real location may appear under more than one navigation collection. For example, `My Alioth Base` can be a child of `Alioth` and also a child of a virtual `My Bases` collection. This is useful and not a duplicate location.

Such a catalog is technically a directed acyclic graph rather than a strict tree. SARN must assign one internal runtime identity to the shared Lua table and deduplicate it before AR rendering, so it is shown only once even when reached through multiple parent paths. Cyclic parent/child references are invalid.

## Hybrid catalog loading

SARN uses a hybrid tree representation.

- A modest branch may store its direct children inline as `children = { ... }`.
- A large or independently maintained branch uses `childrenModule = "sarn/locations/..."`.

Deferred work: `childrenModule` branches must become genuinely lazy. Initialization will retain the module name without requiring it; SARN will load and cache that branch only when its parent becomes relevant, its detailed view opens, or its children are required for rendering. Inline children in the current file necessarily load with that file.
- A node can combine inline `children` with `childrenModule` or `childrenModules` when independently maintained branches share the same parent.

The root catalog stays small. SARN loads a deferred branch only when its parent area becomes relevant to navigation or the player explicitly requests its sub-locations. A regional file may still contain a readable inline sub-tree when that region is modest in size.

## Catalog entry

An entry may contain:

- `name`: player-facing location name.
- `id`: optional numeric DU identifier for the represented system, celestial body, construct, or other place. Planet and satellite nodes use their DU body ID; construct nodes use their construct ID. A group normally has no ID.
- `type`: required structural node type: `space`, `system`, `planet`, `satellite`, `asteroid`, `constructStatic`, `constructSpace`, `zone`, or `group`.
- `kind`: semantic display classification, such as `market`, `base`, `mining`, `outpost`, `settlement`, `mission`, `quest`, `showroom`, `event`, or `station`.
- `icon`: optional icon selected for the location. When absent, SARN uses the default icon configured for `kind`.
- `owner`: literal player-facing owner name. Empty or `nil` means that no owner line is shown; `"unknown"` is rendered literally.
- `coordinate`: a world-space or planet-relative `::pos{...}` string; world-space `{ x, y, z }` tables remain supported. Real places should provide one. A `group` may omit it.
- `atlasBody`: optional `{ systemId, bodyId }` celestial-body identity. Together with the node's centre coordinate and `areaRadius`, it supports body-relative output without loading `atlas.lua`; the runtime atlas may still provide supplementary body information.
- `coreSize`: optional construct-core size when the location represents a construct.
- `size`: optional bounding-box dimensions.
- `radius`: surface radius in metres for a planet or satellite.
- `atmosphereRadius`: atmosphere boundary radius in metres for a planet or satellite; zero means no atmosphere.
- `areaRadius`: optional radius in metres describing the area governed by this location.
- `color`: optional AR RGB override.
- `label`: optional supporting information.
- `description`: optional longer text shown by expanded AR details.
- `excluded`: optional boolean. When `true`, the entry remains in the catalog but does not become an AR object or count in active-location HUD statistics. Its children remain independently eligible unless they are also excluded.
- `children`: optional inline sub-location list.
- `childrenModule`: optional Lua module path containing an additional sub-location list.
- `childrenModules`: optional list of additional child-module paths.
- `childrenModuleKey`: optional named table to select from a shared child module.

The catalog's optional `id` preserves the source DU identifier but is not currently used for rendering or persistence. While loading, SARN separately assigns every distinct Lua location table a unique internal runtime ID for maps, AR selection, hover state, diagnostics, and deduplication. Group nodes normally omit `id`; duplicate source IDs do not invalidate entries.

Imported Aphelia hierarchy records map `constructKind = 3` to `type = "constructStatic"` and `constructKind = 5` to `type = "constructSpace"`. Their numeric construct identifier is stored as `id`, their resolved coordinate is stored as `coordinate`, and their literal owner is `owner = "Aphelia"`. A construct assigned beneath a planet or satellite uses its `planetCoordinate`. The JSON `relationship` value is not copied, but the nesting of each `children` array is preserved recursively.

Planet and satellite nodes must retain a world-space `::pos{0,0,x,y,z}` centre coordinate even when planet-relative coordinates are available. Their `id` must match `atlasBody.bodyId`; `radius` describes the surface, `atmosphereRadius` describes the atmosphere boundary, and `areaRadius` describes the catalog area. `atlasBody` remains separate because it carries both the system and body identities required for coordinate conversion. The catalog also returns a limited offline atlas when the full client atlas is unavailable. Its additional bodies support coordinate conversion without automatically becoming AR location nodes.

Inline `children`, root-level `catalogModules`, and child catalog modules are implemented. A child node may use `childrenModuleKey` to select a named branch from a shared module. Child modules currently load during catalog initialization; distance-driven deferred loading remains planned.

The current default catalog contains all 367 constructs assigned beneath the 21 planet and satellite records in `aphelia-construct-hierarchy.json`. All assigned records in this source revision are static constructs. Generic `Static construct` and `Space construct` labels are stored as empty strings so they do not duplicate type information in AR labels. The JSON's separate 72-construct `unparented` branch is intentionally not imported yet. Existing Settlers module hooks remain attached to Alioth, Haven, and the Institutes construct, and the custom Mission Alioth parking-waypoint group remains alongside the imported construct children. Haven restores two coordinate-less organizational children: `[01-10] Market Districts` contains Haven 01–10 with their existing descendants, while `[11-20] Markets only` contains Haven 11–20. Sanctuary follows the same structure: `[01-10] Market Districts` contains Sanctuary 01–10 with their Market, Shuttle, and UEF Store descendants, while `[11-20] Markets only` contains Sanctuary 11–20. Alioth Exchange groups its eight hall constructs beneath `Halls` and its four landing constructs beneath `Parking`; Center and Pillar remain direct children. Guardians of Alioth Odysseus Alpha groups its UEF Outpost Museums, Gallia Gemina Tour Palaces, and Outpost Museum stands, while its distinct landmarks remain direct children. The Settlers module contributes `Outposts` as another Haven group.

## Visibility principle

SARN normally shows a small useful set of AR objects, approximately 5–20, rather than every known location. A parent area is visible at a distance; its children remain hidden until the player is near enough or explicitly requests them. For example, a player on Haven Moon may see Alioth in the sky and the nearest market or their base, but not every sub-Alioth location or sub-point within their base.

Distance to the player, hierarchy depth, parent/child area size or boundaries, screen visibility, and rendering budget will jointly determine whether a node or its children are shown.

SARN selects the deepest catalog node whose boundary contains the player as the current node. Its normal hierarchy view contains:

- planets directly beneath the active star system when `showSystemPlanets` is enabled;
- satellites directly beneath the closest planet when `showSatellites` is enabled;
- up to `maximumNearbyPlaces` non-celestial direct children when `showCurrentNodeChildren` is enabled;
- up to `maximumNearbyPlaces` non-celestial descendants inside the active nearby range when `showNearbyPlaces` is enabled;
- the current node and, where permitted, its direct parent or parents.

The four exported visibility parameters initialize mutable runtime switches. The quick strip and Locations menu edit the same runtime values without creating pin records. Stored Databank values override the exported defaults at startup.

The current node remains part of the selected set, although projection may omit its marker while the player is inside it, and its name appears in the HUD. Siblings and children of unrelated locations remain hidden unless another independent visibility group or pin selects them.

`areaRadius` is the first planned area-boundary field. Child AR objects inside a parent's area remain hidden until the player is close enough to that parent area. The exact distance rule will be tuned with real places.

For atlas planets and moons, current-node detection treats the body's atmosphere radius—or at least five kilometres above its physical radius—as the active boundary. Non-atlas areas use `areaRadius` directly.

## Owner display

SARN renders the catalog's literal `owner` value as `Owner: Name`. It performs no owner-ID lookup through DU APIs. Standard celestial locations normally omit the owner, while known Aphelia constructs use `owner = "Aphelia"`.
