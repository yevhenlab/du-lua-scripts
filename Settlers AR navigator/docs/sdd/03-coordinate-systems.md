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

World-to-planet conversion uses the reverse calculation from the offset relative to the atlas body centre. It is needed when SARN explicitly needs to present or save planet-relative coordinates; AR rendering always uses normalized world space.

## Invalid atlas bodies

If a planet-relative coordinate refers to a system/body absent from `atlas`:

- skip the catalog entry for AR rendering;
- print one warning in chat for that unique coordinate/body;
- append a structured record to SARN's in-memory warnings/errors list.

Databank persistence of warnings is deferred.
