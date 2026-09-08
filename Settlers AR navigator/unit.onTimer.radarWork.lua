-- Adapts the radar-detail batch to measured CPU usage and periodically reports progress.
-- Library dependencies:
-- - SARNConstructCatalog from library.onStart.constructCatalog.lua.
-- - SARNDiagnostics from library.onStart.diagnostics.lua.
SARNRadarWorkBatch = SARNRadarWorkBatch or 3
local previous = SARNDiagnostics.samples.radarDetails
if previous ~= nil then
    if previous.percent > 70 then
        SARNRadarWorkBatch = math.max(1, math.floor(SARNRadarWorkBatch / 2))
    elseif previous.percent < 60 then
        SARNRadarWorkBatch = math.min(50, SARNRadarWorkBatch + 1)
    end
end
SARNConstructCatalog.detailBatchSize = SARNRadarWorkBatch
local measurement = SARNDiagnostics.beginMeasurement()
local work = SARNConstructCatalog.processNext(SARNRadarWorkBatch)
if work.shouldReport then
    local statistics = work.statistics
    system.print("[SARN] Radar details: " .. tostring(statistics.processed) .. " processed; "
        .. tostring(statistics.total) .. " ready; " .. tostring(statistics.pending) .. " queued; "
        .. tostring(statistics.dynamic) .. " dynamic; " .. tostring(statistics.unavailable) .. " unavailable.")
end
if work.statistics ~= nil and work.statistics.pending == 0 then unit.stopTimer("sarnRadarWork") end
SARNDiagnostics.finishMeasurement("radarDetails", measurement)
