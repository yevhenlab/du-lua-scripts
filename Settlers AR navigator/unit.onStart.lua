-- Loads the known-location catalog and starts the adaptive SARN renderer.
-- Library dependencies: SARN helpers, SARNSettings, SARNLocationCatalog, and SARNRenderer.

local slotsOk, initializeSlotsOrError = pcall(require, "liby.liby4slots")
local initializeSlots = slotsOk and type(initializeSlotsOrError) == "function" and initializeSlotsOrError or nil
SARNSettings.setSlotsInitializer(initializeSlots)
if initializeSlots == nil then
    SARN.reportWarning("slots-unavailable", "Could not load liby.liby4slots: " .. tostring(slotsOk and "invalid module result" or initializeSlotsOrError))
end

local atlasOk, atlasOrError = pcall(require, "atlas")
local atlas = atlasOk and type(atlasOrError) == "table" and atlasOrError or nil

local locationsOk, locationsOrError = pcall(require, "sarn/locations")
local rootLocations = locationsOk and type(locationsOrError) == "table" and locationsOrError or nil
local fallbackAtlas = rootLocations and type(rootLocations.fallbackAtlas) == "table"
    and rootLocations.fallbackAtlas or nil
SARN.setAtlas(atlas or fallbackAtlas, atlasOk and "invalid module result" or atlasOrError)
SARNLocationCatalog.setRootConfig(rootLocations, locationsOk and "invalid module result" or locationsOrError)

SARNSettings.load()
local loaded = SARNLocationCatalog.initialize()
SARNSettings.restorePins()
local initializeLiby4performance = require("liby.liby4performance")
local function createPerformance()
    local performance = initializeLiby4performance(unit, system, {
        adaptArRedrawFrequencyToFps = SARNConfiguration.adaptArRedrawFrequencyToFps,
        maximumArRedrawPercentOfFps = SARNConfiguration.maximumArRedrawPercentOfFps,
        minimumArRedrawFrequency = 5,
        minimumWorkStepsPerUpdate = 1,
        maximumWorkStepsPerUpdate = 4,
        maximumWorkSecondsPerUpdate = 0.002,
        onError = function(kind, message)
            system.print("[SARN] Performance " .. tostring(kind) .. " error: " .. tostring(message))
        end
    })
    performance.setContentRenderer(SARNRenderer.getHtml)
    return performance
end
SARNPerformance = createPerformance()
function SARNRestartPerformance()
    SARNPerformance = createPerformance()
    SARNPerformance.start()
end

system.print("")
system.print("[SARN] " .. SARN.startupCaption())
if loaded then
    system.print("[SARN] Known-place catalog loaded: " .. tostring(SARNLocationCatalog.getStatistics().total) .. " locations.")
else
    system.print("[SARN] Could not load required Lua file 'sarn/locations.lua'.")
end
local started, startError = pcall(SARNPerformance.start)
if not started then
    system.print("[SARN] Renderer did not start: " .. tostring(startError))
    SARNPerformance.onUpdate = function() end
    SARNPerformance.onTimer = function() end
end
