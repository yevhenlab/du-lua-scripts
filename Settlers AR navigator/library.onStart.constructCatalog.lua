-- Discovers radar IDs quickly, enriches them incrementally, and exposes completed non-dynamic constructs as AR targets.
-- Library dependencies: SARN helpers from library.onStart.helpers.lua.
SARNConstructCatalog = SARNConstructCatalog or {}

local knownCoreSizes = { XS = true, S = true, M = true, L = true, XL = true, XXL = true }

local function normalizeCoreSize(value)
    local size = string.upper(tostring(value or "?")):gsub("%s+", "")
    return knownCoreSizes[size] and size or "?"
end

local function ownerIdFromEntity(entity)
    if type(entity) == "table" then return entity.id or entity[1] end
    return entity
end

local function pendingCount()
    return math.max(0, #SARNConstructCatalog.queue - SARNConstructCatalog.queueCursor + 1)
end

function SARNConstructCatalog.resolveOwnerName(ownerId)
    if ownerId == nil or tostring(ownerId) == "" then return "unknown owner" end
    local entityId = tonumber(ownerId) or ownerId
    local organization = system.getOrganization(entityId)
    if type(organization) == "table" then
        local organizationName = organization.name or organization.tag
        if organizationName ~= nil and tostring(organizationName) ~= "" then return tostring(organizationName) end
    end
    local playerName = system.getPlayerName(entityId)
    if playerName ~= nil and tostring(playerName) ~= "" then return tostring(playerName) end
    return tostring(ownerId)
end

function SARNConstructCatalog.rebuildReadyList()
    local list = {}
    for _, record in pairs(SARNConstructCatalog.byId) do
        if record.status == "ready" then list[#list + 1] = record end
    end
    table.sort(list, function(first, second)
        local firstName = string.lower(tostring(first.name or ""))
        local secondName = string.lower(tostring(second.name or ""))
        if firstName == secondName then return tostring(first.id) < tostring(second.id) end
        return firstName < secondName
    end)
    SARNConstructCatalog.list = list
end

function SARNConstructCatalog.refreshIds()
    local radar = SARNConstructCatalog.radar
    if radar == nil then
        SARNConstructCatalog.lastDetected = 0
        return { detected = 0, queued = pendingCount(), changed = false }
    end
    local ids = radar.getConstructIds() or {}
    local detected = 0
    for _, radarId in ipairs(ids) do
        detected = detected + 1
        local id = tostring(radarId)
        local record = SARNConstructCatalog.byId[id]
        if record == nil then
            record = { id = id, radarId = radarId, status = "pending" }
            SARNConstructCatalog.byId[id] = record
            SARNConstructCatalog.queue[#SARNConstructCatalog.queue + 1] = id
            SARNConstructCatalog.queuedById[id] = true
        else
            record.radarId = radarId
        end
        if record.status == "pending" and not SARNConstructCatalog.queuedById[id] then
            SARNConstructCatalog.queue[#SARNConstructCatalog.queue + 1] = id
            SARNConstructCatalog.queuedById[id] = true
        end
    end
    local changed = detected ~= SARNConstructCatalog.lastDetected
    SARNConstructCatalog.lastDetected = detected
    return { detected = detected, queued = pendingCount(), changed = changed }
end

function SARNConstructCatalog.processNext(maximumConstructs)
    local radar = SARNConstructCatalog.radar
    local maximum = math.max(1, math.floor(tonumber(maximumConstructs) or 1))
    local processed = 0
    if radar == nil then return { processed = 0, shouldReport = false } end

    while processed < maximum and SARNConstructCatalog.queueCursor <= #SARNConstructCatalog.queue do
        local id = SARNConstructCatalog.queue[SARNConstructCatalog.queueCursor]
        SARNConstructCatalog.queueCursor = SARNConstructCatalog.queueCursor + 1
        SARNConstructCatalog.queuedById[id] = nil
        local record = SARNConstructCatalog.byId[id]
        local radarId = record.radarId
        local constructKind = radar.getConstructKind(radarId)
        local kindName = string.lower(tostring(constructKind))
        processed = processed + 1
        SARNConstructCatalog.processedSinceStart = SARNConstructCatalog.processedSinceStart + 1
        SARNConstructCatalog.processedSinceReport = SARNConstructCatalog.processedSinceReport + 1

        if tonumber(constructKind) == 5 or string.find(kindName, "dynamic", 1, true) ~= nil then
            record.status = "dynamic"
        else
            local worldPosition = radar.getConstructWorldPos(radarId)
            local boundingBoxSize = radar.getConstructSize(radarId)
            local wx, wy, wz = SARN.components(worldPosition)
            local sx, sy, sz = SARN.components(boundingBoxSize)
            if wx ~= nil and wy ~= nil and wz ~= nil and sx ~= nil and sy ~= nil and sz ~= nil then
                local ownerId = ownerIdFromEntity(radar.getConstructOwnerEntity(radarId))
                record.name = tostring(radar.getConstructName(radarId) or "Unnamed construct")
                record.coreSize = normalizeCoreSize(radar.getConstructCoreSize(radarId))
                record.boundingBoxSize = { x = sx, y = sy, z = sz }
                record.worldPosition = { x = wx, y = wy, z = wz }
                record.ownerId = ownerId
                record.ownerName = SARNConstructCatalog.resolveOwnerName(ownerId)
                record.status = "ready"
            else
                record.status = "unavailable"
            end
        end
    end

    if SARNConstructCatalog.queueCursor > #SARNConstructCatalog.queue then
        SARNConstructCatalog.queue = {}
        SARNConstructCatalog.queueCursor = 1
    end
    SARNConstructCatalog.rebuildReadyList()
    local shouldReport = processed > 0 and (SARNConstructCatalog.processedSinceReport >= 50 or pendingCount() == 0)
    if shouldReport then SARNConstructCatalog.processedSinceReport = 0 end
    return { processed = processed, shouldReport = shouldReport, statistics = SARNConstructCatalog.getStatistics() }
end

function SARNConstructCatalog.initialize(radar)
    SARNConstructCatalog.radar = radar
    SARNConstructCatalog.byId = {}
    SARNConstructCatalog.list = {}
    SARNConstructCatalog.queue = {}
    SARNConstructCatalog.queueCursor = 1
    SARNConstructCatalog.queuedById = {}
    SARNConstructCatalog.lastDetected = -1
    SARNConstructCatalog.processedSinceStart = 0
    SARNConstructCatalog.processedSinceReport = 0
    return SARNConstructCatalog.refreshIds()
end

function SARNConstructCatalog.getTargets()
    local targets = {}
    for _, record in ipairs(SARNConstructCatalog.list or {}) do
        targets[#targets + 1] = {
            id = record.id,
            label = tostring(record.name) .. " " .. tostring(record.coreSize) .. " [" .. tostring(record.ownerName) .. "]",
            coreSize = record.coreSize,
            ownerId = record.ownerId,
            worldPosition = record.worldPosition,
            size = record.boundingBoxSize
        }
    end
    return targets
end

function SARNConstructCatalog.getStatistics()
    local statistics = {
        total = 0, XS = 0, S = 0, M = 0, L = 0, XL = 0, XXL = 0, unknown = 0,
        ids = 0, detected = SARNConstructCatalog.lastDetected or 0, pending = pendingCount(),
        dynamic = 0, unavailable = 0, processed = SARNConstructCatalog.processedSinceStart or 0
    }
    statistics.batch = SARNConstructCatalog.detailBatchSize or 0
    for _, record in pairs(SARNConstructCatalog.byId or {}) do
        statistics.ids = statistics.ids + 1
        if record.status == "ready" then
            statistics.total = statistics.total + 1
            local size = normalizeCoreSize(record.coreSize)
            if statistics[size] ~= nil then statistics[size] = statistics[size] + 1 else statistics.unknown = statistics.unknown + 1 end
        elseif record.status == "dynamic" then
            statistics.dynamic = statistics.dynamic + 1
        elseif record.status == "unavailable" then
            statistics.unavailable = statistics.unavailable + 1
        end
    end
    return statistics
end
