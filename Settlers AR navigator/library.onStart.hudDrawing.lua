-- Draws the compact SARN status and pinned-location HUD panel.
-- Library dependencies: SARN helpers, SARNConfiguration, SARNController, and SARNLocationCatalog.
SARNHudDrawing = SARNHudDrawing or {}
local hudIconsOk, hudIcons = pcall(require, "sarn/icons")
if not hudIconsOk or type(hudIcons) ~= "table" then hudIcons = {} end

local function drawPanelWatermark()
    local icon = hudIcons["novean-logo"]
    if type(icon) ~= "table" or icon.viewBox == nil or icon.body == nil then return "" end
    local placement = ' preserveAspectRatio="xMidYMin meet" style="position:absolute;left:50%;top:0;'
        .. 'transform:translateX(-50%);width:125%;height:125%;pointer-events:none;'
    return '<svg viewBox="' .. tostring(icon.viewBox) .. '"' .. placement
        .. 'fill:rgb('
        .. SARNConfiguration.markerColor
        .. ');opacity:.35">'
        .. icon.body .. '</svg>'
end

local function drawPinnedLocations(entries)
    if type(entries) ~= "table" or #entries == 0 then return "" end
    local rows = {}
    local visibleCount = math.min(5, #entries)
    for index = 1, visibleCount do
        local entry = entries[index]
        rows[#rows + 1] = '<span style="color:#fff">&#9670;</span> '
            .. SARN.escapeHtml(entry.name) .. ' <span style="color:#86b7c8">&#8212; '
            .. SARN.escapeHtml(entry.mode) .. '</span>'
    end
    if #entries > visibleCount then
        rows[#rows + 1] = '<span style="color:#86b7c8">+ '
            .. tostring(#entries - visibleCount) .. ' more</span>'
    end
    return '<div style="margin-top:6px;padding-top:6px;border-top:1px solid rgba(0,0,0,.9);'
        .. 'box-shadow:inset 0 1px 0 rgba(180,235,250,.5);line-height:18px">'
        .. '<b>PINNED LOCATIONS</b><br>' .. table.concat(rows, '<br>') .. '</div>'
end

function SARNHudDrawing.drawCatalogStatus(rendered, currentTarget, available, pinnedEntries)
    local totals = SARNController ~= nil and SARNController.menuOpen
        and 'AR markers hidden - <b style="color:#ff4b55">SARN menu open</b>'
        or SARN.escapeHtml("Visible markers: " .. tostring(rendered or 0)
            .. " / " .. tostring(available or 0))
    local currentSummary = "Current area: Deep space"
    if currentTarget ~= nil then
        local currentName = SARN.escapeHtml(tostring(currentTarget.name or "unknown"))
        local parent = SARNLocationCatalog.getPrimaryParent(currentTarget)
        currentSummary = "Current area: " .. (parent ~= nil
            and (SARN.escapeHtml(tostring(parent.name or "unknown"))
                .. " &#8250; " .. currentName)
            or currentName)
    end
    return '<div style="position:absolute;left:18px;top:18px;padding:7px 10px;overflow:hidden;'
        .. 'color:#dff8ff;background:rgba(3,12,18,0.50);border-left:2px solid rgb('
        .. SARNConfiguration.markerColor
        .. ');font:13px Arial,sans-serif;text-shadow:0 0 4px #000;">'
        .. drawPanelWatermark() .. '<div style="position:relative;z-index:1"><b>'
        .. SARN.escapeHtml(SARN.startupCaption()) .. '</b><br>'
        .. '<span style="color:#86b7c8">' .. currentSummary .. '<br>'
        .. totals .. '</span>'
        .. drawPinnedLocations(pinnedEntries) .. '</div></div>'
end
