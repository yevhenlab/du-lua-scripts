-- Loads the known-location catalog and starts the adaptive SARN renderer.
-- Library dependencies: SARNConstructCatalog and SARNRenderer.
adaptArRedrawFrequencyToFps = true --export -- adapt AR redraw frequency to FPS
maximumArRedrawPercentOfFps = 100 --export -- cap AR redraw rate to 1-100% of FPS

local loaded = SARNConstructCatalog.initialize()
local initializeLiby4performance = require("liby.liby4performance")
SARNPerformance = initializeLiby4performance(unit, system, {
    adaptArRedrawFrequencyToFps = adaptArRedrawFrequencyToFps,
    maximumArRedrawPercentOfFps = maximumArRedrawPercentOfFps,
    minimumArRedrawFrequency = 5,
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
if loaded then
    system.print("[SARN] Known-place catalog loaded: "
        .. tostring(SARNConstructCatalog.getStatistics().total) .. " locations.")
else
    system.print("[SARN] Could not load required Lua file 'sarn/constructs.lua'.")
end
local started, startError = pcall(SARNPerformance.start)
if not started then
    system.print("[SARN] Renderer did not start: " .. tostring(startError))
    SARNPerformance.onUpdate = function() end
    SARNPerformance.onTimer = function() end
end
