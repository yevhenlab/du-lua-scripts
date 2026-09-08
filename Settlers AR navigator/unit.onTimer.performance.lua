-- Forwards the adaptive renderer's scheduled refresh timer.
-- Library dependencies:
-- - SARNPerformance initialized by unit.onStart.lua.
-- - SARNDiagnostics from library.onStart.diagnostics.lua.
local measurement = SARNDiagnostics.beginMeasurement()
local ok, errorMessage = pcall(SARNPerformance.onTimer, tag)
SARNDiagnostics.finishMeasurement("render", measurement)
if not ok then
    system.print("[SARN] Performance timer disabled after error: " .. tostring(errorMessage))
    SARNPerformance.onTimer = function() end
end
