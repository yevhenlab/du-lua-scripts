-- SARN Construct Catalog Configuration
-- Install this file into: <DU Root>/Game/data/lua/sarn/constructs.lua
-- Constructs listed here are rendered as known SARN locations.
--
-- Supported fields for each construct:
--   id:          (number or string) Optional stable location ID.
--   name:        (string) Construct name (or override label).
--   ownerId:     (number or string) Optional player or organization ID; SARN resolves its type and name.
--   coordinate:  (table or string) World coordinates: { x = 0, y = 0, z = 0 } or "::pos{0,0,x,y,z}".
--   color:       (string) Custom RGB color for AR lines and label: "R,G,B" (e.g. "96,220,255").
--   label:       (string) Third AR line with supporting information.
--   coreSize:    (string) Optional core size: "XS", "S", "M", "L", "XL".
--   size:        (table) Optional bounding box: { x = 32, y = 32, z = 32 }.

return {
    {
        id = 100001,
        name = "Primary Outpost",
        ownerId = 12345,
        coordinate = { x = 0, y = 0, z = 0 },
        color = "96,220,255",
        label = "Home Base",
        coreSize = "L"
    },
    {
        id = 100002,
        name = "Mining Platform",
        ownerId = 67890,
        coordinate = "::pos{0,0,10000,20000,30000}",
        color = "255,200,60",
        label = "Ore extraction",
        coreSize = "M"
    }
}
