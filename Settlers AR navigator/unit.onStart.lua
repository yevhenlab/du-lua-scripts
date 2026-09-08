-- Initializes linked elements and the adaptive renderer, then starts the SARN HUD.
-- Library dependencies:
-- - SARNLinkedElements from library.onStart.linkedElements.lua.
-- - SARNConstructCatalog from library.onStart.constructCatalog.lua.
-- - SARNRenderer from library.onStart.renderer.lua.
adaptArRedrawFrequencyToFps = true --export -- adapt AR redraw frequency to FPS
maximumArRedrawPercentOfFps = 100 --export -- cap AR redraw rate to 1-100% of FPS

local initializeLiby4slots = require("liby.liby4slots")
local liby4slots = initializeLiby4slots(_G, unit, system)
local core = SARNLinkedElements.setLiby4slots(liby4slots)
local radar = SARNLinkedElements.radar
local initialScan = SARNConstructCatalog.initialize(radar)
local initializeLiby4performance = require("liby.liby4performance")
SARNPerformance = initializeLiby4performance(unit, system, {
    adaptArRedrawFrequencyToFps = adaptArRedrawFrequencyToFps,
    maximumArRedrawPercentOfFps = maximumArRedrawPercentOfFps,
    minimumWorkStepsPerUpdate = 1,
    maximumWorkStepsPerUpdate = 4,
    maximumWorkSecondsPerUpdate = 0.002,
    onError = function(kind, message)
        system.print("[SARN] Performance " .. tostring(kind) .. " error: " .. tostring(message))
    end
})
SARNPerformance.setContentRenderer(SARNRenderer.getHtml)

system.print("")
system.print("[SARN] " .. SARN.startupCaption())
system.print("[SARN] " .. SARNLinkedElements.getLinkedElementsSummary())
if core == nil then
    system.print("[SARN] Construct Core not linked; linked-element discovery is unavailable.")
else
    system.print("[SARN] Construct Core linked.")
end
if radar == nil then
    system.print("[SARN] Radar not linked; no construct data is available.")
else
    system.print("[SARN] Radar IDs found: " .. tostring(initialScan.detected)
        .. "; queued for details: " .. tostring(initialScan.queued) .. ".")
    unit.setTimer("sarnRadarScan", 5)
    if initialScan.queued > 0 then unit.setTimer("sarnRadarWork", 0.25) end
end
local started, startError = pcall(SARNPerformance.start)
if not started then
    system.print("[SARN] Performance renderer did not start: " .. tostring(startError))
    SARNPerformance.onUpdate = function() end
    SARNPerformance.onTimer = function() end
else
    system.print("[SARN] Timer-only AR renderer started at 2 Hz.")
end
