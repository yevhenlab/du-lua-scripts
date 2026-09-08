-- Draws catalog and AR construct statistics independently of the AR target geometry.
-- Library dependencies:
-- - SARN helpers from library.onStart.helpers.lua.
-- - SARNDiagnostics from library.onStart.diagnostics.lua.
SARNHudDrawing = SARNHudDrawing or {}

function SARNHudDrawing.drawCatalogStatus(statistics)
    statistics = statistics or {}
    local sizeStatistics = "XS " .. tostring(statistics.XS or 0)
        .. " | S " .. tostring(statistics.S or 0)
        .. " | M " .. tostring(statistics.M or 0)
        .. " | L " .. tostring(statistics.L or 0)
        .. " | XL " .. tostring(statistics.XL or 0)
        .. " | XXL " .. tostring(statistics.XXL or 0)
    if (statistics.unknown or 0) > 0 then sizeStatistics = sizeStatistics .. " | ? " .. tostring(statistics.unknown) end
    local idStatus = "Radar IDs: " .. tostring(statistics.detected or 0) .. " detected | "
        .. tostring(statistics.ids or 0) .. " in memory | " .. tostring(statistics.pending or 0) .. " queued"
    local processingStatus = "Processed " .. tostring(statistics.processed or 0) .. " | ready "
        .. tostring(statistics.total or 0) .. " | dynamic " .. tostring(statistics.dynamic or 0)
        .. " | unavailable " .. tostring(statistics.unavailable or 0)
        .. " | batch " .. tostring(statistics.batch or 0)
    local renderCpu = SARNDiagnostics.getSample("render")
    local idsCpu = SARNDiagnostics.getSample("radarIds")
    local detailsCpu = SARNDiagnostics.getSample("radarDetails")
    local cpuStatus = string.format(
        "CPU: render %.1f%% | IDs %.1f%% | details %.1f%% | peak %.1f%%",
        renderCpu.percent, idsCpu.percent, detailsCpu.percent, SARNDiagnostics.peakPercent or 0
    )
    return '<div style="position:absolute;left:18px;top:60px;padding:7px 10px;'
        .. 'color:#dff8ff;background:rgba(3,12,18,0.95);border-left:2px solid rgb('
        .. SARNConfiguration.markerColor .. ');font:13px Arial,sans-serif;text-shadow:0 0 4px #000;">'
        .. '<b>' .. SARN.escapeHtml(SARN.applicationCaption()) .. '</b><br>'
        .. '<span style="color:#b5ced8">AR drawing disabled | ready constructs: '
        .. tostring(statistics.total or 0) .. '</span><br>'
        .. '<span style="color:#86b7c8">' .. SARN.escapeHtml(sizeStatistics) .. '</span><br>'
        .. '<span style="color:#7896a1">' .. SARN.escapeHtml(idStatus) .. '</span><br>'
        .. '<span style="color:#7896a1">' .. SARN.escapeHtml(processingStatus) .. '</span><br>'
        .. '<span style="color:#e5c27a">' .. SARN.escapeHtml(cpuStatus) .. '</span></div>'
end
