-- Receives liby4slots from the Unit handler and resolves linked Core, Radar, and Databank elements.
-- Library dependencies: SARN helpers from library.onStart.helpers.lua.
SARNLinkedElements = SARNLinkedElements or {}

function SARNLinkedElements.setLiby4slots(liby4slots)
    SARNLinkedElements.liby4slots = liby4slots
    local elements = liby4slots ~= nil and liby4slots.getLinkedElements() or {}
    SARNLinkedElements.core = SARNLinkedElements.findByClass(elements, "core")
    SARNLinkedElements.radar = SARNLinkedElements.findByClass(elements, "radar")
    SARNLinkedElements.databank = SARNLinkedElements.findByClass(elements, "databank")
    return SARNLinkedElements.core
end

function SARNLinkedElements.getLinkedElementsSummary()
    local s1 = "Linked elements"
    local liby4slots = SARNLinkedElements.liby4slots
    if liby4slots == nil then return "liby4slots is unavailable." end

    local entries = {}
    for _, element in ipairs(liby4slots.getLinkedElements()) do
        local name = tostring(SARN.call(element, "getName") or "unnamed")
        local className = tostring(SARN.call(element, "getClass") or "unknown")
        local localId = tostring(SARN.call(element, "getLocalId") or "?")
        entries[#entries + 1] = name .. " [" .. className .. ", id=" .. localId .. "]"
    end

    s1 = tostring(#entries) .. " " .. s1 
    if #entries == 0 then return (s1 .. ".") end
    return  s1 .. ": " .. table.concat(entries, "; ")
end

function SARNLinkedElements.findByClass(elements, fragment)
    for _, element in ipairs(elements) do
        local className = string.lower(tostring(SARN.call(element, "getClass") or ""))
        if string.find(className, fragment, 1, true) ~= nil then return element end
    end
    return nil
end

function SARNLinkedElements.getCurrentConstructTarget()
    local constructName = SARN.call(construct, "getName")
    local origin = SARN.call(construct, "getWorldPosition")
    local localCenter = SARN.call(construct, "getBoundingBoxCenter")
    local right = SARN.call(construct, "getWorldOrientationRight")
    local forward = SARN.call(construct, "getWorldOrientationForward")
    local up = SARN.call(construct, "getWorldOrientationUp")
    local boundingBoxSize = SARN.call(construct, "getBoundingBoxSize")
    local ox, oy, oz = SARN.components(origin)
    local cx, cy, cz = SARN.components(localCenter)
    local rx, ry, rz = SARN.components(right)
    local fx, fy, fz = SARN.components(forward)
    local ux, uy, uz = SARN.components(up)
    if ox == nil then return nil end

    local worldPosition = { x = ox, y = oy, z = oz }
    if cx ~= nil and rx ~= nil and fx ~= nil and ux ~= nil then
        worldPosition = {
            x = ox + rx * cx + fx * cy + ux * cz,
            y = oy + ry * cx + fy * cy + uy * cz,
            z = oz + rz * cx + fz * cy + uz * cz
        }
    end
    return {
        label = tostring(constructName or "Construct"),
        worldPosition = worldPosition,
        size = boundingBoxSize,
        worldAxes = { right = right, forward = forward, up = up }
    }
end
