local initializeLiby4slots = require("liby.liby4slots")
local l4s = initializeLiby4slots(_G, unit, system)

local linkedElements = l4s.getLinkedElements()

if #linkedElements > 0 then
    local itemId = linkedElements[1].getItemId()
    local matchingElements = l4s.getElementsByItemId(itemId)

    system.print("[l4s test] itemId=" .. tostring(itemId)
        .. " matches=" .. tostring(#matchingElements))
end

l4s.printLinkedElements()
