-- Loads known SARN locations, resolves default kind icons and owner display names, and assigns runtime-only IDs.
-- Library dependencies: SARN helpers, sarn/locations.lua, and its optional catalog modules.
SARNLocationCatalog = SARNLocationCatalog or {}

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

function SARNLocationCatalog.resolveOwner(ownerId)
    if ownerId == nil or tostring(ownerId) == "" then return "owner", "unknown" end
    local entityId = tonumber(ownerId) or ownerId
    local organization = SARN.call(system, "getOrganization", entityId)
    if type(organization) == "table" then
        local organizationName = organization.name or organization.tag
        if organizationName ~= nil and tostring(organizationName) ~= "" then
            return "owner-org", tostring(organizationName)
        end
    end
    local playerName = SARN.call(system, "getPlayerName", entityId)
    if playerName ~= nil and tostring(playerName) ~= "" then return "owner-p", tostring(playerName) end
    return "owner", "unknown"
end

function SARNLocationCatalog.initialize()
    SARNLocationCatalog.targets = {}
    SARNLocationCatalog.allTargets = {}
    SARNLocationCatalog.runtimeIds = {}
    SARNLocationCatalog.nextRuntimeId = 1
    SARNLocationCatalog.statistics = { total = 0, byDepth = {} }

    local ok, config = pcall(require, "sarn/locations")
    if not ok or type(config) ~= "table" then
        SARN.reportWarning("catalog-unavailable", "Could not load required Lua file 'sarn/locations.lua'.")
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
                local moduleChildren = moduleConfig.locations or moduleConfig.children or moduleConfig
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
        if wx ~= nil and wy ~= nil and wz ~= nil then
            local sx, sy, sz = SARN.components(entry.size or entry.boundingBoxSize)
            local ownerType, ownerName = SARNLocationCatalog.resolveOwner(entry.ownerId)
            local kind = normalizeKind(entry.kind)
            local kindConfiguration = type(kinds[kind]) == "table" and kinds[kind] or {}
            local coreSize = normalizeCoreSize(entry.coreSize)
            local icon = entry.icon or kindConfiguration.icon
            local target = {
                id = runtimeId,
                depth = depth,
                parentIds = parentId ~= nil and { parentId } or {},
                name = entry.name or ("Location " .. tostring(runtimeId)),
                kind = kind,
                icon = icon,
                iconDefinition = resolveIcon(icon),
                coreSize = coreSize,
                constructId = entry.constructId,
                ownerId = entry.ownerId,
                ownerType = ownerType,
                ownerName = ownerName,
                color = resolvedColor,
                sourceColor = entry.color,
                label = entry.label,
                description = entry.description,
                atlasBody = entry.atlasBody,
                areaRadius = tonumber(entry.areaRadius),
                sourceCoordinate = coordinate,
                excluded = entry.excluded == true,
                worldPosition = { x = wx, y = wy, z = wz }
            }
            if sx ~= nil and sy ~= nil and sz ~= nil then target.size = { x = sx, y = sy, z = sz } end
            targetsByRuntimeId[runtimeId] = target
            SARNLocationCatalog.allTargets[#SARNLocationCatalog.allTargets + 1] = target
            if not target.excluded then
                SARNLocationCatalog.targets[#SARNLocationCatalog.targets + 1] = target
                SARNLocationCatalog.statistics.total = SARNLocationCatalog.statistics.total + 1
            end
        end

        visitChildren(entry, function(child)
            loadEntry(child, runtimeId, depth + 1, resolvedColor)
        end)
        return runtimeId
    end

    for _, entry in ipairs(locations) do loadEntry(entry, nil, 1, nil) end
    for _, target in ipairs(SARNLocationCatalog.targets) do
        local targetDepth = target.depth or 1
        SARNLocationCatalog.statistics.byDepth[targetDepth] =
            (SARNLocationCatalog.statistics.byDepth[targetDepth] or 0) + 1
    end
    table.sort(SARNLocationCatalog.targets, function(first, second)
        return string.lower(tostring(first.name)) < string.lower(tostring(second.name))
    end)
    return true
end

function SARNLocationCatalog.getConfiguredTargets()
    return SARNLocationCatalog.targets or {}
end

function SARNLocationCatalog.getTargetById(targetId)
    for _, target in ipairs(SARNLocationCatalog.allTargets or {}) do
        if target.id == targetId then return target end
    end
    return nil
end

function SARNLocationCatalog.getPrimaryParent(target)
    local parentId = target and target.parentIds and target.parentIds[1]
    return parentId ~= nil and SARNLocationCatalog.getTargetById(parentId) or nil
end

function SARNLocationCatalog.getChildren(target)
    local children = {}
    if target == nil then return children end
    for _, candidate in ipairs(SARNLocationCatalog.targets or {}) do
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

function SARNLocationCatalog.getVisibleTargets(playerPosition)
    local current = SARNLocationCatalog.getCurrentTarget(playerPosition)
    local visible = {}
    local parentIds = {}
    if current ~= nil then
        for _, parentId in ipairs(current.parentIds or {}) do parentIds[parentId] = true end
    end
    for _, target in ipairs(SARNLocationCatalog.targets or {}) do
        local isTopLevel = (target.depth or 1) == 1
        local isParent = current ~= nil and parentIds[target.id] == true
        local isCurrentChild = false
        if current ~= nil then
            for _, parentId in ipairs(target.parentIds or {}) do
                if parentId == current.id then
                    isCurrentChild = true
                    break
                end
            end
        end
        if isTopLevel or isParent or isCurrentChild then visible[#visible + 1] = target end
    end
    return visible, current
end

function SARNLocationCatalog.getStatistics()
    return SARNLocationCatalog.statistics or { total = 0, byDepth = {} }
end
