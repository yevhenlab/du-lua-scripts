# 2. Location Catalog

## Source

Known places are explicitly defined in SARN Lua data catalogs installed under `<DU Root>/Game/data/lua/sarn/`. The primary `locations.lua` catalog contains standard locations and can name additional independent files through `catalogModules`. Settlers-specific destinations are kept in `locations-settlers.lua`. The initial high-level planet and moon entries are copied from the client `atlas.lua`; the catalog does not generate them at runtime.

## What a location means

A location is one navigable real-world area with one primary coordinate. It can represent one construct, multiple constructs, or a large event area.

For example, a market composed of several XL parking constructs is saved as one market location, not as every constituent construct. A large fly-in event can likewise be one location, with supporting details about its internal areas. A location may provide a bounding size or boundary later, but its coordinate remains the primary AR navigation anchor.

## Hierarchy

Locations normally form a bounded tree. A node is an area and may contain child areas or spots. A node without children is a leaf location.

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
- A node can combine inline `children` with `childrenModule` or `childrenModules` when independently maintained branches share the same parent.

The root catalog stays small. SARN loads a deferred branch only when its parent area becomes relevant to navigation or the player explicitly requests its sub-locations. A regional file may still contain a readable inline sub-tree when that region is modest in size.

## Catalog entry

An entry may contain:

- `name`: player-facing location name.
- `kind`: semantic location type, such as `market`, `base`, `mining`, `outpost`, `settlement`, `mission`, `quest`, `showroom`, `event`, `station`, or `planet`.
- `icon`: optional icon selected for the location. When absent, SARN uses the default icon configured for `kind`.
- `ownerId`: player or organization ID. This is the only owner field stored in the catalog.
- `coordinate`: a world-space or planet-relative `::pos{...}` string; world-space `{ x, y, z }` tables remain supported.
- `atlasBody`: optional `{ systemId, bodyId }` reference to the corresponding body in `atlas.lua`.
- `coreSize`: optional construct-core size when the location represents a construct.
- `size`: optional bounding-box dimensions.
- `areaRadius`: optional radius in metres describing the area governed by this location.
- `color`: optional AR RGB override.
- `label`: optional supporting information.
- `description`: optional longer text shown by expanded AR details.
- `excluded`: optional boolean. When `true`, the entry remains in the catalog but does not become an AR object or count in active-location HUD statistics. Its children remain independently eligible unless they are also excluded.
- `children`: optional inline sub-location list.
- `childrenModule`: optional Lua module path containing an additional sub-location list.
- `childrenModules`: optional list of additional child-module paths.

Catalog authors do not provide a general `id` field. While loading, SARN assigns every distinct Lua location table a unique internal runtime ID. It needs this only for maps, AR selection, hover state, diagnostics, and deduplication; it is not displayed or written back to catalog files.

When known, a construct ID may be stored separately as optional `constructId`. It describes the real construct associated with the location and can support future verification, but it is not the location's identity and duplicate construct IDs do not invalidate catalog entries.

Inline `children`, root-level `catalogModules`, and child catalog modules are implemented. Child modules currently load during catalog initialization; distance-driven deferred loading remains planned.

## Visibility principle

SARN normally shows a small useful set of AR objects, approximately 5–20, rather than every known location. A parent area is visible at a distance; its children remain hidden until the player is near enough or explicitly requests them. For example, a player on Haven Moon may see Alioth in the sky and the nearest market or their base, but not every sub-Alioth location or sub-point within their base.

Distance to the player, hierarchy depth, parent/child area size or boundaries, screen visibility, and rendering budget will jointly determine whether a node or its children are shown.

SARN selects the deepest catalog node whose boundary contains the player as the current node. Its normal hierarchy view contains:

- every depth-1 location;
- the current node's direct parent or parents;
- the current node's direct children.

The current node itself is omitted from AR because the player is already inside it, but its name appears in the HUD. Siblings of the current node and children of unrelated locations remain hidden. Entering a child boundary makes that child current and replaces the visible branch with its parent and children.

`areaRadius` is the first planned area-boundary field. Child AR objects inside a parent's area remain hidden until the player is close enough to that parent area. The exact distance rule will be tuned with real places.

For atlas planets and moons, current-node detection treats the body's atmosphere radius—or at least five kilometres above its physical radius—as the active boundary. Non-atlas areas use `areaRadius` directly.

## Owner display

At runtime SARN resolves the saved `ownerId` through the DU APIs:

- organization found: `owner-org: OrgName`;
- player found: `owner-p: Name`;
- neither found or no ID: `owner: unknown`.

No owner name, player field, or organization field is stored in the catalog.
