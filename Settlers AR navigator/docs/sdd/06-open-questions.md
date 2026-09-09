# 6. Open Questions

- What exact catalog schema represents a location node, area boundary, icon, public-repository source, and player-private location?
- What should the separate field for an AR object's visual/navigation point be called, when it is distinct from the saved location coordinate?
- When a location is reachable through multiple collections, which parent path controls its parent/child visibility at a given moment?
- Which practical distance and boundary rules switch AR visibility from a parent area to its children?
- How does the player temporarily request more AR objects, and how does SARN return to its normal 5–20-object budget?
- Which additional icons and `kind` mappings are needed beyond the initial planet and moon set?
- Should SARN provide a player command or UI for adding a custom saved location to the catalog?
- Should world-to-planet conversion be exposed as a public SARN helper now, or only used when a future feature requires it?
- When persistent diagnostics are introduced, should warnings be written to a Databank, a downloadable catalog file, or both?
