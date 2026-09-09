-- Draws the SARN version and known-location totals by graph depth.
-- Library dependencies: SARN helpers and SARNConfiguration.
SARNHudDrawing = SARNHudDrawing or {}

function SARNHudDrawing.drawCatalogStatus(statistics, rendered, currentTarget)
    statistics = statistics or {}
    local depths = {}
    for depth, count in pairs(statistics.byDepth or {}) do
        if tonumber(depth) ~= nil and tonumber(count) ~= nil then
            depths[#depths + 1] = { depth = tonumber(depth), count = tonumber(count) }
        end
    end
    table.sort(depths, function(first, second) return first.depth < second.depth end)
    local depthParts = {}
    for _, item in ipairs(depths) do
        depthParts[#depthParts + 1] = "D" .. tostring(item.depth) .. " " .. tostring(item.count)
    end

    local totals = "Known places: " .. tostring(statistics.total or 0)
        .. " | visible " .. tostring(rendered or 0)
    local depthSummary = #depthParts > 0 and table.concat(depthParts, " | ") or "none"
    local currentSummary = currentTarget ~= nil
        and ("Current area: " .. tostring(currentTarget.name or "unknown"))
        or "Current area: deep space"
    return '<div style="position:absolute;left:18px;top:60px;padding:7px 10px;'
        .. 'color:#dff8ff;background:rgba(3,12,18,0.95);border-left:2px solid rgb('
        .. SARNConfiguration.markerColor .. ');font:13px Arial,sans-serif;text-shadow:0 0 4px #000;">'
        .. '<b>' .. SARN.escapeHtml(SARN.startupCaption()) .. '</b><br>'
        .. '<span style="color:#86b7c8">' .. SARN.escapeHtml(totals) .. '<br>'
        .. 'Depth: ' .. SARN.escapeHtml(depthSummary) .. '<br>'
        .. SARN.escapeHtml(currentSummary) .. '</span></div>'
end


function SARNHudDrawing.drawInteractionDebug(lines)
    if type(lines) ~= "table" or #lines == 0 then return "" end
    local escaped = {}
    for _, line in ipairs(lines) do escaped[#escaped + 1] = SARN.escapeHtml(line) end
    return '<div style="position:absolute;left:18px;top:145px;padding:6px 8px;max-width:calc(100vw - 36px);'
        .. 'overflow:hidden;color:#bcefff;background:rgba(3,12,18,.90);border-left:2px solid #52ff72;'
        .. 'font:10px Consolas,monospace;line-height:12px;white-space:nowrap;text-shadow:0 1px 2px #000;">'
        .. '<b>VIEW/SCROLL DEBUG — last 20 samples</b><br>' .. table.concat(escaped, '<br>') .. '</div>'
end
