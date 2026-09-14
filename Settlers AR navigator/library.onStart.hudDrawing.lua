-- Draws separate content-sized ARN status, visible-marker, and pinned-location HUD panels.
-- Library dependencies: ARN helpers, ARNConfiguration, ARNController, and ARNLocationCatalog.
ARNHudDrawing = ARNHudDrawing or {}
local hudIconsOk, hudIcons = pcall(require, "arn/icons")
if not hudIconsOk or type(hudIcons) ~= "table" then hudIcons = {} end

local panelAccentColors = {
    status = "85,232,255",
    markers = "105,225,170",
    pins = "255,199,92"
}

local function panelStyle(extra)
    local fontSize = math.max(9, math.min(24,
        math.floor(tonumber(ARNConfiguration.hudFontSize) or 14)))
    return 'display:table;position:relative;padding:7px 10px;overflow:hidden;'
        .. 'color:#dff8ff;background:rgba(3,12,18,0.30);'
        .. 'font:' .. tostring(fontSize) .. 'px Arial,sans-serif;'
        .. 'line-height:' .. tostring(fontSize + 5) .. 'px;'
        .. 'text-shadow:-1px -1px 2px #000,1px -1px 2px #000,'
        .. '-1px 1px 2px #000,1px 1px 2px #000,0 0 7px #000;'
        .. tostring(extra or "")
end

local function panelAccent(color)
    return '<span style="position:absolute;z-index:2;left:0;top:0;width:3px;height:100%;'
        .. 'pointer-events:none;background:linear-gradient(to right,rgba(' .. color
        .. ',0),rgba(' .. color .. ',1));box-shadow:2px 0 6px rgba('
        .. color .. ',.45)"></span>'
end

local function targetColorCss(target, onScreen, fallback)
    local color = target and target.visibilityColor
    if color == nil or color == "" then return fallback end
    return onScreen == false and ("rgba(" .. color .. ",.48)") or ("rgb(" .. color .. ")")
end

local function drawPanelWatermark(scaleFromWidth, verticalShiftPercent)
    local icon = hudIcons["novean-logo"]
    if type(icon) ~= "table" or icon.viewBox == nil or icon.body == nil then return "" end
    local size = scaleFromWidth and 'width:125%;height:auto;' or 'width:125%;height:125%;'
    local shift = tonumber(verticalShiftPercent) or 0
    local placement = ' preserveAspectRatio="xMidYMin meet" style="position:absolute;left:50%;top:0;'
        .. 'transform:translate(-50%,' .. tostring(shift) .. '%);'
        .. size .. 'pointer-events:none;'
    return '<svg viewBox="' .. tostring(icon.viewBox) .. '"' .. placement
        .. 'fill:rgb('
        .. ARNConfiguration.markerColor
        .. ');opacity:.35">'
        .. icon.body .. '</svg>'
end

local function drawPinnedLocations(entries)
    entries = type(entries) == "table" and entries or {}
    local rows = {}
    local visibleCount = math.min(5, #entries)
    for index = 1, visibleCount do
        local entry = entries[index]
        local color = entry.color ~= nil and ("rgb(" .. entry.color .. ")") or "#fff"
        rows[#rows + 1] = '<span style="color:' .. color .. '">&#9670; '
            .. ARN.escapeHtml(entry.name) .. '</span> <span style="color:#86b7c8">&#8212; '
            .. ARN.escapeHtml(entry.mode) .. '</span>'
    end
    if #entries > visibleCount then
        rows[#rows + 1] = '<span style="color:#86b7c8">+ '
            .. tostring(#entries - visibleCount) .. ' more</span>'
    elseif #entries == 0 then
        rows[1] = '<span style="color:#6f9ead">No pinned locations</span>'
    end
    return '<div style="' .. panelStyle() .. '">'
        .. panelAccent(panelAccentColors.pins) .. drawPanelWatermark(true, -40)
        .. '<div style="position:relative;z-index:1"><b>PINNED LOCATIONS</b><br>'
        .. table.concat(rows, '<br>') .. '</div></div>'
end
local function hierarchyHtml(target, includeAncestors, boldTarget)
    if target == nil then return "Deep space" end
    local parts = {}
    local candidate = target
    local seen = {}
    while candidate ~= nil and not seen[candidate.id] do
        seen[candidate.id] = true
        table.insert(parts, 1, candidate)
        candidate = includeAncestors and ARNLocationCatalog.getPrimaryParent(candidate) or nil
    end
    local html = {}
    for index, part in ipairs(parts) do
        local name = ARN.escapeHtml(tostring(part.name or "unknown"))
        if boldTarget and index == #parts then
            name = '<b style="color:' .. targetColorCss(part, true, "inherit") .. '">' .. name .. '</b>'
        end
        html[#html + 1] = name
    end
    return table.concat(html, " &#8250; ")
end

local function parentAndNodeHtml(target)
    local name = ARN.escapeHtml(tostring(target and target.name or "unknown"))
    local parent = ARNLocationCatalog.getPrimaryParent(target)
    return parent ~= nil and (ARN.escapeHtml(tostring(parent.name or "unknown"))
        .. " &#8250; " .. name) or name
end

local function isAncestor(candidate, target)
    if candidate == nil or target == nil then return false end
    local seen = {}
    local current = target
    while current ~= nil and not seen[current.id] do
        if current.id == candidate.id then return true end
        seen[current.id] = true
        current = ARNLocationCatalog.getPrimaryParent(current)
    end
    return false
end

local function areaEntryPath(target)
    if target == nil then return "" end
    local nodeName = tostring(target.name or "unknown")
    local parent = ARNLocationCatalog.getPrimaryParent(target)
    if parent == nil then return nodeName end
    return tostring(parent.name or "unknown") .. " > " .. nodeName
end
local function queueAreaNotification(action, target)
    if target == nil then return end
    ARNHudDrawing.areaNotificationQueue = ARNHudDrawing.areaNotificationQueue or {}
    ARNHudDrawing.areaNotificationQueue[#ARNHudDrawing.areaNotificationQueue + 1] = {
        action = action,
        path = areaEntryPath(target)
    }
end

local function drawAreaNotification(currentTarget)
    local now = tonumber(ARN.call(system, "getArkTime")) or 0
    local currentId = currentTarget and currentTarget.id or nil
    if not ARNHudDrawing.areaTrackingInitialized then
        ARNHudDrawing.areaTrackingInitialized = true
        ARNHudDrawing.previousAreaId = currentId
    elseif currentId ~= ARNHudDrawing.previousAreaId then
        local previousTarget = ARNHudDrawing.previousAreaId ~= nil
            and ARNLocationCatalog.getTargetById(ARNHudDrawing.previousAreaId) or nil
        local previousContainsCurrent = isAncestor(previousTarget, currentTarget)
        local currentContainsPrevious = isAncestor(currentTarget, previousTarget)

        if previousTarget ~= nil and not previousContainsCurrent
            and ARNConfiguration.showAreaExitNotifications ~= false then
            queueAreaNotification("left", previousTarget)
        end
        if currentTarget ~= nil and not currentContainsPrevious
            and ARNConfiguration.showAreaEntryNotifications ~= false then
            queueAreaNotification("entered", currentTarget)
        end
        ARNHudDrawing.previousAreaId = currentId
    end

    local active = ARNHudDrawing.activeAreaNotification
    if active ~= nil and now - active.startedAt >= 2.5 then
        ARNHudDrawing.activeAreaNotification = nil
        active = nil
    end
    local queue = ARNHudDrawing.areaNotificationQueue or {}
    if active == nil and #queue > 0 then
        active = table.remove(queue, 1)
        active.startedAt = now
        ARNHudDrawing.activeAreaNotification = active
    end
    if active == nil or active.path == "" then return "" end

    local elapsed = now - active.startedAt
    if elapsed < 0 then return "" end
    local topPercent, opacity, color
    if elapsed < 0.5 then
        local progress = elapsed / 0.5
        topPercent = 50 - progress * (50 / 3)
        opacity = progress * 0.5
        color = "168,255,193"
    elseif elapsed < 2 then
        topPercent = 100 / 3
        opacity = 0.5
        color = "168,255,193"
    else
        local progress = math.min(1, (elapsed - 2) / 0.5)
        topPercent = (100 / 3) - progress * (50 / 3)
        opacity = (1 - progress) * 0.5
        color = "74,82,86"
    end

    local verb = active.action == "left" and "You left" or "You entered"
    return '<div style="position:absolute;z-index:2000;left:50%;top:'
        .. string.format("%.2f", topPercent) .. '%;transform:translate(-50%,-50%);'
        .. 'pointer-events:none;white-space:nowrap;text-align:center;font:500 30px Arial,sans-serif;'
        .. 'letter-spacing:.3px;text-shadow:-2px -2px 4px #000,2px -2px 4px #000,-2px 2px 4px #000,2px 2px 6px #000,0 0 10px #000;color:rgb(' .. color .. ');opacity:'
        .. string.format("%.3f", opacity) .. '">' .. verb .. '<br><b>'
        .. ARN.escapeHtml(active.path) .. '</b></div>'
end
local function drawVisibleMarkers(entries, nearbyInfo, currentTarget)
    entries = type(entries) == "table" and entries or {}
    local showOffscreen = ARNConfiguration.showOffscreenMarkersInHud ~= false
    local entryById = {}
    for _, entry in ipairs(entries) do entryById[entry.target.id] = entry end
    local hudContextIds = {}
    if type(nearbyInfo) == "table" then
        for _, contextInfo in ipairs(nearbyInfo.contexts or {}) do
            if contextInfo.target ~= nil then hudContextIds[contextInfo.target.id] = true end
        end
    end
    local selectedContextByTargetId = type(nearbyInfo) == "table"
        and nearbyInfo.selectedContextByTargetId or {}
    local groupedEntries = {}
    local otherEntries = {}
    local planetoidEntries = {}
    local currentParent = ARNLocationCatalog.getPrimaryParent(currentTarget)
    local currentParentId = currentParent ~= nil and currentParent.id or nil
    for _, entry in ipairs(entries) do
        local targetType = entry.target and entry.target.type
        local isPlanetoid = targetType == "planet" or targetType == "satellite"
        local contextId = selectedContextByTargetId[entry.target.id]
        if isPlanetoid then
            -- Enabled planetoids remain identifiable in the HUD even off-screen.
            planetoidEntries[#planetoidEntries + 1] = entry
        elseif contextId ~= nil then
            if showOffscreen or entry.onScreen then
                groupedEntries[contextId] = groupedEntries[contextId] or {}
                groupedEntries[contextId][#groupedEntries[contextId] + 1] = entry
            end
        elseif hudContextIds[entry.target.id] ~= true
            and entry.target.id ~= currentParentId
            and (showOffscreen or entry.onScreen) then
            otherEntries[#otherEntries + 1] = entry
        end
    end

    local function sortEntries(items)
        table.sort(items, function(first, second)
            local firstRank, secondRank = first.nearbyRank, second.nearbyRank
            if firstRank ~= nil and secondRank ~= nil then return firstRank < secondRank end
            if firstRank ~= nil then return true end
            if secondRank ~= nil then return false end
            return string.lower(tostring(first.target.name or ""))
                < string.lower(tostring(second.target.name or ""))
        end)
    end
    sortEntries(otherEntries)
    sortEntries(planetoidEntries)
    for _, items in pairs(groupedEntries) do sortEntries(items) end

    local planetoidGroups = {}
    local planetoidGroupByPlanetId = {}
    for _, entry in ipairs(planetoidEntries) do
        if entry.target.type == "planet" then
            local group = { planet = entry, satellites = {} }
            planetoidGroupByPlanetId[entry.target.id] = group
            planetoidGroups[#planetoidGroups + 1] = group
        end
    end
    for _, entry in ipairs(planetoidEntries) do
        if entry.target.type == "satellite" then
            local parent = ARNLocationCatalog.getPrimaryParent(entry.target)
            local group = parent ~= nil and planetoidGroupByPlanetId[parent.id] or nil
            if group == nil and parent ~= nil then
                group = { planet = { target = parent, onScreen = false }, satellites = {} }
                planetoidGroupByPlanetId[parent.id] = group
                planetoidGroups[#planetoidGroups + 1] = group
            end
            if group ~= nil then group.satellites[#group.satellites + 1] = entry end
        end
    end
    local filteredGroups = {}
    for _, group in ipairs(planetoidGroups) do
        sortEntries(group.satellites)
        if showOffscreen then
            filteredGroups[#filteredGroups + 1] = group
        else
            local visibleSatellites = {}
            for _, satellite in ipairs(group.satellites) do
                if satellite.onScreen then visibleSatellites[#visibleSatellites + 1] = satellite end
            end
            group.satellites = visibleSatellites
            if group.planet.onScreen or #visibleSatellites > 0 then
                filteredGroups[#filteredGroups + 1] = group
            end
        end
    end
    table.sort(filteredGroups, function(first, second)
        return string.lower(tostring(first.planet.target.name or ""))
            < string.lower(tostring(second.planet.target.name or ""))
    end)
    planetoidGroups = filteredGroups

    local rows = {}
    if type(nearbyInfo) == "table" then
        local displayedContexts = {}
        local displayedNearbyCount = 0
        for _, contextInfo in ipairs(nearbyInfo.contexts or {}) do
            local contextEntry = entryById[contextInfo.target.id]
            local children = groupedEntries[contextInfo.target.id] or {}
            displayedNearbyCount = displayedNearbyCount + #children
            if contextInfo.current or (showOffscreen and contextInfo.markerEligible)
                or (contextEntry ~= nil and contextEntry.onScreen) or #children > 0 then
                displayedContexts[#displayedContexts + 1] = contextInfo
            end
        end
        local contextShown = #displayedContexts
        if #(nearbyInfo.contexts or {}) == 1 and nearbyInfo.root ~= nil
            and nearbyInfo.contexts[1].target.id == nearbyInfo.root.id then
            contextShown = displayedNearbyCount
        end
        if not nearbyInfo.suppressContextSummary then
            rows[#rows + 1] = '<span style="color:#86b7c8">Context: '
                .. hierarchyHtml(nearbyInfo.root, true, false) .. ' ('
                .. tostring(contextShown) .. '/' .. tostring(nearbyInfo.contextTotal or 0)
                .. ')</span>'
        end
        rows[#rows + 1] = '<span style="color:#86b7c8">Visible places '
            .. tostring(displayedNearbyCount) .. '/'
            .. tostring(nearbyInfo.candidateCount or 0) .. ':</span>'
        for _, contextInfo in ipairs(displayedContexts) do
            local contextEntry = entryById[contextInfo.target.id]
            local contextOnScreen = contextEntry ~= nil and contextEntry.onScreen
            local contextColor = targetColorCss(contextInfo.target, contextOnScreen,
                contextOnScreen and "#e8fbff" or "#6f9ead")
            local contextName = ARN.escapeHtml(tostring(contextInfo.target.name or "Location"))
            if contextInfo.current or (currentTarget ~= nil
                and contextInfo.target.id == currentTarget.id) then
                contextName = '<b>' .. contextName .. '</b>'
            end
            local children = groupedEntries[contextInfo.target.id] or {}
            rows[#rows + 1] = '<span style="color:' .. contextColor .. '">'
                .. contextName .. ' <span style="color:#86b7c8">('
                .. tostring(#children) .. '/'
                .. tostring(contextInfo.totalChildren or 0) .. ')</span></span>'
            for _, entry in ipairs(children) do
                local prefix = string.format("%2d", tonumber(entry.nearbyRank) or 0)
                local color = targetColorCss(entry.target, entry.onScreen,
                    entry.onScreen and "#e8fbff" or "#6f9ead")
                rows[#rows + 1] = '<span style="display:inline-block;width:24px;text-align:right;'
                    .. 'margin-right:6px;white-space:pre;font-family:monospace;color:#86d7ec">'
                    .. prefix .. '</span>'
                    .. '<span style="color:' .. color .. '">'
                    .. ARN.escapeHtml(tostring(entry.target.name or "Location")) .. '</span>'
            end
        end
    end
    for _, entry in ipairs(otherEntries) do
        local prefix = entry.nearbyRank ~= nil and tostring(entry.nearbyRank) or "&#183;"
        local color = targetColorCss(entry.target, entry.onScreen,
            entry.onScreen and "#e8fbff" or "#6f9ead")
        rows[#rows + 1] = '<span style="display:inline-block;width:24px;text-align:right;'
            .. 'margin-right:6px;white-space:pre;font-family:monospace;color:#86d7ec">'
            .. prefix .. '</span>'
            .. '<span style="color:' .. color .. '">'
            .. ARN.escapeHtml(tostring(entry.target.name or "Location")) .. '</span>'
    end
    if #planetoidGroups > 0 then
        rows[#rows + 1] = '<div style="height:2px;margin:5px 0 3px;'
            .. 'background:linear-gradient(to bottom,rgba(0,0,0,.72),'
            .. 'rgba(150,230,245,.48))"></div>'
            .. '<span style="color:#86b7c8;font-weight:bold">PLANETOIDS</span>'
        for _, group in ipairs(planetoidGroups) do
            local planet = group.planet
            local planetColor = targetColorCss(planet.target, planet.onScreen,
                planet.onScreen and "#e8fbff" or "#6f9ead")
            rows[#rows + 1] = '<span style="display:inline-block;width:24px;text-align:right;'
                .. 'margin-right:6px;color:#86d7ec">&#9675;</span>'
                .. '<b style="color:' .. planetColor .. '">'
                .. ARN.escapeHtml(tostring(planet.target.name or "Planet")) .. '</b>'
            for _, satellite in ipairs(group.satellites) do
                local satelliteColor = targetColorCss(satellite.target, satellite.onScreen,
                    satellite.onScreen and "#e8fbff" or "#6f9ead")
                rows[#rows + 1] = '<span style="display:inline-block;width:36px;text-align:right;'
                    .. 'margin-right:6px;color:#86d7ec">&#8627;</span>'
                    .. '<span style="color:' .. satelliteColor .. '">'
                    .. ARN.escapeHtml(tostring(satellite.target.name or "Satellite")) .. '</span>'
            end
        end
    end
    if #rows == 0 then
        rows[1] = '<span style="color:#6f9ead">No visible markers</span>'
    end
    return '<div style="' .. panelStyle() .. '">'
        .. panelAccent(panelAccentColors.markers) .. drawPanelWatermark()
        .. '<div style="position:relative;z-index:1"><b>VISIBLE MARKERS</b><br>'
        .. table.concat(rows, '<br>') .. '</div></div>'
end
function ARNHudDrawing.drawCatalogStatus(rendered, currentTarget, available, pinnedEntries, markerEntries, nearbyInfo)
    local entryNotification = drawAreaNotification(currentTarget)
    local panels = {}
    if ARNConfiguration.showNavigatorHudPanel ~= false then
        local totals = ARNController ~= nil and ARNController.menuOpen
            and ('AR markers hidden - <b style="color:#ff4b55">'
                .. ARN.escapeHtml(ARN.shortName()) .. ' menu open</b>')
            or ARN.escapeHtml("Visible markers: " .. tostring(rendered or 0)
                .. " / " .. tostring(available or 0))
        local currentSummary = "Current area: " .. hierarchyHtml(currentTarget, true, true)
        panels[#panels + 1] = '<div style="' .. panelStyle() .. '">'
            .. panelAccent(panelAccentColors.status) .. drawPanelWatermark(true, -40)
            .. '<div style="position:relative;z-index:1"><b>'
            .. ARN.escapeHtml(ARN.startupCaption()) .. '</b><br>'
            .. '<span style="color:#86b7c8">' .. currentSummary .. '<br>'
            .. totals .. '</span></div></div>'
    end
    if ARNConfiguration.showVisibleMarkersHudPanel ~= false then
        panels[#panels + 1] = drawVisibleMarkers(markerEntries, nearbyInfo, currentTarget)
    end
    if ARNConfiguration.showPinnedLocationsHudPanel ~= false
        and type(pinnedEntries) == "table" and #pinnedEntries > 0 then
        panels[#panels + 1] = drawPinnedLocations(pinnedEntries)
    end
    local panelHtml = ""
    if #panels > 0 then
        panelHtml = '<div style="position:absolute;left:18px;top:18px">'
            .. table.concat(panels, '<div style="height:6px"></div>')
            .. '</div>'
    end
    return panelHtml .. entryNotification
end