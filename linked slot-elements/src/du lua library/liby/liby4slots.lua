local function initializeLiby4slots(environment, controlUnit, systemApi)
local liby4slots = {}

local reservedGlobals = {
    system = true,
    unit = true,
    library = true,
    construct = true,
    player = true
}

local function isLinkedElement(globalName, value)
    return not reservedGlobals[globalName]
        and type(value) == "table"
        and type(value.getClass) == "function"
        and type(value.getItemId) == "function"
        and type(value.getLocalId) == "function"
end

local function getGlobalElements()
    local elements = {}
    local seenIds = {}
    local seenObjects = {}
    local unitId = tostring(controlUnit.getId())

    for globalName, element in pairs(environment) do
        if isLinkedElement(globalName, element) then
            local localId = tostring(element.getLocalId())

            if element ~= controlUnit
                and localId ~= unitId
                and not seenIds[localId]
                and not seenObjects[element] then
                elements[#elements + 1] = {
                    globalName = globalName,
                    element = element,
                    localId = localId
                }
                seenIds[localId] = true
                seenObjects[element] = true
            end
        end
    end

    return elements
end

local function getPlugEntries(plugMap)
    local entries = {}

    for key, plug in pairs(plugMap) do
        if plug.elementId ~= nil then
            entries[#entries + 1] = {
                localId = tostring(plug.elementId),
                numericPosition = tonumber(key),
                position = tostring(key)
            }
        end
    end

    table.sort(entries, function(left, right)
        if left.numericPosition ~= nil and right.numericPosition ~= nil then
            return left.numericPosition < right.numericPosition
        end

        if left.numericPosition ~= nil then return true end
        if right.numericPosition ~= nil then return false end
        return left.position < right.position
    end)

    return entries
end

local function countMatches(plugs, elementsById)
    local count = 0

    for _, plug in ipairs(plugs) do
        if elementsById[plug.localId] ~= nil then
            count = count + 1
        end
    end

    return count
end

local function sortUnmatched(elements)
    table.sort(elements, function(left, right)
        local leftNumber = tonumber(string.match(left.globalName, "^slot(%d+)$"))
        local rightNumber = tonumber(string.match(right.globalName, "^slot(%d+)$"))

        if leftNumber ~= nil and rightNumber ~= nil then
            return leftNumber < rightNumber
        end

        if leftNumber ~= nil then return true end
        if rightNumber ~= nil then return false end
        return left.globalName < right.globalName
    end)
end

function liby4slots.getLinkedElements()
    local globalElements = getGlobalElements()
    local elementsById = {}

    for _, entry in ipairs(globalElements) do
        elementsById[entry.localId] = entry
    end

    local outPlugs = getPlugEntries(controlUnit.getOutPlugs())
    local inPlugs = getPlugEntries(controlUnit.getInPlugs())
    local orderedPlugs = outPlugs

    if countMatches(inPlugs, elementsById)
        > countMatches(outPlugs, elementsById) then
        orderedPlugs = inPlugs
    end

    local elements = {}
    local added = {}

    for _, plug in ipairs(orderedPlugs) do
        local entry = elementsById[plug.localId]

        if entry ~= nil and not added[entry.element] then
            elements[#elements + 1] = entry.element
            added[entry.element] = true
        end
    end

    local unmatched = {}

    for _, entry in ipairs(globalElements) do
        if not added[entry.element] then
            unmatched[#unmatched + 1] = entry
        end
    end

    sortUnmatched(unmatched)

    for _, entry in ipairs(unmatched) do
        elements[#elements + 1] = entry.element
    end

    return elements
end

function liby4slots.getElementsByItemId(itemId)
    local matches = {}

    for _, element in ipairs(liby4slots.getLinkedElements()) do
        if element.getItemId() == itemId then
            matches[#matches + 1] = element
        end
    end

    return matches
end

function liby4slots.printLinkedElements()
    local elements = liby4slots.getLinkedElements()

    if #elements == 0 then
        systemApi.print("[l4s] No linked elements.")
        return
    end

    systemApi.print("[l4s] Linked elements: " .. tostring(#elements))

    for index, element in ipairs(elements) do
        systemApi.print(string.format(
            "[l4s] slot#%d itemId=%s class=%s name=\"%s\"",
            index,
            tostring(element.getItemId()),
            tostring(element.getClass()),
            tostring(element.getName())
        ))
    end
end

return liby4slots
end

return initializeLiby4slots
