-- Forwards frame updates to liby4performance for adaptive AR refresh timing.
-- Library dependencies: SARNPerformance initialized by unit.onStart.lua.
if SARNArDrawing ~= nil then SARNArDrawing.captureMouseWheel() end
if SARNPerformanceNeedsRestart and type(SARNRestartPerformance) == "function" then
    SARNPerformanceNeedsRestart = false
    local restarted, restartError = pcall(SARNRestartPerformance)
    if not restarted then system.print("[SARN] Renderer restart failed: " .. tostring(restartError)) end
end
local ok, errorMessage = pcall(SARNPerformance.onUpdate)
if not ok then
    system.print("[SARN] Renderer update disabled after error: " .. tostring(errorMessage))
    SARNPerformance.onUpdate = function() end
end
