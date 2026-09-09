-- Projects known world locations and draws their player-facing AR dot labels.
-- Library dependencies: SARN helpers and SARNConfiguration.
SARNArDrawing = SARNArDrawing or {}

function SARNArDrawing.projectWorldPoint(point)
    local x, y, z = SARN.components(point)
    local projected = x ~= nil and SARN.call(library, "getPointOnScreen", { x, y, z }) or nil
    local sx, sy, sz = SARN.components(projected)
    if sx == nil or sy == nil or sz == 0 or sx < 0 or sx > 1 or sy < 0 or sy > 1 then return nil end
    return { x = sx, y = sy }
end

function SARNArDrawing.drawConfiguredLocation(target)
    local projected = SARNArDrawing.projectWorldPoint(target and target.worldPosition)
    if projected == nil
        or projected.x < 0.05 or projected.x > 0.95
        or projected.y < 0.05 or projected.y > 0.95 then return "" end
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local x, y = projected.x * width, projected.y * height
    local color = target.color or SARNConfiguration.markerColor
    local nameAndSize = tostring(target.name or "Construct") .. " [" .. tostring(target.coreSize or "?") .. "]"
    local ownerLine = tostring(target.ownerType or "owner") .. ": " .. tostring(target.ownerName or "unknown")
    local lines = { SARN.escapeHtml(nameAndSize), SARN.escapeHtml(ownerLine) }
    if target.label ~= nil and tostring(target.label) ~= "" then
        lines[#lines + 1] = SARN.escapeHtml(target.label)
    end
    local html = '<div style="position:absolute;left:' .. string.format("%.1f", x - 4)
        .. 'px;top:' .. string.format("%.1f", y - 4)
        .. 'px;width:8px;height:8px;border-radius:50%;background:rgb(' .. color
        .. ');border:1px solid #e8fbff;box-shadow:0 0 6px #001820;pointer-events:none"></div>'
    return html .. '<div style="position:absolute;left:' .. string.format("%.1f", x + 10)
        .. 'px;top:' .. string.format("%.1f", y - 9) .. 'px;color:rgb(' .. color
        .. ');font:13px Arial,sans-serif;line-height:16px;'
        .. 'text-shadow:-2px -2px 2px #000,2px -2px 2px #000,-2px 2px 2px #000,'
        .. '2px 2px 2px #000,0 0 6px #000;white-space:nowrap;pointer-events:none">'
        .. table.concat(lines, '<br>') .. '</div>'
end
