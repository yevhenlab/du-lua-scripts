# 5. Technical Design

SARN runs on a Programming Board and uses DU Lua APIs for AR projection, screen size, player and organization name lookup, and screen output.

## Modules

The project separates configuration, helpers, catalog loading, AR drawing, HUD drawing, and rendering into dedicated Lua files. The board startup loads the catalog and starts the adaptive renderer supplied by `liby4performance`.

SARN requires no linked Core, Radar, or Databank. It does require the client-side Lua library files that its `require(...)` calls reference.

## Normalized runtime location

Each valid catalog entry becomes a runtime location node containing its generated internal ID, display information, source coordinate, normalized world position, and optional children. AR projection receives only normalized world positions. A visibility-selection phase will choose the small active subset before AR HTML is generated.

The internal ID is assigned once to each distinct Lua table encountered during loading. This lets one shared location table be referenced from multiple navigation collections without duplicate AR markers.

## Catalog module loading

The root catalog is loaded at startup. The location tree then uses hybrid loading: smaller branches are inline tables, while large branches are represented by a module path and loaded with `require(...)` only when needed. This prevents a large universe-wide catalog from being parsed and allocated at board startup.

## Current implementation status

The present code loads explicit high-level planet and moon data, recursively reads inline `children`, and resolves configured default icons, but does not yet render icons. Deferred child modules, interaction, per-player additions, and hierarchy-aware visibility selection are design requirements that must be implemented in later steps.

## Diagnostics

Warnings and errors are held in Lua memory for the current board session. This currently covers malformed coordinates, unavailable catalog data, and atlas lookup failures. Persistent diagnostics are explicitly deferred.
