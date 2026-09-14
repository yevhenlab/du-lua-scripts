-- Loads, applies, and saves optional SARN runtime settings and pins in a linked Databank.
-- Library dependencies: SARN helpers, SARNConfiguration, SARNArDrawing, and the slots initializer injected by unit.onStart.
SARNSettings = SARNSettings or {}
SARNSettings.databankKey = "sarn:settings:v1"
SARNSettings.pinsDatabankKey = "sarn:pins:v1"

function SARNSettings.setSlotsInitializer(initializer)
    SARNSettings.initializeSlots = type(initializer) == "function" and initializer or nil
end

local function clampSetting(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
end

local function encode(value)
    return (tostring(value):gsub("([^%w%-%._~])", function(character)
        return string.format("%%%02X", string.byte(character))
    end))
end

local function decode(value)
    return (tostring(value):gsub("%%(%x%x)", function(hexadecimal)
        return string.char(tonumber(hexadecimal, 16))
    end))
end

function SARNSettings.findDatabank()
    local candidates = {}
    local seen = {}
    local function addCandidate(element, source)
        if type(element) == "table" and not seen[element] then
            seen[element] = true
            candidates[#candidates + 1] = { element = element, source = source }
        end
    end

    if type(SARNSettings.initializeSlots) == "function" then
        local initialized, slots = pcall(SARNSettings.initializeSlots, _G, unit, system)
        if initialized and type(slots) == "table"
            and type(slots.getLinkedElements) == "function" then
            local listed, elements = pcall(slots.getLinkedElements)
            if listed and type(elements) == "table" then
                for _, element in ipairs(elements) do addCandidate(element, "linked") end
            end
        end
    end
    for globalName, element in pairs(_G) do addCandidate(element, tostring(globalName)) end

    for _, candidate in ipairs(candidates) do
        local element = candidate.element
        if type(element.getStringValue) == "function"
            and type(element.setStringValue) == "function" then
            SARNSettings.databank = element
            SARNSettings.databankSlot = candidate.source
            return element
        end
    end
    SARNSettings.databank = nil
    SARNSettings.databankSlot = nil
    return nil
end

function SARNSettings.apply(values)
    if type(values) ~= "table" then return false end
    if values.detailsViewCloseDelaySeconds ~= nil then
        SARNConfiguration.detailsViewCloseDelaySeconds =
            clampSetting(values.detailsViewCloseDelaySeconds, 0.1, 10)
    end
    if values.showSystemPlanets ~= nil then
        SARNConfiguration.showSystemPlanets = values.showSystemPlanets == true
        if SARNLocationCatalog ~= nil
            and type(SARNLocationCatalog.setShowSystemPlanets) == "function" then
            SARNLocationCatalog.setShowSystemPlanets(SARNConfiguration.showSystemPlanets)
        end
    end
    if values.showSatellites ~= nil then
        SARNConfiguration.showSatellites = values.showSatellites == true
        if SARNLocationCatalog ~= nil
            and type(SARNLocationCatalog.setShowSatellites) == "function" then
            SARNLocationCatalog.setShowSatellites(SARNConfiguration.showSatellites)
        end
    end
    if values.showCurrentAreaPlaces ~= nil then
        SARNConfiguration.showCurrentAreaPlaces = values.showCurrentAreaPlaces == true
        if SARNLocationCatalog ~= nil
            and type(SARNLocationCatalog.setShowCurrentAreaPlaces) == "function" then
            SARNLocationCatalog.setShowCurrentAreaPlaces(
                SARNConfiguration.showCurrentAreaPlaces)
        end
    end
    if values.showNearbyAreas ~= nil then
        SARNConfiguration.showNearbyAreas = values.showNearbyAreas == true
        if SARNLocationCatalog ~= nil
            and type(SARNLocationCatalog.setShowNearbyAreas) == "function" then
            SARNLocationCatalog.setShowNearbyAreas(SARNConfiguration.showNearbyAreas)
        end
    end
    if values.showNearbyAreaPlaces ~= nil then
        SARNConfiguration.showNearbyAreaPlaces = values.showNearbyAreaPlaces == true
        if SARNLocationCatalog ~= nil
            and type(SARNLocationCatalog.setShowNearbyAreaPlaces) == "function" then
            SARNLocationCatalog.setShowNearbyAreaPlaces(
                SARNConfiguration.showNearbyAreaPlaces)
        end
    end
    if values.nearbyAtmoRangeKm ~= nil then
        nearbyAtmoRangeKm = math.floor(clampSetting(values.nearbyAtmoRangeKm, 1, 100000) + 0.5)
        SARNConfiguration.nearbyAtmoRangeKm = nearbyAtmoRangeKm
    end
    if values.nearbySpaceRangeKm ~= nil then
        nearbySpaceRangeKm = math.floor(clampSetting(values.nearbySpaceRangeKm, 1, 100000) + 0.5)
        SARNConfiguration.nearbySpaceRangeKm = nearbySpaceRangeKm
    end
    if values.maximumNearbyPlaces ~= nil then
        maximumNearbyPlaces = math.floor(clampSetting(values.maximumNearbyPlaces, 1, 100) + 0.5)
        SARNConfiguration.maximumNearbyPlaces = maximumNearbyPlaces
    end
    if values.showSarnHudPanel ~= nil then
        SARNConfiguration.showSarnHudPanel = values.showSarnHudPanel == true
    end
    if values.showVisibleMarkersHudPanel ~= nil then
        SARNConfiguration.showVisibleMarkersHudPanel =
            values.showVisibleMarkersHudPanel == true
    end
    if values.showPinnedLocationsHudPanel ~= nil then
        SARNConfiguration.showPinnedLocationsHudPanel =
            values.showPinnedLocationsHudPanel == true
    end
    if values.showOffscreenMarkersInHud ~= nil then
        SARNConfiguration.showOffscreenMarkersInHud =
            values.showOffscreenMarkersInHud == true
    end
    if values.hudFontSize ~= nil then
        hudFontSize = math.floor(clampSetting(values.hudFontSize, 9, 24) + 0.5)
        SARNConfiguration.hudFontSize = hudFontSize
    end
    if values.showAreaEntryNotifications ~= nil then
        SARNConfiguration.showAreaEntryNotifications =
            values.showAreaEntryNotifications == true
    end
    if values.showAreaExitNotifications ~= nil then
        SARNConfiguration.showAreaExitNotifications =
            values.showAreaExitNotifications == true
    end
    if values.allowGroupsAsCurrentArea ~= nil then
        SARNConfiguration.allowGroupsAsCurrentArea =
            values.allowGroupsAsCurrentArea == true
        if SARNLocationCatalog ~= nil then SARNLocationCatalog.currentTargetCache = nil end
    end
    if values.adaptArRedrawFrequencyToFps ~= nil then
        adaptArRedrawFrequencyToFps = values.adaptArRedrawFrequencyToFps == true
        SARNConfiguration.adaptArRedrawFrequencyToFps = adaptArRedrawFrequencyToFps
    end
    if values.maximumArRedrawPercentOfFps ~= nil then
        maximumArRedrawPercentOfFps = math.floor(
            clampSetting(values.maximumArRedrawPercentOfFps, 1, 100) + 0.5)
        SARNConfiguration.maximumArRedrawPercentOfFps = maximumArRedrawPercentOfFps
    end
    return true
end

function SARNSettings.getValues()
    local showPlanets = SARNConfiguration.showSystemPlanets
    if SARNLocationCatalog ~= nil then
        showPlanets = SARNLocationCatalog.getShowSystemPlanets()
    end
    local showCurrentAreaPlaces = SARNConfiguration.showCurrentAreaPlaces
    local showNearbyAreas = SARNConfiguration.showNearbyAreas
    local showNearbyAreaPlaces = SARNConfiguration.showNearbyAreaPlaces
    if SARNLocationCatalog ~= nil then
        showCurrentAreaPlaces = SARNLocationCatalog.getShowCurrentAreaPlaces()
        showNearbyAreas = SARNLocationCatalog.getShowNearbyAreas()
        showNearbyAreaPlaces = SARNLocationCatalog.getShowNearbyAreaPlaces()
    end
    local showMoons = SARNConfiguration.showSatellites
    if SARNLocationCatalog ~= nil then showMoons = SARNLocationCatalog.getShowSatellites() end
    return {
        detailsViewCloseDelaySeconds = SARNConfiguration.detailsViewCloseDelaySeconds,
        showSystemPlanets = showPlanets,
        showSatellites = showMoons,
        showCurrentAreaPlaces = showCurrentAreaPlaces,
        showNearbyAreas = showNearbyAreas,
        showNearbyAreaPlaces = showNearbyAreaPlaces,
        nearbyAtmoRangeKm = tonumber(SARNConfiguration.nearbyAtmoRangeKm) or 5,
        nearbySpaceRangeKm = tonumber(SARNConfiguration.nearbySpaceRangeKm) or 50,
        maximumNearbyPlaces = tonumber(SARNConfiguration.maximumNearbyPlaces) or 10,
        showSarnHudPanel = SARNConfiguration.showSarnHudPanel ~= false,
        showVisibleMarkersHudPanel = SARNConfiguration.showVisibleMarkersHudPanel ~= false,
        showPinnedLocationsHudPanel = SARNConfiguration.showPinnedLocationsHudPanel ~= false,
        showOffscreenMarkersInHud = SARNConfiguration.showOffscreenMarkersInHud ~= false,
        hudFontSize = tonumber(SARNConfiguration.hudFontSize) or 13,
        showAreaEntryNotifications = SARNConfiguration.showAreaEntryNotifications ~= false,
        showAreaExitNotifications = SARNConfiguration.showAreaExitNotifications ~= false,
        allowGroupsAsCurrentArea = SARNConfiguration.allowGroupsAsCurrentArea == true,
        adaptArRedrawFrequencyToFps = SARNConfiguration.adaptArRedrawFrequencyToFps ~= false,
        maximumArRedrawPercentOfFps =
            tonumber(SARNConfiguration.maximumArRedrawPercentOfFps) or 100
    }
end

function SARNSettings.serialize()
    local values = SARNSettings.getValues()
    return "SARN-SETTINGS-1"
        .. ";details=" .. string.format("%.1f", values.detailsViewCloseDelaySeconds)
        .. ";planets=" .. (values.showSystemPlanets and "1" or "0")
        .. ";satellites=" .. (values.showSatellites and "1" or "0")
        .. ";currentPlaces=" .. (values.showCurrentAreaPlaces and "1" or "0")
        .. ";nearbyAreas=" .. (values.showNearbyAreas and "1" or "0")
        .. ";nearbyAreaPlaces=" .. (values.showNearbyAreaPlaces and "1" or "0")
        .. ";adapt=" .. (values.adaptArRedrawFrequencyToFps and "1" or "0")
        .. ";maximum=" .. tostring(math.floor(values.maximumArRedrawPercentOfFps + 0.5))
        .. ";nearbyAtmo=" .. tostring(math.floor(values.nearbyAtmoRangeKm + 0.5))
        .. ";nearbySpace=" .. tostring(math.floor(values.nearbySpaceRangeKm + 0.5))
        .. ";nearbyCount=" .. tostring(math.floor(values.maximumNearbyPlaces + 0.5))
        .. ";hudStatus=" .. (values.showSarnHudPanel and "1" or "0")
        .. ";hudMarkers=" .. (values.showVisibleMarkersHudPanel and "1" or "0")
        .. ";hudPins=" .. (values.showPinnedLocationsHudPanel and "1" or "0")
        .. ";hudOffscreen=" .. (values.showOffscreenMarkersInHud and "1" or "0")
        .. ";hudFont=" .. tostring(math.floor(values.hudFontSize + 0.5))
        .. ";hudEntry=" .. (values.showAreaEntryNotifications and "1" or "0")
        .. ";hudExit=" .. (values.showAreaExitNotifications and "1" or "0")
        .. ";groupCurrent=" .. (values.allowGroupsAsCurrentArea and "1" or "0")
end

function SARNSettings.serializePins()
    local parts = { "SARN-PINS-1" }
    local entries = SARNArDrawing ~= nil and SARNArDrawing.getPersistedPins() or {}
    for _, entry in ipairs(entries) do
        parts[#parts + 1] = ";" .. entry.mode .. "=" .. encode(entry.key)
    end
    return table.concat(parts)
end

function SARNSettings.load()
    local databank = SARNSettings.findDatabank()
    if databank == nil then return false end
    local payload = SARN.call(databank, "getStringValue", SARNSettings.databankKey)
    local loaded = false
    if type(payload) == "string" and payload:sub(1, 15) == "SARN-SETTINGS-1" then
        local fields = {}
        for key, value in payload:gmatch(";([%a]+)=([^;]+)") do fields[key] = value end
        local values = {}
        if fields.details ~= nil then values.detailsViewCloseDelaySeconds = tonumber(fields.details) end
        if fields.planets ~= nil then values.showSystemPlanets = fields.planets == "1" end
        if fields.satellites ~= nil then values.showSatellites = fields.satellites == "1" end
        if fields.currentPlaces ~= nil then
            values.showCurrentAreaPlaces = fields.currentPlaces == "1"
        elseif fields.children ~= nil then
            values.showCurrentAreaPlaces = fields.children == "1"
        end
        if fields.nearbyAreas ~= nil then
            values.showNearbyAreas = fields.nearbyAreas == "1"
        elseif fields.nearby ~= nil then
            values.showNearbyAreas = fields.nearby == "1"
        end
        if fields.nearbyAreaPlaces ~= nil then
            values.showNearbyAreaPlaces = fields.nearbyAreaPlaces == "1"
        elseif fields.nearby ~= nil then
            values.showNearbyAreaPlaces = fields.nearby == "1"
        end
        if fields.adapt ~= nil then values.adaptArRedrawFrequencyToFps = fields.adapt == "1" end
        if fields.maximum ~= nil then values.maximumArRedrawPercentOfFps = tonumber(fields.maximum) end
        if fields.nearbyAtmo ~= nil then values.nearbyAtmoRangeKm = tonumber(fields.nearbyAtmo) end
        if fields.nearbySpace ~= nil then values.nearbySpaceRangeKm = tonumber(fields.nearbySpace) end
        if fields.nearbyCount ~= nil then values.maximumNearbyPlaces = tonumber(fields.nearbyCount) end
        if fields.hudStatus ~= nil then values.showSarnHudPanel = fields.hudStatus == "1" end
        if fields.hudMarkers ~= nil then
            values.showVisibleMarkersHudPanel = fields.hudMarkers == "1"
        end
        if fields.hudPins ~= nil then
            values.showPinnedLocationsHudPanel = fields.hudPins == "1"
        end
        if fields.hudOffscreen ~= nil then
            values.showOffscreenMarkersInHud = fields.hudOffscreen == "1"
        end
        if fields.hudFont ~= nil then values.hudFontSize = tonumber(fields.hudFont) end
        if fields.hudEntry ~= nil then
            values.showAreaEntryNotifications = fields.hudEntry == "1"
        end
        if fields.hudExit ~= nil then
            values.showAreaExitNotifications = fields.hudExit == "1"
        end
        if fields.groupCurrent ~= nil then
            values.allowGroupsAsCurrentArea = fields.groupCurrent == "1"
        end
        loaded = SARNSettings.apply(values)
    end
    local pinsPayload = SARN.call(databank, "getStringValue", SARNSettings.pinsDatabankKey)
    if type(pinsPayload) == "string" and pinsPayload:sub(1, 11) == "SARN-PINS-1" then
        local entries = {}
        for mode, key in pinsPayload:gmatch(";([%a]+)=([^;]+)") do
            entries[#entries + 1] = { mode = mode, key = decode(key) }
        end
        SARNSettings.pendingPins = entries
        loaded = true
    end
    return loaded
end

function SARNSettings.restorePins()
    if SARNSettings.pendingPins == nil or SARNArDrawing == nil then return false end
    SARNArDrawing.restorePins(SARNSettings.pendingPins)
    SARNSettings.pendingPins = nil
    return true
end

function SARNSettings.save()
    local databank = SARNSettings.findDatabank()
    if databank == nil then return false, "missing" end
    local ok, result = pcall(databank.setStringValue,
        SARNSettings.databankKey, SARNSettings.serialize())
    if not ok or result == false then return false, tostring(result) end
    local pinsOk, pinsResult = pcall(databank.setStringValue,
        SARNSettings.pinsDatabankKey, SARNSettings.serializePins())
    if not pinsOk or pinsResult == false then return false, tostring(pinsResult) end
    return true
end
