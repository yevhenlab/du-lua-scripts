-- Loads known SARN locations from sarn/constructs.lua and resolves their owner display names.
-- Library dependencies: SARN helpers from library.onStart.helpers.lua.
SARNConstructCatalog = SARNConstructCatalog or {}

local knownCoreSizes = { XS = true, S = true, M = true, L = true, XL = true }

local function normalizeCoreSize(value)
    local size = string.upper(tostring(value or "?")):gsub("%s+", "")
    return size ~= "" and size or "?"
end

function SARNConstructCatalog.resolveOwner(ownerId)
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

function SARNConstructCatalog.initialize()
    SARNConstructCatalog.targets = {}
    SARNConstructCatalog.statistics = {
        total = 0, XS = 0, S = 0, M = 0, L = 0, XL = 0, unknown = 0
    }
    local ok, config = pcall(require, "sarn/constructs")
    if not ok or type(config) ~= "table" then return false end
    for index, item in ipairs(config) do
        local entry = type(item) == "table" and item or { id = item }
        local id = tostring(entry.id or ("cfg_" .. tostring(index)))
        local wx, wy, wz = SARN.components(
            entry.coordinate or entry.coordinates or entry.worldPosition or entry.pos
        )
        if wx ~= nil and wy ~= nil and wz ~= nil then
            local sx, sy, sz = SARN.components(entry.size or entry.boundingBoxSize)
            local ownerType, ownerName = SARNConstructCatalog.resolveOwner(entry.ownerId)
            local coreSize = normalizeCoreSize(entry.coreSize)
            local target = {
                id = id,
                name = entry.name or ("Construct " .. id),
                coreSize = coreSize,
                ownerId = entry.ownerId,
                ownerType = ownerType,
                ownerName = ownerName,
                color = entry.color,
                label = entry.label,
                worldPosition = { x = wx, y = wy, z = wz }
            }
            if sx ~= nil and sy ~= nil and sz ~= nil then
                target.size = { x = sx, y = sy, z = sz }
            end
            SARNConstructCatalog.targets[#SARNConstructCatalog.targets + 1] = target
            SARNConstructCatalog.statistics.total = SARNConstructCatalog.statistics.total + 1
            if knownCoreSizes[coreSize] then
                SARNConstructCatalog.statistics[coreSize] = SARNConstructCatalog.statistics[coreSize] + 1
            else
                SARNConstructCatalog.statistics.unknown = SARNConstructCatalog.statistics.unknown + 1
            end
        end
    end
    table.sort(SARNConstructCatalog.targets, function(first, second)
        return string.lower(tostring(first.name)) < string.lower(tostring(second.name))
    end)
    return true
end

function SARNConstructCatalog.getConfiguredTargets()
    return SARNConstructCatalog.targets or {}
end

function SARNConstructCatalog.getStatistics()
    return SARNConstructCatalog.statistics or {
        total = 0, XS = 0, S = 0, M = 0, L = 0, XL = 0, unknown = 0
    }
end
