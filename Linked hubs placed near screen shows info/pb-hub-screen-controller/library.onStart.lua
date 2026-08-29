hscRows = 3 --export
hscColumns = 5 --export
hscScreenTitle = "Hub Production Overview" --export
hscScreenVersion = "0.2.6" --export
hscReserveTopTextArea = true --export
hscReserveBottomTextArea = false --export
hscReservedTextAreaFraction = 0.12 --export
hscSearchRadiusMeters = 8 --export
hscMaxDepthMeters = 5 --export
hscGridMarginLeftMeters = 0.3 --export
hscGridMarginRightMeters = 0.3 --export
hscGridMarginTopMeters = 1 --export
hscGridMarginBottomMeters = 0.5 --export
hscReverseColumns = true --export
hscReverseRows = false --export
hscProjectionFontSize = 12 --export
hscScreenPollSeconds = 0.2 --export
hscMaxClickMarkers = 50 --export
hscClickPollFrames = 2 --export
hscClickDebounceSeconds = 0.25 --export
hscScreenInputMaxCharacters = 1024 --export
hscHubContentRefreshSeconds = 30 --export
hscContainerRefreshSeconds = 5 --export
hscIndustryIndexBatchSize = 50 --export
hscDebugScreen = false --export
hscDebugElements = false --export
hscDebugIndustries = false --export
hscDebugContainers = false --export
hscDebugDatabank = false --export
debugCellAssociation = true --export
debugIndustryHubNameSearch = "1550" --export

hsc = hsc or {}

function hsc.print(message)
    system.print("[HSC] " .. tostring(message))
end

function hsc.onLinkedHubContentUpdate(element)
    if hsc.runtime == nil or element == nil then return end

    local localId = hsc.getLocalId(element)

    if localId == nil then return end

    if hsc.getMethod(element, "getContent") ~= nil
        and hsc.getMethod(element, "updateContent") ~= nil then
        if hscDebugContainers then
            hsc.print("Container content event received for hub "
                .. tostring(localId))
        end
        hsc.refreshDiscovery()
    end
end

function hsc.getSlots()
    local elements = {
        slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9, slot10,
        slot11, slot12, slot13, slot14, slot15, slot16, slot17, slot18, slot19, slot20,
        slot21, slot22, slot23, slot24, slot25, slot26, slot27, slot28, slot29, slot30,
        slot31, slot32, slot33, slot34, slot35, slot36, slot37, slot38, slot39, slot40,
        slot41, slot42, slot43, slot44, slot45, slot46, slot47, slot48, slot49, slot50,
        slot51, slot52, slot53, slot54, slot55, slot56, slot57, slot58, slot59, slot60,
        slot61, slot62, slot63, slot64, slot65, slot66, slot67, slot68, slot69, slot70,
        slot71, slot72, slot73, slot74, slot75, slot76, slot77, slot78, slot79, slot80,
        slot81, slot82, slot83, slot84, slot85, slot86, slot87, slot88, slot89, slot90,
        slot91, slot92, slot93, slot94, slot95, slot96, slot97, slot98, slot99, slot100
    }
    local slots = {}

    for slotIndex = 1, 100 do
        slots[#slots + 1] = {
            name = "slot" .. tostring(slotIndex),
            slotIndex = slotIndex,
            element = elements[slotIndex]
        }
    end

    slots[#slots + 1] = { name = "core", element = core }
    slots[#slots + 1] = { name = "databank", element = databank }
    slots[#slots + 1] = { name = "db", element = db }
    slots[#slots + 1] = { name = "screen", element = screen }
    return slots
end

function hsc.getOrderedLinkedSlots(slots)
    local linkedSlots = {}
    local seen = {}

    for _, candidate in ipairs(slots or hsc.getSlots()) do
        if candidate.slotIndex ~= nil and candidate.element ~= nil then
            local localId = hsc.getLocalId(candidate.element)

            if localId ~= nil and not seen[localId] then
                seen[localId] = true
                linkedSlots[#linkedSlots + 1] = candidate
            end
        end
    end

    return linkedSlots
end

function hsc.getLinkedElementsByLocalId(slots)
    local linkedElements = {}

    for _, candidate in ipairs(slots or hsc.getSlots()) do
        local element = candidate.element
        local localId = hsc.getLocalId(element)

        if element ~= nil and localId ~= nil then
            linkedElements[localId] = element
        end
    end

    return linkedElements
end

function hsc.getMethod(object, methodName)
    if object == nil then
        return nil
    end

    local ok, method = pcall(function()
        return object[methodName]
    end)

    if ok and type(method) == "function" then
        return method
    end

    return nil
end

function hsc.call(object, methodName, ...)
    local method = hsc.getMethod(object, methodName)

    if method == nil then
        return nil
    end

    local ok, value = pcall(method, ...)

    if ok then
        return value
    end

    return nil
end

function hsc.getClassName(element)
    return tostring(
        hsc.call(element, "getClass")
        or ""
    )
end

function hsc.discoverLinkedElements(slots)
    local result = {
        core = nil,
        databank = nil,
        screen = nil
    }

    slots = slots or hsc.getSlots()

    for _, candidate in ipairs(slots) do
        local element = candidate.element

        if element ~= nil then
            local className = string.lower(hsc.getClassName(element))
            local isCore = string.find(className, "core", 1, true) ~= nil
                or hsc.getMethod(element, "getElementIdList") ~= nil
            local isScreen = string.find(className, "screen", 1, true) ~= nil
                or hsc.getMethod(element, "setRenderScript") ~= nil
            local isDatabank = string.find(className, "databank", 1, true) ~= nil
                or string.find(className, "data bank", 1, true) ~= nil
                or hsc.getMethod(element, "setStringValue") ~= nil

            if isCore and result.core == nil then
                result.core = element
                result.coreSlot = candidate.name
            elseif isScreen and result.screen == nil then
                result.screen = element
                result.screenSlot = candidate.name
            elseif isDatabank and result.databank == nil then
                result.databank = element
                result.databankSlot = candidate.name
            end
        end
    end

    return result
end

function hsc.getLocalId(element)
    return hsc.call(element, "getLocalId") or hsc.call(element, "getId")
end

function hsc.vectorSubtract(left, right)
    return {
        left[1] - right[1],
        left[2] - right[2],
        left[3] - right[3]
    }
end

function hsc.dot(left, right)
    return left[1] * right[1]
        + left[2] * right[2]
        + left[3] * right[3]
end

function hsc.normalize(vector)
    local length = math.sqrt(hsc.dot(vector, vector))

    if length <= 0.000001 then
        return vector
    end

    return {
        vector[1] / length,
        vector[2] / length,
        vector[3] / length
    }
end

function hsc.addTextPart(parts, value)
    if value ~= nil then
        parts[#parts + 1] = string.lower(tostring(value))
    end
end

function hsc.getElementDescription(core, localId)
    local parts = {}

    hsc.addTextPart(parts, hsc.call(core, "getElementDisplayNameById", localId))
    hsc.addTextPart(parts, hsc.call(core, "getElementClassById", localId))

    local classId = hsc.call(core, "getElementClassIdById", localId)

    if classId ~= nil then
        local item = hsc.call(system, "getItem", classId)

        if item ~= nil then
            hsc.addTextPart(parts, item.name)
            hsc.addTextPart(parts, item.displayName)
            hsc.addTextPart(parts, item.type)
        end
    end

    return table.concat(parts, " ")
end

function hsc.getCoreElementClassName(core, localId)
    hsc.coreElementClassCache = hsc.coreElementClassCache or {}

    if hsc.coreElementClassCache[localId] == nil then
        hsc.coreElementClassCache[localId] = string.lower(tostring(
            hsc.call(core, "getElementClassById", localId) or ""
        ))
    end

    return hsc.coreElementClassCache[localId]
end

function hsc.isIndustryClassName(className)
    className = string.lower(tostring(className or ""))

    return className == "industryunit"
        or string.find(className, "industry", 1, true) ~= nil
        or string.match(className, "^industry%d*$") ~= nil
        or string.match(className, "^industryunit%d+$") ~= nil
end

function hsc.isContainerHub(core, localId)
    local className = hsc.getCoreElementClassName(core, localId)
    local compactClass = string.gsub(className, "[%s_%-]", "")

    if string.find(compactClass, "containerhub", 1, true) ~= nil
        or string.find(compactClass, "containerrelay", 1, true) ~= nil then
        return true
    end

    -- Most construct elements can be rejected with one cheap class lookup.
    -- Only generic Container classes need the slower item-description probe.
    if compactClass ~= ""
        and string.find(compactClass, "container", 1, true) == nil then
        return false
    end

    local description = hsc.getElementDescription(core, localId)
    local compact = string.gsub(description, "[%s_%-]", "")

    return string.find(compact, "containerhub", 1, true) ~= nil
        or string.find(compact, "containerrelay", 1, true) ~= nil
end

function hsc.isDirectContainerHub(element)
    local description = string.lower(table.concat({
        tostring(hsc.call(element, "getClass") or ""),
        tostring(hsc.call(element, "getDisplayName") or ""),
        tostring(hsc.call(element, "getName") or "")
    }, " "))
    local compact = string.gsub(description, "[%s_%-]", "")

    return string.find(compact, "containerhub", 1, true) ~= nil
        or string.find(compact, "containerrelay", 1, true) ~= nil
end

function hsc.isDirectContainer(element)
    if element == nil or hsc.isDirectContainerHub(element) then
        return false
    end

    local description = string.lower(table.concat({
        tostring(hsc.call(element, "getClass") or ""),
        tostring(hsc.call(element, "getDisplayName") or ""),
        tostring(hsc.call(element, "getName") or "")
    }, " "))
    local compact = string.gsub(description, "[%s_%-]", "")

    return string.find(compact, "container", 1, true) ~= nil
        and hsc.getMethod(element, "getContent") ~= nil
end

function hsc.isDirectIndustry(element, core, localId)
    if element == nil then return false end

    local description = string.lower(table.concat({
        tostring(hsc.call(element, "getClass") or ""),
        tostring(hsc.call(element, "getDisplayName") or ""),
        tostring(hsc.call(element, "getName") or ""),
        tostring(hsc.call(core, "getElementClassById", localId) or "")
    }, " "))
    local compact = string.gsub(description, "[%s_%-]", "")

    return string.find(compact, "industry", 1, true) ~= nil
end

function hsc.isInfrastructureElement(element)
    if element == nil then return false end

    local className = string.lower(hsc.getClassName(element))

    return string.find(className, "core", 1, true) ~= nil
        or string.find(className, "screen", 1, true) ~= nil
        or string.find(className, "databank", 1, true) ~= nil
        or string.find(className, "data bank", 1, true) ~= nil
        or hsc.getMethod(element, "getElementIdList") ~= nil
        or hsc.getMethod(element, "setRenderScript") ~= nil
        or hsc.getMethod(element, "setStringValue") ~= nil
end

function hsc.getDirectElementKind(element, core, localId)
    if hsc.isInfrastructureElement(element) then return nil end
    if hsc.isDirectContainerHub(element) then return "hub" end
    if hsc.isDirectContainer(element) then return "container" end
    if hsc.isDirectIndustry(element, core, localId) then return "industry" end
    return nil
end

function hsc.getDirectElementName(element, localId)
    local name = hsc.call(element, "getName")
        or hsc.call(element, "getDisplayName")

    if name == nil or tostring(name) == "" then
        return "Element " .. tostring(localId)
    end

    return tostring(name)
end

function hsc.getElementName(core, localId)
    local name = hsc.call(core, "getElementNameById", localId)

    if name == nil or tostring(name) == "" then
        return "Hub " .. tostring(localId)
    end

    return tostring(name)
end

function hsc.sanitizeLabel(value)
    local label = tostring(value or "")
    label = string.gsub(label, "[|\r\n\t]", " ")
    label = string.gsub(label, "%s+", " ")
    return label
end

function hsc.getConnectedElementIds(core, methodName, localId)
    local plugs = hsc.call(core, methodName, localId)
    local elementIds = {}
    local seen = {}
    local visitedTables = {}
    local visitedCount = 0
    local maximumVisitedEntries = 64
    local idFieldNames = {
        elementId = true, elementID = true, element_id = true,
        localId = true, localID = true, local_id = true,
        id = true, item = true
    }

    if type(plugs) ~= "table" then
        return elementIds
    end

    local function addElementId(value)
        if type(value) ~= "number" and type(value) ~= "string" then
            return
        end

        local elementId = tonumber(value)

        if elementId ~= nil and not seen[elementId] then
            seen[elementId] = true
            elementIds[#elementIds + 1] = elementId
        end
    end

    local function visit(value, depth)
        depth = depth or 0

        if depth > 4 or visitedCount >= maximumVisitedEntries then
            return
        end

        if type(value) ~= "table" then
            addElementId(value)
            return
        end

        if visitedTables[value] then return end
        visitedTables[value] = true
        visitedCount = visitedCount + 1

        addElementId(value.elementId)
        addElementId(value.elementID)
        addElementId(value.element_id)
        addElementId(value.localId)
        addElementId(value.localID)
        addElementId(value.local_id)
        addElementId(value.id)

        for key, nestedValue in pairs(value) do
            -- Server plug maps may be flat, arrays, or nested maps. Collect
            -- every connected value and validate the resulting IDs by class
            -- afterwards instead of keeping only the first nested entry. A
            -- boolean map uses element IDs as keys; array indices are ignored.
            if type(nestedValue) == "boolean" then
                if nestedValue then addElementId(key) end
            elseif type(nestedValue) == "table" then
                visit(nestedValue, depth + 1)
            elseif idFieldNames[key]
                or (
                    type(key) == "string"
                    and (
                        string.find(key, "IN%-") ~= nil
                        or string.find(key, "OUT%-") ~= nil
                    )
                ) then
                addElementId(nestedValue)
            end

            visitedCount = visitedCount + 1
            if visitedCount >= maximumVisitedEntries then break end
        end
    end

    visit(plugs, 0)

    return elementIds
end

function hsc.isIndustryElement(core, localId)
    hsc.industryElementCache = hsc.industryElementCache or {}

    if hsc.industryElementCache[localId] ~= nil then
        return hsc.industryElementCache[localId]
    end

    local className = hsc.getCoreElementClassName(core, localId)

    if hsc.isIndustryClassName(className) then
        hsc.industryElementCache[localId] = true
        return true
    end

    -- Relationship tables also contain item IDs and plug metadata. Only a
    -- construct element whose Core class is an Industry may become a source.
    hsc.industryElementCache[localId] = false
    return false
end

function hsc.getIndustryName(core, localId)
    local name = hsc.call(core, "getElementNameById", localId)

    if name == nil or tostring(name) == "" then
        return "Industry " .. tostring(localId)
    end

    return tostring(name)
end

function hsc.formatQuantity(value)
    value = tonumber(value)

    if value == nil then
        return nil
    end

    if math.abs(value - math.floor(value)) < 0.001 then
        return tostring(math.floor(value))
    end

    local formatted = string.format("%.1f", value)
    return string.gsub(formatted, "%.0$", "")
end

function hsc.formatMeasurement(value, unit)
    value = tonumber(value)

    if value == nil then
        return nil
    end

    if unit == "kg" then
        if math.abs(value) >= 1000000 then
            return hsc.formatQuantity(value / 1000000) .. " kTon"
        end

        if math.abs(value) >= 1000 then
            return hsc.formatQuantity(value / 1000) .. " ton"
        end
    elseif unit == "L" then
        if math.abs(value) >= 1000000 then
            return hsc.formatQuantity(value / 1000000) .. " ML"
        end

        if math.abs(value) >= 1000 then
            return hsc.formatQuantity(value / 1000) .. " kL"
        end
    end

    local formatted = hsc.formatQuantity(value)
    return formatted ~= nil and formatted .. " " .. unit or nil
end

function hsc.getProductCategory(item)
    if type(item) ~= "table" then
        return "product"
    end

    local displayClassId = item.displayClassId or item.displayClassID
    local displayClass = displayClassId ~= nil
        and hsc.call(system, "getItem", displayClassId)
        or nil
    local category = type(displayClass) == "table"
        and (displayClass.displayName or displayClass.name)
        or nil
    local classId = item.classId or item.classID
    local classItem = classId ~= nil
        and hsc.call(system, "getItem", classId)
        or nil

    if category == nil or tostring(category) == "" then
        category = type(classItem) == "table"
            and (classItem.displayName or classItem.name)
            or nil
    end

    if category == nil or tostring(category) == "" then
        category = item.type or item.className or "product"
    end

    return tostring(category)
end

function hsc.getProductFromItem(itemId, quantity)
    local item = itemId ~= nil and hsc.call(system, "getItem", itemId) or nil
    local productName = item ~= nil and (item.displayName or item.name) or nil

    if productName == nil or tostring(productName) == "" then
        productName = "item " .. tostring(itemId or "?")
    end

    return {
        itemId = itemId,
        name = tostring(productName),
        category = hsc.getProductCategory(item),
        size = item ~= nil and tostring(item.size or item.unitSize or "") or "",
        tier = item ~= nil and tonumber(item.tier) or nil,
        unitVolume = item ~= nil and tonumber(item.unitVolume) or nil,
        unitMass = item ~= nil and tonumber(item.unitMass) or nil,
        iconPath = item ~= nil and item.iconPath or nil,
        containerQuantity = quantity
    }
end

function hsc.getIndustryProduct(core, localId, industryElement)
    local info = hsc.call(core, "getElementIndustryInfoById", localId)
        or hsc.call(industryElement, "getInfo")
        or hsc.call(industryElement, "getIndustryInfo")

    if type(info) ~= "table" then
        return nil
    end

    local product = nil

    if type(info.currentProducts) == "table" then
        product = info.currentProducts[1]

        if product == nil then
            for _, entry in pairs(info.currentProducts) do
                product = entry
                break
            end
        end
    end

    if type(product) ~= "table" then
        return {
            label = "no product",
            state = info.state,
            unitsProduced = info.unitsProduced
        }
    end

    local itemId = product.id or product.itemId or product[1]
    local item = itemId ~= nil and hsc.call(system, "getItem", itemId) or nil
    local result = hsc.getProductFromItem(itemId)

    -- This is the recipe output for one production cycle, not the hub inventory.
    local cycleQuantity = product.quantity or product.amount
    local unitVolume = item ~= nil and tonumber(item.unitVolume) or nil
    local unitMass = item ~= nil and tonumber(item.unitMass) or nil

    result.cycleQuantity = cycleQuantity
    result.cycleVolume = cycleQuantity ~= nil and result.unitVolume ~= nil
        and cycleQuantity * result.unitVolume or nil
    result.cycleMass = cycleQuantity ~= nil and result.unitMass ~= nil
        and cycleQuantity * result.unitMass or nil
    result.label = result.name
    result.state = info.state
    result.unitsProduced = info.unitsProduced
    result.remainingTime = info.remainingTime
    result.batchesRemaining = info.batchesRemaining

    return result
end

function hsc.getHubInventoryMetrics(hub, itemId, hubId)
    if hub == nil then
        return nil
    end

    hsc.contentRequestTimes = hsc.contentRequestTimes or {}
    hsc.contentRequestResults = hsc.contentRequestResults or {}
    local metrics = {
        totalVolume = hsc.call(hub, "getItemsVolume"),
        totalMass = hsc.call(hub, "getItemsMass"),
        maxVolume = hsc.call(hub, "getMaxVolume")
    }
    local content = hsc.call(hub, "getContent")

    metrics.items = {}

    local function addContentItem(itemId, quantity)
        itemId = tonumber(itemId)
        quantity = tonumber(quantity)

        if itemId ~= nil and quantity ~= nil then
            metrics.items[itemId] = (metrics.items[itemId] or 0) + quantity
            return true
        end

        return false
    end

    if type(content) == "table" then
        local entries = content

        -- A single occupied slot may be returned directly as
        -- { id = itemId, quantity = amount } instead of an array of slots.
        if content.id ~= nil or content.itemId ~= nil
            or content.itemID ~= nil or content.item_id ~= nil then
            entries = { content }
        end

        for key, entry in pairs(entries) do
            local itemId = tonumber(key)
            local quantity = entry
            local decodedNestedPair = false

            if type(entry) == "table" then
                itemId = tonumber(
                    entry.id or entry.itemId or entry.itemID or entry.item_id
                    or entry.typeId or entry[1]
                ) or itemId
                quantity = entry.quantity or entry.amount or entry.count
                    or entry.qty or entry[2]

                if itemId == nil then
                    for nestedId, nestedQuantity in pairs(entry) do
                        if addContentItem(nestedId, nestedQuantity) then
                            decodedNestedPair = true
                        end
                    end
                end
            end

            if not decodedNestedPair then
                addContentItem(itemId, quantity)
            end
        end
    end

    local itemCount = 0
    for _ in pairs(metrics.items) do
        itemCount = itemCount + 1
    end

    metrics.contentRefreshRequested = false
    metrics.cachedItemCount = itemCount
    metrics.lastContentRequestTime = hsc.contentRequestTimes[hubId]
    metrics.lastContentRequestResult = hsc.contentRequestResults[hubId]

    if hscDebugContainers and itemCount == 0
        and (tonumber(metrics.totalVolume) or 0) > 0 then
        local preview = {}

        for key, entry in pairs(content) do
            local entryText = type(entry) == "table" and "table" or tostring(entry)
            preview[#preview + 1] = tostring(key) .. "=" .. entryText

            if #preview >= 6 then break end
        end

        hsc.print("Container " .. tostring(hubId)
            .. " has volume but getContent returned no decodable items (type="
            .. type(content) .. ", entries=" .. table.concat(preview, ",")
            .. ", lastRequest=" .. tostring(metrics.lastContentRequestTime)
            .. ", result=" .. tostring(metrics.lastContentRequestResult) .. ")")
    end

    if type(content) == "table" and itemId ~= nil then
        metrics.productQuantity = content[itemId] or content[tostring(itemId)]

        if type(metrics.productQuantity) == "table" then
            metrics.productQuantity = metrics.productQuantity.quantity
                or metrics.productQuantity.amount or metrics.productQuantity[2]
        end

        if metrics.productQuantity == nil then
            for key, entry in pairs(content) do
                if tonumber(key) == tonumber(itemId) then
                    metrics.productQuantity = entry
                    break
                end

                if type(entry) == "table"
                    and (tonumber(entry.id) == tonumber(itemId)
                        or tonumber(entry.itemId) == tonumber(itemId)) then
                    metrics.productQuantity = entry.quantity or entry.amount
                        or entry[2]
                    break
                end
            end
        end
    end

    if metrics.totalVolume == nil and metrics.totalMass == nil
        and metrics.maxVolume == nil and metrics.productQuantity == nil
        and next(metrics.items) == nil then
        return nil
    end

    return metrics
end

-- Content is asynchronous. Request only one linked hub per container timer
-- cycle; its onContentUpdate event performs the following cache read.
function hsc.requestNextHubContent()
    if hsc.runtime == nil then return false end

    hsc.contentRequestTimes = hsc.contentRequestTimes or {}
    hsc.contentRequestResults = hsc.contentRequestResults or {}

    local clock = hsc.runtime.contentElapsedSeconds or 0

    if clock < (hsc.runtime.nextContentRequestAt or 0) then
        return false
    end

    local candidates = {}
    local linkedById = hsc.runtime.linkedElementsByLocalId or {}

    for _, projectedHub in ipairs(hsc.runtime.hubs or {}) do
        local hub = linkedById[projectedHub.id]

        if hub ~= nil
            and hsc.getMethod(hub, "getContent") ~= nil
            and hsc.getMethod(hub, "updateContent") ~= nil then
            candidates[#candidates + 1] = {
                id = projectedHub.id,
                element = hub
            }
        end
    end

    if #candidates == 0 then return false end

    local startIndex = (hsc.runtime.nextContentHubIndex or 0) + 1

    if hsc.runtime.pendingContentHubId ~= nil then
        for index, candidate in ipairs(candidates) do
            if candidate.id == hsc.runtime.pendingContentHubId then
                startIndex = index
                break
            end
        end
    end

    for offset = 0, #candidates - 1 do
        local index = ((startIndex + offset - 1) % #candidates) + 1
        local candidate = candidates[index]
        local lastRequest = hsc.contentRequestTimes[candidate.id]

        if lastRequest == nil
            or clock - lastRequest >= hscHubContentRefreshSeconds then
            local requestResult = hsc.call(candidate.element, "updateContent")
            hsc.contentRequestResults[candidate.id] = requestResult
            local cooldown = tonumber(requestResult)

            -- A positive return is the API cooldown remaining. It is not a
            -- successful request and therefore cannot be treated as fresh data.
            if cooldown ~= nil and cooldown > 0 then
                hsc.runtime.pendingContentHubId = candidate.id
                hsc.runtime.nextContentHubIndex = index
                hsc.runtime.nextContentRequestAt = clock + cooldown + 0.1

                if hscDebugContainers then
                    hsc.print("Content request for hub " .. tostring(candidate.id)
                        .. " is rate-limited; retrying in "
                        .. string.format("%.1f", cooldown) .. " second(s).")
                end

                return false
            end

            hsc.contentRequestTimes[candidate.id] = clock
            hsc.runtime.pendingContentHubId = nil
            hsc.runtime.nextContentHubIndex = index
            hsc.runtime.nextContentRequestAt = clock + hscContainerRefreshSeconds

            if hscDebugContainers then
                hsc.print("Requested content from hub " .. tostring(candidate.id)
                    .. ", result=" .. tostring(requestResult))
            end

            return true
        end
    end

    return false
end

function hsc.getProductDisplayLabel(product, inventory)
    if product == nil then
        return "no product"
    end

    local parts = { product.name }
    local unitDetails = {}

    if product.unitVolume ~= nil then
        unitDetails[#unitDetails + 1] = hsc.formatMeasurement(product.unitVolume, "L")
    end

    if product.unitMass ~= nil then
        unitDetails[#unitDetails + 1] = hsc.formatMeasurement(product.unitMass, "kg")
    end

    if #unitDetails > 0 then
        parts[#parts + 1] = "1pc:" .. table.concat(unitDetails, "/")
    end

    local cycleQuantity = hsc.formatQuantity(product.cycleQuantity)
    local cycleDetails = {}

    if cycleQuantity ~= nil then
        cycleDetails[#cycleDetails + 1] = cycleQuantity .. "pc"
    end

    if product.cycleVolume ~= nil then
        cycleDetails[#cycleDetails + 1] = hsc.formatMeasurement(product.cycleVolume, "L")
    end

    if product.cycleMass ~= nil then
        cycleDetails[#cycleDetails + 1] = hsc.formatMeasurement(product.cycleMass, "kg")
    end

    if #cycleDetails > 0 then
        parts[#parts + 1] = "R:" .. table.concat(cycleDetails, "/")
    end

    if inventory ~= nil then
        local hubDetails = {}

        if inventory.productQuantity ~= nil then
            hubDetails[#hubDetails + 1] = hsc.formatQuantity(
                inventory.productQuantity
            ) .. "pc"
        end

        if inventory.totalVolume ~= nil then
            hubDetails[#hubDetails + 1] = hsc.formatMeasurement(
                inventory.totalVolume,
                "L"
            )
        end

        if inventory.totalMass ~= nil then
            hubDetails[#hubDetails + 1] = hsc.formatMeasurement(inventory.totalMass, "kg")
        end

        if #hubDetails > 0 then
            parts[#parts + 1] = "H:" .. table.concat(hubDetails, "/")
        end
    end

    return table.concat(parts, " | ")
end

function hsc.findOutputIndustriesForHub(core, hubId)
    local industryIds = hsc.getConnectedElementIds(
        core,
        "getElementInPlugsById",
        hubId
    )
    local industries = {}
    local seen = {}

    for _, indexedIndustryId in ipairs(
        (hsc.industryOutputsByTarget or {})[hubId] or {}
    ) do
        industryIds[#industryIds + 1] = indexedIndustryId
    end

    for _, industryId in ipairs(industryIds) do
        if not seen[industryId] and hsc.isIndustryElement(core, industryId) then
            seen[industryId] = true
            industries[#industries + 1] = {
                id = industryId,
                name = hsc.getIndustryName(core, industryId)
            }
        end
    end

    table.sort(industries, function(left, right)
        return left.name < right.name
    end)

    return industries
end

function hsc.prepareIndustryOutputIndex(core, elementIds)
    hsc.industryOutputsByTarget = {}
    hsc.industryIndexCore = core
    hsc.industryIndexElementIds = elementIds or {}
    hsc.industryIndexCursor = 0
    hsc.industryIndexComplete = core == nil or #hsc.industryIndexElementIds == 0
end

function hsc.advanceIndustryOutputIndex()
    if hsc.industryIndexComplete then return false end

    local core = hsc.industryIndexCore
    local elementIds = hsc.industryIndexElementIds or {}
    local batchSize = math.max(1, math.floor(
        tonumber(hscIndustryIndexBatchSize) or 50
    ))
    local changed = false

    for _ = 1, batchSize do
        local nextIndex = (hsc.industryIndexCursor or 0) + 1
        local industryId = elementIds[nextIndex]

        if industryId == nil then
            hsc.industryIndexComplete = true
            break
        end

        hsc.industryIndexCursor = nextIndex

        if hsc.isIndustryClassName(
            hsc.getCoreElementClassName(core, industryId)
        ) then
            for _, targetId in ipairs(hsc.getConnectedElementIds(
                core,
                "getElementOutPlugsById",
                industryId
            )) do
                local targetIndustries = hsc.industryOutputsByTarget[targetId]

                if targetIndustries == nil then
                    targetIndustries = {}
                    hsc.industryOutputsByTarget[targetId] = targetIndustries
                end

                local alreadyAdded = false
                for _, existingId in ipairs(targetIndustries) do
                    if existingId == industryId then
                        alreadyAdded = true
                        break
                    end
                end

                if not alreadyAdded then
                    targetIndustries[#targetIndustries + 1] = industryId
                    changed = true
                end
            end
        end
    end

    if (hsc.industryIndexCursor or 0) >= #elementIds then
        hsc.industryIndexComplete = true

        if debugCellAssociation then
            hsc.print("Industry output relationship scan complete.")
        end
    end

    return changed
end

function hsc.buildStorageSource(
    core,
    linkedElement,
    localId,
    sourceKind,
    linkedElementsByLocalId
)
    local industries = core ~= nil
        and hsc.findOutputIndustriesForHub(core, localId)
        or {}
    local sourceName = core ~= nil
        and hsc.getElementName(core, localId)
        or hsc.getDirectElementName(linkedElement, localId)
    local inventory = hsc.getHubInventoryMetrics(linkedElement, nil, localId)
    local containerProducts = {}
    local productLabels = {}
    local productionDetails = {}
    local iconPath = nil

    if inventory ~= nil then
        for itemId, quantity in pairs(inventory.items or {}) do
            containerProducts[#containerProducts + 1] = hsc.getProductFromItem(
                itemId,
                quantity
            )
        end

        table.sort(containerProducts, function(left, right)
            return (tonumber(left.containerQuantity) or 0)
                > (tonumber(right.containerQuantity) or 0)
        end)
    end

    for _, industry in ipairs(industries) do
        local directIndustry = linkedElementsByLocalId ~= nil
            and linkedElementsByLocalId[industry.id]
            or nil
        industry.product = hsc.getIndustryProduct(
            core,
            industry.id,
            directIndustry
        )

        if industry.product ~= nil then
            industry.product.inventory = inventory
            local productLabel = hsc.getProductDisplayLabel(
                industry.product,
                inventory
            )
            productLabels[#productLabels + 1] = productLabel
            iconPath = iconPath or industry.product.iconPath
            productionDetails[#productionDetails + 1] = string.format(
                "%s -> %s (state=%s, produced=%s, remaining=%s)",
                industry.name,
                productLabel,
                tostring(industry.product.state),
                tostring(industry.product.unitsProduced),
                tostring(industry.product.remainingTime)
            )
        end
    end

    local industrySearch = string.lower(tostring(
        debugIndustryHubNameSearch or ""
    ))
    local matchesIndustryDebug = industrySearch ~= ""
        and string.find(
            string.lower(tostring(sourceName)),
            industrySearch,
            1,
            true
        ) ~= nil

    hsc.announcedIndustryRelations = hsc.announcedIndustryRelations or {}
    hsc.announcedIndustryCounts = hsc.announcedIndustryCounts or {}

    if debugCellAssociation and matchesIndustryDebug then
        local announcedRelations = hsc.announcedIndustryRelations[localId] or {}
        hsc.announcedIndustryRelations[localId] = announcedRelations

        if hsc.announcedIndustryCounts[localId] ~= #industries then
            hsc.announcedIndustryCounts[localId] = #industries
            hsc.print(string.format(
                "Hub %s [%s] related industries: %d",
                tostring(sourceName),
                tostring(localId),
                #industries
            ))
        end

        for _, industry in ipairs(industries) do
            local product = industry.product
            local productName = product ~= nil
                and tostring(product.name or product.label or "no product")
                or "no product"
            local amount = product ~= nil
                and hsc.formatQuantity(product.cycleQuantity)
                or nil
            local productId = product ~= nil and product.itemId or nil
            local productText = productName

            if amount ~= nil then productText = productText .. " x" .. amount end
            if productId ~= nil then
                productText = productText .. " [" .. tostring(productId) .. "]"
            end
            local relationFingerprint = tostring(industry.name)
                .. "|" .. productText

            if announcedRelations[industry.id] ~= relationFingerprint then
                announcedRelations[industry.id] = relationFingerprint
                hsc.print(string.format(
                    "industry %s [%s] -> %s",
                    tostring(industry.name),
                    tostring(industry.id),
                    productText
                ))
            end
        end
    end

    return {
        id = localId,
        name = sourceName,
        sourceKind = sourceKind or "hub",
        industryIds = industries,
        productionDetails = productionDetails,
        label = #productLabels > 0
            and table.concat(productLabels, " / ")
            or sourceName,
        iconPath = iconPath,
        inventory = inventory,
        containerProducts = containerProducts
    }
end

function hsc.buildIndustrySource(core, industryElement, localId)
    local sourceName = core ~= nil
        and hsc.getIndustryName(core, localId)
        or hsc.getDirectElementName(industryElement, localId)
    local product = hsc.getIndustryProduct(core, localId, industryElement)
    local industry = {
        id = localId,
        name = sourceName,
        product = product
    }
    local label = product ~= nil
        and hsc.getProductDisplayLabel(product, nil)
        or sourceName

    return {
        id = localId,
        name = sourceName,
        sourceKind = "industry",
        industryIds = { industry },
        productionDetails = product ~= nil and {
            string.format(
                "%s -> %s (state=%s, produced=%s, remaining=%s)",
                sourceName,
                label,
                tostring(product.state),
                tostring(product.unitsProduced),
                tostring(product.remainingTime)
            )
        } or {},
        label = label,
        iconPath = product ~= nil and product.iconPath or nil,
        inventory = nil,
        containerProducts = {}
    }
end

function hsc.discoverNearbyHubs(core, screen, linkedElementsByLocalId)
    local screenId = hsc.getLocalId(screen)

    if screenId == nil then
        return nil, "The linked screen did not return a local ID."
    end

    local screenPosition = hsc.call(screen, "getPosition")
        or hsc.call(core, "getElementPositionById", screenId)
    local screenRight = hsc.call(screen, "getRight")
        or hsc.call(core, "getElementRightById", screenId)
    local screenUp = hsc.call(screen, "getUp")
        or hsc.call(core, "getElementUpById", screenId)
    local screenForward = hsc.call(screen, "getForward")
        or hsc.call(core, "getElementForwardById", screenId)
    local screenBoundsSize = hsc.call(screen, "getBoundingBoxSize")

    if screenPosition == nil or screenRight == nil
        or screenUp == nil or screenForward == nil or screenBoundsSize == nil then
        return nil, "The linked Screen did not return its bounds and orientation."
    end

    screenRight = hsc.normalize(screenRight)
    screenUp = hsc.normalize(screenUp)
    screenForward = hsc.normalize(screenForward)
    -- Generic Element bounding-box dimensions are expressed in the element's
    -- own right/forward/up axes, independently of construct placement.
    local screenWidth = math.abs(screenBoundsSize[1])
    local screenHeight = math.abs(screenBoundsSize[3])

    if screenWidth <= 0.001 or screenHeight <= 0.001 then
        return nil, "The linked Screen returned invalid bounding-box dimensions."
    end

    local elementIds = hsc.call(core, "getElementIdList")

    if elementIds == nil then
        elementIds = {}

        for localId in pairs(linkedElementsByLocalId or {}) do
            elementIds[#elementIds + 1] = localId
        end

        table.sort(elementIds)
    end

    local nearbyHubs = {}

    for _, localId in ipairs(elementIds) do
        local linkedHub = linkedElementsByLocalId ~= nil
            and linkedElementsByLocalId[localId]
            or nil
        local isHub = core ~= nil
            and hsc.isContainerHub(core, localId)
            or hsc.isDirectContainerHub(linkedHub)

        if isHub then
            local position = hsc.call(core, "getElementPositionById", localId)
                or hsc.call(linkedHub, "getPosition")

            if position ~= nil then
                local relative = hsc.vectorSubtract(position, screenPosition)
                local x = hsc.dot(relative, screenRight)
                local y = hsc.dot(relative, screenUp)
                local depth = hsc.dot(relative, screenForward)
                local planarDistance = math.sqrt(x * x + y * y)

                if math.abs(depth) <= hscMaxDepthMeters
                    and planarDistance <= hscSearchRadiusMeters then
                    nearbyHubs[#nearbyHubs + 1] = {
                        id = localId,
                        linkedElement = linkedHub,
                        position = position,
                        x = x,
                        y = y,
                        depth = depth
                    }
                end
            end
        end
    end

    hsc.prepareIndustryOutputIndex(core, elementIds)
    local hubs = {}

    for _, nearbyHub in ipairs(nearbyHubs) do
        local source = hsc.buildStorageSource(
            core,
            nearbyHub.linkedElement,
            nearbyHub.id,
            "hub",
            linkedElementsByLocalId
        )
        source.position = nearbyHub.position
        source.x = nearbyHub.x
        source.y = nearbyHub.y
        source.depth = nearbyHub.depth
        hubs[#hubs + 1] = source
    end

    return {
        screenId = screenId,
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        hubs = hubs
    }
end

function hsc.getAssociatedElementIds(projected)
    local associated = {}

    for _, cell in ipairs(projected or {}) do
        associated[cell.id] = true

        for _, industry in ipairs(cell.industryIds or {}) do
            associated[industry.id] = true
        end
    end

    return associated
end

function hsc.getUnassociatedLinkedSources(
    core,
    projected,
    orderedSlots,
    linkedElementsByLocalId
)
    local associated = hsc.getAssociatedElementIds(projected)
    orderedSlots = orderedSlots or hsc.getOrderedLinkedSlots()
    local linkedKinds = {}
    local absorbedIndustries = {}

    for _, candidate in ipairs(orderedSlots) do
        local localId = hsc.getLocalId(candidate.element)
        local kind = hsc.getDirectElementKind(candidate.element, core, localId)

        if kind ~= nil then
            linkedKinds[localId] = kind

            if kind == "hub" or kind == "container" then
                for _, industry in ipairs(
                    core ~= nil and hsc.findOutputIndustriesForHub(core, localId) or {}
                ) do
                    absorbedIndustries[industry.id] = true
                end
            end
        end
    end

    local sources = {}
    local counts = { hub = 0, container = 0, industry = 0 }

    for _, candidate in ipairs(orderedSlots) do
        local element = candidate.element
        local localId = hsc.getLocalId(element)
        local kind = linkedKinds[localId]
        local source = nil

        if kind ~= nil and not associated[localId] then
            if kind == "industry" and not absorbedIndustries[localId] then
                source = hsc.buildIndustrySource(core, element, localId)
            elseif kind == "hub" or kind == "container" then
                source = hsc.buildStorageSource(
                    core,
                    element,
                    localId,
                    kind,
                    linkedElementsByLocalId
                )
            end
        end

        if source ~= nil then
            source.slotIndex = candidate.slotIndex
            sources[#sources + 1] = source
            counts[kind] = counts[kind] + 1
        end
    end

    return sources, counts
end

function hsc.getEmptyCells(projected)
    local occupied = {}
    local emptyCells = {}

    for _, cell in ipairs(projected or {}) do
        occupied[tostring(cell.cellColumn) .. ":" .. tostring(cell.cellRow)] = true
    end

    for row = 1, hscRows do
        for column = 1, hscColumns do
            local key = tostring(column) .. ":" .. tostring(row)

            if not occupied[key] then
                emptyCells[#emptyCells + 1] = { column = column, row = row }
            end
        end
    end

    return emptyCells
end

function hsc.assignLinkedSourcesToEmptyCells(
    projected,
    core,
    width,
    height,
    orderedSlots,
    linkedElementsByLocalId
)
    local emptyCells = hsc.getEmptyCells(projected)
    local sources, counts = hsc.getUnassociatedLinkedSources(
        core,
        projected,
        orderedSlots,
        linkedElementsByLocalId
    )
    local awaiting = {}

    if debugCellAssociation then
        hsc.print("Cells available after nearby Hub association: "
            .. tostring(#emptyCells))
        hsc.print(string.format(
            "Linked elements available for cells: %d container(s), %d hub(s), %d industry unit(s).",
            counts.container,
            counts.hub,
            counts.industry
        ))
    end

    for sourceIndex, source in ipairs(sources) do
        local target = emptyCells[sourceIndex]

        if target ~= nil then
            projected[#projected + 1] = hscScreen.createAssignedCell(
                source,
                target.column,
                target.row,
                width,
                height,
                { manuallyAssociated = true }
            )

            if debugCellAssociation then
                hsc.print(string.format(
                    "cell (%d, %d) - %s [%s]",
                    target.column,
                    target.row,
                    tostring(source.name),
                    tostring(source.id)
                ))
            end
        else
            awaiting[#awaiting + 1] = source
        end
    end

    if debugCellAssociation then
        local remainingCells = math.max(0, #emptyCells - #sources)
        hsc.print("Free cells after linked-element association: "
            .. tostring(remainingCells))

        if #awaiting > 0 then
            hsc.print("Linked elements awaiting a cell: " .. tostring(#awaiting))

            for _, source in ipairs(awaiting) do
                hsc.print("awaiting cell - " .. tostring(source.name)
                    .. " [" .. tostring(source.id) .. "]")
            end
        end
    end

    table.sort(projected, function(left, right)
        if left.cellRow ~= right.cellRow then
            return left.cellRow < right.cellRow
        end

        return left.cellColumn < right.cellColumn
    end)

    return projected
end

function hsc.makeCellAssignments(projected)
    local assignments = {}

    for _, cell in ipairs(projected or {}) do
        assignments[#assignments + 1] = {
            id = cell.id,
            sourceKind = cell.sourceKind or "hub",
            cellColumn = cell.cellColumn,
            cellRow = cell.cellRow,
            screenX = cell.screenX,
            screenY = cell.screenY,
            x = cell.x,
            y = cell.y,
            depth = cell.depth,
            position = cell.position,
            surfaceDistance = cell.surfaceDistance,
            inside = cell.inside,
            manuallyAssociated = cell.manuallyAssociated == true
        }
    end

    return assignments
end

function hsc.rebuildAssignedCells()
    local linkedById = hsc.runtime.linkedElementsByLocalId or {}
    local rebuilt = {}

    for _, assignment in ipairs(hsc.runtime.cellAssignments or {}) do
        local linkedElement = linkedById[assignment.id]
        local source

        if assignment.sourceKind == "industry" then
            source = hsc.buildIndustrySource(
                hsc.runtime.core,
                linkedElement,
                assignment.id
            )
        else
            source = hsc.buildStorageSource(
                hsc.runtime.core,
                linkedElement,
                assignment.id,
                assignment.sourceKind,
                linkedById
            )
        end

        source.position = hsc.call(
            hsc.runtime.core,
            "getElementPositionById",
            assignment.id
        ) or hsc.call(linkedElement, "getPosition") or assignment.position

        rebuilt[#rebuilt + 1] = hscScreen.createAssignedCell(
            source,
            assignment.cellColumn,
            assignment.cellRow,
            hsc.runtime.screenWidth,
            hsc.runtime.screenHeight,
            assignment
        )
    end

    return rebuilt
end


function hsc.refreshDiscovery()
    if hsc.runtime == nil then
        return
    end

    local projected = hsc.rebuildAssignedCells()
    local dirtyHubs = hscStorage.syncHubs(
        hsc.runtime.databank,
        hsc.runtime.screenId,
        projected
    )
    hsc.runtime.hubs = projected

    if #dirtyHubs > 0 then
        hscStorage.saveHubCells(hsc.runtime.databank, hsc.runtime.screenId, projected)
        hscScreen.queueDirtyCells(dirtyHubs)
        hsc.printDebugDetails(dirtyHubs)
    end
end

function hsc.printElementDebug(projected)
    for _, hub in ipairs(projected or {}) do
        local inventory = hub.inventory or {}
        local requestStatus = inventory.contentRefreshRequested and " requested" or " cached"

        hsc.print(string.format(
            "%s [%s] -> screen=(%.4f, %.4f), cell=(%d, %d), local=(%.3f, %.3f, %.3f), items=%s%s",
            tostring(hub.hubName or hub.name),
            tostring(hub.id),
            tonumber(hub.screenX) or 0,
            tonumber(hub.screenY) or 0,
            tonumber(hub.cellColumn) or 0,
            tonumber(hub.cellRow) or 0,
            tonumber(hub.x) or 0,
            tonumber(hub.y) or 0,
            tonumber(hub.depth) or 0,
            tostring(inventory.cachedItemCount or 0),
            requestStatus
        ))
    end
end

function hsc.printIndustryDebug(projected)
    for _, hub in ipairs(projected or {}) do
        for _, detail in ipairs(hub.productionDetails or {}) do
            hsc.print(string.format(
                "Industry for %s [%s]: %s",
                tostring(hub.hubName or hub.name),
                tostring(hub.id),
                tostring(detail)
            ))
        end
    end
end

function hsc.printContainerDebug(projected)
    for _, hub in ipairs(projected or {}) do
        local inventory = hub.inventory

        if inventory ~= nil then
            local items = {}

            for _, product in ipairs(hub.containerProducts or {}) do
                items[#items + 1] = tostring(product.name)
                    .. " x" .. tostring(hsc.formatQuantity(product.containerQuantity) or 0)
            end

            hsc.print(string.format(
                "Container %s [%s]: %s / %s, items=%s",
                tostring(hub.hubName or hub.name),
                tostring(hub.id),
                tostring(hsc.formatMeasurement(inventory.totalVolume, "L") or "unknown"),
                tostring(hsc.formatMeasurement(inventory.maxVolume, "L") or "unknown"),
                #items > 0 and table.concat(items, ", ") or "empty"
            ))
        end
    end
end

function hsc.printDebugDetails(projected)
    if hscDebugElements then
        hsc.printElementDebug(projected)
    end

    if hscDebugIndustries then
        hsc.printIndustryDebug(projected)
    end

    if hscDebugContainers then
        hsc.printContainerDebug(projected)
    end
end

function hsc.onScreenTimer()
    hscScreen.pollClickOutput()

    if hsc.runtime == nil then return end

    hscScreen.sendNextDirtyCell()
end

function hsc.onContainerTimer()
    if hsc.runtime == nil then return end

    hsc.runtime.contentElapsedSeconds = (hsc.runtime.contentElapsedSeconds or 0)
        + hscContainerRefreshSeconds
    hsc.requestNextHubContent()
    hsc.advanceIndustryOutputIndex()
    hsc.refreshDiscovery()
end

function hsc.run()
    hsc.industryElementCache = {}
    hsc.coreElementClassCache = {}
    hsc.industryOutputsByTarget = {}
    hsc.announcedIndustryRelations = {}
    hsc.announcedIndustryCounts = {}

    if hscStorage == nil then
        error("Storage library is missing. Add library.onStart.storage.lua to Library > onStart.")
    end

    if hscScreen == nil then
        error("Screen library is missing. Add library.onStart.screen.lua to Library > onStart.")
    end

    local slots = hsc.getSlots()
    local linked = hsc.discoverLinkedElements(slots)
    local linkedElementsByLocalId = hsc.getLinkedElementsByLocalId(slots)
    local orderedLinkedSlots = hsc.getOrderedLinkedSlots(slots)

    if linked.databank == nil then
        error("No linked Databank was detected.")
    end

    if linked.screen == nil then
        error("No linked Screen Unit was detected.")
    end

    hsc.print("Core=" .. tostring(linked.coreSlot or "none")
        .. ", Databank=" .. linked.databankSlot
        .. ", Screen=" .. linked.screenSlot)

    local discovery, discoveryError = hsc.discoverNearbyHubs(
        linked.core,
        linked.screen,
        linkedElementsByLocalId
    )

    if discovery == nil then
        error(discoveryError)
    end

    if debugCellAssociation then
        hsc.print("Nearby Hub discovery complete: "
            .. tostring(#(discovery.hubs or {})) .. " candidate(s).")
    end

    local projected, width, height = hscScreen.projectHubsToScreen(
        discovery.hubs,
        discovery.screenWidth,
        discovery.screenHeight
    )

    if debugCellAssociation then
        hsc.print("Nearby Hub projection complete: "
            .. tostring(#(projected or {})) .. " cell(s) occupied.")
    end

    projected = hsc.assignLinkedSourcesToEmptyCells(
        projected,
        linked.core,
        width,
        height,
        orderedLinkedSlots,
        linkedElementsByLocalId
    )
    local cellAssignments = hsc.makeCellAssignments(projected)
    local dirtyHubs = hscStorage.syncHubs(
        linked.databank,
        discovery.screenId,
        projected
    )
    hscStorage.saveHubCells(linked.databank, discovery.screenId, projected)

    linked.screen.setRenderScript(hscScreen.getRenderScript())
    linked.screen.activate()

    hsc.runtime = {
        core = linked.core,
        hubs = projected,
        screen = linked.screen,
        databank = linked.databank,
        screenId = discovery.screenId,
        screenWidth = width,
        screenHeight = height,
        linkedElementsByLocalId = linkedElementsByLocalId,
        cellAssignments = cellAssignments,
        clickMarkers = {},
        nextClickIndex = 0,
        lastClickOutput = nil,
        lastClickX = nil,
        lastClickY = nil,
        lastClickTime = nil,
        discoveryElapsed = 0,
        contentElapsedSeconds = 0,
        nextContentHubIndex = 0,
        nextContentRequestAt = 0,
        pendingContentHubId = nil,
        dirtyCellQueue = {},
        queuedCells = {}
    }

    hscScreen.sendConfiguration()
    -- A newly started Screen has no cached cells. Bootstrap every saved cell
    -- once; subsequent timer cycles enqueue only Databank-dirty cells.
    hscScreen.queueDirtyCells(projected)
    hsc.requestNextHubContent()

    if hscScreenPollSeconds > 0 then
        unit.setTimer("hscScreenDelivery", hscScreenPollSeconds)
        hsc.print(
            "Started Screen delivery timer at "
            .. tostring(hscScreenPollSeconds) .. " second(s)."
        )
    end

    if hscContainerRefreshSeconds > 0 then
        unit.setTimer("hscContainerRefresh", hscContainerRefreshSeconds)
        hsc.print(
            "Started container refresh timer at "
            .. tostring(hscContainerRefreshSeconds) .. " second(s)."
        )
    end

    hsc.printDebugDetails(dirtyHubs)

    return #projected
end
