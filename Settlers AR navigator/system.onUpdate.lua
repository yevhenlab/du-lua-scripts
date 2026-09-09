-- Forwards frame updates to liby4performance for adaptive AR refresh timing.
-- Library dependencies: SARNPerformance initialized by unit.onStart.lua.
local ok, errorMessage = pcall(SARNPerformance.onUpdate)
if not ok then
    system.print("[SARN] Renderer update disabled after error: " .. tostring(errorMessage))
    SARNPerformance.onUpdate = function() end
end
