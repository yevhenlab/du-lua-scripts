-- Example custom ARN location catalog.
--
-- This module is registered by locations-registry.lua. Its Alioth example branch is
-- loaded beneath Institutes. It demonstrates direct exclusion and module-level disabling.
-- A named list is attached with a registration like this:
--
-- {
--     module = "arn/locations-example",
--     attachments = {
--         { parentId = 100210, sourceKey = "institutesExamples" },
--         { parentId = 2, sourceKey = "planetoidExamples" }
--     }
-- }
--
-- parentId is the `id` of an existing standard or registered custom node.
-- sourceKey selects one named list returned below. Registry order does not matter.
--
-- Supported node fields:
--
-- name              Required player-facing name.
-- id                Optional DU body, construct, or place ID. Groups may omit it.
-- type              Required node classification used for behavior and its default
--                   icon, such as system, planet, satellite, asteroid, location-group,
--                   construct, zone, market, base, parking, outpost, or station.
-- icon              Optional explicit icon key from arn/icons.lua.
-- owner             Optional literal owner name. nil or "" hides the owner line.
-- coordinate        Optional ::pos string or { x, y, z } world-position table.
-- atlasBody         Optional { systemId = N, bodyId = N } identity for a planetoid.
-- coreSize          Optional construct-core size: XS, S, M, L, or XL.
-- size              Optional bounds dimensions: { x = N, y = N, z = N } metres.
-- worldUp           Optional world-space up vector: { x = N, y = N, z = N }.
-- radius            Planetoid surface radius in metres.
-- atmosphereRadius  Planetoid atmosphere radius in metres; use 0 for none.
-- areaRadius        Optional spherical area radius in metres around coordinate.
-- color             Optional marker RGB string, for example "70,220,255".
-- label             Optional short second-line text.
-- description       Optional longer details text.
-- excluded          true skips this node and its complete descendant branch while
--                   building the runtime catalog. The skipped branch is not indexed,
--                   counted, rendered, or listed in detailed views.
-- children          Optional inline list of child nodes.
--
-- A registered module may also return `disabled = { ids = {...}, paths = {...} }`.
-- Rules from every successfully loaded module are combined. Prefer IDs; use a full
-- `Parent > Child > Node` path for an ID-less node. Disabling a node skips its entire
-- descendant branch, so descendants do not need their own entries.
--
-- Coordinate aliases accepted by the loader are coordinates, worldPosition, and pos.
-- boundingBoxSize is accepted as an alias for size. Prefer the canonical names above.

return {
    -- A custom module may introduce location types. Existing definitions are not replaced.
    types = {
        ["example-place"] = {
            icon = "icon-market"
        }
    },

    -- Only the parent ID is listed. Its child below is disabled transitively.
    -- Additional registered modules may contribute more IDs or full paths.
    disabled = {
        ids = {
            900000004
        },
        paths = {
            -- "Known Space > Helios System > Alioth > An ID-less group"
        }
    },

    -- This example list is attached beneath Institutes (standard ID 100210).
    institutesExamples = {
        {
            name = "Example visible location",
            id = 900000001,
            type = "example-place",
            icon = "icon-market",
            owner = "Example owner",
            coordinate = "::pos{0,2,29.0380,95.1534,374.0935}",
            atlasBody = {
                systemId = 0,
                bodyId = 2
            },
            coreSize = "L",
            size = {
                x = 100,
                y = 80,
                z = 40
            },
            worldUp = {
                x = 0,
                y = 0,
                z = 1
            },
            areaRadius = 100,
            color = "70,220,255",
            label = "Example label",
            description = "Example longer description.",
            excluded = true,
            children = {
                {
                    name = "Example hidden child",
                    id = 900000002,
                    type = "parking",
                    coordinate = "::pos{0,2,29.0380,95.1534,374.0935}",
                    owner = nil,
                    excluded = false
                }
            }
        },
        {
            name = "Example disabled location",
            id = 900000004,
            type = "example-place",
            coordinate = "::pos{0,2,29.0400,95.1550,374}",
            children = {
                {
                    name = "Example transitively disabled child",
                    id = 900000005,
                    type = "parking",
                    coordinate = "::pos{0,2,29.0401,95.1551,374}"
                }
            }
        }
    },

    -- This list is attached beneath Alioth. Change excluded to false to load the
    -- example as one of Alioth's satellites. Celestial-only fields are separated
    -- because they should not be
    -- added to an ordinary construct or zone node.
    planetoidExamples = {
        {
            name = "Example hidden satellite",
            id = 900000003,
            type = "satellite",
            coordinate = "::pos{0,0,200000,-8,-126303}",
            atlasBody = {
                systemId = 0,
                bodyId = 900000003
            },
            radius = 10000,
            atmosphereRadius = 0,
            areaRadius = 10000,
            excluded = true
        }
    }
}