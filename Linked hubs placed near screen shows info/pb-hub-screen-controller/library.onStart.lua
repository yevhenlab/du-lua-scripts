hscRows = 3 --export
hscColumns = 5 --export
hscScreenTitle = "Hub Production Overview" --export
hscScreenVersion = "0.1.83" --export
hscReserveTopTextArea = true --export
hscReserveBottomTextArea = false --export
hscReservedTextAreaFraction = 0.12 --export
hscSearchRadiusMeters = 20 --export
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
hscDebugScreen = false --export
hscDebugElements = false --export
hscDebugIndustries = false --export
hscDebugContainers = false --export
hscDebugDatabank = false --export

hsc = hsc or {}

function hsc.print(message)
    system.print("[HSC] " .. tostring(message))
end

function hsc.onLinkedHubContentUpdate(element)
    if hsc.runtime == nil or element == nil then return end

    local localId = hsc.getLocalId(element)

    if localId == nil then return end

    local linkedElement = hsc.getLinkedElementsByLocalId()[localId]

    if linkedElement ~= nil
        and hsc.getMethod(linkedElement, "getContent") ~= nil
        and hsc.getMethod(linkedElement, "updateContent") ~= nil then
        if hscDebugContainers then
            hsc.print("Container content event received for hub "
                .. tostring(localId))
        end
        hsc.refreshDiscovery()
    end
end

function hsc.getSlots()
    return {
        { name = "slot1", element = slot1 },
        { name = "slot2", element = slot2 },
        { name = "slot3", element = slot3 },
        { name = "slot4", element = slot4 },
        { name = "slot5", element = slot5 },
        { name = "slot6", element = slot6 },
        { name = "slot7", element = slot7 },
        { name = "slot8", element = slot8 },
        { name = "slot9", element = slot9 },
        { name = "slot10", element = slot10 },
        { name = "core", element = core },
        { name = "databank", element = databank },
        { name = "db", element = db },
        { name = "screen", element = screen }
    }
end

function hsc.getLinkedElementsByLocalId()
    local linkedElements = {}

    for _, candidate in ipairs(hsc.getSlots()) do
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

function hsc.discoverLinkedElements()
    local result = {
        core = nil,
        databank = nil,
        screen = nil
    }

    local slots = hsc.getSlots()

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

function hsc.isContainerHub(core, localId)
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

function hsc.getDirectElementName(element, localId)
    local name = hsc.call(element, "getName")
        or hsc.call(element, "getDisplayName")

    if name == nil or tostring(name) == "" then
        return "Hub " .. tostring(localId)
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

    if type(plugs) ~= "table" then
        return elementIds
    end

    for _, plug in pairs(plugs) do
        local elementId = plug

        if type(plug) == "table" then
            elementId = plug.elementId or plug.elementID or plug.element_id
                or plug.localId or plug.localID or plug.local_id
                or plug.id or plug[1]
        end

        elementId = tonumber(elementId) or elementId

        if elementId ~= nil and not seen[elementId] then
            seen[elementId] = true
            elementIds[#elementIds + 1] = elementId
        end
    end

    return elementIds
end

function hsc.isIndustryElement(core, localId)
    if type(hsc.call(core, "getElementIndustryInfoById", localId)) == "table" then
        return true
    end

    local className = string.lower(tostring(
        hsc.call(core, "getElementClassById", localId) or ""
    ))

    return className == "industryunit"
        or string.find(className, "industry", 1, true) ~= nil
        or string.match(className, "^industry%d*$") ~= nil
        or string.match(className, "^industryunit%d+$") ~= nil
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

function hsc.getIndustryProduct(core, localId)
    local info = hsc.call(core, "getElementIndustryInfoById", localId)

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
    local linkedById = hsc.getLinkedElementsByLocalId()

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

    for _, industryId in ipairs(industryIds) do
        if hsc.isIndustryElement(core, industryId) then
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

    local hubs = {}

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
                    local industries = core ~= nil
                        and hsc.findOutputIndustriesForHub(core, localId)
                        or {}
                    local productLabels = {}
                    local productionDetails = {}
                    local iconPath = nil
                    local hubInventory = hsc.getHubInventoryMetrics(
                        linkedHub,
                        nil,
                        localId
                    )
                    local containerProducts = {}

                    if hubInventory ~= nil then
                        for itemId, quantity in pairs(hubInventory.items or {}) do
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
                        industry.product = hsc.getIndustryProduct(core, industry.id)

                        if industry.product ~= nil then
                            industry.product.inventory = hubInventory
                            local productLabel = hsc.getProductDisplayLabel(
                                industry.product,
                                hubInventory
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

                    local label = #industries == 0 and "no indy"
                        or (#productLabels > 0
                            and table.concat(productLabels, " / ")
                            or "no product")
                    hubs[#hubs + 1] = {
                        id = localId,
                        name = core ~= nil
                            and hsc.getElementName(core, localId)
                            or hsc.getDirectElementName(linkedHub, localId),
                        industryIds = industries,
                        productionDetails = productionDetails,
                        label = label,
                        iconPath = iconPath,
                        inventory = hubInventory,
                        containerProducts = containerProducts,
                        position = position,
                        x = x,
                        y = y,
                        depth = depth
                    }
                end
            end
        end
    end

    return {
        screenId = screenId,
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        hubs = hubs
    }
end


function hsc.refreshDiscovery()
    if hsc.runtime == nil then
        return
    end

    local discovery, discoveryError = hsc.discoverNearbyHubs(
        hsc.runtime.core,
        hsc.runtime.screen,
        hsc.getLinkedElementsByLocalId()
    )

    if discovery == nil then
        hsc.print("Discovery refresh failed: " .. tostring(discoveryError))
        return
    end

    local projected, width, height = hscScreen.projectHubsToScreen(
        discovery.hubs,
        discovery.screenWidth,
        discovery.screenHeight
    )
    local dirtyHubs = hscStorage.syncHubs(
        hsc.runtime.databank,
        hsc.runtime.screenId,
        projected
    )

    if #dirtyHubs > 0 then
        hsc.runtime.hubs = projected
        hsc.runtime.screenWidth = width
        hsc.runtime.screenHeight = height
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
    hsc.refreshDiscovery()
end

function hsc.run()
    if hscStorage == nil then
        error("Storage library is missing. Add library.onStart.storage.lua to Library > onStart.")
    end

    if hscScreen == nil then
        error("Screen library is missing. Add library.onStart.screen.lua to Library > onStart.")
    end

    local linked = hsc.discoverLinkedElements()

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
        hsc.getLinkedElementsByLocalId()
    )

    if discovery == nil then
        error(discoveryError)
    end

    local projected, width, height = hscScreen.projectHubsToScreen(
        discovery.hubs,
        discovery.screenWidth,
        discovery.screenHeight
    )
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
