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

function SARNLocationCatalog.initialize()
    SARNLocationCatalog.targets = {}
    SARNLocationCatalog.allTargets = {}
    SARNLocationCatalog.runtimeIds = {}
    SARNLocationCatalog.nextRuntimeId = 1
    SARNLocationCatalog.statistics = { total = 0, byDepth = {} }
    SARNLocationCatalog.showSystemPlanets = SARNConfiguration.showSystemPlanets == true
    SARNLocationCatalog.showSatellites = SARNConfiguration.showSatellites == true
    SARNLocationCatalog.showCurrentNodeChildren =
        SARNConfiguration.showCurrentNodeChildren == true
    SARNLocationCatalog.showNearbyPlaces = SARNConfiguration.showNearbyPlaces == true

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

function SARNLocationCatalog.setShowCurrentNodeChildren(enabled)
    SARNLocationCatalog.showCurrentNodeChildren = enabled == true
    return SARNLocationCatalog.showCurrentNodeChildren
end

function SARNLocationCatalog.getShowCurrentNodeChildren()
    return SARNLocationCatalog.showCurrentNodeChildren == true
end

function SARNLocationCatalog.setShowNearbyPlaces(enabled)
    SARNLocationCatalog.showNearbyPlaces = enabled == true
    return SARNLocationCatalog.showNearbyPlaces
end

function SARNLocationCatalog.getShowNearbyPlaces()
    return SARNLocationCatalog.showNearbyPlaces == true
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
    for _, candidate in ipairs(SARNLocationCatalog.allTargets or {}) do
        for _, parentId in ipairs(candidate.parentIds or {}) do
            if parentId == target.id then
                children[#children + 1] = candidate
                break
            end
        end
    end
    table.sort(children, function(first, second)
        return string.lower(tostring(first.name)) < string.lower(tostring(second.name))
    end)
    return children
end

local function activationRadius(target)
    local radius = tonumber(target and target.areaRadius)
    if radius == nil or radius <= 0 then return nil end
    if type(target.atlasBody) ~= "table" then return radius end
    local systemId = target.atlasBody.systemId or target.atlasBody[1]
    local bodyId = target.atlasBody.bodyId or target.atlasBody[2]
    local atlas = SARN.getAtlas()
    local bodies = atlas and (atlas[systemId] or atlas[tostring(systemId)])
    local body = bodies and (bodies[bodyId] or bodies[tostring(bodyId)])
    local atmosphereRadius = body and tonumber(body.atmosphereRadius)
    local surfaceRadius = body and tonumber(body.radius) or radius
    return math.max(radius, surfaceRadius + 5000, atmosphereRadius or 0)
end

function SARNLocationCatalog.getCurrentTarget(playerPosition)
    local current = nil
    local currentDistance = nil
    for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
        local radius = activationRadius(target)
        local distance = radius ~= nil and SARN.distance(playerPosition, target.worldPosition) or nil
        if distance ~= nil and distance <= radius then
            local deeper = current == nil or (target.depth or 1) > (current.depth or 1)
            local nearer = current ~= nil and (target.depth or 1) == (current.depth or 1)
                and (currentDistance == nil or distance < currentDistance)
            if deeper or nearer then
                current = target
                currentDistance = distance
            end
        end
    end
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
    local maximum = math.max(1,
        math.floor(tonumber(SARNConfiguration.maximumNearbyPlaces) or 10))
    for index = 1, math.min(maximum, #candidates) do
        ids[candidates[index].target.id] = true
    end
    return ids
end

local function getAreaPlaceIds(current, playerPosition)
    if current == nil or not SARNLocationCatalog.getShowCurrentNodeChildren() then return {} end
    local candidates = {}
    for _, child in ipairs(SARNLocationCatalog.getChildren(current)) do
        if not child.excluded and child.worldPosition ~= nil and not isCelestial(child) then
            local distance = SARN.distance(playerPosition, child.worldPosition)
            if distance ~= nil then
                candidates[#candidates + 1] = { target = child, distance = distance }
            end
        end
    end
    return limitedNearestIds(candidates)
end

local function getNearbyTargetIds(current, playerPosition)
    local nearbyIds = {}
    if current == nil or not SARNLocationCatalog.getShowNearbyPlaces() then return nearbyIds end
    local inAtmosphere = (tonumber(unit.getAtmosphereDensity()) or 0) > 0
    local rangeKm = inAtmosphere and SARNConfiguration.nearbyAtmoRangeKm
        or SARNConfiguration.nearbySpaceRangeKm
    local rangeMeters = math.max(0, tonumber(rangeKm) or 0) * 1000
    local candidates = {}
    local visited = {}
    local function visitOrganizationalChildren(parent)
        if parent == nil or visited[parent.id] then return end
        visited[parent.id] = true
        for _, child in ipairs(SARNLocationCatalog.getChildren(parent)) do
            if child.worldPosition ~= nil then
                local distance = SARN.distance(playerPosition, child.worldPosition)
                if not child.excluded and not isCelestial(child)
                    and distance ~= nil and distance <= rangeMeters then
                    candidates[#candidates + 1] = { target = child, distance = distance }
                end
            else
                visitOrganizationalChildren(child)
            end
        end
    end
    visitOrganizationalChildren(current)
    return limitedNearestIds(candidates)
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
    local areaPlaceIds = getAreaPlaceIds(current, playerPosition)
    local nearbyIds = getNearbyTargetIds(current, playerPosition)
    local satelliteIds = getSatelliteIds(activeSystem, playerPosition)
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
        local isCurrent = current ~= nil and target.id == current.id
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
        if isCurrent or isParent or isSatellite or isAreaPlace or isNearby or isBaselineVisible then
            visible[#visible + 1] = target
        end
    end
    return visible, current
end

function SARNLocationCatalog.getStatistics()
    return SARNLocationCatalog.statistics or { total = 0, byDepth = {} }
end
