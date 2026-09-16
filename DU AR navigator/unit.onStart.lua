-- Loads the known-location catalog and starts the adaptive ARN renderer.
-- Library dependencies: ARN helpers, ARNSettings, ARNLocationCatalog, and ARNRenderer.

local slotsOk, initializeSlotsOrError = pcall(require, "liby.liby4slots")
local initializeSlots = slotsOk and type(initializeSlotsOrError) == "function" and initializeSlotsOrError or nil
ARNSettings.setSlotsInitializer(initializeSlots)
if initializeSlots == nil then
    ARN.reportWarning("slots-unavailable", "Could not load liby.liby4slots: " .. tostring(slotsOk and "invalid module result" or initializeSlotsOrError))
end

local atlasOk, atlasOrError = pcall(require, "atlas")
local atlas = atlasOk and type(atlasOrError) == "table" and atlasOrError or nil

local locationsOk, locationsOrError = pcall(require, "arn/locations")
local rootLocations = locationsOk and type(locationsOrError) == "table" and locationsOrError or nil
local fallbackAtlas = rootLocations and type(rootLocations.fallbackAtlas) == "table"
    and rootLocations.fallbackAtlas or nil
ARN.setAtlas(atlas or fallbackAtlas, atlasOk and "invalid module result" or atlasOrError)
ARNLocationCatalog.setRootConfig(rootLocations, locationsOk and "invalid module result" or locationsOrError)

ARNSettings.load()
local loaded = ARNLocationCatalog.initialize()
ARNSettings.restorePins()
local performanceOk, performanceOrError = pcall(require, "liby.liby4performance")
local initializeLiby4performance = performanceOk
    and type(performanceOrError) == "function" and performanceOrError or nil
if initializeLiby4performance == nil then
    ARN.reportWarning("performance-unavailable",
        "Could not load liby.liby4performance; rendering disabled: "
        .. tostring(performanceOk and "invalid module result" or performanceOrError))
end
local function createPerformance()
    if initializeLiby4performance == nil then
        return {
            start = function() end,
            onUpdate = function() end,
            onTimer = function() end
        }
    end
    local performance = initializeLiby4performance(unit, system, {
        adaptArRedrawFrequencyToFps = ARNConfiguration.adaptArRedrawFrequencyToFps,
        maximumArRedrawPercentOfFps = ARNConfiguration.maximumArRedrawPercentOfFps,
        minimumArRedrawFrequency = 5,
        minimumWorkStepsPerUpdate = 1,
        maximumWorkStepsPerUpdate = 4,
        maximumWorkSecondsPerUpdate = 0.002,
        onError = function(kind, message)
            system.print(ARN.chatPrefix() .. "Performance " .. tostring(kind) .. " error: " .. tostring(message))
        end
    })
    performance.setContentRenderer(ARNRenderer.getHtml)
    return performance
end
ARNPerformance = createPerformance()
function ARNRestartPerformance()
    ARNPerformance = createPerformance()
    ARNPerformance.start()
end

system.print("")
system.print(ARN.chatPrefix() .. ARN.startupCaption())
if loaded then
    system.print(ARN.chatPrefix() .. "Known-place catalog loaded: " .. tostring(ARNLocationCatalog.getStatistics().total) .. " locations.")
else
    system.print(ARN.chatPrefix() .. "Could not load required Lua file 'arn/locations.lua'.")
end
local started, startError = pcall(ARNPerformance.start)
if not started then
    system.print(ARN.chatPrefix() .. "Renderer did not start: " .. tostring(startError))
    ARNPerformance.onUpdate = function() end
    ARNPerformance.onTimer = function() end
end
