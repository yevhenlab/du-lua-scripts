-- Loads known SARN locations, resolves default kind icons and literal owner names, and assigns runtime-only IDs.
-- Library dependencies: SARN helpers, root locations injected by unit.onStart, sarn/icons.lua, and optional catalog modules.
SARNLocationCatalog = SARNLocationCatalog or {}

function SARNLocationCatalog.setRootConfig(config, loadError)
    SARNLocationCatalog.rootConfig = type(config) == "table" and config or nil
    SARNLocationCatalog.rootConfigError = loadError
end

local function normalizeCoreSize(value)
    local size = string.upper(tostring(value or "?")):gsub("%s+", "")
    return size ~= "" and size or "?"
end

local function normalizeKind(value)
    local kind = string.lower(tostring(value or "location")):gsub("%s+", "-")
    return kind ~= "" and kind or "location"
end

local function paleColor(color)
    local red, green, blue = tostring(color or ""):match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
    local defaultRed, defaultGreen, defaultBlue = tostring(SARNConfiguration.markerColor)
        :match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
    if red == nil or defaultRed == nil then return SARNConfiguration.markerColor end
    local factor = math.max(0, math.min(1, tonumber(SARNConfiguration.childColorPaleFactor) or 0.15))
    local function blend(value, target)
        return math.floor(tonumber(value) * (1 - factor) + tonumber(target) * factor + 0.5)
    end
    return tostring(blend(red, defaultRed)) .. ","
        .. tostring(blend(green, defaultGreen)) .. ","
        .. tostring(blend(blue, defaultBlue))
end

local currentAreaColor = "85,232,255"
local nearbyAreaColors = {
    "255,193,92", "174,133,255", "104,225,166", "255,126,153",
    "112,178,255", "241,145,89", "214,117,235", "155,214,87"
}

local function tintColor(color, amount)
    local red, green, blue = tostring(color or ""):match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    if red == nil then return color end
    local factor = math.max(0, math.min(1, tonumber(amount) or 0))
    local function tint(value)
        return math.floor(tonumber(value) + (255 - tonumber(value)) * factor + 0.5)
    end
    return tostring(tint(red)) .. "," .. tostring(tint(green)) .. "," .. tostring(tint(blue))
end

local function paletteStart(target)
    local key = tostring(target and (target.persistenceKey or target.id or target.name) or "")
    local hash = 0
    for index = 1, #key do hash = (hash * 33 + string.byte(key, index)) % 65521 end
    return hash % #nearbyAreaColors + 1
end

local function assignVisibilityColors(current, areaPlaceIds, nearbyInfo)
    for _, target in ipairs(SARNLocationCatalog.visibilityColoredTargets or {}) do
        target.visibilityColor = nil
    end
    local coloredTargets = {}
    SARNLocationCatalog.visibilityColoredTargets = coloredTargets
    local function setColor(target, color)
        if target == nil then return end
        if target.visibilityColor == nil then coloredTargets[#coloredTargets + 1] = target end
        target.visibilityColor = color
    end
    if current == nil then return end
    setColor(current, currentAreaColor)
    for targetId in pairs(areaPlaceIds or {}) do
        setColor(SARNLocationCatalog.getTargetById(targetId), tintColor(currentAreaColor, 0.32))
    end
    if type(nearbyInfo) ~= "table" then return end
    local colorsByAreaId = { [current.id] = currentAreaColor }
    local used = {}
    for _, contextInfo in ipairs(nearbyInfo.contexts or {}) do
        local area = contextInfo.target
        local color = colorsByAreaId[area.id]
        if color == nil then
            local start = paletteStart(area)
            local selected = start
            for offset = 0, #nearbyAreaColors - 1 do
                local candidate = (start + offset - 1) % #nearbyAreaColors + 1
                if not used[candidate] then selected = candidate break end
            end
            used[selected] = true
            color = nearbyAreaColors[selected]
            colorsByAreaId[area.id] = color
        end
        contextInfo.color = color
        setColor(area, color)
    end
    for targetId, areaId in pairs(nearbyInfo.selectedContextByTargetId or {}) do
        local areaColor = colorsByAreaId[areaId]
        if areaColor ~= nil then
            setColor(SARNLocationCatalog.getTargetById(targetId), tintColor(areaColor, 0.32))
        end
    end
end
function SARNLocationCatalog.initialize()
    SARNLocationCatalog.targets = {}
    SARNLocationCatalog.allTargets = {}
    SARNLocationCatalog.runtimeIds = {}
    SARNLocationCatalog.nextRuntimeId = 1
    SARNLocationCatalog.statistics = { total = 0, byDepth = {} }
    SARNLocationCatalog.showSystemPlanets = SARNConfiguration.showSystemPlanets == true
    SARNLocationCatalog.showSatellites = SARNConfiguration.showSatellites == true
    SARNLocationCatalog.showCurrentAreaPlaces =
        SARNConfiguration.showCurrentAreaPlaces == true
    SARNLocationCatalog.showNearbyAreas = SARNConfiguration.showNearbyAreas == true
    SARNLocationCatalog.showNearbyAreaPlaces =
        SARNConfiguration.showNearbyAreaPlaces == true

    local config = SARNLocationCatalog.rootConfig
    if type(config) ~= "table" then
        SARN.reportWarning("catalog-unavailable", "Could not load required Lua file 'sarn/locations.lua': "
            .. tostring(SARNLocationCatalog.rootConfigError or "invalid module result"))
        return false
    end
    local primaryLocations = config.locations or config
    if type(primaryLocations) ~= "table" then
        SARN.reportWarning("catalog-invalid", "sarn/locations.lua did not return a location list.")
        return false
    end
    local locations = {}
    for _, entry in ipairs(primaryLocations) do locations[#locations + 1] = entry end
    local kinds = {}
    if type(config.kinds) == "table" then
        for kind, definition in pairs(config.kinds) do kinds[kind] = definition end
    end
    if type(config.catalogModules) == "table" then
        for _, moduleName in ipairs(config.catalogModules) do
            local moduleOk, moduleConfig = pcall(require, tostring(moduleName))
            if moduleOk and type(moduleConfig) == "table" then
                local moduleLocations = moduleConfig.locations or moduleConfig
                if type(moduleLocations) == "table" then
                    for _, entry in ipairs(moduleLocations) do locations[#locations + 1] = entry end
                end
                if type(moduleConfig.kinds) == "table" then
                    for kind, definition in pairs(moduleConfig.kinds) do
                        if kinds[kind] == nil then kinds[kind] = definition end
                    end
                end
            else
                SARN.reportWarning("catalog-module-unavailable",
                    "Could not load optional Lua catalog '" .. tostring(moduleName) .. "'.")
            end
        end
    end

    local iconsOk, icons = pcall(require, "sarn/icons")
    if not iconsOk or type(icons) ~= "table" then
        icons = {}
        SARN.reportWarning("icons-unavailable", "Could not load required Lua file 'sarn/icons.lua'; using dot markers.")
    end
    local resolvedIcons = {}
    local function resolveIcon(iconName)
        if iconName == nil then return nil end
        if resolvedIcons[iconName] ~= nil then return resolvedIcons[iconName] or nil end
        local definition = icons[iconName]
        local scale = 1
        local seen = {}
        while type(definition) == "table" and definition.alias ~= nil and not seen[definition] do
            seen[definition] = true
            scale = scale * (tonumber(definition.scale) or 1)
            definition = icons[definition.alias]
        end
        if type(definition) == "table" and definition.viewBox ~= nil and definition.body ~= nil then
            resolvedIcons[iconName] = {
                viewBox = definition.viewBox,
                body = definition.body,
                scale = scale * (tonumber(definition.scale) or 1)
            }
            return resolvedIcons[iconName]
        end
        resolvedIcons[iconName] = false
        return nil
    end

    local targetsByRuntimeId = {}
    local function visitChildren(entry, visitor)
        if type(entry.children) == "table" then
            for _, child in ipairs(entry.children) do visitor(child) end
        end
        local moduleNames = {}
        if type(entry.childrenModule) == "string" then
            moduleNames[#moduleNames + 1] = entry.childrenModule
        end
        if type(entry.childrenModules) == "table" then
            for _, moduleName in ipairs(entry.childrenModules) do moduleNames[#moduleNames + 1] = moduleName end
        end
        for _, moduleName in ipairs(moduleNames) do
            local moduleOk, moduleConfig = pcall(require, moduleName)
            if moduleOk and type(moduleConfig) == "table" then
                if type(moduleConfig.kinds) == "table" then
                    for kind, definition in pairs(moduleConfig.kinds) do
                        if kinds[kind] == nil then kinds[kind] = definition end
                    end
                end
                local moduleKey = type(entry.childrenModuleKey) == "string"
                    and entry.childrenModuleKey or nil
                local moduleChildren
                if moduleKey ~= nil then
                    moduleChildren = moduleConfig[moduleKey]
                else
                    moduleChildren = moduleConfig.locations or moduleConfig.children or moduleConfig
                end
                if type(moduleChildren) == "table" then
                    for _, child in ipairs(moduleChildren) do visitor(child) end
                end
            else
                SARN.reportWarning("children-module-unavailable",
                    "Could not load child catalog '" .. tostring(moduleName) .. "'.")
            end
        end
    end

    local function loadEntry(entry, parentId, depth, parentColor)
        if type(entry) ~= "table" then return nil end
        local existingId = SARNLocationCatalog.runtimeIds[entry]
        if existingId ~= nil then
            local existingTarget = targetsByRuntimeId[existingId]
            if existingTarget ~= nil and parentId ~= nil then
                existingTarget.parentIds[#existingTarget.parentIds + 1] = parentId
            end
            local becameShallower = existingTarget ~= nil and depth < existingTarget.depth
            if becameShallower then
                existingTarget.depth = depth
                visitChildren(entry, function(child)
                    loadEntry(child, existingId, depth + 1, existingTarget.color)
                end)
            end
            return existingId
        end

        local runtimeId = SARNLocationCatalog.nextRuntimeId
        SARNLocationCatalog.nextRuntimeId = runtimeId + 1
        SARNLocationCatalog.runtimeIds[entry] = runtimeId
        local resolvedColor = entry.color ~= nil and tostring(entry.color)
            or (parentColor ~= nil and paleColor(parentColor) or SARNConfiguration.markerColor)
        local coordinate = entry.coordinate or entry.coordinates or entry.worldPosition or entry.pos
        local wx, wy, wz = SARN.components(coordinate)
        local upX, upY, upZ = SARN.components(entry.worldUp)
        local sx, sy, sz = SARN.components(entry.size or entry.boundingBoxSize)
        local owner = entry.owner ~= nil and tostring(entry.owner) or nil
        if owner == "" then owner = nil end
        local kind = normalizeKind(entry.kind)
        local kindConfiguration = type(kinds[kind]) == "table" and kinds[kind] or {}
        local coreSize = normalizeCoreSize(entry.coreSize)
        local icon = entry.icon or kindConfiguration.icon
        local parentTarget = parentId ~= nil and targetsByRuntimeId[parentId] or nil
        local persistenceSegment = kind .. ":" .. tostring(entry.name or ("Location " .. runtimeId))
        local persistenceKey = parentTarget ~= nil
            and (parentTarget.persistenceKey .. "/" .. persistenceSegment) or persistenceSegment
        local target = {
            id = runtimeId,
            persistenceKey = persistenceKey,
            depth = depth,
            parentIds = parentId ~= nil and { parentId } or {},
            name = entry.name or ("Location " .. tostring(runtimeId)),
            sourceId = entry.id,
            type = entry.type,
            kind = kind,
            icon = icon,
            iconDefinition = resolveIcon(icon),
            coreSize = coreSize,
            owner = owner,
            color = resolvedColor,
            sourceColor = entry.color,
            label = entry.label,
            description = entry.description,
            atlasBody = entry.atlasBody,
            radius = tonumber(entry.radius),
            areaRadius = tonumber(entry.areaRadius),
            sourceCoordinate = coordinate,
            excluded = entry.excluded == true,
            worldPosition = wx ~= nil and wy ~= nil and wz ~= nil and { x = wx, y = wy, z = wz } or nil,
            worldUp = upX ~= nil and upY ~= nil and upZ ~= nil
                and { x = upX, y = upY, z = upZ } or nil
        }
        if sx ~= nil and sy ~= nil and sz ~= nil then target.size = { x = sx, y = sy, z = sz } end
        targetsByRuntimeId[runtimeId] = target
        SARNLocationCatalog.allTargets[#SARNLocationCatalog.allTargets + 1] = target
        if not target.excluded then
            SARNLocationCatalog.statistics.total = SARNLocationCatalog.statistics.total + 1
            if target.worldPosition ~= nil then
                SARNLocationCatalog.targets[#SARNLocationCatalog.targets + 1] = target
            end
        end

        visitChildren(entry, function(child)
            loadEntry(child, runtimeId, depth + 1, resolvedColor)
        end)
        return runtimeId
    end

    for _, entry in ipairs(locations) do loadEntry(entry, nil, 1, nil) end

    local childrenByParentId = {}
    local function rebuildChildrenIndex()
        childrenByParentId = {}
        for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
            for _, parentId in ipairs(target.parentIds or {}) do
                childrenByParentId[parentId] = childrenByParentId[parentId] or {}
                childrenByParentId[parentId][#childrenByParentId[parentId] + 1] = target
            end
        end
        SARNLocationCatalog.childrenByParentId = childrenByParentId
    end
    rebuildChildrenIndex()
    local function calculateEnclosingEllipsoid(sources)
        if #sources == 0 then return nil, nil, nil, nil end
        if #sources == 1 then
            local source = sources[1]
            return { x = source.x, y = source.y, z = source.z },
                source.radiusX, source.radiusY, source.radiusZ
        end

        local minimumX, minimumY, minimumZ = math.huge, math.huge, math.huge
        local maximumX, maximumY, maximumZ = -math.huge, -math.huge, -math.huge
        for _, source in ipairs(sources) do
            local radiusX = math.max(0, tonumber(source.radiusX) or 0)
            local radiusY = math.max(0, tonumber(source.radiusY) or 0)
            local radiusZ = math.max(0, tonumber(source.radiusZ) or 0)
            minimumX = math.min(minimumX, source.x - radiusX)
            maximumX = math.max(maximumX, source.x + radiusX)
            minimumY = math.min(minimumY, source.y - radiusY)
            maximumY = math.max(maximumY, source.y + radiusY)
            minimumZ = math.min(minimumZ, source.z - radiusZ)
            maximumZ = math.max(maximumZ, source.z + radiusZ)
        end

        local center = {
            x = (minimumX + maximumX) * 0.5,
            y = (minimumY + maximumY) * 0.5,
            z = (minimumZ + maximumZ) * 0.5
        }
        local radiusX = (maximumX - minimumX) * 0.5
        local radiusY = (maximumY - minimumY) * 0.5
        local radiusZ = (maximumZ - minimumZ) * 0.5
        if radiusX <= 0 and radiusY <= 0 and radiusZ <= 0 then return center, nil, nil, nil end

        -- A line or plane still needs a visible three-dimensional cross-section.
        radiusX, radiusY, radiusZ = math.max(radiusX, 1), math.max(radiusY, 1), math.max(radiusZ, 1)

        -- Expand the parent to include every child ellipsoid's six axis extrema.
        -- A single child is returned unchanged, so hierarchy-only wrappers do not grow it.
        local requiredScale = 1
        local function includePoint(x, y, z)
            local dx = (x - center.x) / radiusX
            local dy = (y - center.y) / radiusY
            local dz = (z - center.z) / radiusZ
            requiredScale = math.max(requiredScale, math.sqrt(dx * dx + dy * dy + dz * dz))
        end
        for _, source in ipairs(sources) do
            local childRadiusX = math.max(0, tonumber(source.radiusX) or 0)
            local childRadiusY = math.max(0, tonumber(source.radiusY) or 0)
            local childRadiusZ = math.max(0, tonumber(source.radiusZ) or 0)
            includePoint(source.x - childRadiusX, source.y, source.z)
            includePoint(source.x + childRadiusX, source.y, source.z)
            includePoint(source.x, source.y - childRadiusY, source.z)
            includePoint(source.x, source.y + childRadiusY, source.z)
            includePoint(source.x, source.y, source.z - childRadiusZ)
            includePoint(source.x, source.y, source.z + childRadiusZ)
        end
        return center, radiusX * requiredScale, radiusY * requiredScale, radiusZ * requiredScale
    end

    local function calculateBounds(target, visiting, complete)
        if complete[target.id] then
            return target.boundsCenter, target.boundsRadiusX, target.boundsRadiusY,
                target.boundsRadiusZ, target.boundsSourceCount
        end
        if visiting[target.id] then return nil, nil, nil, nil, 0 end
        visiting[target.id] = true
        local sources = {}
        local sourceCount = 0
        for _, child in ipairs(childrenByParentId[target.id] or {}) do
            local childCenter, childRadiusX, childRadiusY, childRadiusZ, childCount =
                calculateBounds(child, visiting, complete)
            if childCenter ~= nil then
                sources[#sources + 1] = {
                    x = childCenter.x,
                    y = childCenter.y,
                    z = childCenter.z,
                    radiusX = childRadiusX or 0,
                    radiusY = childRadiusY or 0,
                    radiusZ = childRadiusZ or 0
                }
                sourceCount = sourceCount + (childCount or 0)
            end
        end
        if target.worldPosition ~= nil then
            local ownRadius = math.max(0, tonumber(target.areaRadius) or 0)
            sources[#sources + 1] = {
                x = target.worldPosition.x,
                y = target.worldPosition.y,
                z = target.worldPosition.z,
                radiusX = ownRadius,
                radiusY = ownRadius,
                radiusZ = ownRadius
            }
            sourceCount = sourceCount + 1
        end
        visiting[target.id] = nil
        complete[target.id] = true
        if #sources == 0 then
            target.boundsCenter = nil
            target.boundsRadiusX = nil
            target.boundsRadiusY = nil
            target.boundsRadiusZ = nil
            target.boundsSourceCount = 0
        else
            target.boundsCenter, target.boundsRadiusX, target.boundsRadiusY, target.boundsRadiusZ =
                calculateEnclosingEllipsoid(sources)
            target.boundsSourceCount = sourceCount
        end
        return target.boundsCenter, target.boundsRadiusX, target.boundsRadiusY,
            target.boundsRadiusZ, target.boundsSourceCount
    end
    local function refreshDisplayPositions()
        for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
            target.displayPosition = target.worldPosition or target.boundsCenter
        end
    end

    function SARNLocationCatalog.recalculateBounds()
        rebuildChildrenIndex()
        local visiting, complete = {}, {}
        for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
            calculateBounds(target, visiting, complete)
        end
        refreshDisplayPositions()
    end
    SARNLocationCatalog.recalculateBounds()
    for _, target in ipairs(SARNLocationCatalog.allTargets) do
        if not target.excluded and target.worldPosition == nil and target.displayPosition ~= nil then
            SARNLocationCatalog.targets[#SARNLocationCatalog.targets + 1] = target
        end
    end
    for _, target in ipairs(SARNLocationCatalog.allTargets) do
        if not target.excluded then
        local targetDepth = target.depth or 1
        SARNLocationCatalog.statistics.byDepth[targetDepth] =
            (SARNLocationCatalog.statistics.byDepth[targetDepth] or 0) + 1
        end
    end
    table.sort(SARNLocationCatalog.targets, function(first, second)
        return string.lower(tostring(first.name)) < string.lower(tostring(second.name))
    end)
    return true
end

function SARNLocationCatalog.getConfiguredTargets()
    return SARNLocationCatalog.targets or {}
end

function SARNLocationCatalog.setShowSystemPlanets(enabled)
    SARNLocationCatalog.showSystemPlanets = enabled == true
    return SARNLocationCatalog.showSystemPlanets
end

function SARNLocationCatalog.getShowSystemPlanets()
    return SARNLocationCatalog.showSystemPlanets == true
end

function SARNLocationCatalog.setShowSatellites(enabled)
    SARNLocationCatalog.showSatellites = enabled == true
    return SARNLocationCatalog.showSatellites
end

function SARNLocationCatalog.getShowSatellites()
    return SARNLocationCatalog.showSatellites == true
end

function SARNLocationCatalog.setShowCurrentAreaPlaces(enabled)
    SARNLocationCatalog.showCurrentAreaPlaces = enabled == true
    return SARNLocationCatalog.showCurrentAreaPlaces
end

function SARNLocationCatalog.getShowCurrentAreaPlaces()
    return SARNLocationCatalog.showCurrentAreaPlaces == true
end

function SARNLocationCatalog.setShowNearbyAreas(enabled)
    SARNLocationCatalog.showNearbyAreas = enabled == true
    return SARNLocationCatalog.showNearbyAreas
end

function SARNLocationCatalog.getShowNearbyAreas()
    return SARNLocationCatalog.showNearbyAreas == true
end

function SARNLocationCatalog.setShowNearbyAreaPlaces(enabled)
    SARNLocationCatalog.showNearbyAreaPlaces = enabled == true
    return SARNLocationCatalog.showNearbyAreaPlaces
end

function SARNLocationCatalog.getShowNearbyAreaPlaces()
    return SARNLocationCatalog.showNearbyAreaPlaces == true
end

function SARNLocationCatalog.getTargetById(targetId)
    for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
        if target.id == targetId then return target end
    end
    return nil
end

function SARNLocationCatalog.getTargetByPersistenceKey(persistenceKey)
    for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
        if target.persistenceKey == persistenceKey then return target end
    end
    return nil
end

function SARNLocationCatalog.getPrimaryParent(target)
    local parentId = target and target.parentIds and target.parentIds[1]
    return parentId ~= nil and SARNLocationCatalog.getTargetById(parentId) or nil
end

function SARNLocationCatalog.getNearestCoordinateBody(target)
    if target == nil then return nil end
    local queue = { target }
    local seen = {}
    local queueIndex = 1
    while queueIndex <= #queue do
        local candidate = queue[queueIndex]
        queueIndex = queueIndex + 1
        local candidateId = candidate and (candidate.id or candidate)
        if candidate ~= nil and not seen[candidateId] then
            seen[candidateId] = true
            if type(candidate.atlasBody) == "table"
                and candidate.worldPosition ~= nil
                and tonumber(candidate.areaRadius) ~= nil
                and tonumber(candidate.areaRadius) > 0 then
                return candidate
            end
            for _, parentId in ipairs(candidate.parentIds or {}) do
                local parent = SARNLocationCatalog.getTargetById(parentId)
                if parent ~= nil then queue[#queue + 1] = parent end
            end
        end
    end
    return nil
end

function SARNLocationCatalog.getNearestSystem(target)
    if target == nil then return nil end
    local queue = { target }
    local seen = {}
    local queueIndex = 1
    while queueIndex <= #queue do
        local candidate = queue[queueIndex]
        queueIndex = queueIndex + 1
        local candidateId = candidate and (candidate.id or candidate)
        if candidate ~= nil and not seen[candidateId] then
            seen[candidateId] = true
            if candidate.kind == "system" then return candidate end
            for _, parentId in ipairs(candidate.parentIds or {}) do
                local parent = SARNLocationCatalog.getTargetById(parentId)
                if parent ~= nil then queue[#queue + 1] = parent end
            end
        end
    end
    return nil
end

function SARNLocationCatalog.getChildren(target)
    local children = {}
    if target == nil then return children end
    for _, candidate in ipairs((SARNLocationCatalog.childrenByParentId or {})[target.id] or {}) do
        children[#children + 1] = candidate
    end
    table.sort(children, function(first, second)
        return string.lower(tostring(first.name)) < string.lower(tostring(second.name))
    end)
    return children
end

local function boundsContainmentDistance(target, playerPosition)
    local center = target and target.boundsCenter
    local radiusX = tonumber(target and target.boundsRadiusX)
    local radiusY = tonumber(target and target.boundsRadiusY)
    local radiusZ = tonumber(target and target.boundsRadiusZ)
    local px, py, pz = SARN.components(playerPosition)
    if center == nil or radiusX == nil or radiusY == nil or radiusZ == nil
        or radiusX <= 0 or radiusY <= 0 or radiusZ <= 0 or px == nil then return nil end
    local centerDistance = SARN.distance(playerPosition, center)
    if centerDistance == nil then return nil end
    -- Derived bounds use one consistent 75% outer entry margin.
    local entryScale = 1.75
    local dx = (px - center.x) / (radiusX * entryScale)
    local dy = (py - center.y) / (radiusY * entryScale)
    local dz = (pz - center.z) / (radiusZ * entryScale)
    if dx * dx + dy * dy + dz * dz > 1 then return nil end
    return centerDistance
end

local function currentContainmentDistance(target, playerPosition)
    return boundsContainmentDistance(target, playerPosition)
end

function SARNLocationCatalog.getCurrentTarget(playerPosition)
    local now = tonumber(SARN.call(system, "getArkTime")) or 0
    local cached = SARNLocationCatalog.currentTargetCache
    -- Current-area containment checks every catalog node. The short cache avoids
    -- repeating that full scan on every renderer frame while keeping transitions responsive.
    if cached ~= nil and now - cached.time < 0.15 then return cached.target end
    local current = nil
    local currentDistance = nil
    for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
        local isGroup = target.type == "group" or target.kind == "location-group"
        local distance = (not isGroup or SARNConfiguration.allowGroupsAsCurrentArea)
            and currentContainmentDistance(target, playerPosition) or nil
        if distance ~= nil then
            local deeper = current == nil or (target.depth or 1) > (current.depth or 1)
            local nearer = current ~= nil and (target.depth or 1) == (current.depth or 1)
                and (currentDistance == nil or distance < currentDistance)
            if deeper or nearer then
                current = target
                currentDistance = distance
            end
        end
    end
    SARNLocationCatalog.currentTargetCache = { time = now, target = current }
    return current
end

local function isDirectChildOf(target, parent)
    if target == nil or parent == nil then return false end
    for _, parentId in ipairs(target.parentIds or {}) do
        if parentId == parent.id then return true end
    end
    return false
end

local function isCelestial(target)
    local locationType = target and target.type
    return locationType == "space" or locationType == "system"
        or locationType == "planet" or locationType == "satellite"
        or locationType == "asteroid"
end

local function limitedNearestIds(candidates)
    table.sort(candidates, function(first, second)
        if first.distance == second.distance then
            return string.lower(tostring(first.target.name))
                < string.lower(tostring(second.target.name))
        end
        return first.distance < second.distance
    end)
    local ids = {}
    local ranks = {}
    local selected = {}
    local maximum = math.max(1,
        math.floor(tonumber(SARNConfiguration.maximumNearbyPlaces) or 10))
    for index = 1, math.min(maximum, #candidates) do
        local candidate = candidates[index]
        local id = candidate.target.id
        ids[id] = true
        ranks[id] = index - 1
        selected[#selected + 1] = candidate
    end
    return ids, ranks, selected
end

local function getAreaPlaceIds(current, playerPosition)
    if current == nil or not SARNLocationCatalog.getShowCurrentAreaPlaces() then
        return {}, {}, {}, 0, 0
    end
    local inAtmosphere = (tonumber(unit.getAtmosphereDensity()) or 0) > 0
    local rangeKm = inAtmosphere and SARNConfiguration.nearbyAtmoRangeKm
        or SARNConfiguration.nearbySpaceRangeKm
    local rangeMeters = math.max(0, tonumber(rangeKm) or 0) * 1000
    local rangeSquared = rangeMeters * rangeMeters
    local px, py, pz = SARN.components(playerPosition)
    local candidates = {}
    local total = 0
    local visited = {}
    local function visitChildren(parent)
        if parent == nil or visited[parent.id] then return end
        visited[parent.id] = true
        for _, child in ipairs(SARNLocationCatalog.getChildren(parent)) do
            local position = child.displayPosition
            if not child.excluded and position ~= nil and not isCelestial(child) then
                total = total + 1
                local x, y, z = SARN.components(position)
                if px ~= nil and x ~= nil then
                    local dx, dy, dz = x - px, y - py, z - pz
                    local squared = dx * dx + dy * dy + dz * dz
                    if squared <= rangeSquared then
                        candidates[#candidates + 1] = { target = child, distance = squared }
                    end
                end
            elseif position == nil then
                visitChildren(child)
            end
        end
    end
    visitChildren(current)
    local ids, ranks, selected = limitedNearestIds(candidates)
    return ids, ranks, selected, #candidates, total
end
local function getNearbyTargetIds(current, playerPosition)
    local nearbyIds = {}
    local nearbyRanks = {}
    if current == nil or (not SARNLocationCatalog.getShowNearbyAreas()
        and not SARNLocationCatalog.getShowNearbyAreaPlaces()) then
        return nearbyIds, nearbyRanks, nil, {}
    end
    local inAtmosphere = (tonumber(unit.getAtmosphereDensity()) or 0) > 0
    local rangeKm = inAtmosphere and SARNConfiguration.nearbyAtmoRangeKm
        or SARNConfiguration.nearbySpaceRangeKm
    local rangeMeters = math.max(0, tonumber(rangeKm) or 0) * 1000
    local rangeSquared = rangeMeters * rangeMeters
    local candidates = {}
    local contextIds = {}
    local nearbyInfo = {
        root = current,
        contexts = {},
        contextIds = contextIds,
        selectedContextByTargetId = {},
        contextTotal = 0,
        candidateCount = 0,
        selectedCount = 0,
        maximum = math.max(1,
            math.floor(tonumber(SARNConfiguration.maximumNearbyPlaces) or 10))
    }
    local px, py, pz = SARN.components(playerPosition)
    local function distanceSquared(position)
        local x, y, z = SARN.components(position)
        if px == nil or x == nil then return nil end
        local dx, dy, dz = x - px, y - py, z - pz
        return dx * dx + dy * dy + dz * dz
    end
    local function inspectChildren(parent, contextId, collectPlaces)
        local total = 0
        local inRange = 0
        for _, child in ipairs(SARNLocationCatalog.getChildren(parent)) do
            if not child.excluded and not isCelestial(child) then
                total = total + 1
                local squared = distanceSquared(child.displayPosition)
                if squared ~= nil and squared <= rangeSquared then
                    inRange = inRange + 1
                    if collectPlaces then
                        candidates[#candidates + 1] = {
                            target = child,
                            distance = squared,
                            contextId = contextId
                        }
                    end
                end
            end
        end
        return total, inRange
    end

    -- Nearby areas are non-celestial siblings of the current area. Their markers
    -- and their direct places are controlled independently, although both use
    -- the same inexpensive centre-distance preselection.
    local parent = not isCelestial(current) and SARNLocationCatalog.getPrimaryParent(current) or nil
    if parent ~= nil then
        nearbyInfo.root = parent
        local contextRange = rangeMeters * 2 * 1.2
        local contextRangeSquared = contextRange * contextRange
        local contextCandidates = {}
        for _, sibling in ipairs(SARNLocationCatalog.getChildren(parent)) do
            if not sibling.excluded and not isCelestial(sibling) then
                nearbyInfo.contextTotal = nearbyInfo.contextTotal + 1
                local squared = distanceSquared(sibling.displayPosition)
                if sibling.id == current.id
                    or (squared ~= nil and squared <= contextRangeSquared) then
                    contextCandidates[#contextCandidates + 1] = {
                        target = sibling,
                        distanceSquared = squared or 0
                    }
                end
            end
        end
        table.sort(contextCandidates, function(first, second)
            if first.target.id == current.id then return true end
            if second.target.id == current.id then return false end
            if first.distanceSquared == second.distanceSquared then
                return string.lower(tostring(first.target.name))
                    < string.lower(tostring(second.target.name))
            end
            return first.distanceSquared < second.distanceSquared
        end)
        for _, contextCandidate in ipairs(contextCandidates) do
            local context = contextCandidate.target
            local isCurrent = context.id == current.id
            local total, inRange = 0, 0
            if not isCurrent then
                total, inRange = inspectChildren(context, context.id,
                    SARNLocationCatalog.getShowNearbyAreaPlaces())
            end
            local markerEligible = not isCurrent and inRange > 0
            if markerEligible and SARNLocationCatalog.getShowNearbyAreas() then
                contextIds[context.id] = true
            end
            nearbyInfo.contexts[#nearbyInfo.contexts + 1] = {
                target = context,
                totalChildren = total,
                inRangeChildren = inRange,
                selectedChildren = 0,
                current = isCurrent,
                markerEligible = markerEligible
            }
        end
    end
    local ids, ranks, selected = limitedNearestIds(candidates)
    nearbyInfo.candidateCount = #candidates
    nearbyInfo.selectedCount = #selected
    local contextInfoById = {}
    for _, contextInfo in ipairs(nearbyInfo.contexts) do
        contextInfoById[contextInfo.target.id] = contextInfo
    end
    for _, candidate in ipairs(selected) do
        nearbyInfo.selectedContextByTargetId[candidate.target.id] = candidate.contextId
        local contextInfo = contextInfoById[candidate.contextId]
        if contextInfo ~= nil then
            contextInfo.selectedChildren = contextInfo.selectedChildren + 1
        end
    end
    return ids, ranks, nearbyInfo, contextIds
end
local function getClosestPlanet(systemTarget, playerPosition)
    if systemTarget == nil then return nil end
    local closest = nil
    local closestDistance = nil
    for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
        if target.type == "planet" and target.worldPosition ~= nil
            and isDirectChildOf(target, systemTarget) then
            local centerDistance = SARN.distance(playerPosition, target.worldPosition)
            local surfaceDistance = centerDistance ~= nil
                and math.abs(centerDistance - (tonumber(target.areaRadius) or 0)) or nil
            if surfaceDistance ~= nil
                and (closestDistance == nil or surfaceDistance < closestDistance) then
                closest = target
                closestDistance = surfaceDistance
            end
        end
    end
    return closest
end

local function getSatelliteIds(systemTarget, playerPosition)
    if not SARNLocationCatalog.getShowSatellites() then return {} end
    local planet = getClosestPlanet(systemTarget, playerPosition)
    local ids = {}
    for _, child in ipairs(SARNLocationCatalog.getChildren(planet)) do
        if not child.excluded and child.type == "satellite" then ids[child.id] = true end
    end
    return ids
end

function SARNLocationCatalog.getVisibleTargets(playerPosition)
    local current = SARNLocationCatalog.getCurrentTarget(playerPosition)
    local activeSystem = SARNLocationCatalog.getNearestSystem(current)
    local areaPlaceIds, areaPlaceRanks, areaPlaceSelected, areaPlaceInRange, areaPlaceTotal =
        getAreaPlaceIds(current, playerPosition)
    local nearbyIds, nearbyRanks, nearbyInfo, contextIds =
        getNearbyTargetIds(current, playerPosition)
    if current ~= nil and SARNLocationCatalog.getShowCurrentAreaPlaces() then
        if type(nearbyInfo) ~= "table" then
            nearbyInfo = {
                root = current,
                contexts = {},
                contextIds = {},
                selectedContextByTargetId = {},
                contextTotal = 1,
                candidateCount = 0,
                selectedCount = 0,
                maximum = math.max(1,
                    math.floor(tonumber(SARNConfiguration.maximumNearbyPlaces) or 10)),
                suppressContextSummary = true
            }
        end
        local currentInfo = nil
        for _, contextInfo in ipairs(nearbyInfo.contexts or {}) do
            if contextInfo.target.id == current.id then currentInfo = contextInfo break end
        end
        if currentInfo == nil then
            currentInfo = { target = current, current = true }
            table.insert(nearbyInfo.contexts, 1, currentInfo)
        end
        currentInfo.totalChildren = areaPlaceTotal or 0
        currentInfo.inRangeChildren = areaPlaceInRange or 0
        currentInfo.selectedChildren = #(areaPlaceSelected or {})
        for _, candidate in ipairs(areaPlaceSelected or {}) do
            nearbyInfo.selectedContextByTargetId[candidate.target.id] = current.id
        end
        nearbyInfo.candidateCount = (nearbyInfo.candidateCount or 0) + (areaPlaceInRange or 0)
        nearbyInfo.selectedCount = (nearbyInfo.selectedCount or 0) + #(areaPlaceSelected or {})
    end
    local visibleRanks = {}
    for targetId, rank in pairs(areaPlaceRanks or {}) do visibleRanks[targetId] = rank end
    for targetId, rank in pairs(nearbyRanks or {}) do visibleRanks[targetId] = rank end
    local satelliteIds = getSatelliteIds(activeSystem, playerPosition)
    assignVisibilityColors(current, areaPlaceIds, nearbyInfo)
    local visible = {}
    local parentIds = {}
    if current ~= nil then
        for _, parentId in ipairs(current.parentIds or {}) do parentIds[parentId] = true end
    end
    for _, target in ipairs(SARNLocationCatalog.targets or {}) do
        local isTopLevel = (target.depth or 1) == 1
        local isSystemPlanet = false
        for _, parentId in ipairs(target.parentIds or {}) do
            local parent = SARNLocationCatalog.getTargetById(parentId)
            if target.kind == "planet" and parent ~= nil and activeSystem ~= nil
                and parent.id == activeSystem.id then
                isSystemPlanet = true
            end
        end
        local currentAllowsParent = current ~= nil
            and current.kind ~= "planet" and current.kind ~= "system"
        local isParent = currentAllowsParent and parentIds[target.id] == true
        local isAreaPlace = areaPlaceIds[target.id] == true
        local isSatellite = satelliteIds[target.id] == true
        local isHighLevelHiddenByDefault = target.kind == "known-space"
            or target.kind == "system"
        local isBaselineVisible = false
        if isSystemPlanet then
            isBaselineVisible = SARNLocationCatalog.getShowSystemPlanets()
        elseif not isHighLevelHiddenByDefault then
            isBaselineVisible = isTopLevel
        end
        local isNearby = nearbyIds[target.id] == true
        local isContext = contextIds[target.id] == true
        if isParent or isSatellite or isAreaPlace
            or isNearby or isContext or isBaselineVisible then
            visible[#visible + 1] = target
        end
    end
    return visible, current, visibleRanks, nearbyInfo
end

function SARNLocationCatalog.getStatistics()
    return SARNLocationCatalog.statistics or { total = 0, byDepth = {} }
end
