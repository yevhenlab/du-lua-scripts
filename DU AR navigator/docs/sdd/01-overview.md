# 1. Overview

## Name

AR Navigator (ARN).

## Purpose

ARN is an in-game augmented-reality navigator for known, well-established places in Dual Universe. A new player can copy its Programming Board script and receive guidance to places worth visiting.

ARN is a curated catalog, not a live world scanner. A location represents a meaningful place or area, rather than necessarily representing one construct.

## Catalog sources

The ARN public repository can contain:

1. Common Aphelia locations.
2. Settlers-server locations created for players to visit.
3. Player-created public locations intended for other players to visit.
4. Player-private locations in the player's own copy of ARN.

Examples include player and organization bases, mining locations, outposts, settlements, markets, mission starters, quest spots, showrooms, and event locations.

There is no ARN server or automatic catalog-update/merge service. Each player owns and may freely modify their copied script and Lua files. A player who wants a location included in the shared catalog contributes it to the public repository; ARN's creators review and accept that change.

## Current development focus

The current mini-project establishes the reusable foundation for known-location navigation:

- a Lua catalog of places and areas;
- a bounded hierarchy of areas and sub-areas;
- AR and HUD presentation separated from catalog and helper code;
- ownership display read directly from a saved owner name;
- support for both world-space and planet-relative coordinates;
- reliable diagnostics for invalid catalog data, including unknown atlas bodies;
- registered custom catalog modules that attach destinations without editing the standard catalog;
- persisted visibility, HUD, performance, pin, and pin-range settings;
- context-aware nearby selection that limits AR output to useful direct places.

## Scope boundary

ARN does not use Radar, scan constructs, or persist the location catalog in a Databank. An optional Databank stores selected ARN settings and pin state. Radar-assisted construct discovery belongs to the separate `lua radar AR static constructs` mini-project.

ARN is a location navigator rather than a piloting assistant. It does not require a linked Core Unit and does not present construct braking, planet, gravity, atmosphere, or similar flight-system information.

## Player-facing marker


The current location model separates three ideas: a node can be the player's current area, be context for nearby selection, or be an AR-visible marker. Entering an area's calculated bounds does not by itself make its marker visible.
For a known place, ARN draws an AR object. Its smallest form includes a name and icon, and may include owner information or other details when useful. It can be highlighted and eventually interacted with.

The current simple label form is:

1. `Location name [size, when relevant] | distance`
2. `Owner: Name` when the catalog provides an owner
3. Optional supporting label or extra information.

The exact visual and interaction rules are owned by `04-ar-and-hud-rendering.md`.
