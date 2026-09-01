debugElements = true --export
debugPbStartInfo = false --export
newElementSearchSeconds = 3 --export
elementGroupMinimumGapSeconds = 30 --export
arEnabled = true --export
showArRectanglePrisms = false --export
reduceArFrequencyOnFpsDrop = true --export
arTextDistanceMeters = 50 --export
arEllipseDistanceMeters = 50 --export
arSourceLabelDistanceMeters = 30 --export
maximumOutputLinks = 20 --export
sourceScanBatchSize = 3 --export
arIdleRefreshSeconds = 0.2 --export
arMinimumRefreshSeconds = 0.033 --export
arFullSpeedDegreesPerSecond = 45 --export
arFullPlayerSpeedMetersPerSecond = 5 --export
arMotionCurveExponent = 0.5 --export
databankKey = "ibh:v1:added-elements" --export
version = "0.0.81" --export

ibhDebugElements = debugElements
ibhDebugPbStartInfo = debugPbStartInfo
ibhNewElementSearchSeconds = newElementSearchSeconds
ibhElementGroupMinimumGapSeconds = elementGroupMinimumGapSeconds
ibhArEnabled = arEnabled
ibhShowArRectanglePrisms = showArRectanglePrisms
ibhReduceArFrequencyOnFpsDrop = reduceArFrequencyOnFpsDrop
ibhArTextDistanceMeters = arTextDistanceMeters
ibhArEllipseDistanceMeters = arEllipseDistanceMeters
ibhArSourceLabelDistanceMeters = arSourceLabelDistanceMeters
ibhMaximumOutputLinks = maximumOutputLinks
ibhSourceScanBatchSize = sourceScanBatchSize
ibhArIdleRefreshSeconds = arIdleRefreshSeconds
ibhArMinimumRefreshSeconds = arMinimumRefreshSeconds
ibhArFullSpeedDegreesPerSecond = arFullSpeedDegreesPerSecond
ibhArFullPlayerSpeedMetersPerSecond = arFullPlayerSpeedMetersPerSecond
ibhArMotionCurveExponent = arMotionCurveExponent
ibhDatabankKey = databankKey
ibhVersion = version

ibh = ibh or {}
ibh.addedElementGroups = ibh.addedElementGroups or {}
ibh.addedElementIntervals = ibh.addedElementIntervals or {}
ibh.performance = ibh.performance or {
    frameCount = 0,
    sampleStartedAt = nil,
    fps = nil,
    fpsHistory = {},
    arFrequencyReduction = 0,
    fpsReductionByWindow = {}
}
ibh.render = ibh.render or {
    lastRenderedAt = nil,
    lastCameraSampleAt = nil,
    lastCameraForward = nil,
    lastPlayerPosition = nil,
    angularSpeed = 0,
    playerSpeed = 0,
    targetInterval = 0.2,
    refreshCount = 0,
    refreshSampleStartedAt = nil,
    refreshHz = 0
}
ibh.knownIndustryOutputLinks = ibh.knownIndustryOutputLinks or {}
ibh.knownDirectOutputLinks = ibh.knownDirectOutputLinks or {}
ibh.knownPbContainerLinks = ibh.knownPbContainerLinks or {}
ibh.knownRunningIndustries = {}
ibh.announcedDoneButtons = {}
ibh.directContainerCapacityById = {}
ibh.containerCapacityCatalog = {}
ibh.loadedUnknownContainerKeys = {}
ibh.legacyContainerCapacityRows = {}
ibh.containerCatalogNeedsMigration = false

function ibh.print(message)
    system.print("[IBH] " .. tostring(message))
end

function ibh.debugElements(message)
    if ibhDebugElements then
        ibh.print(message)
    end
end

function ibh.getMethod(element, methodName)
    if element == nil then return nil end

    local ok, method = pcall(function()
        return element[methodName]
    end)

    if ok and type(method) == "function" then
        return method
    end

    return nil
end

function ibh.call(element, methodName, ...)
    local method = ibh.getMethod(element, methodName)
    if method == nil then return nil end

    local ok, value = pcall(method, ...)
    if ok then return value end

    return nil
end

function ibh.getSlots()
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
        slots[slotIndex] = {
            name = "slot" .. tostring(slotIndex),
            index = slotIndex,
            element = elements[slotIndex]
        }
    end

    return slots
end

function ibh.isCore(element)
    if element == nil then return false end

    local className = string.lower(tostring(
        ibh.call(element, "getClass") or ""
    ))

    return string.find(className, "core", 1, true) ~= nil
        or ibh.getMethod(element, "getElementIdList") ~= nil
end

function ibh.findCore()
    for _, candidate in ipairs(ibh.getSlots()) do
        if ibh.isCore(candidate.element) then
            ibh.core = candidate.element
            ibh.coreSlot = candidate.name
            ibh.coreSlotIndex = candidate.index
            return candidate.element, candidate.name, candidate.index
        end
    end

    ibh.core = nil
    ibh.coreSlot = nil
    ibh.coreSlotIndex = nil
    return nil
end

function ibh.findDatabank()
    for _, candidate in ipairs(ibh.getSlots()) do
        local element = candidate.element
        local className = string.lower(tostring(
            ibh.call(element, "getClass") or ""
        ))
        local isDatabank = string.find(className, "databank", 1, true) ~= nil
            or string.find(className, "data bank", 1, true) ~= nil
            or ibh.getMethod(element, "setStringValue") ~= nil

        if isDatabank then
            ibh.databank = element
            ibh.databankSlot = candidate.name
            return element, candidate.name
        end
    end

    ibh.databank = nil
    ibh.databankSlot = nil
    return nil
end

function ibh.encodeStorageField(value)
    return tostring(value or ""):gsub("([^%w%._%- ])", function(character)
        return string.format("%%%02X", string.byte(character))
    end)
end

function ibh.decodeStorageField(value)
    return tostring(value or ""):gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

function ibh.splitStorageLine(line)
    local fields = {}
    for field in (tostring(line or "") .. "|"):gmatch("(.-)|") do
        fields[#fields + 1] = ibh.decodeStorageField(field)
    end
    return fields
end

function ibh.serializeTrackedElements()
    local lines = { "IBH-ADDED-1" }

    for groupIndex, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements or {}) do
            local x, y, z = ibh.getVectorComponents(element.position)
            local fields = {
                groupIndex,
                group.firstAddedAt or element.addedAt or 0,
                group.lastAddedAt or element.addedAt or 0,
                element.id or "",
                element.className or "",
                element.name or "",
                x or 0,
                y or 0,
                z or 0,
                element.addedAt or group.lastAddedAt or 0,
                element.unitMass or ""
            }
            for index, value in ipairs(fields) do
                fields[index] = ibh.encodeStorageField(value)
            end
            lines[#lines + 1] = table.concat(fields, "|")
        end
    end

    return table.concat(lines, "\n")
end

function ibh.saveTrackedElements()
    if ibh.databank == nil then return false end
    local payload = ibh.serializeTrackedElements()
    local current = ibh.call(ibh.databank, "getStringValue", ibhDatabankKey)
    if current == payload then return true end

    local method = ibh.getMethod(ibh.databank, "setStringValue")
    if method == nil then return false end
    local ok = pcall(method, ibhDatabankKey, payload)
    if ok then ibh.debugElements("Databank saved.") end
    return ok
end

function ibh.loadTrackedElements()
    if ibh.databank == nil then return 0 end
    local payload = ibh.call(ibh.databank, "getStringValue", ibhDatabankKey)
    if type(payload) ~= "string"
        or payload:sub(1, 11) ~= "IBH-ADDED-1" then return 0 end

    local groupsByIndex = {}
    local restored = 0
    for line in payload:gmatch("[^\r\n]+") do
        if line ~= "IBH-ADDED-1" then
            local fields = ibh.splitStorageLine(line)
            local groupIndex = tonumber(fields[1])
            local localId = tonumber(fields[4]) or fields[4]
            if groupIndex ~= nil and localId ~= nil and localId ~= "" then
                local group = groupsByIndex[groupIndex]
                if group == nil then
                    group = {
                        firstAddedAt = tonumber(fields[2]) or 0,
                        lastAddedAt = tonumber(fields[3]) or 0,
                        elements = {}
                    }
                    groupsByIndex[groupIndex] = group
                end

                local position = ibh.vector(
                    tonumber(fields[7]) or 0,
                    tonumber(fields[8]) or 0,
                    tonumber(fields[9]) or 0
                )
                local className = fields[5] or ""
                local positionKey = ibh.getElementPositionKey(position)
                group.elements[#group.elements + 1] = {
                    id = localId,
                    className = className,
                    name = fields[6] or className,
                    position = position,
                    positionKey = positionKey,
                    identityKey = tostring(localId) .. "|" .. className
                        .. "|" .. positionKey,
                    addedAt = tonumber(fields[10]) or group.lastAddedAt,
                    unitMass = tonumber(fields[11]),
                    removed = false
                }
                restored = restored + 1
            end
        end
    end

    ibh.addedElementGroups = {}
    for groupIndex = 1, 5 do
        if groupsByIndex[groupIndex] ~= nil then
            ibh.addedElementGroups[#ibh.addedElementGroups + 1]
                = groupsByIndex[groupIndex]
        end
    end
    return restored
end

function ibh.getContainerCapacityDatabankKey()
    return tostring(ibhDatabankKey) .. ":container-capacities"
end

function ibh.getContainerCatalogKey(className)
    className = tostring(className or "")
    if className == "" then return nil end
    return string.lower(className)
end

function ibh.serializeContainerCapacities()
    local keys = {}
    for key in pairs(ibh.containerCapacityCatalog) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)

    local lines = { "IBH-CONTAINER-CAPACITY-3" }
    for _, key in ipairs(keys) do
        local entry = ibh.containerCapacityCatalog[key]
        local fields = {
            entry.className or "",
            tonumber(entry.maxVolume) or "?"
        }
        for index, value in ipairs(fields) do
            fields[index] = ibh.encodeStorageField(value)
        end
        lines[#lines + 1] = table.concat(fields, "|")
    end
    return table.concat(lines, "\n")
end

function ibh.loadContainerCapacities()
    ibh.containerCapacityCatalog = {}
    ibh.loadedUnknownContainerKeys = {}
    ibh.legacyContainerCapacityRows = {}
    ibh.containerCatalogNeedsMigration = false
    if ibh.databank == nil then return 0 end
    local payload = ibh.call(
        ibh.databank,
        "getStringValue",
        ibh.getContainerCapacityDatabankKey()
    )
    if type(payload) ~= "string" then
        return 0
    end

    if payload:sub(1, 24) ~= "IBH-CONTAINER-CAPACITY-3" then
        ibh.containerCatalogNeedsMigration = true
        for line in payload:gmatch("[^\r\n]+") do
            if payload:sub(1, 24) == "IBH-CONTAINER-CAPACITY-1"
                and line ~= "IBH-CONTAINER-CAPACITY-1" then
                local classId, maxVolume = line:match("^([^|]+)|([^|]+)$")
                if classId ~= nil then
                    ibh.legacyContainerCapacityRows[#ibh.legacyContainerCapacityRows + 1] = {
                        label = "classId " .. tostring(classId),
                        maxVolume = tonumber(maxVolume)
                    }
                end
            elseif payload:sub(1, 24) == "IBH-CONTAINER-CAPACITY-2"
                and line ~= "IBH-CONTAINER-CAPACITY-2" then
                local fields = ibh.splitStorageLine(line)
                ibh.legacyContainerCapacityRows[#ibh.legacyContainerCapacityRows + 1] = {
                    label = tostring(fields[2] or fields[1] or "record"),
                    maxVolume = tonumber(fields[3])
                }
            end
        end
        return 0
    end

    local count = 0
    for line in payload:gmatch("[^\r\n]+") do
        if line ~= "IBH-CONTAINER-CAPACITY-3" then
            local fields = ibh.splitStorageLine(line)
            local className = fields[1]
            local maxVolume = tonumber(fields[2])
            local key = ibh.getContainerCatalogKey(className)
            if key ~= nil then
                ibh.containerCapacityCatalog[key] = {
                    className = className,
                    maxVolume = maxVolume
                }
                if maxVolume ~= nil then
                    count = count + 1
                else
                    ibh.loadedUnknownContainerKeys[key] = true
                end
            end
        end
    end
    return count
end

function ibh.saveContainerCapacities()
    if ibh.databank == nil then return false end
    local payload = ibh.serializeContainerCapacities()
    local key = ibh.getContainerCapacityDatabankKey()
    local current = ibh.call(ibh.databank, "getStringValue", key)
    if current == payload then
        ibh.containerCatalogNeedsMigration = false
        return true
    end
    local method = ibh.getMethod(ibh.databank, "setStringValue")
    if method == nil then return false end
    local ok = pcall(method, key, payload)
    if ok then ibh.containerCatalogNeedsMigration = false end
    return ok
end

function ibh.rememberContainerCapacity(className, maxVolume)
    local key = ibh.getContainerCatalogKey(className)
    maxVolume = tonumber(maxVolume)
    if key == nil or maxVolume == nil then return false end
    local previousEntry = ibh.containerCapacityCatalog[key]
    local previous = previousEntry and tonumber(previousEntry.maxVolume)
    if previous ~= nil and math.abs(previous - maxVolume) < 0.000001 then
        return false
    end
    ibh.containerCapacityCatalog[key] = {
        className = tostring(className),
        maxVolume = maxVolume
    }
    return true
end

function ibh.rememberUnknownContainerClass(className)
    local key = ibh.getContainerCatalogKey(className)
    if key == nil or ibh.containerCapacityCatalog[key] ~= nil then return false end
    ibh.containerCapacityCatalog[key] = {
        className = tostring(className),
        maxVolume = nil
    }
    return true
end

function ibh.getSavedContainerCapacity(className)
    local key = ibh.getContainerCatalogKey(className)
    local entry = key ~= nil and ibh.containerCapacityCatalog[key] or nil
    return entry ~= nil and tonumber(entry.maxVolume) or nil
end

function ibh.getCoreElementIds(coreElement)
    local ids = ibh.call(coreElement, "getElementIdList")
    if type(ids) ~= "table" then return nil end

    return ids
end

function ibh.getCoreElementName(localId)
    local coreElement = ibh.core
    local name = ibh.call(coreElement, "getElementNameById", localId)

    if name == nil or tostring(name) == "" then
        name = ibh.call(coreElement, "getElementDisplayNameById", localId)
    end

    if name == nil or tostring(name) == "" then
        name = ibh.call(coreElement, "getElementClassById", localId)
    end

    if name == nil or tostring(name) == "" then
        name = "Element " .. tostring(localId)
    end

    return name
end

function ibh.getCoreElementDisplayName(localId)
    local name = ibh.call(ibh.core, "getElementDisplayNameById", localId)
    if name == nil or tostring(name) == "" then
        name = ibh.call(ibh.core, "getElementClassById", localId)
    end
    return tostring(name or ("Element " .. tostring(localId)))
end

function ibh.getElementPositionKey(position)
    if type(position) ~= "table" then return "unknown" end

    local x = tonumber(position[1] or position.x) or 0
    local y = tonumber(position[2] or position.y) or 0
    local z = tonumber(position[3] or position.z) or 0

    return string.format("%.4f,%.4f,%.4f", x, y, z)
end

function ibh.getCoreElementSnapshot(localId)
    local className = tostring(
        ibh.call(ibh.core, "getElementClassById", localId) or ""
    )
    local position = ibh.call(ibh.core, "getElementPositionById", localId)
    local positionKey = ibh.getElementPositionKey(position)
    local classId = ibh.call(ibh.core, "getElementClassIdById", localId)
    local item = classId ~= nil and ibh.call(system, "getItem", classId) or nil
    local unitMass = tonumber(ibh.call(
        ibh.core,
        "getElementMassById",
        localId
    ))
    if unitMass == nil and type(item) == "table" then
        unitMass = tonumber(item.unitMass or item.mass)
    end

    return {
        id = localId,
        className = className,
        classId = classId,
        displayName = ibh.getCoreElementDisplayName(localId),
        unitMass = unitMass,
        position = position,
        positionKey = positionKey,
        identityKey = tostring(localId)
            .. "|" .. className
            .. "|" .. positionKey
    }
end

function ibh.getCoreElementSnapshots()
    local ids = ibh.getCoreElementIds(ibh.core)
    if ids == nil then return nil end

    local snapshots = {}
    local byId = {}

    for _, localId in ipairs(ids) do
        local snapshot = ibh.getCoreElementSnapshot(localId)
        snapshots[#snapshots + 1] = snapshot
        byId[localId] = snapshot
    end

    return snapshots, byId
end

function ibh.findTrackedElement(identityKey)
    for _, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements) do
            if type(element) == "table"
                and element.identityKey == identityKey then
                return element
            end
        end
    end

    return nil
end

function ibh.describeCoreElement(snapshot)
    snapshot.name = ibh.getCoreElementName(snapshot.id)
    snapshot.addedAt = system.getArkTime()
    snapshot.removed = false

    return snapshot
end

function ibh.refreshTrackedElements(currentById)
    for _, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements) do
            if type(element) == "table" and element.id ~= nil then
                local current = currentById[element.id]
                local isPresent = current ~= nil
                    and current.identityKey == element.identityKey
                element.removed = not isPresent

                if isPresent then
                    element.name = ibh.getCoreElementName(element.id)
                    element.unitMass = current.unitMass or element.unitMass
                end
            end
        end
    end
end

function ibh.getElementEllipseRadius(element)
    local mass = tonumber(element.unitMass)
    if mass == nil or mass < 50 then return 0.3 end
    if mass < 150 then return 0.7 end
    if mass < 450 then return 1 end
    if mass < 1000 then return 1.5 end
    if mass < 15000 then return 2 end
    if mass < 100000 then return 3 end
    return 4
end

function ibh.formatElementMass(mass)
    mass = tonumber(mass)
    if mass == nil then return "?kg" end
    if mass >= 1000 then
        return ibh.formatNumber(mass / 1000) .. "t"
    end
    return ibh.formatNumber(mass) .. "kg"
end

function ibh.isIndustryClassName(className)
    local compact = string.lower(tostring(className or ""))
        :gsub("[%s_%-]", "")

    return string.find(compact, "industry", 1, true) ~= nil
end

function ibh.getFirstTableEntry(values)
    if type(values) ~= "table" then return nil end
    if type(values[1]) == "table" then return values[1] end

    for _, value in pairs(values) do
        if type(value) == "table" then return value end
    end

    return nil
end

function ibh.getItemDetails(itemId)
    local item = itemId ~= nil and ibh.call(system, "getItem", itemId) or nil
    if type(item) ~= "table" then
        return {
            id = itemId,
            name = "Item " .. tostring(itemId or "?"),
            className = "Unknown"
        }
    end

    local displayClassId = item.displayClassId or item.displayClassID
    local displayClass = displayClassId ~= nil
        and ibh.call(system, "getItem", displayClassId)
        or nil
    local className = type(displayClass) == "table"
        and (displayClass.displayName or displayClass.name)
        or item.type
        or item.className
        or "Unknown"

    return {
        id = itemId,
        name = tostring(item.displayName or item.name or itemId),
        className = tostring(className),
        unitVolume = tonumber(item.unitVolume),
        unitMass = tonumber(item.unitMass),
        iconPath = item.iconPath
    }
end

function ibh.recipeSupportsProducer(recipe, producerClassId)
    if producerClassId == nil or type(recipe.producers) ~= "table" then
        return false
    end

    for _, producer in pairs(recipe.producers) do
        local producerId = type(producer) == "table"
            and (producer.id or producer.itemId or producer[1])
            or producer

        if tostring(producerId) == tostring(producerClassId) then
            return true
        end
    end

    return false
end

function ibh.getRecipeIngredients(productId, producerClassId)
    local recipes = ibh.call(system, "getRecipes", productId)
    local recipe = ibh.getFirstTableEntry(recipes)
    local ingredients = {}

    if type(recipes) == "table" then
        for _, candidate in pairs(recipes) do
            if type(candidate) == "table"
                and ibh.recipeSupportsProducer(candidate, producerClassId) then
                recipe = candidate
                break
            end
        end
    end

    if type(recipe) ~= "table" or type(recipe.ingredients) ~= "table" then
        return ingredients, nil
    end

    local productionQuantity = nil

    if type(recipe.products) == "table" then
        for _, output in pairs(recipe.products) do
            if type(output) == "table" then
                local outputId = output.id or output.itemId or output[1]

                if tostring(outputId) == tostring(productId) then
                    productionQuantity = tonumber(
                        output.quantity or output.amount or output[2]
                    )
                    break
                end
            end
        end
    end

    for _, ingredient in pairs(recipe.ingredients) do
        if type(ingredient) == "table" then
            local itemId = ingredient.id or ingredient.itemId or ingredient[1]
            local details = ibh.getItemDetails(itemId)
            details.quantity = tonumber(
                ingredient.quantity or ingredient.amount or ingredient[2]
            )
            details.isMaterial = ibh.call(system, "isMaterialItem", itemId)
                or ibh.call(system, "isRawMaterialItem", itemId)
            ingredients[#ingredients + 1] = details
        end
    end

    table.sort(ingredients, function(left, right)
        return string.lower(left.name) < string.lower(right.name)
    end)
    return ingredients, productionQuantity
end

function ibh.getIndustryStateLabel(state)
    local labels = {
        [1] = "Stopped",
        [2] = "Running",
        [3] = "Missing ingredients",
        [4] = "Output full",
        [5] = "No output container",
        [6] = "Pending",
        [7] = "Missing schematic"
    }
    local number = tonumber(state)
    if number ~= nil then return labels[number] or ("State " .. number) end
    if state == nil or tostring(state) == "" then return "Unknown" end

    return tostring(state)
end

function ibh.getIndustryModeLabel(info, productionQuantity)
    local maintain = tonumber(info.maintainProductAmount)
    if maintain ~= nil and maintain > 0 then
        return "Maintain x" .. ibh.formatNumber(maintain)
    end

    local batches = tonumber(info.batchesRequested)
    if batches ~= nil and batches > 0 then
        local amount = batches * (tonumber(productionQuantity) or 1)
        return "Make x" .. ibh.formatNumber(amount)
    end

    return "Run"
end

function ibh.getIndustryRequestedAmount(info, productionQuantity)
    local maintain = tonumber(info.maintainProductAmount)
    if maintain ~= nil and maintain > 0 then return maintain end
    local batches = tonumber(info.batchesRequested)
    if batches ~= nil and batches > 0 then
        return batches * (tonumber(productionQuantity) or 1)
    end
    return nil
end

function ibh.getIndustryProductionMode(info)
    local maintain = tonumber(info.maintainProductAmount)
    if maintain ~= nil and maintain > 0 then
        return "maintain", maintain
    end
    local batches = tonumber(info.batchesRequested)
    if batches ~= nil and batches > 0 then return "make", nil end
    return "run", nil
end

function ibh.getIndustryDetails(element, includeRecipe)
    local info = ibh.call(ibh.core, "getElementIndustryInfoById", element.id)
    local currentProduct = type(info) == "table"
        and ibh.getFirstTableEntry(info.currentProducts)
        or nil
    local itemId = currentProduct ~= nil
        and (currentProduct.id or currentProduct.itemId or currentProduct[1])
        or nil

    if itemId == nil then
        return {
            state = type(info) == "table" and info.state or nil,
            statusLabel = ibh.getIndustryStateLabel(
                type(info) == "table" and info.state or nil
            ),
            product = nil
        }
    end

    local product = ibh.getItemDetails(itemId)
    local producerClassId = ibh.call(
        ibh.core,
        "getElementClassIdById",
        element.id
    )
    product.quantity = tonumber(
        currentProduct.quantity or currentProduct.amount or currentProduct[2]
    )
    local ingredients = {}
    local productionQuantity = product.quantity
    if includeRecipe ~= false then
        ingredients, productionQuantity = ibh.getRecipeIngredients(
            itemId,
            producerClassId
        )
    end
    product.ingredients = ingredients
    product.productionQuantity = productionQuantity or product.quantity
    local modeKind, maintainAmount = ibh.getIndustryProductionMode(info)

    return {
        state = info.state,
        statusLabel = ibh.getIndustryStateLabel(info.state),
        modeLabel = ibh.getIndustryModeLabel(info, product.productionQuantity),
        requestedAmount = ibh.getIndustryRequestedAmount(
            info,
            product.productionQuantity
        ),
        modeKind = modeKind,
        maintainAmount = maintainAmount,
        unitsProduced = tonumber(info.unitsProduced),
        currentProductionAmount = tonumber(info.currentProductionAmount),
        product = product
    }
end

function ibh.refreshTrackedIndustries()
    local runningIndustries = {}
    for _, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements) do
            if type(element) == "table"
                and not element.removed
                and ibh.isIndustryClassName(element.className) then
                element.industry = ibh.getIndustryDetails(element)
                if tonumber(element.industry.state) == 2 then
                    local key = tostring(element.id)
                    runningIndustries[key] = true
                    if not ibh.knownRunningIndustries[key] then
                        ibh.print(
                            "Industry working: "
                            .. ibh.getNameWithLocalId(element.name, element.id)
                        )
                    end
                end
            elseif type(element) == "table" then
                element.industry = nil
            end
        end
    end
    ibh.knownRunningIndustries = runningIndustries
end

function ibh.refreshArIndustries(snapshots)
    ibh.arIndustries = {}
    if not ibhArEnabled or type(snapshots) ~= "table" then return end

    local selectedProducts = {}
    for _, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements) do
            local product = type(element) == "table"
                and not element.removed
                and element.industry
                and element.industry.product
                or nil
            if product ~= nil and product.id ~= nil then
                selectedProducts[tostring(product.id)] = true
            end
        end
    end

    if next(selectedProducts) == nil then return end

    for _, snapshot in ipairs(snapshots) do
        if ibh.isIndustryClassName(snapshot.className) then
            local details = ibh.getIndustryDetails(snapshot, false)
            local product = details.product
            if product ~= nil and selectedProducts[tostring(product.id)] then
                snapshot.name = ibh.getCoreElementName(snapshot.id)
                snapshot.industry = details
                ibh.arIndustries[#ibh.arIndustries + 1] = snapshot
            end
        end
    end
end

function ibh.refreshArElements()
    ibh.arElements = {}
    if not ibhArEnabled then return end

    for _, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements or {}) do
            if type(element) == "table" and not element.removed
                and element.position ~= nil then
                ibh.arElements[#ibh.arElements + 1] = element
            end
        end
    end
end

function ibh.getConnectedElementIds(methodName, localId)
    local plugs = ibh.call(ibh.core, methodName, localId)
    local ids, seen, visited = {}, {}, {}
    local visitedCount = 0
    local idFields = {
        elementId = true, elementID = true, element_id = true,
        localId = true, localID = true, local_id = true, id = true,
        item = true
    }

    local function add(value)
        local id = tonumber(value)
        if id ~= nil and not seen[id] then
            seen[id] = true
            ids[#ids + 1] = id
        end
    end

    local function visit(value, depth)
        if depth > 4 or visitedCount >= 64 then return end
        if type(value) ~= "table" then add(value) return end
        if visited[value] then return end
        visited[value] = true
        visitedCount = visitedCount + 1

        add(value.elementId)
        add(value.elementID)
        add(value.element_id)
        add(value.localId)
        add(value.localID)
        add(value.local_id)
        add(value.id)

        for key, nested in pairs(value) do
            if type(nested) == "boolean" then
                if nested then add(key) end
            elseif type(nested) == "table" then
                visit(nested, depth + 1)
            elseif idFields[key]
                or (type(key) == "string"
                    and (string.find(key, "IN%-") ~= nil
                        or string.find(key, "OUT%-") ~= nil)) then
                add(nested)
            end
            visitedCount = visitedCount + 1
            if visitedCount >= 64 then break end
        end
    end

    if type(plugs) == "table" then visit(plugs, 0) end
    return ids
end

function ibh.findDirectLinkedElement(localId)
    local wantedId = tonumber(localId)
    for _, slot in ipairs(ibh.getSlots()) do
        local element = slot.element
        local elementId = ibh.call(element, "getLocalId")
        if element ~= nil and tonumber(elementId) == wantedId then
            return element, slot.name
        end
    end
    return nil, nil
end

function ibh.countTableEntries(values)
    if type(values) ~= "table" then return nil end
    local count = 0
    for _ in pairs(values) do count = count + 1 end
    return count
end

function ibh.getContainerHubCapacity(hubId, snapshotsById, visited)
    visited = visited or {}
    local visitKey = tostring(hubId)
    if visited[visitKey] then return 0 end
    visited[visitKey] = true

    local linkedIds, seen = {}, {}
    for _, methodName in ipairs({
        "getElementInPlugsById",
        "getElementOutPlugsById"
    }) do
        for _, linkedId in ipairs(ibh.getConnectedElementIds(
            methodName,
            hubId
        )) do
            local key = tostring(linkedId)
            if not seen[key] then
                seen[key] = true
                linkedIds[#linkedIds + 1] = linkedId
            end
        end
    end

    local total = 0
    for _, linkedId in ipairs(linkedIds) do
        local snapshot = snapshotsById[linkedId]
        if snapshot ~= nil and ibh.isContainerClassName(snapshot.className) then
            local capacity
            if ibh.isContainerHubClassName(snapshot.className) then
                capacity = ibh.getContainerHubCapacity(
                    linkedId,
                    snapshotsById,
                    visited
                )
            else
                capacity = tonumber(
                    ibh.directContainerCapacityById[tostring(linkedId)]
                )
                    or ibh.getSavedContainerCapacity(snapshot.className)
            end
            if capacity == nil then return nil end
            total = total + capacity
        end
    end
    return total
end

function ibh.collectOutputContainerInfo(
    containerId,
    snapshotsById,
    knownDirectElement,
    knownSlotName
)
    local snapshot = snapshotsById[containerId]
    if snapshot == nil or not ibh.isContainerClassName(snapshot.className) then
        return nil
    end

    local directElement, slotName = knownDirectElement, knownSlotName
    if directElement == nil then
        directElement, slotName = ibh.findDirectLinkedElement(containerId)
    end
    local info = {
        id = containerId,
        name = ibh.getCoreElementName(containerId),
        displayName = snapshot.displayName
            or ibh.getCoreElementDisplayName(containerId),
        className = snapshot.className,
        classId = snapshot.classId
            or ibh.call(ibh.core, "getElementClassIdById", containerId),
        position = snapshot.position,
        totalMass = snapshot.unitMass,
        inLinkCount = #ibh.getConnectedElementIds(
            "getElementInPlugsById",
            containerId
        ),
        outLinkCount = #ibh.getConnectedElementIds(
            "getElementOutPlugsById",
            containerId
        ),
        directSlot = slotName
    }

    if directElement ~= nil then
        info.selfMass = tonumber(ibh.call(directElement, "getSelfMass"))
        info.itemsMass = tonumber(ibh.call(directElement, "getItemsMass"))
        info.itemsVolume = tonumber(ibh.call(directElement, "getItemsVolume"))
        info.maxVolume = tonumber(ibh.call(directElement, "getMaxVolume"))
        info.content = ibh.call(directElement, "getContent")
    end
    if ibh.isContainerHubClassName(info.className) then
        info.maxVolume = ibh.getContainerHubCapacity(
            containerId,
            snapshotsById
        )
        info.capacityAssumed = true
    elseif info.maxVolume == nil then
        info.maxVolume = ibh.getSavedContainerCapacity(info.className)
        info.capacityAssumed = info.maxVolume ~= nil
    end
    if info.maxVolume ~= nil and info.itemsVolume ~= nil then
        info.freeVolume = math.max(0, info.maxVolume - info.itemsVolume)
    end
    return info
end

function ibh.getNameWithLocalId(name, localId)
    name = tostring(name or "Container")
    local idLabel = "[" .. tostring(localId) .. "]"
    if string.find(name, idLabel, 1, true) ~= nil then return name end
    return name .. " " .. idLabel
end

function ibh.printOutputContainerInfo(industry, container, relationLabel)
    local name = tostring(container.name or container.className or "Container")
    if #name > 24 then name = string.sub(name, 1, 22) .. ".." end
    ibh.print((relationLabel or "OUT linked") .. ": "
        .. ibh.getNameWithLocalId(name, container.id))
    ibh.print("class: " .. tostring(container.className or "?"))
    ibh.print("class id: " .. tostring(container.classId or "?"))

    local x, y, z = ibh.getVectorComponents(container.position)
    if x ~= nil then
        ibh.print(string.format("pos: %.1f, %.1f, %.1f", x, y, z))
    end
    ibh.print("mass: " .. ibh.formatElementMass(container.totalMass))
    ibh.print("plugs: IN " .. tostring(container.inLinkCount)
        .. " | OUT " .. tostring(container.outLinkCount))

    if container.directSlot == nil then
        if container.maxVolume ~= nil then
            ibh.print("capacity: ~" .. ibh.formatNumber(container.maxVolume)
                .. " L saved")
        else
            ibh.print("capacity: link container to PB")
        end
        return
    end

    ibh.print("PB slot: " .. tostring(container.directSlot))
    if container.maxVolume ~= nil then
        ibh.print("capacity: " .. ibh.formatNumber(container.maxVolume) .. " L")
    end
    if container.itemsVolume ~= nil then
        ibh.print("used: " .. ibh.formatNumber(container.itemsVolume)
            .. " L | free " .. ibh.formatNumber(container.freeVolume) .. " L")
    end
    if container.selfMass ~= nil or container.itemsMass ~= nil then
        ibh.print("mass self/items: "
            .. ibh.formatNumber(container.selfMass) .. "/"
            .. ibh.formatNumber(container.itemsMass) .. " kg")
    end
    local contentCount = ibh.countTableEntries(container.content)
    if contentCount ~= nil then
        ibh.print("cached content types: " .. tostring(contentCount))
        for key, entry in pairs(container.content) do
            local itemId, quantity
            if type(entry) == "table" then
                itemId = entry.id or entry.itemId or entry[1]
                quantity = entry.quantity or entry.amount or entry[2]
            elseif tonumber(entry) ~= nil then
                itemId = key
                quantity = entry
            end
            if itemId ~= nil then
                local item = ibh.getItemDetails(itemId)
                local itemName = tostring(item.name or itemId)
                if #itemName > 25 then
                    itemName = string.sub(itemName, 1, 23) .. ".."
                end
                ibh.print("item: " .. itemName .. " x"
                    .. ibh.formatNumber(quantity))
            end
        end
    else
        ibh.print("cached content: unavailable")
    end
end

function ibh.printPbContainerSummary(container)
    ibh.print(tostring(container.className or "?")
        .. " | " .. ibh.formatCompactVolume(container.maxVolume))
end

function ibh.printContainerCapacityDatabank()
    local entries = {}
    for _, entry in pairs(ibh.containerCapacityCatalog or {}) do
        entries[#entries + 1] = entry
    end
    local legacyEntries = ibh.legacyContainerCapacityRows or {}
    if #entries == 0 and #legacyEntries == 0 then return end
    ibh.print("DB container data:")
    table.sort(entries, function(left, right)
        return tostring(left.className) < tostring(right.className)
    end)
    for _, entry in ipairs(entries) do
        ibh.print("DB: " .. tostring(entry.className or "?")
            .. " | " .. ibh.formatCompactVolume(entry.maxVolume))
    end
    for _, entry in ipairs(legacyEntries) do
        ibh.print("DB old: " .. tostring(entry.label or "record"))
        ibh.print("max " .. ibh.formatCompactVolume(entry.maxVolume)
            .. " (ignored)")
    end
end

function ibh.recordUnknownContainerClasses(snapshotsById)
    local changed = false
    for _, snapshot in pairs(snapshotsById or {}) do
        if ibh.isContainerClassName(snapshot.className)
            and not ibh.isContainerHubClassName(snapshot.className) then
            changed = ibh.rememberUnknownContainerClass(snapshot.className)
                or changed
        end
    end
    if changed or ibh.containerCatalogNeedsMigration then
        ibh.saveContainerCapacities()
    end
end

function ibh.refreshLinkedPbContainers(snapshotsById, announce)
    local currentLinks = {}
    ibh.directContainerCapacityById = {}
    local announcedIds = {}
    local announcedContainers = {}
    local capacityChanged = false
    for _, slot in ipairs(ibh.getSlots()) do
        local element = slot.element
        local localId = tonumber(ibh.call(element, "getLocalId"))
        local snapshot = localId ~= nil and snapshotsById[localId] or nil
        if snapshot ~= nil and ibh.isContainerClassName(snapshot.className) then
            local key = slot.name .. ":" .. tostring(localId)
            currentLinks[key] = true
            local container = ibh.collectOutputContainerInfo(
                localId,
                snapshotsById,
                element,
                slot.name
            )
            if container ~= nil then
                if not ibh.isContainerHubClassName(container.className) then
                    ibh.directContainerCapacityById[tostring(localId)]
                        = container.maxVolume
                    capacityChanged = ibh.rememberContainerCapacity(
                        container.className,
                        container.maxVolume
                    ) or capacityChanged
                end
                if announce and not announcedIds[tostring(localId)] then
                    announcedContainers[#announcedContainers + 1] = container
                    announcedIds[tostring(localId)] = true
                end
            end
        end
    end
    ibh.knownPbContainerLinks = currentLinks
    if capacityChanged then ibh.saveContainerCapacities() end
    if #announcedContainers > 0 then
        ibh.print("Linked elements:")
        for _, container in ipairs(announcedContainers) do
            if ibh.isContainerHubClassName(container.className) then
                container.maxVolume = ibh.getContainerHubCapacity(
                    container.id,
                    snapshotsById
                )
            end
            ibh.printPbContainerSummary(container)
        end
    end
end

function ibh.refreshTrackedIndustryConnections(snapshotsById)
    local currentOutputLinks = {}
    local currentDirectLinks = {}
    for _, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements or {}) do
            if type(element) == "table" and not element.removed
                and element.industry ~= nil
                and ibh.isIndustryClassName(element.className) then
                local inputIds = ibh.getConnectedElementIds(
                    "getElementInPlugsById",
                    element.id
                )
                element.inputLinkIds = {}
                for _, inputId in ipairs(inputIds) do
                    element.inputLinkIds[tostring(inputId)] = true
                end

                element.outputContainers = {}
                for _, outputId in ipairs(ibh.getConnectedElementIds(
                    "getElementOutPlugsById",
                    element.id
                )) do
                    local container = ibh.collectOutputContainerInfo(
                        outputId,
                        snapshotsById
                    )
                    if container ~= nil then
                        element.outputContainers[#element.outputContainers + 1]
                            = container
                        local linkKey = tostring(element.id) .. ">"
                            .. tostring(outputId)
                        currentOutputLinks[linkKey] = true
                        if container.directSlot ~= nil then
                            currentDirectLinks[linkKey] = true
                        end
                    end
                end
            elseif type(element) == "table" then
                element.inputLinkIds = nil
                element.outputContainers = nil
            end
        end
    end
    ibh.knownIndustryOutputLinks = currentOutputLinks
    ibh.knownDirectOutputLinks = currentDirectLinks
end

function ibh.isContainerClassName(className)
    local compact = string.lower(tostring(className or ""))
        :gsub("[%s_%-]", "")
    return string.find(compact, "container", 1, true) ~= nil
end

function ibh.isContainerHubClassName(className)
    local compact = string.lower(tostring(className or ""))
        :gsub("[%s_%-]", "")
    return string.find(compact, "containerhub", 1, true) ~= nil
end

function ibh.isPotentialProductSource(className)
    local compact = string.lower(tostring(className or ""))
        :gsub("[%s_%-]", "")
    return string.find(compact, "industry", 1, true) ~= nil
        or string.find(compact, "transfer", 1, true) ~= nil
end

function ibh.getIngredientColors(neededList)
    local palette = {
        "95,155,175", "175,125,95", "125,165,105", "155,115,165",
        "180,155,85", "95,130,180", "170,105,115", "95,165,145"
    }
    local colors = {}
    table.sort(neededList, function(left, right)
        return string.lower(left.name) < string.lower(right.name)
    end)
    for index, ingredient in ipairs(neededList) do
        colors[tostring(ingredient.id)] = palette[(index - 1) % #palette + 1]
    end
    return colors
end

function ibh.addSourceFlow(scan, container, sourceId, product, details)
    if container == nil or not ibh.isContainerClassName(container.className)
        or product == nil or product.id == nil then return end

    local flow = scan.flowsByContainer[container.id]
    if flow == nil then
        flow = { snapshot = container, resources = {} }
        scan.flowsByContainer[container.id] = flow
    end
    local productKey = tostring(product.id)
    local resource = flow.resources[productKey]
    if resource == nil then
        resource = {
            id = product.id,
            name = product.name,
            unitVolume = tonumber(product.unitVolume),
            cycleQuantity = 0,
            unitsProduced = 0,
            producerCount = 0,
            producers = {},
            needed = scan.neededById[productKey] ~= nil,
            color = scan.colors[productKey]
        }
        flow.resources[productKey] = resource
    end
    if not resource.producers[sourceId] then
        resource.producers[sourceId] = {
            modeKind = details and details.modeKind or "run",
            maintainAmount = tonumber(details and details.maintainAmount),
            unitsProduced = tonumber(details and details.unitsProduced) or 0
        }
        resource.cycleQuantity = resource.cycleQuantity
            + (tonumber(product.quantity) or 0)
        resource.unitsProduced = resource.unitsProduced
            + (tonumber(details and details.unitsProduced) or 0)
        resource.producerCount = resource.producerCount + 1
    end
end

function ibh.estimateSourceResource(resource, container)
    local anyRun = false
    local allMaintain = resource.producerCount > 0
    local maximumMaintain = 0
    for _, producer in pairs(resource.producers or {}) do
        local modeKind = producer.modeKind or "run"
        if modeKind == "run" then anyRun = true end
        if modeKind ~= "maintain" then allMaintain = false end
        maximumMaintain = math.max(
            maximumMaintain,
            tonumber(producer.maintainAmount) or 0
        )
    end

    local maxVolume = tonumber(container.maxVolume)
        or ibh.getSavedContainerCapacity(container.className)
    local unitVolume = tonumber(resource.unitVolume)
    if anyRun and maxVolume ~= nil and unitVolume ~= nil and unitVolume > 0 then
        resource.estimatedQuantity = math.floor(maxVolume / unitVolume)
        resource.estimateKind = "run"
    elseif allMaintain and maximumMaintain > 0 then
        resource.estimatedQuantity = maximumMaintain
        resource.estimateKind = "maintain"
    else
        resource.estimatedQuantity = tonumber(resource.unitsProduced) or 0
        resource.estimateKind = "produced"
    end
end

function ibh.startSourceCandidateScan(snapshots)
    if type(snapshots) ~= "table" then return end
    if ibh.sourceScan ~= nil then
        ibh.pendingSourceSnapshots = snapshots
        return
    end

    local neededById, neededList = {}, {}
    for _, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements or {}) do
            local product = type(element) == "table" and not element.removed
                and element.industry and element.industry.product or nil
            for _, ingredient in ipairs(
                type(product) == "table" and product.ingredients or {}
            ) do
                local key = tostring(ingredient.id)
                if ingredient.id ~= nil and neededById[key] == nil then
                    neededById[key] = ingredient
                    neededList[#neededList + 1] = ingredient
                end
            end
        end
    end
    if #neededList == 0 then
        ibh.sourceCandidates = {}
        return
    end

    local snapshotsById = {}
    for _, snapshot in ipairs(snapshots) do
        snapshotsById[snapshot.id] = snapshot
    end
    ibh.sourceScan = {
        phase = "sources",
        cursor = 1,
        snapshots = snapshots,
        snapshotsById = snapshotsById,
        neededById = neededById,
        colors = ibh.getIngredientColors(neededList),
        productsBySourceId = {},
        flowsByContainer = {},
        candidates = {}
    }
end

function ibh.finishSourceCandidate(scan, containerId, flow)
    if ibh.isContainerHubClassName(flow.snapshot.className) then
        flow.snapshot.maxVolume = ibh.getContainerHubCapacity(
            containerId,
            scan.snapshotsById
        )
    end
    local neededResources, otherResources = {}, {}
    for _, resource in pairs(flow.resources) do
        ibh.estimateSourceResource(resource, flow.snapshot)
        if resource.needed then
            neededResources[#neededResources + 1] = resource
        else
            otherResources[#otherResources + 1] = resource
        end
    end
    if #neededResources == 0 then return end

    local function byName(left, right)
        return string.lower(left.name) < string.lower(right.name)
    end
    table.sort(neededResources, byName)
    table.sort(otherResources, byName)
    local resources = {}
    for _, resource in ipairs(neededResources) do
        resources[#resources + 1] = resource
    end
    for _, resource in ipairs(otherResources) do
        resources[#resources + 1] = resource
    end

    local snapshot = flow.snapshot
    snapshot.name = ibh.getCoreElementName(containerId)
    snapshot.inLinkCount = 0
    for _, inputId in ipairs(ibh.getConnectedElementIds(
        "getElementInPlugsById",
        containerId
    )) do
        if scan.snapshotsById[inputId] ~= nil then
            snapshot.inLinkCount = snapshot.inLinkCount + 1
        end
    end
    snapshot.outLinkCount = 0
    for _, outputId in ipairs(ibh.getConnectedElementIds(
        "getElementOutPlugsById",
        containerId
    )) do
        if scan.snapshotsById[outputId] ~= nil then
            snapshot.outLinkCount = snapshot.outLinkCount + 1
        end
    end
    snapshot.sourceResources = resources
    snapshot.neededResources = neededResources
    scan.candidates[#scan.candidates + 1] = snapshot
end

function ibh.advanceSourceCandidateScan()
    local scan = ibh.sourceScan
    if scan == nil then return end
    local budget = math.max(1, math.floor(
        tonumber(ibhSourceScanBatchSize) or 3
    ))

    while budget > 0 and ibh.sourceScan == scan do
        if scan.phase == "sources" then
            local source = scan.snapshots[scan.cursor]
            if source == nil then
                scan.phase, scan.cursor = "containers", 1
            else
                scan.cursor = scan.cursor + 1
                budget = budget - 1
                if ibh.isPotentialProductSource(source.className) then
                    local details = ibh.getIndustryDetails(source, false)
                    local product = details and details.product or nil
                    if product ~= nil and product.id ~= nil then
                        scan.productsBySourceId[source.id] = {
                            product = product,
                            details = details
                        }
                        for _, outputId in ipairs(ibh.getConnectedElementIds(
                            "getElementOutPlugsById",
                            source.id
                        )) do
                            ibh.addSourceFlow(
                                scan,
                                scan.snapshotsById[outputId],
                                source.id,
                                product,
                                details
                            )
                        end
                    end
                end
            end
        elseif scan.phase == "containers" then
            local container = scan.snapshots[scan.cursor]
            if container == nil then
                scan.flowIds = {}
                for containerId in pairs(scan.flowsByContainer) do
                    scan.flowIds[#scan.flowIds + 1] = containerId
                end
                scan.phase, scan.cursor = "finalize", 1
            else
                scan.cursor = scan.cursor + 1
                budget = budget - 1
                if ibh.isContainerClassName(container.className) then
                    for _, sourceId in ipairs(ibh.getConnectedElementIds(
                        "getElementInPlugsById",
                        container.id
                    )) do
                        local source = scan.productsBySourceId[sourceId]
                        if source ~= nil then
                            ibh.addSourceFlow(
                                scan,
                                container,
                                sourceId,
                                source.product,
                                source.details
                            )
                        end
                    end
                end
            end
        else
            local containerId = scan.flowIds[scan.cursor]
            if containerId == nil then
                table.sort(scan.candidates, function(left, right)
                    return string.lower(left.name) < string.lower(right.name)
                end)
                ibh.sourceCandidates = scan.candidates
                ibh.sourceScan = nil
                local pending = ibh.pendingSourceSnapshots
                ibh.pendingSourceSnapshots = nil
                if pending ~= nil then ibh.startSourceCandidateScan(pending) end
            else
                scan.cursor = scan.cursor + 1
                budget = budget - 1
                ibh.finishSourceCandidate(
                    scan,
                    containerId,
                    scan.flowsByContainer[containerId]
                )
            end
        end
    end
end

function ibh.startElementSearch(coreElement)
    if coreElement == nil then return false end

    ibh.core = coreElement
    local snapshots, byId = ibh.getCoreElementSnapshots()
    if byId == nil then return false end

    ibh.knownElementsById = byId
    ibh.refreshTrackedElements(byId)
    ibh.refreshTrackedIndustries()
    ibh.refreshLinkedPbContainers(byId, ibhDebugPbStartInfo)
    ibh.recordUnknownContainerClasses(byId)
    ibh.refreshTrackedIndustryConnections(byId)
    ibh.refreshArElements()
    ibh.startSourceCandidateScan(snapshots)
    unit.setTimer(
        "ibhNewElementSearch",
        math.max(1, tonumber(ibhNewElementSearchSeconds) or 3)
    )
    return true
end

function ibh.searchForNewElements()
    if ibh.core == nil or ibh.knownElementsById == nil then return end

    local snapshots, currentById = ibh.getCoreElementSnapshots()
    if snapshots == nil then return end
    local addedElements = {}

    ibh.refreshTrackedElements(currentById)

    for _, snapshot in ipairs(snapshots) do
        local previous = ibh.knownElementsById[snapshot.id]
        local isNewIdentity = previous == nil
            or previous.identityKey ~= snapshot.identityKey

        if isNewIdentity
            and ibh.findTrackedElement(snapshot.identityKey) == nil then
            addedElements[#addedElements + 1] = ibh.describeCoreElement(snapshot)
        end
    end

    ibh.knownElementsById = currentById

    if #addedElements > 0 then
        ibh.recordAddedElements(addedElements, system.getArkTime())
        ibh.debugElements("Added elements: " .. tostring(#addedElements))
    end

    ibh.refreshTrackedIndustries()
    ibh.refreshLinkedPbContainers(currentById)
    ibh.recordUnknownContainerClasses(currentById)
    ibh.refreshTrackedIndustryConnections(currentById)
    ibh.refreshArElements()
    ibh.startSourceCandidateScan(snapshots)
    ibh.saveTrackedElements()
end

function ibh.formatElapsed(seconds)
    local total = math.max(0, tonumber(seconds) or 0)

    if total < 60 then
        return tostring(math.floor(total)) .. " sec"
    end

    if total < 3600 then
        return string.format("%.1f min", total / 60)
    end

    if total < 86400 then
        return string.format("%.1f hours", total / 3600)
    end

    return string.format("%.1f days", total / 86400)
end

function ibh.escapeHtml(value)
    return tostring(value or "")
        :gsub("&", "&amp;")
        :gsub("<", "&lt;")
        :gsub(">", "&gt;")
        :gsub('"', "&quot;")
end

function ibh.getMedian(values)
    if #values == 0 then return nil end

    local sorted = {}
    for index, value in ipairs(values) do sorted[index] = value end
    table.sort(sorted)

    local middle = math.floor(#sorted / 2) + 1
    if #sorted % 2 == 1 then return sorted[middle] end

    return (sorted[middle - 1] + sorted[middle]) / 2
end

function ibh.getElementGroupGap()
    local median = ibh.getMedian(ibh.addedElementIntervals)
    if median == nil then return ibhElementGroupMinimumGapSeconds end

    return math.max(ibhElementGroupMinimumGapSeconds, median * 3)
end

function ibh.getAddedElementLabel(element)
    if type(element) ~= "table" then return tostring(element) end

    local label = tostring(
        element.name
        or element.displayName
        or element.className
        or element.id
        or "Unknown element"
    )

    if element.removed then
        label = label .. " (removed)"
    end

    return label
end

function ibh.recordAddedElements(elements, addedAt)
    if type(elements) ~= "table" or #elements == 0 then return end

    local timestamp = tonumber(addedAt) or system.getArkTime()
    local newest = ibh.addedElementGroups[1]
    local startNewGroup = newest == nil

    if newest ~= nil then
        local interval = math.max(0, timestamp - newest.lastAddedAt)
        startNewGroup = interval > ibh.getElementGroupGap()

        if not startNewGroup and interval > 0 then
            ibh.addedElementIntervals[#ibh.addedElementIntervals + 1] = interval
            if #ibh.addedElementIntervals > 20 then
                table.remove(ibh.addedElementIntervals, 1)
            end
        end
    end

    if startNewGroup then
        newest = {
            firstAddedAt = timestamp,
            lastAddedAt = timestamp,
            elements = {}
        }
        table.insert(ibh.addedElementGroups, 1, newest)

        while #ibh.addedElementGroups > 5 do
            table.remove(ibh.addedElementGroups)
        end
    end

    newest.lastAddedAt = timestamp
    for _, element in ipairs(elements) do
        newest.elements[#newest.elements + 1] = element
    end

    ibh.saveTrackedElements()
    ibh.updateHudClock()
end

function ibh.buildAddedElementsHtml()
    local colors = {
        { 112, 112, 255, 1.0 },
        { 148, 148, 255, 0.9 },
        { 184, 184, 255, 0.8 },
        { 219, 219, 255, 0.7 },
        { 231, 231, 231, 0.6 }
    }
    local html = [[
        <div style="height:8px;"></div>
        <div style="color:#dce9ef;">Last added elements</div>
    ]]

    if #ibh.addedElementGroups == 0 then
        return html .. [[
            <div style="margin-top:3px;color:rgba(210,220,225,0.65);">None</div>
        ]]
    end

    for groupIndex, group in ipairs(ibh.addedElementGroups) do
        local color = colors[groupIndex]
        html = html
            .. '<div style="margin-top:5px;color:rgba('
            .. table.concat({ color[1], color[2], color[3] }, ",")
            .. ',' .. tostring(color[4]) .. ');">'

        for _, element in ipairs(group.elements) do
            html = html
                .. '<div style="margin-top:2px;">'
                .. ibh.escapeHtml(ibh.getAddedElementLabel(element))
                .. '</div>'
        end

        html = html .. '</div>'
    end

    return html
end

function ibh.formatNumber(value)
    value = tonumber(value)
    if value == nil then return "-" end
    if math.abs(value - math.floor(value)) < 0.000001 then
        return tostring(math.floor(value))
    end

    return string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
end

function ibh.formatCompactVolume(value)
    value = tonumber(value)
    if value == nil then return "?L" end
    if math.abs(value) >= 1000 then
        return ibh.formatNumber(value / 1000) .. "kL"
    end
    return ibh.formatNumber(value) .. "L"
end

function ibh.getIngredientInputStatus(element, ingredient)
    local inputIds = element.inputLinkIds or {}
    local ingredientKey = tostring(ingredient.id)
    local linked, available = false, 0
    for _, candidate in ipairs(ibh.sourceCandidates or {}) do
        if inputIds[tostring(candidate.id)] then
            for _, resource in ipairs(candidate.sourceResources or {}) do
                if tostring(resource.id) == ingredientKey then
                    linked = true
                    available = available
                        + math.max(
                            0,
                            tonumber(resource.estimatedQuantity)
                                or tonumber(resource.unitsProduced)
                                or 0
                        )
                end
            end
        end
    end
    return linked, available
end

function ibh.isIndustryReadyForDone(element)
    local details = type(element) == "table" and element.industry or nil
    local product = details and details.product or nil
    if element == nil or element.removed or product == nil
        or tonumber(details.state) ~= 2
        or #(element.outputContainers or {}) == 0 then
        return false
    end

    for _, ingredient in ipairs(product.ingredients or {}) do
        local linked = ibh.getIngredientInputStatus(element, ingredient)
        if not linked then return false end
    end
    return true
end

function ibh.filterSourceCandidatesToTrackedNeeds()
    local neededById = {}
    for _, group in ipairs(ibh.addedElementGroups or {}) do
        for _, element in ipairs(group.elements or {}) do
            local product = type(element) == "table" and not element.removed
                and element.industry and element.industry.product or nil
            for _, ingredient in ipairs(
                type(product) == "table" and product.ingredients or {}
            ) do
                if ingredient.id ~= nil then
                    neededById[tostring(ingredient.id)] = true
                end
            end
        end
    end

    local candidates = {}
    for _, candidate in ipairs(ibh.sourceCandidates or {}) do
        local neededResources = {}
        for _, resource in ipairs(candidate.sourceResources or {}) do
            if neededById[tostring(resource.id)] then
                neededResources[#neededResources + 1] = resource
            end
        end
        candidate.neededResources = neededResources
        if #neededResources > 0 then
            candidates[#candidates + 1] = candidate
        end
    end
    ibh.sourceCandidates = candidates
end

function ibh.completeTrackedIndustry(localId)
    local removed = false
    for groupIndex = #ibh.addedElementGroups, 1, -1 do
        local group = ibh.addedElementGroups[groupIndex]
        for elementIndex = #(group.elements or {}), 1, -1 do
            local element = group.elements[elementIndex]
            if tostring(element.id) == tostring(localId)
                and ibh.isIndustryClassName(element.className) then
                table.remove(group.elements, elementIndex)
                removed = true
            end
        end
        if #(group.elements or {}) == 0 then
            table.remove(ibh.addedElementGroups, groupIndex)
        end
    end
    if not removed then return false end

    ibh.arDoneTarget = nil
    ibh.sourceScan = nil
    ibh.pendingSourceSnapshots = nil
    ibh.filterSourceCandidatesToTrackedNeeds()
    ibh.refreshTrackedIndustries()
    ibh.refreshTrackedIndustryConnections(ibh.knownElementsById or {})
    ibh.refreshArElements()
    ibh.saveTrackedElements()

    local snapshots = {}
    for _, snapshot in pairs(ibh.knownElementsById or {}) do
        snapshots[#snapshots + 1] = snapshot
    end
    ibh.startSourceCandidateScan(snapshots)
    ibh.cachedHudHtml = ibh.buildHudHtml()
    ibh.renderScreen()
    return true
end

function ibh.activateArDoneTarget()
    if ibh.pendingDoneTargetId ~= nil then return end
    local target = ibh.arDoneTarget
    ibh.arDoneTarget = nil
    if target ~= nil and ibh.isIndustryReadyForDone(target) then
        ibh.pendingDoneTargetId = target.id
        ibh.pressedDoneTargetId = tostring(target.id)
        ibh.renderScreen()
        unit.setTimer("ibhDoneClick", 0.3)
    end
end

function ibh.finishArDoneClick()
    local localId = ibh.pendingDoneTargetId
    ibh.pendingDoneTargetId = nil
    ibh.pressedDoneTargetId = nil
    if localId ~= nil then ibh.completeTrackedIndustry(localId) end
end

function ibh.buildIngredientHtml(ingredient, linked, available)
    local required = ibh.formatNumber(ingredient.quantity)
    if ingredient.isMaterial then required = required .. " L" end
    local checkColor = linked and "#86d99a" or "#89979d"
    local checkMark = linked and "&#9745;" or "&#9744;"
    local availableLabel = ibh.formatNumber(available or 0)

    return [[
        <div style="display:flex;align-items:center;
            min-height:20px;">
            <div style="width:36px;flex:none;color:]] .. checkColor .. [[;
                font-size:18px;font-weight:bold;line-height:20px;">
    ]] .. checkMark .. [[</div>
            <div style="flex:1;min-width:0;color:#c9e8f2;
                white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
    ]] .. ibh.escapeHtml(ingredient.name) .. [[</div>
            <div style="color:#e5f7ff;white-space:nowrap;">
    ]] .. ibh.escapeHtml(availableLabel) .. [[ / ]] .. ibh.escapeHtml(required) .. [[</div>
        </div>
    ]]
end

function ibh.buildIndustryOutputsHtml(element, product, details)
    local outputs = element.outputContainers or {}
    if #outputs == 0 then
        return [[
            <div style="color:#99aab0;">Output: not linked</div>
        ]]
    end

    local html = ""
    for _, container in ipairs(outputs) do
        local outputName = ibh.getNameWithLocalId(container.name, container.id)
        local maxVolume = tonumber(container.maxVolume)
        local capacityLabel = maxVolume ~= nil
            and ibh.formatCompactVolume(maxVolume)
            or "?L"
        html = html .. '<div style="display:flex;align-items:baseline;'
            .. 'color:#b9dce7;white-space:nowrap;">'
            .. '<div style="flex:1;min-width:0;overflow:hidden;'
            .. 'text-overflow:ellipsis;">Output: '
            .. ibh.escapeHtml(outputName) .. '</div>'
            .. '<div style="flex:none;margin-left:6px;color:#d9eef4;">'
            .. ibh.escapeHtml(capacityLabel) .. '</div></div>'

        if container.maxVolume ~= nil then
            local unitVolume = tonumber(product and product.unitVolume)
            if unitVolume ~= nil and unitVolume > 0 then
                local fitCount = math.floor(container.maxVolume / unitVolume)
                local fitVolume = fitCount * unitVolume
                local comparison = ibh.formatNumber(fitCount) .. " pcs: "
                    .. ibh.formatNumber(fitVolume) .. " L / "
                    .. ibh.formatNumber(container.maxVolume) .. " L"
                local batchQuantity = math.max(
                    1,
                    math.floor(tonumber(product.productionQuantity) or 1)
                )
                local suggestedCount = math.floor(
                    fitCount * 0.70 / batchQuantity
                ) * batchQuantity
                html = html .. '<div style="margin-top:2px;margin-left:12px;'
                    .. 'color:#a9c5ce;">'
                    .. ibh.escapeHtml(comparison) .. '</div>'
                    .. '<div style="margin-top:2px;margin-left:12px;'
                    .. 'color:#d7e8ed;">'
                    .. 'Suggest 70%: maintain ['
                    .. ibh.escapeHtml(ibh.formatNumber(suggestedCount))
                    .. ' pcs]</div>'
            end
        end
    end
    return html
end

function ibh.buildIndustryCardHtml(element)
    local details = element.industry or { product = nil }
    local product = details.product
    local isRunning = tonumber(details.state) == 2
    local statusLabel = details.statusLabel or "Unknown"
    local statusColor = isRunning and "#78e59a" or "#9eacb2"
    local html = [[
        <div style="margin-top:8px;padding:5px 6px;
            background:rgba(12,24,31,0.58);
            border:1px solid rgba(120,165,180,0.38);border-radius:3px;">
            <div style="display:flex;align-items:baseline;margin-bottom:5px;">
                <div style="flex:1;min-width:0;color:#9fcfff;overflow:hidden;
                    white-space:nowrap;text-overflow:ellipsis;">
    ]] .. ibh.escapeHtml(element.name) .. [[</div>
                <div style="flex:none;margin-left:6px;color:]] .. statusColor .. [[;
                    font-weight:bold;white-space:nowrap;">
    ]] .. ibh.escapeHtml(statusLabel) .. [[</div></div>
            <div style="margin-left:6px;">
    ]]

    if product == nil then
        return html .. [[
            <div style="color:rgba(220,230,235,0.7);">no product</div>
            </div>
        </div>
        ]]
    end

    html = html .. [[
    ]] .. ibh.buildIndustryOutputsHtml(element, product, details) .. [[
        <div style="margin-top:8px;color:#ffd36a;font-size:14px;">
    ]] .. ibh.escapeHtml(product.name) .. [[</div>
        <div style="margin-top:2px;color:#a9c5ce;">
    ]] .. ibh.escapeHtml(ibh.formatNumber(product.productionQuantity))
        .. [[ ]] .. ((tonumber(product.productionQuantity) or 0) == 1
            and "piece" or "pieces") .. [[: volume ]]
        .. ibh.escapeHtml(ibh.formatNumber(product.unitVolume))
        .. [[ L, mass ]] .. ibh.escapeHtml(ibh.formatNumber(product.unitMass))
        .. [[ kg</div>
        <div style="margin-top:6px;color:#dce9ef;">Input components</div>
        <div style="margin:3px 0 0 8px;padding:2px 0;">
    ]]

    if #product.ingredients == 0 then
        html = html .. [[
            <div style="margin-top:3px;color:rgba(210,220,225,0.65);">
                Recipe unavailable
            </div>
        ]]
    else
        for _, ingredient in ipairs(product.ingredients) do
            local linked, available = ibh.getIngredientInputStatus(
                element,
                ingredient
            )
            html = html .. ibh.buildIngredientHtml(
                ingredient,
                linked,
                available
            )
        end
    end

    return html .. "</div></div></div>"
end

function ibh.buildIndustriesHtml()
    local html = [[
        <div style="width:300px;padding:6px 10px;color:#ecf8ff;
            background:rgba(4,12,18,0.84);border-radius:4px;">
            <div style="color:#dce9ef;">Added industries</div>
    ]]
    local count = 0

    for _, group in ipairs(ibh.addedElementGroups) do
        for _, element in ipairs(group.elements) do
            if type(element) == "table"
                and not element.removed
                and ibh.isIndustryClassName(element.className) then
                count = count + 1
                html = html .. ibh.buildIndustryCardHtml(element)
            end
        end
    end

    if count == 0 then
        html = html .. [[
            <div style="margin-top:6px;color:rgba(210,220,225,0.65);">None</div>
        ]]
    end

    return html .. "</div>"
end

function ibh.getVectorComponents(value)
    if value == nil then return nil end

    local function read(index, key)
        local indexOk, indexValue = pcall(function()
            return value[index]
        end)
        if indexOk and tonumber(indexValue) ~= nil then
            return tonumber(indexValue)
        end

        local keyOk, keyValue = pcall(function()
            return value[key]
        end)
        return keyOk and tonumber(keyValue) or nil
    end

    local x, y, z = read(1, "x"), read(2, "y"), read(3, "z")
    if x == nil or y == nil or z == nil then return nil end
    return x, y, z
end

function ibh.vector(x, y, z)
    return { x = x, y = y, z = z }
end

function ibh.vectorDistance(left, right)
    local lx, ly, lz = ibh.getVectorComponents(left)
    local rx, ry, rz = ibh.getVectorComponents(right)
    if lx == nil or rx == nil then return math.huge end

    local dx, dy, dz = lx - rx, ly - ry, lz - rz
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function ibh.vectorAngleDegrees(left, right)
    local lx, ly, lz = ibh.getVectorComponents(left)
    local rx, ry, rz = ibh.getVectorComponents(right)
    if lx == nil or rx == nil then return 0 end

    local leftLength = math.sqrt(lx * lx + ly * ly + lz * lz)
    local rightLength = math.sqrt(rx * rx + ry * ry + rz * rz)
    if leftLength <= 0 or rightLength <= 0 then return 0 end

    local dot = (lx * rx + ly * ry + lz * rz)
        / (leftLength * rightLength)
    dot = math.max(-1, math.min(1, dot))
    return math.deg(math.acos(dot))
end

function ibh.updateAdaptiveAr()
    if ibh.startedAt == nil or not ibhArEnabled then return end

    local render = ibh.render
    local now = system.getArkTime()
    local cameraForward = ibh.call(system, "getCameraWorldForward")
    local playerPosition = ibh.call(player, "getPosition")
        or ibh.call(player, "getWorldPosition")
    if ibh.getVectorComponents(cameraForward) == nil then return end

    if render.lastCameraSampleAt ~= nil
        and render.lastCameraForward ~= nil then
        local elapsed = now - render.lastCameraSampleAt
        if elapsed > 0 then
            local angle = ibh.vectorAngleDegrees(
                render.lastCameraForward,
                cameraForward
            )
            local speed = angle / elapsed
            local smoothing = math.min(1, elapsed * 8)
            render.angularSpeed = render.angularSpeed
                + (speed - render.angularSpeed) * smoothing

            if render.lastPlayerPosition ~= nil
                and ibh.getVectorComponents(playerPosition) ~= nil then
                local playerSpeed = ibh.vectorDistance(
                    render.lastPlayerPosition,
                    playerPosition
                ) / elapsed
                render.playerSpeed = render.playerSpeed
                    + (playerSpeed - render.playerSpeed) * smoothing
            end
        end
    end

    render.lastCameraSampleAt = now
    render.lastCameraForward = cameraForward
    render.lastPlayerPosition = playerPosition

    local idleInterval = math.max(
        0.1,
        tonumber(ibhArIdleRefreshSeconds) or 0.2
    )
    local minimumInterval = math.max(
        0.02,
        math.min(
            idleInterval,
            tonumber(ibhArMinimumRefreshSeconds) or 0.033
        )
    )
    local fullSpeed = math.max(
        1,
        tonumber(ibhArFullSpeedDegreesPerSecond) or 45
    )
    local fullPlayerSpeed = math.max(
        0.1,
        tonumber(ibhArFullPlayerSpeedMetersPerSecond) or 5
    )
    local cameraMovement = render.angularSpeed / fullSpeed
    local playerMovement = render.playerSpeed / fullPlayerSpeed
    local movement = math.min(1, math.max(cameraMovement, playerMovement))
    local curveExponent = math.max(
        0.1,
        tonumber(ibhArMotionCurveExponent) or 0.5
    )
    local curvedMovement = movement ^ curveExponent
    local idleFrequency = 1 / idleInterval
    local maximumFrequency = 1 / minimumInterval
    local targetFrequency = idleFrequency
        + (maximumFrequency - idleFrequency) * curvedMovement
    local fpsReduction = ibhReduceArFrequencyOnFpsDrop
        and math.max(0, math.min(
            0.95,
            tonumber(ibh.performance.arFrequencyReduction) or 0
        ))
        or 0
    targetFrequency = math.max(
        0.5,
        targetFrequency * (1 - fpsReduction)
    )
    render.targetInterval = 1 / targetFrequency

    if render.lastRenderedAt == nil
        or now - render.lastRenderedAt >= render.targetInterval then
        ibh.renderScreen()
    end
end

function ibh.localDirectionToWorld(direction, right, forward, up)
    local x, y, z = ibh.getVectorComponents(direction)
    local rx, ry, rz = ibh.getVectorComponents(right)
    local fx, fy, fz = ibh.getVectorComponents(forward)
    local ux, uy, uz = ibh.getVectorComponents(up)
    if x == nil or rx == nil or fx == nil or ux == nil then return nil end

    return ibh.vector(
        rx * x + fx * y + ux * z,
        ry * x + fy * y + uy * z,
        rz * x + fz * y + uz * z
    )
end

function ibh.localPositionToWorld(position, origin, right, forward, up)
    local direction = ibh.localDirectionToWorld(position, right, forward, up)
    local ox, oy, oz = ibh.getVectorComponents(origin)
    if direction == nil or ox == nil then return nil end

    return ibh.vector(
        ox + direction.x,
        oy + direction.y,
        oz + direction.z
    )
end

function ibh.getConstructWorldFrame()
    local origin = ibh.call(construct, "getWorldPosition")
    local right = ibh.call(construct, "getWorldOrientationRight")
    local forward = ibh.call(construct, "getWorldOrientationForward")
    local up = ibh.call(construct, "getWorldOrientationUp")

    if ibh.getVectorComponents(origin) == nil
        or ibh.getVectorComponents(right) == nil
        or ibh.getVectorComponents(forward) == nil
        or ibh.getVectorComponents(up) == nil then
        return nil
    end

    return { origin = origin, right = right, forward = forward, up = up }
end

function ibh.getElementWorldGeometry(element, frame)
    local ellipseRadius = ibh.getElementEllipseRadius(element)
    local ellipseDiameter = ellipseRadius * 2
    local size = ibh.vector(ellipseDiameter, ellipseDiameter, ellipseDiameter)
    local originPosition = element.position
    local origin = ibh.localPositionToWorld(
        originPosition,
        frame.origin,
        frame.right,
        frame.forward,
        frame.up
    )
    if origin == nil then return nil end

    return {
        origin = origin,
        center = origin,
        right = frame.right,
        forward = frame.forward,
        up = frame.up,
        size = size
    }
end

function ibh.offsetWorldPoint(center, right, forward, up, x, y, z)
    local cx, cy, cz = ibh.getVectorComponents(center)
    local rx, ry, rz = ibh.getVectorComponents(right)
    local fx, fy, fz = ibh.getVectorComponents(forward)
    local ux, uy, uz = ibh.getVectorComponents(up)
    if cx == nil or rx == nil or fx == nil or ux == nil then return nil end

    return ibh.vector(
        cx + rx * x + fx * y + ux * z,
        cy + ry * x + fy * y + uy * z,
        cz + rz * x + fz * y + uz * z
    )
end

function ibh.projectWorldPoint(point)
    if point == nil then return nil end
    local projected = ibh.call(
        library,
        "getPointOnScreen",
        { point.x, point.y, point.z }
    )
    local x, y, z = ibh.getVectorComponents(projected)
    if x == nil or z == 0 then return nil end
    return { x = x, y = y, z = z }
end

function ibh.buildArDotHtml(
    worldPoint,
    color,
    diameter,
    ringOnly,
    screenWidth,
    screenHeight
)
    local point = ibh.projectWorldPoint(worldPoint)
    if point == nil then return "" end

    local fillAlpha = ringOnly and 0.08 or 0.95
    return '<div style="position:absolute;left:'
        .. string.format("%.6f", point.x * 100)
        .. '%;top:' .. string.format("%.6f", point.y * 100)
        .. '%;width:' .. tostring(diameter) .. 'px;height:'
        .. tostring(diameter) .. 'px;transform:translate(-50%,-50%);'
        .. 'box-sizing:border-box;border-radius:50%;background:rgba('
        .. color .. ',' .. tostring(fillAlpha) .. ');border:1px solid rgb('
        .. color .. ');box-shadow:0 0 6px rgba(' .. color .. ',0.9);"></div>'
end

function ibh.buildArEllipseHtml(geometry, screenWidth, screenHeight, opacity)
    local radiusRight = math.max(0.1, geometry.size.x / 2)
    local radiusForward = math.max(0.1, geometry.size.y / 2)
    local points = {}

    for index = 0, 15 do
        local angle = index / 16 * math.pi * 2
        local worldPoint = ibh.offsetWorldPoint(
            geometry.origin,
            geometry.right,
            geometry.forward,
            geometry.up,
            math.cos(angle) * radiusRight,
            math.sin(angle) * radiusForward,
            0
        )
        local point = ibh.projectWorldPoint(worldPoint)
        if point == nil then return "" end
        points[#points + 1] = string.format(
            "%.6f,%.6f",
            point.x * 100,
            point.y * 100
        )
    end

    return '<svg style="position:absolute;left:0;top:0;width:100%;height:100%;'
        .. 'overflow:visible;" viewBox="0 0 100 100" '
        .. 'preserveAspectRatio="none"'
        .. '"><polygon points="' .. table.concat(points, " ")
        .. '" fill="rgb(90,220,255)" fill-opacity="'
        .. string.format("%.2f", opacity * 0.12)
        .. '" stroke="rgb(90,220,255)" stroke-opacity="'
        .. string.format("%.2f", opacity)
        .. '" stroke-width="2" vector-effect="non-scaling-stroke"/></svg>'
end

function ibh.buildArWireframeBoxHtml(geometry, color, scale)
    local radius = math.max(0.1, geometry.size.x / 4) * (scale or 1)
    local corners = {}
    for zIndex = -1, 1, 2 do
        for yIndex = -1, 1, 2 do
            for xIndex = -1, 1, 2 do
                local worldPoint = ibh.offsetWorldPoint(
                    geometry.origin,
                    geometry.right,
                    geometry.forward,
                    geometry.up,
                    xIndex * radius,
                    yIndex * radius,
                    zIndex * radius
                )
                local point = ibh.projectWorldPoint(worldPoint)
                if point == nil then return "" end
                corners[#corners + 1] = {
                    x = point.x * 100,
                    y = point.y * 100
                }
            end
        end
    end

    local edges = {
        {1, 2}, {1, 3}, {2, 4}, {3, 4},
        {5, 6}, {5, 7}, {6, 8}, {7, 8},
        {1, 5}, {2, 6}, {3, 7}, {4, 8}
    }
    local lines = {}
    for _, edge in ipairs(edges) do
        local first, second = corners[edge[1]], corners[edge[2]]
        lines[#lines + 1] = string.format(
            '<line x1="%.6f" y1="%.6f" x2="%.6f" y2="%.6f"/>',
            first.x, first.y, second.x, second.y
        )
    end

    return '<svg style="position:absolute;left:0;top:0;width:100%;height:100%;'
        .. 'overflow:visible;" viewBox="0 0 100 100" '
        .. 'preserveAspectRatio="none"><g fill="none" stroke="rgb('
        .. tostring(color) .. ')" stroke-opacity="0.40" stroke-width="1" '
        .. 'vector-effect="non-scaling-stroke">'
        .. table.concat(lines) .. '</g></svg>'
end

function ibh.buildSourceMarkerHtml(candidate, geometry, showContainerName)
    local needed = candidate.neededResources or {}
    local primary = needed[1]
    local color = primary and primary.color or "135,165,175"
    local label = primary and primary.name or "Resource"
    local marker = ibh.buildArDotHtml(
        geometry.origin,
        color,
        13,
        false,
        0,
        0
    ) .. ibh.buildArDotHtml(
        geometry.origin,
        "235,245,248",
        19,
        true,
        0,
        0
    )
    local point = ibh.projectWorldPoint(geometry.origin)
    if point == nil then return marker end
    if showContainerName then return marker end

    return marker .. '<div style="position:absolute;left:'
        .. string.format("%.6f", point.x * 100)
        .. '%;top:' .. string.format("%.6f", point.y * 100)
        .. '%;transform:translate(12px,-50%);padding:3px 6px;'
        .. 'background:rgba(4,10,14,0.92);border:1px solid rgb(' .. color .. ');'
        .. 'color:rgb(' .. color .. ');font:normal 14px Arial,sans-serif;'
        .. 'text-shadow:0 1px 2px #000;box-shadow:0 0 4px rgba(0,0,0,0.8);'
        .. 'white-space:nowrap;">' .. ibh.escapeHtml(label) .. '</div>'
end

function ibh.getOutputAvailabilityColor(outLinks, resourceTypeCount, maximum)
    if outLinks >= maximum then return "225,80,75" end
    if 1 + outLinks + resourceTypeCount < maximum then
        return "90,205,115"
    end
    return "230,190,75"
end

function ibh.buildSourceLabelHtml(candidate, geometry, opacity)
    local point = ibh.projectWorldPoint(geometry.origin)
    if point == nil then return "" end
    local lines = {}

    for index, resource in ipairs(candidate.sourceResources or {}) do
        local amount = tonumber(resource.cycleQuantity)
        local produced = tonumber(resource.unitsProduced)
        local estimated = tonumber(resource.estimatedQuantity)
        local amountLabel
        if resource.estimateKind == "run" and estimated ~= nil then
            amountLabel = " ~" .. ibh.formatNumber(estimated) .. " assumed full"
        elseif resource.estimateKind == "maintain" and estimated ~= nil then
            amountLabel = " ~" .. ibh.formatNumber(estimated) .. " maintain"
        elseif produced ~= nil and produced > 0 then
            amountLabel = " ~" .. ibh.formatNumber(produced) .. " produced"
        elseif amount ~= nil and amount > 0 then
            amountLabel = " ~" .. ibh.formatNumber(amount) .. "/cycle"
        else
            amountLabel = " ~flow"
        end
        local color = resource.needed and resource.color or "165,175,180"
        local weight = index == 1 and "bold" or "normal"
        lines[#lines + 1] = '<div style="color:rgb(' .. tostring(color)
            .. ');font-weight:' .. weight .. ';">'
            .. ibh.escapeHtml(resource.name) .. amountLabel .. '</div>'
    end

    local maximumLinks = math.max(0, tonumber(ibhMaximumOutputLinks) or 20)
    local usedIn = math.max(0, tonumber(candidate.inLinkCount) or 0)
    local usedOut = math.max(0, tonumber(candidate.outLinkCount) or 0)
    local availableIn = math.max(0, maximumLinks - usedIn)
    local availableOut = math.max(0, maximumLinks - usedOut)
    local resourceTypeCount = #(candidate.sourceResources or {})
    local inputColor = "155,165,170"
    local outputColor = ibh.getOutputAvailabilityColor(
        usedOut,
        resourceTypeCount,
        maximumLinks
    )
    local primary = (candidate.neededResources or {})[1]
    local containerColor = primary and primary.color or "135,165,175"
    local containerName = ibh.getNameWithLocalId(
        candidate.name or "Container",
        candidate.id or "?"
    )
    local plugLines = '<div>plug IN : <span style="color:rgb('
        .. inputColor .. ');">available ' .. tostring(availableIn) .. '/'
        .. tostring(maximumLinks) .. '</span></div>'
        .. '<div>plug OUT: <span style="color:rgb(' .. outputColor
        .. ');">available ' .. tostring(availableOut) .. '/'
        .. tostring(maximumLinks) .. '</span></div>'
    local containerLine = '<div style="color:rgb(' .. tostring(containerColor)
        .. ');font-size:17px;font-weight:bold;line-height:19px;">'
        .. ibh.escapeHtml(containerName) .. '</div>'
        .. '<div style="height:1px;background:#87969c;margin:4px 0;"></div>'

    return '<div style="position:absolute;left:'
        .. string.format("%.6f", point.x * 100)
        .. '%;top:' .. string.format("%.6f", point.y * 100)
        .. '%;transform:translate(10px,-45px);opacity:'
        .. string.format("%.3f", opacity or 1) .. ';padding:3px 5px;'
        .. 'background:rgba(4,10,14,0.92);border-left:1px solid #82949c;'
        .. 'color:#e8f1f4;font:normal 14px Arial,sans-serif;'
        .. 'text-shadow:0 0 4px #000;white-space:nowrap;">'
        .. plugLines .. containerLine .. table.concat(lines) .. '</div>'
end

function ibh.buildArDiagnosticDotsHtml(geometry, screenWidth, screenHeight)
    local axisLength = 1
    local rightPoint = ibh.offsetWorldPoint(
        geometry.origin, geometry.right, geometry.forward, geometry.up,
        axisLength, 0, 0
    )
    local forwardPoint = ibh.offsetWorldPoint(
        geometry.origin, geometry.right, geometry.forward, geometry.up,
        0, axisLength, 0
    )
    local upPoint = ibh.offsetWorldPoint(
        geometry.origin, geometry.right, geometry.forward, geometry.up,
        0, 0, axisLength
    )

    return ibh.buildArDotHtml(
        geometry.origin, "255,70,70", 8, false, screenWidth, screenHeight
    ) .. ibh.buildArDotHtml(
        rightPoint, "80,255,110", 6, false, screenWidth, screenHeight
    ) .. ibh.buildArDotHtml(
        forwardPoint, "70,150,255", 6, false, screenWidth, screenHeight
    ) .. ibh.buildArDotHtml(
        upPoint, "245,90,255", 6, false, screenWidth, screenHeight
    )
end

function ibh.buildArMarkerHtml(element, geometry, screenWidth, screenHeight, showText)
    local marker = ibh.buildArDotHtml(
        geometry.center,
        "98,220,255",
        14,
        true,
        screenWidth,
        screenHeight
    )
    if not showText then return marker end

    local point = ibh.projectWorldPoint(geometry.center)
    if point == nil then return marker end

    local details = element.industry
    local product = details.product
    local info = ibh.escapeHtml(element.name)
        .. "<br>" .. ibh.escapeHtml(element.className)
        .. "<br>" .. ibh.escapeHtml(product.name)
        .. " | " .. ibh.escapeHtml(details.modeLabel or "Run")
        .. "<br>" .. ibh.escapeHtml(details.statusLabel or "Unknown")

    return marker .. '<div style="position:absolute;left:'
        .. string.format("%.1f", point.x * screenWidth)
        .. 'px;top:' .. string.format("%.1f", point.y * screenHeight)
        .. 'px;transform:translate(10px,-50%);'
        .. 'color:#dcf7ff;font:normal 12px Arial,sans-serif;'
        .. 'text-shadow:0 0 4px #000;white-space:nowrap;">'
        .. '<div style="padding:3px 5px;'
        .. 'background:rgba(3,12,18,0.64);border-left:1px solid #62dcff;">'
        .. info .. "</div></div>"
end

function ibh.buildArHtml()
    ibh.arDoneTarget = nil
    if not ibhArEnabled or type(ibh.arElements) ~= "table"
        or #ibh.arElements == 0 then return "" end

    local frame = ibh.getConstructWorldFrame()
    local cameraPosition = ibh.call(system, "getCameraWorldPos")
    local cameraForward = ibh.call(system, "getCameraWorldForward")
    local playerPosition = ibh.call(player, "getWorldPosition")
        or cameraPosition
    local screenWidth = tonumber(ibh.call(system, "getScreenWidth")) or 1920
    local screenHeight = tonumber(ibh.call(system, "getScreenHeight")) or 1080
    if frame == nil or ibh.getVectorComponents(playerPosition) == nil then
        return ""
    end

    local html = ""
    for _, element in ipairs(ibh.arElements) do
        local geometry = ibh.getElementWorldGeometry(element, frame)
        if geometry ~= nil and geometry.right ~= nil
            and geometry.forward ~= nil and geometry.up ~= nil then
            local ellipseDistance = math.max(
                0,
                tonumber(ibhArEllipseDistanceMeters) or 50
            )
            if ibh.vectorDistance(playerPosition, geometry.origin)
                <= ellipseDistance then
                html = html .. ibh.buildArEllipseHtml(
                    geometry,
                    screenWidth,
                    screenHeight,
                    0.8
                )
            end
            html = html .. ibh.buildArDotHtml(
                geometry.origin,
                "98,220,255",
                10,
                false,
                screenWidth,
                screenHeight
            )
        end
    end

    local sourceRenderItems = {}
    for _, candidate in ipairs(ibh.sourceCandidates or {}) do
        local geometry = ibh.getElementWorldGeometry(candidate, frame)
        if geometry ~= nil and geometry.right ~= nil
            and geometry.forward ~= nil and geometry.up ~= nil then
            local distance = ibh.vectorDistance(playerPosition, geometry.origin)
            sourceRenderItems[#sourceRenderItems + 1] = {
                candidate = candidate,
                geometry = geometry,
                distance = distance
            }
            local drawDistance = math.max(
                0,
                tonumber(ibhArEllipseDistanceMeters) or 50
            )
            if ibhShowArRectanglePrisms and distance <= drawDistance then
                for index, resource in ipairs(candidate.neededResources or {}) do
                    html = html .. ibh.buildArWireframeBoxHtml(
                        geometry,
                        resource.color,
                        1 + (index - 1) * 0.08
                    )
                end
            end
        end
    end

    local labelDistance = math.max(
        0,
        tonumber(ibhArSourceLabelDistanceMeters) or 30
    )
    table.sort(sourceRenderItems, function(left, right)
        if math.abs(left.distance - right.distance) < 0.001 then
            return tostring(left.candidate.id or "")
                < tostring(right.candidate.id or "")
        end
        return left.distance > right.distance
    end)
    for _, item in ipairs(sourceRenderItems) do
        html = html .. ibh.buildSourceMarkerHtml(
            item.candidate,
            item.geometry,
            item.distance <= labelDistance
        )
        if item.distance <= labelDistance then
            local opaqueDistance = math.min(5, labelDistance)
            local fadeRange = math.max(0.001, labelDistance - opaqueDistance)
            local approach = math.max(0, math.min(
                1,
                (labelDistance - item.distance) / fadeRange
            ))
            local opacity = item.distance <= opaqueDistance
                and 1
                or 0.40 + approach * 0.60
            html = html .. ibh.buildSourceLabelHtml(
                item.candidate,
                item.geometry,
                opacity
            )
        end
    end

    local doneItems = {}
    local readyDoneIds = {}
    for _, element in ipairs(ibh.arElements) do
        if ibh.isIndustryReadyForDone(element) then
            local elementKey = tostring(element.id)
            readyDoneIds[elementKey] = true
            local geometry = ibh.getElementWorldGeometry(element, frame)
            local distance = geometry ~= nil
                and ibh.vectorDistance(playerPosition, geometry.origin)
                or math.huge
            if geometry ~= nil and distance <= 10 then
                local buttonPoint = ibh.offsetWorldPoint(
                    geometry.origin,
                    geometry.right,
                    geometry.forward,
                    geometry.up,
                    0,
                    0,
                    0.8
                )
                local point = ibh.projectWorldPoint(buttonPoint)
                if point ~= nil and point.x >= 0 and point.x <= 1
                    and point.y >= 0 and point.y <= 1 then
                    local wallRightPoint = ibh.projectWorldPoint(
                        ibh.offsetWorldPoint(
                            buttonPoint,
                            geometry.right,
                            geometry.forward,
                            geometry.up,
                            1,
                            0,
                            0
                        )
                    )
                    local wallUpPoint = ibh.projectWorldPoint(
                        ibh.offsetWorldPoint(
                            buttonPoint,
                            geometry.right,
                            geometry.forward,
                            geometry.up,
                            0,
                            0,
                            1
                        )
                    )
                    local wallRadius = 120
                    for _, edgePoint in ipairs({ wallRightPoint, wallUpPoint }) do
                        if edgePoint ~= nil then
                            local dx = (edgePoint.x - point.x) * screenWidth
                            local dy = (edgePoint.y - point.y) * screenHeight
                            wallRadius = math.max(
                                wallRadius,
                                math.sqrt(dx * dx + dy * dy)
                            )
                        end
                    end
                    wallRadius = math.min(900, wallRadius)
                    local angle = math.huge
                    local cx, cy, cz = ibh.getVectorComponents(cameraPosition)
                    local bx, by, bz = ibh.getVectorComponents(buttonPoint)
                    if cx ~= nil and bx ~= nil
                        and ibh.getVectorComponents(cameraForward) ~= nil then
                        angle = ibh.vectorAngleDegrees(
                            cameraForward,
                            ibh.vector(bx - cx, by - cy, bz - cz)
                        )
                    end
                    doneItems[#doneItems + 1] = {
                        element = element,
                        point = point,
                        distance = distance,
                        angle = angle,
                        wallRadius = wallRadius
                    }
                    if not ibh.announcedDoneButtons[elementKey] then
                        ibh.announcedDoneButtons[elementKey] = true
                        ibh.print(
                            "DONE button drawn: "
                            .. ibh.getNameWithLocalId(element.name, element.id)
                        )
                    end
                end
            end
        end
    end
    for elementKey in pairs(ibh.announcedDoneButtons) do
        if not readyDoneIds[elementKey] then
            ibh.announcedDoneButtons[elementKey] = nil
        end
    end

    local selected = nil
    for _, item in ipairs(doneItems) do
        if item.angle <= 2.5 and (selected == nil
            or item.angle < selected.angle
            or (math.abs(item.angle - selected.angle) < 0.001
                and item.distance < selected.distance)) then
            selected = item
        end
    end
    if selected ~= nil then ibh.arDoneTarget = selected.element end

    table.sort(doneItems, function(left, right)
        return left.distance > right.distance
    end)
    for _, item in ipairs(doneItems) do
        local active = selected == item
        local pressed = tostring(item.element.id)
            == tostring(ibh.pressedDoneTargetId)
        local background = pressed
            and "linear-gradient(180deg,rgba(18,90,55,0.98),rgba(5,42,27,0.98))"
            or active
            and "linear-gradient(180deg,rgba(92,225,145,0.98),rgba(25,125,72,0.98))"
            or "linear-gradient(180deg,rgba(30,115,76,0.96),rgba(5,45,31,0.96))"
        local border = active and "#b9ffd1" or "#67d99a"
        local shadow = pressed
            and "0 1px 0 rgba(2,28,19,0.98),0 3px 9px rgba(0,0,0,0.50),inset 0 3px 7px rgba(0,0,0,0.42)"
            or active
            and "0 5px 0 rgba(7,62,35,0.96),0 10px 24px rgba(65,255,150,0.42),inset 0 2px 0 rgba(255,255,255,0.42)"
            or "0 5px 0 rgba(2,28,19,0.98),0 10px 22px rgba(0,0,0,0.60),inset 0 2px 0 rgba(210,255,230,0.22)"
        local buttonTransform = pressed
            and "translate(-50%,-50%) translateY(5px)"
            or "translate(-50%,-50%)"
        local wallDiameter = item.wallRadius * 2
        html = html .. '<div style="position:absolute;left:'
            .. string.format("%.1f", item.point.x * screenWidth)
            .. 'px;top:' .. string.format("%.1f", item.point.y * screenHeight)
            .. 'px;width:' .. string.format("%.1f", wallDiameter)
            .. 'px;height:' .. string.format("%.1f", wallDiameter)
            .. 'px;transform:translate(-50%,-50%);border-radius:50%;'
            .. 'background:radial-gradient(circle,rgba(92,220,155,0.31) 0%,'
            .. 'rgba(65,165,120,0.24) 45%,rgba(35,105,80,0.175) 75%,'
            .. 'rgba(20,70,55,0) 100%);"></div>'
            .. '<div style="position:absolute;left:'
            .. string.format("%.1f", item.point.x * screenWidth)
            .. 'px;top:' .. string.format("%.1f", item.point.y * screenHeight)
            .. 'px;transform:' .. buttonTransform .. ';padding:9px 22px;'
            .. 'color:#effff5;background:' .. background .. ';border:2px solid '
            .. border .. ';border-radius:6px;font:bold 20px Arial,sans-serif;'
            .. 'letter-spacing:0.8px;box-shadow:' .. shadow .. ';'
            .. 'text-shadow:0 2px 3px #001b10;white-space:nowrap;">DONE</div>'
    end

    return html
end

function ibh.onSystemUpdate()
    local performance = ibh.performance
    local now = system.getArkTime()

    if ibh.render.refreshSampleStartedAt == nil then
        ibh.render.refreshSampleStartedAt = now
    else
        local refreshElapsed = now - ibh.render.refreshSampleStartedAt
        if refreshElapsed >= 1 then
            ibh.render.refreshHz = ibh.render.refreshCount / refreshElapsed
            ibh.render.refreshCount = 0
            ibh.render.refreshSampleStartedAt = now
        end
    end

    if performance.sampleStartedAt == nil then
        performance.sampleStartedAt = now
        performance.frameCount = 0
    end

    performance.frameCount = performance.frameCount + 1
    local elapsed = now - performance.sampleStartedAt
    if elapsed < 1 then return end

    performance.fps = performance.frameCount / elapsed
    performance.fpsHistory[#performance.fpsHistory + 1] = performance.fps
    while #performance.fpsHistory > 60 do
        table.remove(performance.fpsHistory, 1)
    end
    performance.arFrequencyReduction,
        performance.fpsReductionByWindow
        = ibh.getFpsFrequencyReduction(performance.fpsHistory)

    performance.frameCount = 0
    performance.sampleStartedAt = now
end

function ibh.getFpsColor(fps)
    if fps < 25 then return "255,100,100" end
    if fps < 40 then return "255,205,90" end
    return "100,225,255"
end

function ibh.getFpsAgeColor(ageSeconds)
    if ageSeconds >= 30 then return "165,165,165" end
    if ageSeconds >= 15 then return "185,200,215" end
    if ageSeconds >= 5 then return "155,215,255" end
    return "245,245,245"
end

function ibh.getRecentFpsAverage(history, seconds)
    if #history == 0 then return nil end

    local first = math.max(1, #history - seconds + 1)
    local total, count = 0, 0
    for index = first, #history do
        total = total + history[index]
        count = count + 1
    end

    return count > 0 and total / count or nil
end

function ibh.getFpsFrequencyReduction(history)
    if #history < 5 then return 0, {} end
    local recent = ibh.getRecentFpsAverage(history, 5)
    if recent == nil then return 0, {} end

    local reductions = {}
    local maximumReduction = 0
    for _, seconds in ipairs({ 15, 30, 60 }) do
        if #history >= seconds then
            local baseline = ibh.getRecentFpsAverage(history, seconds)
            local reduction = baseline ~= nil and baseline > 0
                and math.max(0, (baseline - recent) / baseline)
                or 0
            reductions[seconds] = reduction
            maximumReduction = math.max(maximumReduction, reduction)
        end
    end
    return math.min(0.95, maximumReduction), reductions
end

function ibh.buildPerformanceHtml()
    local now = system.getArkTime()
    if ibh.performance.cachedHtml ~= nil
        and ibh.performance.htmlBuiltAt ~= nil
        and now - ibh.performance.htmlBuiltAt < 1 then
        return ibh.performance.cachedHtml
    end

    local history = ibh.performance.fpsHistory
    local current = tonumber(ibh.performance.fps)
    local maximum = 60

    for _, fps in ipairs(history) do
        maximum = math.max(maximum, fps)
    end

    local scale = math.max(60, math.ceil(maximum / 30) * 30)
    local graphValues = {}
    local firstHistoryIndex = math.max(1, #history - 59)
    local historyIndex = firstHistoryIndex

    while historyIndex <= #history do
        local total, count = history[historyIndex], 1
        if historyIndex + 1 <= #history then
            total = total + history[historyIndex + 1]
            count = 2
        end
        graphValues[#graphValues + 1] = {
            fps = total / count,
            age = #history - historyIndex
        }
        historyIndex = historyIndex + 2
    end

    local lines = ""

    for index, value in ipairs(graphValues) do
        local x = #graphValues > 1
            and 2 + (index - 1) * 190 / (#graphValues - 1)
            or 192
        local height = math.max(1, math.min(56, value.fps / scale * 56))
        lines = lines .. string.format(
            '<line x1="%.1f" y1="73" x2="%.1f" y2="%.1f" '
                .. 'stroke="rgb(%s)" stroke-width="3"/>',
            x,
            x,
            73 - height,
            ibh.getFpsAgeColor(value.age)
        )
    end

    local currentLabel = current ~= nil
        and string.format("%.0f FPS", current)
        or "Measuring..."
    local function averageLabel(seconds)
        local average = ibh.getRecentFpsAverage(history, seconds)
        return average ~= nil and string.format("%.0f fps", average) or "- fps"
    end

    local averageLabels = string.format(
        '<text x="1" y="10" text-anchor="start" fill="rgb(%s)">%s</text>'
            .. '<text x="97" y="10" text-anchor="middle" fill="rgb(%s)">%s</text>'
            .. '<text x="146" y="10" text-anchor="middle" fill="rgb(%s)">%s</text>'
            .. '<text x="193" y="10" text-anchor="end" fill="rgb(%s)">%s</text>',
        ibh.getFpsAgeColor(60), averageLabel(60),
        ibh.getFpsAgeColor(30), averageLabel(30),
        ibh.getFpsAgeColor(15), averageLabel(15),
        ibh.getFpsAgeColor(5), averageLabel(5)
    )

    local html = [[
        <div style="position:absolute;right:32px;top:34%;width:210px;
            box-sizing:border-box;padding:7px 8px;color:#f2fbff;
            background:rgba(3,8,12,0.38);
            border-left:1px solid rgba(100,225,255,0.55);
            font:normal 12px Arial,sans-serif;text-shadow:0 0 5px #000;">
            <div style="display:flex;justify-content:space-between;">
                <span>Performance</span><span>]]
        .. ibh.escapeHtml(currentLabel) .. [[</span>
            </div>
            <div style="display:flex;justify-content:space-between;margin-top:3px;
                color:rgba(225,240,246,0.9);font-size:10px;">
                <span>Graph max ]] .. tostring(scale) .. [[ FPS</span>
                <span>AR ]] .. string.format("%.1f", ibh.render.refreshHz or 0)
        .. [[ Hz</span>
            </div>
            <svg width="194" height="74" viewBox="0 0 194 74"
                style="display:block;margin-top:4px;">
                <g style="font-family:Arial,sans-serif;font-size:9px;">
                    ]] .. averageLabels .. [[
                </g>
                <line x1="0" y1="73" x2="194" y2="73"
                    stroke="rgba(185,215,225,0.16)" stroke-width="1"/>
                ]] .. lines .. [[
            </svg>
            <div style="display:flex;justify-content:space-between;
                width:194px;box-sizing:border-box;padding:0 2px;
                color:rgba(225,240,246,0.8);font-size:9px;">
                <span>]] .. tostring(math.min(60, #history))
        .. [[ sec ago</span><span>now</span>
            </div>
        </div>
    ]]

    ibh.performance.cachedHtml = html
    ibh.performance.htmlBuiltAt = now
    return html
end

function ibh.buildHudHtml()
    local elapsed = system.getArkTime() - ibh.startedAt
    local label = ibh.formatElapsed(elapsed)

    return ibh.buildPerformanceHtml() .. [[
        <div style="
            position:absolute;
            top:18px;
            left:18px;
            display:flex;
            align-items:flex-start;
            gap:10px;
            font-family:Arial,sans-serif;
            font-size:12.6px;
            font-weight:normal;
            text-shadow:0 0 4px #000;
        ">
            <div style="width:190px;padding:6px 10px;color:#ecf8ff;
                background:rgba(4,12,18,0.72);
                border:1px solid rgba(90,210,255,0.8);border-radius:4px;">
                <div>PB uptime: ]] .. label .. [[</div>
                <div style="text-align:right;color:rgba(210,225,232,0.72);">
                    v]] .. ibh.escapeHtml(ibhVersion) .. [[
                </div>
    ]] .. ibh.buildAddedElementsHtml() .. [[
            </div>
    ]] .. ibh.buildIndustriesHtml() .. [[
        </div>
    ]]
end

function ibh.renderScreen()
    if ibh.startedAt == nil then return end
    if ibh.cachedHudHtml == nil then
        ibh.cachedHudHtml = ibh.buildHudHtml()
    end

    system.setScreen(ibh.buildArHtml() .. ibh.cachedHudHtml)
    ibh.render.lastRenderedAt = system.getArkTime()
    ibh.render.refreshCount = (ibh.render.refreshCount or 0) + 1
end

function ibh.updateHudClock()
    if ibh.startedAt == nil then return end

    ibh.cachedHudHtml = ibh.buildHudHtml()
    local lastRenderedAt = ibh.render.lastRenderedAt
    local now = system.getArkTime()
    if lastRenderedAt == nil or now - lastRenderedAt >= 0.05 then
        ibh.renderScreen()
    end
end
