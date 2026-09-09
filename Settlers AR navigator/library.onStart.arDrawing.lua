-- Projects known world locations and draws interactive compact or hovered AR labels.
-- Library dependencies: SARN helpers and SARNConfiguration.
SARNArDrawing = SARNArDrawing or {}
SARNArDrawing.hoveredTargetId = nil
SARNArDrawing.hoveredBounds = nil
SARNArDrawing.hoveredSeen = false
SARNArDrawing.hoverOutsideSince = nil
SARNArDrawing.candidateTargetId = nil
SARNArDrawing.candidateSince = nil
SARNArDrawing.candidateSeen = false
SARNArDrawing.debugLines = SARNArDrawing.debugLines or {}

local function pointInside(x, y, bounds)
    return bounds ~= nil and x ~= nil and y ~= nil
        and x >= bounds.left and x <= bounds.right
        and y >= bounds.top and y <= bounds.bottom
end

local function cursorHitMode(bounds)
    for _, candidate in ipairs(SARNArDrawing.cursorCandidates or {}) do
        if pointInside(candidate.x, candidate.y, bounds) then return candidate.name end
    end
    return nil
end

local function cursorInside(bounds)
    return cursorHitMode(bounds) ~= nil
end

local function appendDebugLine(line)
    local lines = SARNArDrawing.debugLines
    lines[#lines + 1] = line
    while #lines > 20 do table.remove(lines, 1) end
end

function SARNArDrawing.beginFrame()
    local screenWidth = tonumber(SARN.call(system, "getScreenWidth")) or 1920
    local screenHeight = tonumber(SARN.call(system, "getScreenHeight")) or 1080
    -- With the normal locked game view, the visible aiming cursor is fixed at screen centre.
    -- getMousePosX/Y describes separate flight/free-look input and must not drive AR hover.
    local candidates = {
        { name = "screenCenter", x = screenWidth * 0.5, y = screenHeight * 0.5 }
    }
    SARNArDrawing.cursorCandidates = candidates
    SARNArDrawing.screenWidth = screenWidth
    SARNArDrawing.screenHeight = screenHeight
    SARNArDrawing.debugViewSample = nil
    SARNArDrawing.selectedAction = nil
    SARNArDrawing.childrenListHovered = false
    SARNArDrawing.now = tonumber(SARN.call(system, "getArkTime")) or 0
    SARNArDrawing.hoveredSeen = false
    SARNArDrawing.candidateSeen = false
end

function SARNArDrawing.endFrame()
    if SARNArDrawing.hoveredTargetId ~= nil and not SARNArDrawing.hoveredSeen then
        local oldBounds = SARNArDrawing.hoveredBounds
        SARNArDrawing.hoveredTargetId = nil
        SARNArDrawing.hoveredBounds = nil
        SARNArDrawing.hoverOutsideSince = nil
        SARNArDrawing.viewContentTarget = nil
        SARNArDrawing.viewTopOffset = nil
        SARNArDrawing.navigationBounds = nil
        SARNArDrawing.navigationUntil = nil
        if oldBounds ~= nil then
            SARNArDrawing.debugViewSample = { state = "CLOSE-NOT-VISIBLE", bounds = oldBounds, inside = false }
        end
    end
    if SARNArDrawing.candidateTargetId ~= nil and not SARNArDrawing.candidateSeen then
        SARNArDrawing.candidateTargetId = nil
        SARNArDrawing.candidateSince = nil
    end
    local sample = SARNArDrawing.debugViewSample
    if sample ~= nil and sample.bounds ~= nil then
        local cursor = SARNArDrawing.cursorCandidates[1]
        local bounds = sample.bounds
        appendDebugLine(tostring(sample.state) .. " center(" .. string.format("%.0f", cursor.x) .. ","
            .. string.format("%.0f", cursor.y) .. ") view[" .. string.format("%.0f", bounds.left) .. ","
            .. string.format("%.0f", bounds.top) .. "," .. string.format("%.0f", bounds.right) .. ","
            .. string.format("%.0f", bounds.bottom) .. "] inside=" .. (sample.inside and "yes" or "no")
            .. " outside=" .. string.format("%.2f", sample.outsideFor or 0) .. "s bgAlpha="
            .. string.format("%.2f", sample.backgroundAlpha or 0.68))
    end
end

function SARNArDrawing.getDebugLines()
    return SARNArDrawing.debugLines
end

function SARNArDrawing.captureMouseWheel()
    local wheel = tonumber(SARN.call(system, "getMouseWheel")) or 0
    local previous = SARNArDrawing.previousMouseWheel or 0
    if SARNArDrawing.childrenListHovered and wheel ~= 0 and previous == 0 then
        SARNArDrawing.pendingMouseWheel = (SARNArDrawing.pendingMouseWheel or 0) + (wheel > 0 and 1 or -1)
        SARNArDrawing.lastCapturedMouseWheel = wheel
    end
    SARNArDrawing.previousMouseWheel = wheel
end

function SARNArDrawing.activateSelectedAction()
    local action = SARNArDrawing.selectedAction
    if type(action) ~= "table" or action.target == nil
        or (action.kind ~= "open-parent" and action.kind ~= "open-child") then return false end
    SARNArDrawing.navigationBounds = SARNArDrawing.hoveredBounds
    SARNArDrawing.navigationUntil = (tonumber(SARN.call(system, "getArkTime")) or SARNArDrawing.now or 0) + 1
    SARNArDrawing.viewContentTarget = action.target
    SARNArDrawing.hoverOutsideSince = nil
    SARNArDrawing.candidateTargetId = nil
    SARNArDrawing.candidateSince = nil
    return true
end

function SARNArDrawing.projectWorldPoint(point)
    local x, y, z = SARN.components(point)
    local projected = x ~= nil and SARN.call(library, "getPointOnScreen", { x, y, z }) or nil
    local sx, sy, sz = SARN.components(projected)
    if sx == nil or sy == nil or sz == 0 or sx < 0 or sx > 1 or sy < 0 or sy > 1 then return nil end
    return { x = sx, y = sy }
end

function SARNArDrawing.getStyles()
    return [=[
<style>
.sarn-ar-object{position:absolute;font:13px Arial,sans-serif;line-height:16px;white-space:nowrap;pointer-events:none}
.sarn-ar-compact{display:flex;align-items:flex-start;gap:6px}
.sarn-ar-object.sarn-hover-ready .sarn-ar-compact{margin:-4px -6px;padding:3px 5px;background:rgba(3,12,18,.58);border:1px solid currentColor;box-shadow:0 0 7px currentColor}
.sarn-ar-details{display:none;width:280px;box-sizing:border-box;padding:8px 10px;color:inherit;background:rgba(3,12,18,.68);border:1px solid currentColor;box-shadow:0 0 7px currentColor;white-space:nowrap;overflow:hidden}
.sarn-ar-object.sarn-expanded .sarn-ar-compact{display:none}
.sarn-ar-object.sarn-expanded .sarn-ar-details{display:block}
.sarn-ar-parent{height:24px;box-sizing:border-box;margin-bottom:5px;padding:3px 5px;color:#d8edf3;border:1px solid rgba(216,237,243,.42);background:rgba(20,40,50,.48);font-weight:bold}
.sarn-ar-parent.sarn-action-selected{color:#fff;border-color:currentColor;background:rgba(45,85,100,.82);box-shadow:0 0 7px currentColor}
.sarn-ar-children-header{height:20px;box-sizing:border-box;padding-top:2px;color:#9fc5d2;font-weight:bold}
.sarn-ar-children-list{height:120px;box-sizing:border-box;background:rgba(7,22,29,.52);box-shadow:inset 0 0 0 1px rgba(216,237,243,.35);overflow:hidden}
.sarn-ar-child{height:24px;box-sizing:border-box;padding:3px 6px;color:#d8edf3;border-bottom:1px solid rgba(216,237,243,.14);overflow:hidden;text-overflow:ellipsis}
.sarn-ar-child.sarn-action-selected{color:#fff;background:rgba(45,85,100,.88);border:1px solid currentColor;box-shadow:inset 0 0 6px currentColor}
.sarn-ar-children-footer{height:18px;box-sizing:border-box;padding-top:2px;color:#85aeba;text-align:center;font-size:11px}
.sarn-ar-icon{display:inline-block;flex:none;color:inherit;filter:drop-shadow(0 0 3px #001820)}
.sarn-ar-dot{display:inline-block;width:8px;height:8px;margin:7px;border-radius:50%;background:currentColor;border:1px solid #e8fbff;box-shadow:0 0 6px #001820;flex:none}
.sarn-ar-text{text-shadow:-2px -2px 2px #000,2px -2px 2px #000,-2px 2px 2px #000,2px 2px 2px #000,0 0 6px #000}
.sarn-ar-details-title{display:flex;align-items:center;gap:6px;margin-bottom:5px;font-weight:bold}
.sarn-ar-details-line{color:#d8edf3;text-shadow:0 1px 2px #000}
</style>
]=]
end

local function drawMarker(target)
    local definition = target and target.iconDefinition
    if type(definition) ~= "table" then
        return '<span class="sarn-ar-dot"></span>'
    end
    local size = 22
    local scale = math.max(0.1, math.min(1, tonumber(definition.scale) or 1))
    local body = definition.body
    if scale ~= 1 then
        local offset = 150 * (1 - scale)
        body = '<g transform="translate(' .. string.format("%.2f", offset) .. ' '
            .. string.format("%.2f", offset) .. ') scale(' .. string.format("%.3f", scale) .. ')">'
            .. body .. '</g>'
    end
    return '<span class="sarn-ar-icon" style="width:' .. tostring(size) .. 'px;height:'
        .. tostring(size) .. 'px">'
        .. '<svg width="' .. tostring(size) .. '" height="' .. tostring(size)
        .. '" viewBox="' .. SARN.escapeHtml(definition.viewBox)
        .. '" fill="currentColor" xmlns="http://www.w3.org/2000/svg">' .. body .. '</svg></span>'
end

function SARNArDrawing.drawConfiguredLocation(target)
    local projected = SARNArDrawing.projectWorldPoint(target and target.worldPosition)
    if projected == nil
        or projected.x < 0.05 or projected.x > 0.95
        or projected.y < 0.05 or projected.y > 0.95 then
        return ""
    end
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local x, y = projected.x * width, projected.y * height
    local targetId = target.id or target
    local expanded = SARNArDrawing.hoveredTargetId == targetId
    local displayTarget = expanded and (SARNArDrawing.viewContentTarget or target) or target
    local color = displayTarget.color or SARNConfiguration.markerColor
    local nameAndSize = tostring(displayTarget.name or "Location")
    if displayTarget.coreSize ~= nil and displayTarget.coreSize ~= "?" then
        nameAndSize = nameAndSize .. " [" .. tostring(displayTarget.coreSize) .. "]"
    end
    local distance = SARN.distance(system.getCameraWorldPos(), displayTarget.worldPosition)
    if distance ~= nil then nameAndSize = nameAndSize .. " | " .. SARN.formatDistance(distance) end
    local rawLines = { nameAndSize }
    if displayTarget.ownerId ~= nil and tostring(displayTarget.ownerId) ~= "" then
        rawLines[#rawLines + 1] = tostring(displayTarget.ownerType or "owner")
            .. ": " .. tostring(displayTarget.ownerName or "unknown")
    end
    if displayTarget.label ~= nil and tostring(displayTarget.label) ~= "" then
        rawLines[#rawLines + 1] = tostring(displayTarget.label)
    end
    local lines = {}
    local longestLine = 0
    for _, line in ipairs(rawLines) do
        lines[#lines + 1] = SARN.escapeHtml(line)
        longestLine = math.max(longestLine, #line)
    end
    local details = {}
    details[#details + 1] = "Type: " .. SARN.escapeHtml(displayTarget.kind or "location")
    if displayTarget.areaRadius ~= nil and displayTarget.areaRadius > 0 then
        details[#details + 1] = "Radius: " .. SARN.escapeHtml(SARN.formatDistance(displayTarget.areaRadius))
    end
    if displayTarget.ownerId ~= nil and tostring(displayTarget.ownerId) ~= "" then
        details[#details + 1] = SARN.escapeHtml(tostring(displayTarget.ownerType or "owner")
            .. ": " .. tostring(displayTarget.ownerName or "unknown"))
    end
    if displayTarget.label ~= nil and tostring(displayTarget.label) ~= "" then
        details[#details + 1] = SARN.escapeHtml(displayTarget.label)
    end
    if displayTarget.description ~= nil and tostring(displayTarget.description) ~= "" then
        details[#details + 1] = SARN.escapeHtml(displayTarget.description)
    end
    local left, top = x - 11, y - 11
    local compactWidth = math.max(30, 28 + longestLine * 7.2)
    local compactHeight = math.max(22, #rawLines * 16)
    local viewBackgroundAlpha = 0.68
    local viewRenderTopOffset = 0
    local parent = SARNLocationCatalog.getPrimaryParent(displayTarget)
    local children = SARNLocationCatalog.getChildren(displayTarget)
    local childrenBlockHeight = #children > 0 and 158 or 20
    local parentSelected = false
    local selectedChildIndex = nil
    local candidate = false
    local compactBounds = {
        left = left - 6,
        top = top - 4,
        right = left + compactWidth + 6,
        bottom = top + compactHeight + 4
    }
    if not expanded and SARNArDrawing.hoveredTargetId == nil then
        if cursorInside(compactBounds) then
            if SARNArDrawing.candidateTargetId ~= targetId then
                SARNArDrawing.candidateTargetId = targetId
                SARNArDrawing.candidateSince = SARNArDrawing.now
            end
            SARNArDrawing.candidateSeen = true
            candidate = true
            if SARNArDrawing.now - (SARNArDrawing.candidateSince or SARNArDrawing.now) >= 0.5 then
                SARNArDrawing.hoveredTargetId = targetId
                SARNArDrawing.viewContentTarget = target
                SARNArDrawing.viewTopOffset = (parent ~= nil and 29 or 0) + 8
                SARNArDrawing.hoverOutsideSince = nil
                SARNArDrawing.candidateTargetId = nil
                SARNArDrawing.candidateSince = nil
                expanded = true
                candidate = false
            end
        elseif SARNArDrawing.candidateTargetId == targetId then
            SARNArDrawing.candidateTargetId = nil
            SARNArDrawing.candidateSince = nil
        end
    end
    if expanded then
        local parentHeight = parent ~= nil and 29 or 0
        local viewTopOffset = SARNArDrawing.viewTopOffset or (parentHeight + 8)
        SARNArDrawing.viewTopOffset = viewTopOffset
        viewRenderTopOffset = viewTopOffset
        local viewTop = top - viewTopOffset
        local viewBounds = {
            left = left,
            top = viewTop,
            right = left + 280,
            bottom = viewTop + 45 + parentHeight + #details * 16 + childrenBlockHeight
        }
        if parent ~= nil then
            local parentBounds = {
                left = left + 10,
                top = viewTop + 8,
                right = left + 270,
                bottom = viewTop + 32
            }
            parentSelected = cursorInside(parentBounds)
            if parentSelected then
                SARNArDrawing.selectedAction = { kind = "open-parent", target = parent }
            end
        end
        if #children > 0 then
            SARNArDrawing.childScrollByTargetId = SARNArDrawing.childScrollByTargetId or {}
            local maximumStart = math.max(1, #children - 4)
            local scrollStart = math.max(1, math.min(maximumStart,
                tonumber(SARNArDrawing.childScrollByTargetId[displayTarget.id]) or 1))
            local listTop = viewTop + 9 + parentHeight + 27 + #details * 16 + 20
            local listBounds = {
                left = left + 10,
                top = listTop,
                right = left + 270,
                bottom = listTop + 120
            }
            local listHovered = cursorInside(listBounds)
            SARNArDrawing.childrenListHovered = listHovered
            local wheel = SARNArDrawing.pendingMouseWheel or 0
            if listHovered and wheel ~= 0 and #children > 5 then
                local oldStart = scrollStart
                scrollStart = math.max(1, math.min(maximumStart,
                    scrollStart + (wheel > 0 and -1 or 1)))
                SARNArDrawing.childScrollByTargetId[displayTarget.id] = scrollStart
                appendDebugLine("SCROLL " .. tostring(displayTarget.name) .. " wheel="
                    .. tostring(SARNArDrawing.lastCapturedMouseWheel or wheel) .. " start="
                    .. tostring(oldStart) .. "->" .. tostring(scrollStart) .. "/" .. tostring(#children))
            end
            SARNArDrawing.pendingMouseWheel = 0
            if listHovered then
                local cursor = SARNArDrawing.cursorCandidates[1]
                local visibleRow = math.floor((cursor.y - listTop) / 24) + 1
                if visibleRow >= 1 and visibleRow <= 5 then
                    local childIndex = scrollStart + visibleRow - 1
                    if childIndex <= #children then
                        selectedChildIndex = childIndex
                        SARNArDrawing.selectedAction = { kind = "open-child", target = children[childIndex] }
                    end
                end
                local signature = tostring(displayTarget.id) .. ":" .. tostring(scrollStart)
                    .. ":" .. tostring(selectedChildIndex or 0)
                if signature ~= SARNArDrawing.lastChildrenHoverDebug then
                    appendDebugLine("LIST-HOVER " .. tostring(displayTarget.name) .. " rows="
                        .. tostring(scrollStart) .. "-" .. tostring(math.min(#children, scrollStart + 4))
                        .. "/" .. tostring(#children) .. " selected="
                        .. tostring(selectedChildIndex and children[selectedChildIndex].name or "none"))
                    SARNArDrawing.lastChildrenHoverDebug = signature
                end
            else
                SARNArDrawing.lastChildrenHoverDebug = nil
            end
            SARNArDrawing.currentChildScrollStart = scrollStart
        else
            SARNArDrawing.pendingMouseWheel = 0
            SARNArDrawing.currentChildScrollStart = 1
        end
        local insideNewView = cursorInside(viewBounds)
        local insideNavigationBridge = not insideNewView
            and SARNArDrawing.navigationBounds ~= nil
            and SARNArDrawing.now < (SARNArDrawing.navigationUntil or 0)
            and cursorInside(SARNArDrawing.navigationBounds)
        local inside = insideNewView or insideNavigationBridge
        if insideNewView or SARNArDrawing.now >= (SARNArDrawing.navigationUntil or math.huge) then
            SARNArDrawing.navigationBounds = nil
            SARNArDrawing.navigationUntil = nil
        end
        if inside then
            SARNArDrawing.hoverOutsideSince = nil
        elseif SARNArDrawing.hoverOutsideSince == nil then
            SARNArDrawing.hoverOutsideSince = SARNArDrawing.now
        end
        local outsideFor = SARNArDrawing.hoverOutsideSince ~= nil
            and math.max(0, SARNArDrawing.now - SARNArDrawing.hoverOutsideSince) or 0
        viewBackgroundAlpha = 0.68 * (1 - math.min(1, outsideFor) * 0.7)
        if not inside and outsideFor >= 1 then
            SARNArDrawing.hoveredTargetId = nil
            SARNArDrawing.hoveredBounds = nil
            SARNArDrawing.hoverOutsideSince = nil
            SARNArDrawing.viewContentTarget = nil
            SARNArDrawing.viewTopOffset = nil
            SARNArDrawing.navigationBounds = nil
            SARNArDrawing.navigationUntil = nil
            SARNArDrawing.debugViewSample = {
                state = "CLOSE",
                bounds = viewBounds,
                inside = false,
                outsideFor = outsideFor,
                backgroundAlpha = viewBackgroundAlpha
            }
        else
            SARNArDrawing.hoveredSeen = true
            SARNArDrawing.hoveredBounds = viewBounds
            SARNArDrawing.debugViewSample = {
                state = "OPEN",
                bounds = viewBounds,
                inside = inside,
                outsideFor = outsideFor,
                backgroundAlpha = viewBackgroundAlpha
            }
        end
    end
    local markerHtml = drawMarker(displayTarget)
    local parentHtml = ""
    if parent ~= nil then
        parentHtml = '<div class="sarn-ar-parent' .. (parentSelected and ' sarn-action-selected' or '')
            .. '">&#8593; Parent: ' .. SARN.escapeHtml(parent.name or "Location") .. '</div>'
    end
    local childrenHtml = ""
    if expanded then
        childrenHtml = '<div class="sarn-ar-children-header">Children: '
            .. tostring(#children) .. '</div>'
    end
    if expanded and #children > 0 then
        local scrollStart = SARNArDrawing.currentChildScrollStart or 1
        local rows = {}
        for childIndex = scrollStart, math.min(#children, scrollStart + 4) do
            local child = children[childIndex]
            rows[#rows + 1] = '<div class="sarn-ar-child'
                .. (selectedChildIndex == childIndex and ' sarn-action-selected' or '') .. '">&#8250; '
                .. SARN.escapeHtml(child.name or "Location") .. '</div>'
        end
        childrenHtml = childrenHtml .. '<div class="sarn-ar-children-list">'
            .. table.concat(rows) .. '</div><div class="sarn-ar-children-footer">'
            .. (#children > 5 and '&#8597; wheel &nbsp; ' or '') .. tostring(scrollStart) .. '-'
            .. tostring(math.min(#children, scrollStart + 4)) .. ' / ' .. tostring(#children) .. '</div>'
    end
    return '<div class="sarn-ar-object' .. (expanded and ' sarn-expanded' or '')
        .. (candidate and ' sarn-hover-ready' or '')
        .. '" style="left:' .. string.format("%.1f", left)
        .. 'px;top:' .. string.format("%.1f", top) .. 'px;color:rgb(' .. color .. ')">' 
        .. '<div class="sarn-ar-compact">' .. markerHtml
        .. '<span class="sarn-ar-text">' .. table.concat(lines, '<br>') .. '</span></div>'
        .. '<div class="sarn-ar-details" style="transform:translateY(-'
        .. tostring(expanded and viewRenderTopOffset or 0)
        .. 'px);background:rgba(3,12,18,'
        .. string.format("%.3f", viewBackgroundAlpha) .. ')">' .. parentHtml
        .. '<div class="sarn-ar-details-title">' .. markerHtml
        .. '<span class="sarn-ar-text">' .. SARN.escapeHtml(nameAndSize) .. '</span></div>'
        .. '<div class="sarn-ar-details-line">' .. table.concat(details, '<br>') .. '</div>'
        .. childrenHtml .. '</div></div>'
end
