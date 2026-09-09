-- Forwards the scheduled HUD refresh to liby4performance.
-- Library dependencies: SARNPerformance initialized by unit.onStart.lua.
local ok, errorMessage = pcall(SARNPerformance.onTimer, tag)
if not ok then
    system.print("[SARN] Renderer timer disabled after error: " .. tostring(errorMessage))
    SARNPerformance.onTimer = function() end
end
