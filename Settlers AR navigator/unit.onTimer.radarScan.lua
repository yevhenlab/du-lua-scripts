-- Refreshes the lightweight in-memory ID queue from the linked Radar.
-- Library dependencies:
-- - SARNConstructCatalog from library.onStart.constructCatalog.lua.
-- - SARNDiagnostics from library.onStart.diagnostics.lua.
local measurement = SARNDiagnostics.beginMeasurement()
local refresh = SARNConstructCatalog.refreshIds()
if refresh.changed then
    system.print("[SARN] Radar IDs found: " .. tostring(refresh.detected)
        .. "; queued for details: " .. tostring(refresh.queued) .. ".")
end
if refresh.queued > 0 then unit.setTimer("sarnRadarWork", 0.25) end
SARNDiagnostics.finishMeasurement("radarIds", measurement)
