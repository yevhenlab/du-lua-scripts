# 1. Overview

## Name

Settlers AR Navigator (SARN).

## Purpose

SARN is an in-game augmented-reality navigator for known, well-established places in Dual Universe. A new player can copy its Programming Board script and receive guidance to places worth visiting.

SARN is a curated catalog, not a live world scanner. A location represents a meaningful place or area, rather than necessarily representing one construct.

## Catalog sources

The SARN public repository can contain:

1. Common Aphelia locations.
2. Settlers-server locations created for players to visit.
3. Player-created public locations intended for other players to visit.
4. Player-private locations in the player's own copy of SARN.

Examples include player and organization bases, mining locations, outposts, settlements, markets, mission starters, quest spots, showrooms, and event locations.

There is no SARN server or automatic catalog-update/merge service. Each player owns and may freely modify their copied script and Lua files. A player who wants a location included in the shared catalog contributes it to the public repository; SARN's creators review and accept that change.

## Current development focus

The current mini-project establishes the reusable foundation for known-location navigation:

- a Lua catalog of places and areas;
- a bounded hierarchy of areas and sub-areas;
- AR and HUD presentation separated from catalog and helper code;
- ownership display resolved from a saved `ownerId`;
- support for both world-space and planet-relative coordinates;
- reliable diagnostics for invalid catalog data, including unknown atlas bodies.

## Scope boundary

SARN does not use Radar, scan constructs, or persist runtime catalog data in a Databank. Radar-assisted construct discovery belongs to the separate `lua radar AR static constructs` mini-project.

## Player-facing marker

For a known place, SARN draws an AR object. Its smallest form includes a name and icon, and may include owner information or other details when useful. It can be highlighted and eventually interacted with.

The current simple label form is:

1. `Location name [size, when relevant] | distance`
2. `owner-p: Name`, `owner-org: Name`, or `owner: unknown`
3. Optional supporting label or extra information.

The exact visual and interaction rules are owned by `04-ar-and-hud-rendering.md`.
