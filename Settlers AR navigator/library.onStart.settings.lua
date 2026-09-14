-- Loads, applies, and saves optional ARN runtime settings and pins in a linked Databank.
-- Library dependencies: ARN helpers, ARNConfiguration, ARNArDrawing, and the slots initializer injected by unit.onStart.
ARNSettings = ARNSettings or {}
local settingsBrand = ARN.shortName()
local settingsNamespace = string.lower(settingsBrand)
ARNSettings.databankKey = settingsNamespace .. ":settings:v1"
ARNSettings.pinsDatabankKey = settingsNamespace .. ":pins:v1"
ARNSettings.settingsHeader = settingsBrand .. "-SETTINGS-1"
ARNSettings.pinsHeader = settingsBrand .. "-PINS-1"

function ARNSettings.setSlotsInitializer(initializer)
    ARNSettings.initializeSlots = type(initializer) == "function" and initializer or nil
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

function ARNSettings.findDatabank()
    local candidates = {}
    local seen = {}
    local function addCandidate(element, source)
        if type(element) == "table" and not seen[element] then
            seen[element] = true
            candidates[#candidates + 1] = { element = element, source = source }
        end
    end

    if type(ARNSettings.initializeSlots) == "function" then
        local initialized, slots = pcall(ARNSettings.initializeSlots, _G, unit, system)
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
            ARNSettings.databank = element
            ARNSettings.databankSlot = candidate.source
            return element
        end
    end
    ARNSettings.databank = nil
    ARNSettings.databankSlot = nil
    return nil
end

function ARNSettings.apply(values)
    if type(values) ~= "table" then return false end
    if values.detailsViewCloseDelaySeconds ~= nil then
        ARNConfiguration.detailsViewCloseDelaySeconds =
            clampSetting(values.detailsViewCloseDelaySeconds, 0.1, 10)
    end
    if values.showSystemPlanets ~= nil then
        ARNConfiguration.showSystemPlanets = values.showSystemPlanets == true
        if ARNLocationCatalog ~= nil
            and type(ARNLocationCatalog.setShowSystemPlanets) == "function" then
            ARNLocationCatalog.setShowSystemPlanets(ARNConfiguration.showSystemPlanets)
        end
    end
    if values.showSatellites ~= nil then
        ARNConfiguration.showSatellites = values.showSatellites == true
        if ARNLocationCatalog ~= nil
            and type(ARNLocationCatalog.setShowSatellites) == "function" then
            ARNLocationCatalog.setShowSatellites(ARNConfiguration.showSatellites)
        end
    end
    if values.showCurrentAreaPlaces ~= nil then
        ARNConfiguration.showCurrentAreaPlaces = values.showCurrentAreaPlaces == true
        if ARNLocationCatalog ~= nil
            and type(ARNLocationCatalog.setShowCurrentAreaPlaces) == "function" then
            ARNLocationCatalog.setShowCurrentAreaPlaces(
                ARNConfiguration.showCurrentAreaPlaces)
        end
    end
    if values.showNearbyAreas ~= nil then
        ARNConfiguration.showNearbyAreas = values.showNearbyAreas == true
        if ARNLocationCatalog ~= nil
            and type(ARNLocationCatalog.setShowNearbyAreas) == "function" then
            ARNLocationCatalog.setShowNearbyAreas(ARNConfiguration.showNearbyAreas)
        end
    end
    if values.showNearbyAreaPlaces ~= nil then
        ARNConfiguration.showNearbyAreaPlaces = values.showNearbyAreaPlaces == true
        if ARNLocationCatalog ~= nil
            and type(ARNLocationCatalog.setShowNearbyAreaPlaces) == "function" then
            ARNLocationCatalog.setShowNearbyAreaPlaces(
                ARNConfiguration.showNearbyAreaPlaces)
        end
    end
    if values.nearbyAtmoRangeKm ~= nil then
        nearbyAtmoRangeKm = math.floor(clampSetting(values.nearbyAtmoRangeKm, 1, 100000) + 0.5)
        ARNConfiguration.nearbyAtmoRangeKm = nearbyAtmoRangeKm
    end
    if values.nearbySpaceRangeKm ~= nil then
        nearbySpaceRangeKm = math.floor(clampSetting(values.nearbySpaceRangeKm, 1, 100000) + 0.5)
        ARNConfiguration.nearbySpaceRangeKm = nearbySpaceRangeKm
    end
    if values.maximumNearbyPlaces ~= nil then
        maximumNearbyPlaces = math.floor(clampSetting(values.maximumNearbyPlaces, 1, 100) + 0.5)
        ARNConfiguration.maximumNearbyPlaces = maximumNearbyPlaces
    end
    if values.showNavigatorHudPanel ~= nil then
        ARNConfiguration.showNavigatorHudPanel = values.showNavigatorHudPanel == true
    end
    if values.showVisibleMarkersHudPanel ~= nil then
        ARNConfiguration.showVisibleMarkersHudPanel =
            values.showVisibleMarkersHudPanel == true
    end
    if values.showPinnedLocationsHudPanel ~= nil then
        ARNConfiguration.showPinnedLocationsHudPanel =
            values.showPinnedLocationsHudPanel == true
    end
    if values.showOffscreenMarkersInHud ~= nil then
        ARNConfiguration.showOffscreenMarkersInHud =
            values.showOffscreenMarkersInHud == true
    end
    if values.hudFontSize ~= nil then
        hudFontSize = math.floor(clampSetting(values.hudFontSize, 9, 24) + 0.5)
        ARNConfiguration.hudFontSize = hudFontSize
    end
    if values.showAreaEntryNotifications ~= nil then
        ARNConfiguration.showAreaEntryNotifications =
            values.showAreaEntryNotifications == true
    end
    if values.showAreaExitNotifications ~= nil then
        ARNConfiguration.showAreaExitNotifications =
            values.showAreaExitNotifications == true
    end
    if values.allowGroupsAsCurrentArea ~= nil then
        ARNConfiguration.allowGroupsAsCurrentArea =
            values.allowGroupsAsCurrentArea == true
        if ARNLocationCatalog ~= nil then ARNLocationCatalog.currentTargetCache = nil end
    end
    if values.adaptArRedrawFrequencyToFps ~= nil then
        adaptArRedrawFrequencyToFps = values.adaptArRedrawFrequencyToFps == true
        ARNConfiguration.adaptArRedrawFrequencyToFps = adaptArRedrawFrequencyToFps
    end
    if values.maximumArRedrawPercentOfFps ~= nil then
        maximumArRedrawPercentOfFps = math.floor(
            clampSetting(values.maximumArRedrawPercentOfFps, 1, 100) + 0.5)
        ARNConfiguration.maximumArRedrawPercentOfFps = maximumArRedrawPercentOfFps
    end
    return true
end

function ARNSettings.getValues()
    local showPlanets = ARNConfiguration.showSystemPlanets
    if ARNLocationCatalog ~= nil then
        showPlanets = ARNLocationCatalog.getShowSystemPlanets()
    end
    local showCurrentAreaPlaces = ARNConfiguration.showCurrentAreaPlaces
    local showNearbyAreas = ARNConfiguration.showNearbyAreas
    local showNearbyAreaPlaces = ARNConfiguration.showNearbyAreaPlaces
    if ARNLocationCatalog ~= nil then
        showCurrentAreaPlaces = ARNLocationCatalog.getShowCurrentAreaPlaces()
        showNearbyAreas = ARNLocationCatalog.getShowNearbyAreas()
        showNearbyAreaPlaces = ARNLocationCatalog.getShowNearbyAreaPlaces()
    end
    local showMoons = ARNConfiguration.showSatellites
    if ARNLocationCatalog ~= nil then showMoons = ARNLocationCatalog.getShowSatellites() end
    return {
        detailsViewCloseDelaySeconds = ARNConfiguration.detailsViewCloseDelaySeconds,
        showSystemPlanets = showPlanets,
        showSatellites = showMoons,
        showCurrentAreaPlaces = showCurrentAreaPlaces,
        showNearbyAreas = showNearbyAreas,
        showNearbyAreaPlaces = showNearbyAreaPlaces,
        nearbyAtmoRangeKm = tonumber(ARNConfiguration.nearbyAtmoRangeKm) or 5,
        nearbySpaceRangeKm = tonumber(ARNConfiguration.nearbySpaceRangeKm) or 50,
        maximumNearbyPlaces = tonumber(ARNConfiguration.maximumNearbyPlaces) or 10,
        showNavigatorHudPanel = ARNConfiguration.showNavigatorHudPanel ~= false,
        showVisibleMarkersHudPanel = ARNConfiguration.showVisibleMarkersHudPanel ~= false,
        showPinnedLocationsHudPanel = ARNConfiguration.showPinnedLocationsHudPanel ~= false,
        showOffscreenMarkersInHud = ARNConfiguration.showOffscreenMarkersInHud ~= false,
        hudFontSize = tonumber(ARNConfiguration.hudFontSize) or 14,
        showAreaEntryNotifications = ARNConfiguration.showAreaEntryNotifications ~= false,
        showAreaExitNotifications = ARNConfiguration.showAreaExitNotifications ~= false,
        allowGroupsAsCurrentArea = ARNConfiguration.allowGroupsAsCurrentArea == true,
        adaptArRedrawFrequencyToFps = ARNConfiguration.adaptArRedrawFrequencyToFps ~= false,
        maximumArRedrawPercentOfFps =
            tonumber(ARNConfiguration.maximumArRedrawPercentOfFps) or 80
    }
end

function ARNSettings.serialize()
    local values = ARNSettings.getValues()
    return ARNSettings.settingsHeader
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
        .. ";hudStatus=" .. (values.showNavigatorHudPanel and "1" or "0")
        .. ";hudMarkers=" .. (values.showVisibleMarkersHudPanel and "1" or "0")
        .. ";hudPins=" .. (values.showPinnedLocationsHudPanel and "1" or "0")
        .. ";hudOffscreen=" .. (values.showOffscreenMarkersInHud and "1" or "0")
        .. ";hudFont=" .. tostring(math.floor(values.hudFontSize + 0.5))
        .. ";hudEntry=" .. (values.showAreaEntryNotifications and "1" or "0")
        .. ";hudExit=" .. (values.showAreaExitNotifications and "1" or "0")
        .. ";groupCurrent=" .. (values.allowGroupsAsCurrentArea and "1" or "0")
end

function ARNSettings.serializePins()
    local parts = { ARNSettings.pinsHeader }
    local entries = ARNArDrawing ~= nil and ARNArDrawing.getPersistedPins() or {}
    for _, entry in ipairs(entries) do
        parts[#parts + 1] = ";" .. entry.mode .. "=" .. encode(entry.key)
    end
    return table.concat(parts)
end

function ARNSettings.load()
    local databank = ARNSettings.findDatabank()
    if databank == nil then return false end
    local payload = ARN.call(databank, "getStringValue", ARNSettings.databankKey)
    local validSettingsPayload = type(payload) == "string"
        and payload:sub(1, #ARNSettings.settingsHeader) == ARNSettings.settingsHeader
    local loaded = false
    if validSettingsPayload then
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
        if fields.hudStatus ~= nil then values.showNavigatorHudPanel = fields.hudStatus == "1" end
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
        loaded = ARNSettings.apply(values)
    end
    local pinsPayload = ARN.call(databank, "getStringValue", ARNSettings.pinsDatabankKey)
    local validPinsPayload = type(pinsPayload) == "string"
        and pinsPayload:sub(1, #ARNSettings.pinsHeader) == ARNSettings.pinsHeader
    if validPinsPayload then
        local entries = {}
        for mode, key in pinsPayload:gmatch(";([%a]+)=([^;]+)") do
            entries[#entries + 1] = { mode = mode, key = decode(key) }
        end
        ARNSettings.pendingPins = entries
        loaded = true
    end
    return loaded
end

function ARNSettings.restorePins()
    if ARNSettings.pendingPins == nil or ARNArDrawing == nil then return false end
    ARNArDrawing.restorePins(ARNSettings.pendingPins)
    ARNSettings.pendingPins = nil
    return true
end

function ARNSettings.save()
    local databank = ARNSettings.findDatabank()
    if databank == nil then return false, "missing" end
    local ok, result = pcall(databank.setStringValue,
        ARNSettings.databankKey, ARNSettings.serialize())
    if not ok or result == false then return false, tostring(result) end
    local pinsOk, pinsResult = pcall(databank.setStringValue,
        ARNSettings.pinsDatabankKey, ARNSettings.serializePins())
    if not pinsOk or pinsResult == false then return false, tostring(pinsResult) end
    return true
end
