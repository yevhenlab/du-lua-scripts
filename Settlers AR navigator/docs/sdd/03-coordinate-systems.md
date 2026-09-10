# 3. Coordinate Systems

## Accepted input

SARN accepts two coordinate forms:

- World space: `::pos{0,0,x,y,z}`. `x`, `y`, and `z` are used directly.
- Planet-relative: `::pos{systemId,bodyId,latitude,longitude,altitude}`. Latitude and longitude are degrees; altitude is metres above the body radius.

Players may save either form. SARN retains the original catalog value and produces a normalized world-space position in Lua memory for distance calculation and AR projection.

## Conversion

SARN loads the client-provided `atlas` Lua module from `<Dual Universe>/Game/data/lua/atlas.lua`. For planet-relative input it looks up the specified system and body, then calculates:

```text
worldPosition = bodyCenter + (bodyRadius + altitude) * direction(latitude, longitude)
```

World-to-planet conversion first uses SARN's own nearest planet or moon node: its `atlasBody` system/body IDs, world-space centre coordinate, and `areaRadius`. This makes the detailed-view coordinate action independent of the runtime atlas for catalog locations and their descendants. Atlas lookup remains a fallback for unrelated world-space locations. AR rendering always uses normalized world space.

A planet or moon catalog node is anchored at the celestial body's exact centre, where latitude and longitude have no unique value. SARN represents this reversible special case as latitude `0`, longitude `0`, and altitude equal to the negative body radius.

## Invalid atlas bodies

If a planet-relative coordinate refers to a system/body absent from `atlas`:

- skip the catalog entry for AR rendering;
- print one warning in chat for that unique coordinate/body;
- append a structured record to SARN's in-memory warnings/errors list.

Databank persistence of warnings is deferred.
