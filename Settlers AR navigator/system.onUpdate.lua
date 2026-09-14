-- Forwards frame updates to liby4performance for adaptive AR refresh timing.
-- Library dependencies: ARNPerformance initialized by unit.onStart.lua.
if ARNArDrawing ~= nil then ARNArDrawing.captureMouseWheel() end
if ARNPerformanceNeedsRestart and type(ARNRestartPerformance) == "function" then
    ARNPerformanceNeedsRestart = false
    local restarted, restartError = pcall(ARNRestartPerformance)
    if not restarted then system.print(ARN.chatPrefix() .. "Renderer restart failed: " .. tostring(restartError)) end
end
local ok, errorMessage = pcall(ARNPerformance.onUpdate)
if not ok then
    system.print(ARN.chatPrefix() .. "Renderer update disabled after error: " .. tostring(errorMessage))
    ARNPerformance.onUpdate = function() end
end
