-- Loads, applies, and saves optional SARN runtime settings in a linked Databank.
-- Library dependencies: SARN helpers and SARNConfiguration.
SARNSettings = SARNSettings or {}
SARNSettings.databankKey = "sarn:settings:v1"

local function clampSetting(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, tonumber(value) or minimum))
end

function SARNSettings.findDatabank()
    for index = 1, 100 do
        local element = _G["slot" .. tostring(index)]
        if type(element) == "table"
            and type(element.getStringValue) == "function"
            and type(element.setStringValue) == "function" then
            SARNSettings.databank = element
            SARNSettings.databankSlot = index
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
    return {
        detailsViewCloseDelaySeconds = SARNConfiguration.detailsViewCloseDelaySeconds,
        showSystemPlanets = showPlanets,
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
        .. ";adapt=" .. (values.adaptArRedrawFrequencyToFps and "1" or "0")
        .. ";maximum=" .. tostring(math.floor(values.maximumArRedrawPercentOfFps + 0.5))
end

function SARNSettings.load()
    local databank = SARNSettings.findDatabank()
    if databank == nil then return false end
    local payload = SARN.call(databank, "getStringValue", SARNSettings.databankKey)
    if type(payload) ~= "string" or payload:sub(1, 15) ~= "SARN-SETTINGS-1" then return false end
    local fields = {}
    for key, value in payload:gmatch(";([%a]+)=([^;]+)") do fields[key] = value end
    local values = {}
    if fields.details ~= nil then values.detailsViewCloseDelaySeconds = tonumber(fields.details) end
    if fields.planets ~= nil then values.showSystemPlanets = fields.planets == "1" end
    if fields.adapt ~= nil then values.adaptArRedrawFrequencyToFps = fields.adapt == "1" end
    if fields.maximum ~= nil then values.maximumArRedrawPercentOfFps = tonumber(fields.maximum) end
    return SARNSettings.apply(values)
end

function SARNSettings.save()
    local databank = SARNSettings.findDatabank()
    if databank == nil then return false, "missing" end
    local ok, result = pcall(databank.setStringValue,
        SARNSettings.databankKey, SARNSettings.serialize())
    if not ok or result == false then return false, tostring(result) end
    return true
end
