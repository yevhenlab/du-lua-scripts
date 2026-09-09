-- Draws the known-location catalog totals and visible AR-label count.
-- Library dependencies: SARN helpers and SARNConfiguration.
SARNHudDrawing = SARNHudDrawing or {}

function SARNHudDrawing.drawCatalogStatus(statistics, rendered)
    statistics = statistics or {}
    local sizes = "Known places: " .. tostring(statistics.total or 0)
        .. " | visible " .. tostring(rendered or 0)
        .. " | XS " .. tostring(statistics.XS or 0)
        .. " | S " .. tostring(statistics.S or 0)
        .. " | M " .. tostring(statistics.M or 0)
        .. " | L " .. tostring(statistics.L or 0)
        .. " | XL " .. tostring(statistics.XL or 0)
    if (statistics.unknown or 0) > 0 then sizes = sizes .. " | other " .. tostring(statistics.unknown) end
    return '<div style="position:absolute;left:18px;top:60px;padding:7px 10px;'
        .. 'color:#dff8ff;background:rgba(3,12,18,0.95);border-left:2px solid rgb('
        .. SARNConfiguration.markerColor .. ');font:13px Arial,sans-serif;text-shadow:0 0 4px #000;">'
        .. '<b>' .. SARN.escapeHtml(SARN.applicationCaption()) .. '</b><br>'
        .. '<span style="color:#86b7c8">' .. SARN.escapeHtml(sizes) .. '</span></div>'
end
