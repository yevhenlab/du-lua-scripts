# ARN catalog and context rules

Sources: [2026-09-23 ARN development chat archive](../raw/chatsai/2026-09-23-arn-navigator-development.md); [2026-09-24 module parentId migration chat](../raw/chatsai/2026-09-24-arn-module-parentid-migration.md).

## Catalog

- locations.lua holds standard Dual Universe locations; registered modules add custom roots without editing it.
- Custom modules return a nodes table keyed by descriptive names. Each module root has parentId; descendants use inline children. Standard catalog nodes retain their inline hierarchy.
- locations-registry.lua lists each module and optional display label; it does not map source keys to parent IDs. ARN indexes standard and module node IDs before resolving root parents, so registry order does not determine hierarchy.
- Registry labels appear in ARN's Source filter. Module-level types and disabled rules continue to be collected.
- Each node has a semantic type, not kind. The type selects its default icon.
- `id`, literal `owner`, coordinate, label, area radius, and planetoid size data are optional catalog fields where relevant.
- `excluded = true` prevents a node and all descendants from loading. Registered modules may also disable existing branches by ID or full path; rules combine.
- Runtime source IDs distinguish standard catalog locations (`0`) from registered custom modules (`1+`).

## Bounds and entry

- Every node recursively derives `boundsCenter` and `boundsRadiusX/Y/Z` from descendants plus its own coordinate and `areaRadius`.
- `areaRadius` is catalog input, not a post-calculation rendering or detection fallback.
- Entering an area is independent from AR visibility. The current entry threshold is calculated bounds expanded by `1.75`.
- Coordinate-less groups with useful derived bounds are real renderable areas. They normally do not become the current area unless the optional setting permits it.

## Context and nearby places

- Real nearby range defaults to 5 km in atmosphere and 50 km in space.
- When current node is an area, candidate sibling areas come from the current node's parent children. Preselect candidates with squared centre distance within `visibleRange × 2 × 1.2`.
- Inspect only direct places of selected context areas. Keep only places within real visible range, sort globally by player distance, and limit to `maximumNearbyPlaces`.
- A nearby area appears only if it contributes an actual in-range direct place.

## Open questions

- Continue catalog grouping and hierarchy balancing as locations are added.
- Assign parents to unparented construct roots before expecting ARN to load them; refresh the ARN construct snapshot when editor output changes.
- Test current-area and nearby context behavior in-game before changing the selection model.
