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
SARNArDrawing.pins = SARNArDrawing.pins or {}

local waypointIcon = {
    viewBox = "0 0 26 26",
    body = '<rect height="2" width="7.5" x="18.5" y="12"/><rect height="7.5" width="2" x="14.3" y="16.2"/><rect height="7.5" width="2" x="14.3" y="2.3"/><path d="M7.5 4.2L3.7 2.7l1.5 2.8C-1 7.9.7 13.6.7 13.6.6 10.2 4.5 8.4 6 7.8l.5 3.1 3.8-5.6z"/><polygon points="8.9,14 12,14 12,12 8.9,12"/><rect height="8.2" width="8.2" y="14.4"/><path d="M17.7 3.9v1.5c2.6.8 4.6 2.9 5.4 5.5h1.4c-.8-3.5-3.4-6.1-6.8-7zM23.2 15.2c-.7 2.7-2.8 4.9-5.5 5.7v1.4c3.4-.9 6.1-3.7 6.9-7.2z"/>'
}
local pinIcon = {
    viewBox = "0 0 2.82 2.82",
    body = '<polygon points="2.48 .88 1.95 .34 1.25 .87 1.96 1.57"/><polygon points="0 2.83 1.05 1.42 1.4 1.78"/><polygon points="1.98 0 2 .27 2.56 .82 2.83 .84"/><polygon points="1.32 1.5 1.94 2.11 1.88 1.65 1.18 .94 .72 .9"/>'
}
local planetCoordinateIcon = {
    viewBox = "0 0 300 300",
    body = '<path d="M173.8 200.2c-22.6 12.6-46.4 22.9-71.1 30.8 40.2 27 94.4 16.2 121.4-24.7 10.4-15.4 15.5-33.8 14.5-52.3-20 16.7-41.8 31.4-64.8 43.8z"/><path d="M148.8 154.8c33.2-18.2 59.2-39 69.7-54.2-27-39.3-80.7-49.3-120-22.3-34.2 23.5-46.9 68-30.1 106 18.8-1.3 48.8-11.9 80.4-29.2z"/><path d="M206.3 74.1c45.1-15.8 79.2-18.6 86.9-4.6 11.8 21.5-44 74.8-124.4 118.7S13.4 250.7 1.6 229.2c-7.7-13.9 13.1-41.2 50.4-70.6l1 4.9C39.7 177.2 33.5 189 37.3 196c8.5 15.4 62 2.3 119.5-29.3s97.3-69.6 88.9-85c-3.8-7-17.1-8.1-35.8-4.2z"/>'
}
local spaceCoordinateIcon = {
    viewBox = "0 0 300 300",
    body = '<path d="M281 112.4l19-4.2-19.3-3.8-4.1-19-3.9 19.1-19.2 4.2 19.5 3.9 4.3 19.2zM137.8 73.4l31.5-6.9-32-6.2-6.9-31.5-6.3 31.6-31.9 6.9 32.3 6.4 7.1 31.8zM25.6 162.6l18.3-4.1-18.6-3.5-4-18.3-3.6 18.3-18.5 4 18.7 3.7 4.1 18.5zM260 211.3l29-6.4-29.4-5.8-6.3-29-5.8 29.1-29.4 6.4 29.7 5.9 6.5 29.3z"/>'
}

local nodeActionMocks = {
    { key = "set-waypoint", title = "Set waypoint", action = "set-waypoint",
        requiresCoordinate = true, svg = waypointIcon },
    { key = "pin-place", title = "Pin location", action = "pin-place",
        requiresCoordinate = true, svg = pinIcon },
    { key = "planet-coordinate", title = "Show planet coordinate", action = "planet-coordinate",
        requiresCoordinate = true, svg = planetCoordinateIcon },
    { key = "space-coordinate", title = "Show space coordinate", action = "space-coordinate",
        requiresCoordinate = true, svg = spaceCoordinateIcon }
}

local childrenActionMocks = {
    { key = "pin-children", title = "Pin children", action = "pin-children", svg = pinIcon },
    { key = "children-sort", icon = "&#8645;", title = "Children action 2" },
    { key = "children-expand", icon = "&#9660;", title = "Children action 3" },
    { key = "children-focus", icon = "&#9678;", title = "Children action 4" },
    { key = "children-more", icon = "&#8943;", title = "Children action 5" }
}

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

local function getPinState(target, create)
    local targetId = target and target.id
    if targetId == nil then return nil end
    local state = SARNArDrawing.pins[targetId]
    if state == nil and create then
        state = { target = target, place = false, children = false }
        SARNArDrawing.pins[targetId] = state
    end
    return state
end

local function togglePin(target, mode)
    local state = getPinState(target, true)
    if state == nil then return false end
    state[mode] = not state[mode]
    if not state.place and not state.children then SARNArDrawing.pins[target.id] = nil end
    return state[mode]
end

function SARNArDrawing.isTargetPinned(target)
    local ownState = getPinState(target, false)
    if ownState ~= nil and ownState.place then return true end
    for _, state in pairs(SARNArDrawing.pins) do
        if state.children and state.target ~= nil then
            for _, child in ipairs(SARNLocationCatalog.getChildren(state.target)) do
                if child.id == target.id then return true end
            end
        end
    end
    return false
end

function SARNArDrawing.getPinnedEntries()
    local entries = {}
    for _, state in pairs(SARNArDrawing.pins) do
        if state.target ~= nil and (state.place or state.children) then
            entries[#entries + 1] = {
                name = state.target.name or "Location",
                mode = state.place and state.children and "place + children"
                    or (state.place and "place" or "children")
            }
        end
    end
    table.sort(entries, function(first, second)
        return string.lower(tostring(first.name)) < string.lower(tostring(second.name))
    end)
    return entries
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
    SARNArDrawing.cursorInsideExpandedView = false
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
    if type(action) ~= "table" or action.target == nil then return false end
    if action.kind == "open-compact" then
        local target = action.target
        SARNArDrawing.hoveredTargetId = target.id or target
        SARNArDrawing.hoveredBounds = action.bounds
        SARNArDrawing.viewContentTarget = target
        SARNArDrawing.viewTopOffset =
            (SARNLocationCatalog.getPrimaryParent(target) ~= nil and 29 or 0) + 8
        SARNArDrawing.hoverOutsideSince = nil
        SARNArDrawing.navigationBounds = action.bounds
        SARNArDrawing.navigationUntil =
            (tonumber(SARN.call(system, "getArkTime")) or SARNArDrawing.now or 0) + 1
        SARNArDrawing.candidateTargetId = nil
        SARNArDrawing.candidateSince = nil
        return true
    end
    if action.kind == "node-action" then
        SARNArDrawing.activatedMockActionKey = action.key
        SARNArDrawing.activatedMockActionUntil =
            (tonumber(SARN.call(system, "getArkTime")) or SARNArDrawing.now or 0) + 0.5
        local target = action.target
        local name = tostring(target.name or "Location")
        if action.action == "set-waypoint" then
            local waypoint = type(target.sourceCoordinate) == "string" and target.sourceCoordinate
                or SARN.worldPositionString(target.worldPosition)
            if waypoint == nil then return false end
            local ok = pcall(system.setWaypoint, waypoint, true)
            if ok then system.print('[SARN] Waypoint set to "' .. name .. '".') end
            return ok
        elseif action.action == "planet-coordinate" then
            local coordinateBody = SARNLocationCatalog.getNearestCoordinateBody(target)
            local coordinate = SARN.bodyRelativePositionString(target.worldPosition, coordinateBody)
            if coordinate == nil then
                coordinate = SARN.closestPlanetPositionString(target.worldPosition)
            end
            if coordinate == nil then
                system.print('[SARN] "' .. name .. '": unknown body ID; use world coordinates.')
                return false
            end
            system.print('[SARN] "' .. name .. '" planet-relative position: ' .. coordinate)
            return true
        elseif action.action == "space-coordinate" then
            local coordinate = SARN.worldPositionString(target.worldPosition)
            if coordinate == nil then return false end
            system.print('[SARN] "' .. name .. '" world-space position: ' .. coordinate)
            return true
        elseif action.action == "pin-place" then
            local pinned = togglePin(target, "place")
            system.print('[SARN] "' .. name .. '" ' .. (pinned and "pinned." or "unpinned."))
            return true
        elseif action.action == "pin-children" then
            local pinned = togglePin(target, "children")
            system.print('[SARN] Children of "' .. name .. '" '
                .. (pinned and "pinned." or "unpinned."))
            return true
        end
        return false
    end
    if action.kind == "mock-action" then
        SARNArDrawing.activatedMockActionKey = action.key
        SARNArDrawing.activatedMockActionUntil =
            (tonumber(SARN.call(system, "getArkTime")) or SARNArDrawing.now or 0) + 0.5
        appendDebugLine("MOCK-ACTION " .. tostring(action.scope) .. " "
            .. tostring(action.title) .. " @ " .. tostring(action.target.name or "Location"))
        return true
    end
    if action.kind ~= "open-parent" and action.kind ~= "open-child" then return false end
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

local function compactLayoutSize(target, cameraPosition, pinned)
    local name = tostring(target.name or "Location")
    if target.coreSize ~= nil and target.coreSize ~= "?" then
        name = name .. " [" .. tostring(target.coreSize) .. "]"
    end
    local distance = SARN.distance(cameraPosition, target.worldPosition)
    if distance ~= nil then name = name .. " | " .. SARN.formatDistance(distance) end
    local longest = #name
    local lineCount = 1
    if target.ownerId ~= nil and tostring(target.ownerId) ~= "" then
        local owner = tostring(target.ownerType or "owner") .. ": "
            .. tostring(target.ownerName or "unknown")
        longest = math.max(longest, #owner)
        lineCount = lineCount + 1
    end
    if target.label ~= nil and tostring(target.label) ~= "" then
        longest = math.max(longest, #tostring(target.label))
        lineCount = lineCount + 1
    end
    local pinWidth = pinned and 22 or 0
    return math.max(30, 30 + longest * 7.2 + pinWidth), math.max(22, lineCount * 16)
end

local function layoutBoundsOverlap(first, second)
    local clearance = 5
    return first.left < second.right + clearance
        and first.right + clearance > second.left
        and first.top < second.bottom + clearance
        and first.bottom + clearance > second.top
end

function SARNArDrawing.prepareCompactLayout(targets)
    local width = SARNArDrawing.screenWidth or tonumber(SARN.call(system, "getScreenWidth")) or 1920
    local height = SARNArDrawing.screenHeight or tonumber(SARN.call(system, "getScreenHeight")) or 1080
    local cameraPosition = SARN.call(system, "getCameraWorldPos")
    local safeLeft, safeRight = width * 0.05, width * 0.95
    local safeTop, safeBottom = height * 0.05, height * 0.95
    local occupied = {}
    local layouts = {}

    -- Targets arrive farthest-first for paint order. Allocate nearest-first so the
    -- most relevant labels retain the slots closest to their projected points.
    for targetIndex = #targets, 1, -1 do
        local target = targets[targetIndex]
        local projected = SARNArDrawing.projectWorldPoint(target.worldPosition)
        if projected ~= nil and projected.x >= 0.05 and projected.x <= 0.95
            and projected.y >= 0.05 and projected.y <= 0.95 then
            local anchorX, anchorY = projected.x * width, projected.y * height
            local labelWidth, labelHeight = compactLayoutSize(
                target, cameraPosition, SARNArDrawing.isTargetPinned(target))
            local selected = nil
            for band = 0, 4 do
                local horizontalDistance = 14 + band * 42
                for row = 0, 12 do
                    local rowIndex = row == 0 and 0
                        or (row % 2 == 1 and -((row + 1) / 2) or row / 2)
                    local candidateTop = anchorY - labelHeight * 0.5
                        + rowIndex * (labelHeight + 10)
                    for side = 1, 2 do
                        local candidateLeft = side == 1
                            and anchorX + horizontalDistance
                            or anchorX - horizontalDistance - labelWidth
                        candidateLeft = math.max(safeLeft + 6,
                            math.min(safeRight - labelWidth - 6, candidateLeft))
                        candidateTop = math.max(safeTop + 4,
                            math.min(safeBottom - labelHeight - 4, candidateTop))
                        local candidate = {
                            left = candidateLeft - 6,
                            top = candidateTop - 4,
                            right = candidateLeft + labelWidth + 6,
                            bottom = candidateTop + labelHeight + 4
                        }
                        local overlaps = false
                        for _, used in ipairs(occupied) do
                            if layoutBoundsOverlap(candidate, used) then
                                overlaps = true
                                break
                            end
                        end
                        if not overlaps then
                            selected = {
                                left = candidateLeft,
                                top = candidateTop,
                                width = labelWidth,
                                height = labelHeight,
                                anchorX = anchorX,
                                anchorY = anchorY,
                                bounds = candidate
                            }
                            break
                        end
                    end
                    if selected ~= nil then break end
                end
                if selected ~= nil then break end
            end
            if selected == nil then
                local fallbackLeft = math.max(safeLeft + 6,
                    math.min(safeRight - labelWidth - 6, anchorX + 14))
                local fallbackTop = math.max(safeTop + 4,
                    math.min(safeBottom - labelHeight - 4, anchorY - labelHeight * 0.5))
                selected = {
                    left = fallbackLeft,
                    top = fallbackTop,
                    width = labelWidth,
                    height = labelHeight,
                    anchorX = anchorX,
                    anchorY = anchorY,
                    bounds = {
                        left = fallbackLeft - 6,
                        top = fallbackTop - 4,
                        right = fallbackLeft + labelWidth + 6,
                        bottom = fallbackTop + labelHeight + 4
                    }
                }
            end
            layouts[target.id or target] = selected
            occupied[#occupied + 1] = selected.bounds
        end
    end
    SARNArDrawing.compactLayouts = layouts
end

function SARNArDrawing.getStyles()
    return [=[
<style>
.sarn-ar-object{position:absolute;z-index:2;font:13px Arial,sans-serif;line-height:16px;white-space:nowrap;pointer-events:none}
.sarn-ar-anchor-line{position:absolute;z-index:0;height:2px;background:currentColor;opacity:.62;transform-origin:0 50%;pointer-events:none}
.sarn-ar-label-underline{position:absolute;z-index:1;height:2px;background:currentColor;opacity:.78;pointer-events:none}
.sarn-ar-anchor-dot{position:absolute;z-index:1;width:5px;height:5px;margin:-3px 0 0 -3px;border:1px solid #e8fbff;border-radius:50%;background:currentColor;box-shadow:0 0 5px currentColor;pointer-events:none}
.sarn-ar-compact{display:flex;align-items:flex-start}
.sarn-ar-object.sarn-hover-ready .sarn-ar-compact{margin:-4px -6px;padding:3px 5px;background:rgba(3,12,18,.58);border:1px solid currentColor;box-shadow:0 0 7px currentColor}
.sarn-ar-pinned-badge{display:inline-flex;width:14px;height:22px;margin-left:8px;align-items:center;justify-content:center;align-self:center;flex:none}
.sarn-ar-pinned-badge svg{width:14px;height:14px;fill:currentColor;filter:drop-shadow(0 1px 2px #000)}
.sarn-ar-details{display:none;width:280px;box-sizing:border-box;padding:8px 10px;color:inherit;background:rgba(3,12,18,.68);border:1px solid currentColor;box-shadow:0 0 7px currentColor;white-space:nowrap;overflow:visible}
.sarn-ar-object.sarn-expanded{z-index:1000}
.sarn-ar-object.sarn-expanded .sarn-ar-compact{display:none}
.sarn-ar-object.sarn-expanded .sarn-ar-details{display:block}
.sarn-ar-guide{position:fixed;left:0;top:0;width:100vw;height:100vh;overflow:hidden;pointer-events:none}
.sarn-ar-guide-label{position:fixed;padding:2px 5px;color:inherit;background:rgba(3,12,18,.72);border:1px solid currentColor;font-weight:bold;text-shadow:-2px -2px 2px #000,2px -2px 2px #000,-2px 2px 2px #000,2px 2px 2px #000,0 0 6px #000}
.sarn-ar-parent{height:24px;box-sizing:border-box;margin-bottom:5px;padding:3px 5px;color:#d8edf3;border:1px solid rgba(216,237,243,.42);background:rgba(20,40,50,.48);font-weight:bold}
.sarn-ar-parent.sarn-action-selected{color:#fff;border-color:currentColor;background:rgba(45,85,100,.82);box-shadow:0 0 7px currentColor}
.sarn-ar-children-header{position:relative;display:flex;align-items:center;height:20px;box-sizing:border-box;padding-top:2px;color:#9fc5d2;font-weight:bold}
.sarn-ar-children-list{height:120px;margin-top:4px;box-sizing:border-box;background:rgba(7,22,29,.52);box-shadow:inset 0 0 0 1px rgba(216,237,243,.35);overflow:hidden}
.sarn-ar-child{height:24px;box-sizing:border-box;padding:3px 6px;color:#d8edf3;border-bottom:1px solid rgba(216,237,243,.14);overflow:hidden;text-overflow:ellipsis}
.sarn-ar-child.sarn-action-selected{color:#fff;background:rgba(45,85,100,.88);border:1px solid currentColor;box-shadow:inset 0 0 6px currentColor}
.sarn-ar-children-footer{height:18px;box-sizing:border-box;padding-top:2px;color:#85aeba;text-align:center;font-size:11px}
.sarn-ar-icon{display:inline-block;align-self:center;flex:none;margin-right:8px;color:inherit;filter:drop-shadow(-1px -1px .5px #000) drop-shadow(1px -1px .5px #000) drop-shadow(-1px 1px .5px #000) drop-shadow(1px 1px .5px #000) drop-shadow(0 0 2px #000)}
.sarn-ar-dot{display:inline-block;align-self:center;width:8px;height:8px;margin:7px 15px 7px 7px;border-radius:50%;background:currentColor;border:1px solid #e8fbff;box-shadow:0 0 6px #001820;flex:none}
.sarn-ar-text{text-shadow:-2px -2px 2px #000,2px -2px 2px #000,-2px 2px 2px #000,2px 2px 2px #000,0 0 6px #000}
.sarn-ar-compact-name{font-weight:bold}
.sarn-ar-details-title{position:relative;display:flex;align-items:center;margin-bottom:5px}
.sarn-ar-details-title .sarn-ar-text{min-width:0;padding-right:117px;overflow:hidden;text-overflow:ellipsis}
.sarn-ar-details-name{font-weight:bold}
.sarn-ar-details-secondary{font-weight:normal}
.sarn-ar-details-line{color:#d8edf3;text-shadow:0 1px 2px #000}
.sarn-ar-action-group{position:absolute;right:0;top:-3px;display:flex;align-items:center;gap:3px;flex:none}
.sarn-ar-action{position:relative;display:flex;align-items:center;justify-content:center;width:26px;height:26px;box-sizing:border-box;color:#d8edf3;background:transparent;border:1px solid transparent;border-radius:4px;font:18px Arial,sans-serif;line-height:24px;text-shadow:0 1px 2px #000}
.sarn-ar-action svg{width:18px;height:18px;fill:currentColor;filter:drop-shadow(0 1px 2px #000)}
.sarn-ar-children-actions{top:-2px}
.sarn-ar-children-actions .sarn-ar-action{width:24px;height:24px;font-size:16px;line-height:22px}
.sarn-ar-children-actions .sarn-ar-action svg{width:16px;height:16px}
.sarn-ar-action.sarn-action-selected{color:#fff;background:rgba(45,85,100,.94);border-color:currentColor;box-shadow:0 0 7px currentColor}
.sarn-ar-action.sarn-action-activated{color:#061219;background:rgba(216,237,243,.96);border-color:#fff;box-shadow:0 0 9px currentColor}
.sarn-ar-action.sarn-action-toggled{color:#fff;background:rgba(45,85,100,.72);box-shadow:inset 0 0 0 1px currentColor}
.sarn-ar-action.sarn-action-disabled{color:#8b969a;opacity:.32;background:transparent;border-color:transparent;box-shadow:none}
.sarn-ar-action-tooltip{position:absolute;right:-1px;bottom:calc(100% + 5px);padding:2px 5px;color:#fff;background:rgba(3,12,18,.94);border:1px solid currentColor;font:11px Arial,sans-serif;line-height:14px;white-space:nowrap;text-shadow:0 1px 2px #000}
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

local function projectWorldPointRaw(point)
    local x, y, z = SARN.components(point)
    local projected = x ~= nil and SARN.call(library, "getPointOnScreen", { x, y, z }) or nil
    local sx, sy, sz = SARN.components(projected)
    if sx == nil or sy == nil or sz == nil then return nil end
    return { x = sx, y = sy, visible = sz ~= 0 }
end

local function rayToRectangleEdge(originX, originY, directionX, directionY, bounds)
    local best = math.huge
    if directionX > 0 then best = math.min(best, (bounds.right - originX) / directionX) end
    if directionX < 0 then best = math.min(best, (bounds.left - originX) / directionX) end
    if directionY > 0 then best = math.min(best, (bounds.bottom - originY) / directionY) end
    if directionY < 0 then best = math.min(best, (bounds.top - originY) / directionY) end
    if best == math.huge or best < 0 then return originX, originY end
    return originX + directionX * best, originY + directionY * best
end

local function cameraDirectionToTarget(point)
    local tx, ty, tz = SARN.components(point)
    local cx, cy, cz = SARN.components(SARN.call(system, "getCameraWorldPos"))
    local rx, ry, rz = SARN.components(SARN.call(system, "getCameraWorldRight"))
    local ux, uy, uz = SARN.components(SARN.call(system, "getCameraWorldUp"))
    if tx == nil or cx == nil or rx == nil or ux == nil then return 0, 1 end
    local dx, dy, dz = tx - cx, ty - cy, tz - cz
    local screenX = dx * rx + dy * ry + dz * rz
    local screenY = -(dx * ux + dy * uy + dz * uz)
    if math.abs(screenX) + math.abs(screenY) < 0.000001 then return 0, 1 end
    return screenX, screenY
end

local function drawNavigationGuide(displayTarget, viewBounds, width, height, distance, anchorX, anchorY)
    if displayTarget.worldPosition == nil then return "" end
    local raw = projectWorldPointRaw(displayTarget.worldPosition)
    if raw ~= nil and raw.visible
        and raw.x >= 0.35 and raw.x <= 0.65
        and raw.y >= 0.35 and raw.y <= 0.65 then
        return ""
    end

    local safeBounds = {
        left = width * 0.05,
        top = height * 0.05,
        right = width * 0.95,
        bottom = height * 0.95
    }
    local originX = anchorX or (viewBounds.left + viewBounds.right) * 0.5
    local originY = anchorY or (viewBounds.top + viewBounds.bottom) * 0.5
    local directionX, directionY
    local targetX, targetY
    if raw ~= nil and raw.visible then
        targetX, targetY = raw.x * width, raw.y * height
        directionX, directionY = targetX - originX, targetY - originY
    else
        directionX, directionY = cameraDirectionToTarget(displayTarget.worldPosition)
        targetX, targetY = originX + directionX, originY + directionY
    end
    if math.abs(directionX) + math.abs(directionY) < 0.001 then return "" end

    local endX, endY = targetX, targetY
    if raw == nil or not raw.visible
        or targetX < safeBounds.left or targetX > safeBounds.right
        or targetY < safeBounds.top or targetY > safeBounds.bottom then
        endX, endY = rayToRectangleEdge(originX, originY, directionX, directionY, safeBounds)
    end
    local startX, startY = rayToRectangleEdge(originX, originY, directionX, directionY, viewBounds)
    local lineX, lineY = endX - startX, endY - startY
    local length = math.sqrt(lineX * lineX + lineY * lineY)
    if length < 24 then return "" end

    local angle = math.deg(math.atan(lineY, lineX))
    local arrowCount = math.max(1, math.min(12, math.floor(length / 38)))
    local arrows = {}
    for index = 1, arrowCount do
        local progress = index / (arrowCount + 1)
        local arrowX = startX + lineX * progress
        local arrowY = startY + lineY * progress
        arrows[#arrows + 1] = '<polyline points="-8,-6 0,0 -8,6" transform="translate('
            .. string.format("%.1f %.1f", arrowX, arrowY) .. ') rotate('
            .. string.format("%.1f", angle) .. ')" fill="none" stroke="currentColor" '
            .. 'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" opacity=".5"/>'
    end

    local label = tostring(displayTarget.name or "Location")
    if distance ~= nil then label = label .. " | " .. SARN.formatDistance(distance) end
    local labelWidth = math.max(90, math.min(260, #label * 7.2 + 12))
    local labelLeft = endX > width * 0.5 and endX - labelWidth - 10 or endX + 10
    labelLeft = math.max(safeBounds.left, math.min(safeBounds.right - labelWidth, labelLeft))
    local labelTop = math.max(safeBounds.top, math.min(safeBounds.bottom - 22, endY - 11))
    local pulseRings = {}
    local pulseDuration = 3.6
    local pulseTime = (SARNArDrawing.now or 0) / pulseDuration
    for ringIndex = 0, 2 do
        local phase = (pulseTime + ringIndex / 3) % 1
        local radius = 5 + phase * 65
        local opacity = 0.75 * (1 - phase)
        pulseRings[#pulseRings + 1] = '<circle cx="' .. string.format("%.1f", endX)
            .. '" cy="' .. string.format("%.1f", endY) .. '" r="'
            .. string.format("%.1f", radius)
            .. '" fill="none" stroke="currentColor" stroke-width="4.5" opacity="'
            .. string.format("%.3f", opacity) .. '"/>'
    end
    return '<svg class="sarn-ar-guide" viewBox="0 0 ' .. tostring(width) .. ' ' .. tostring(height)
        .. '"><line x1="' .. string.format("%.1f", startX) .. '" y1="'
        .. string.format("%.1f", startY) .. '" x2="' .. string.format("%.1f", endX)
        .. '" y2="' .. string.format("%.1f", endY)
        .. '" stroke="currentColor" stroke-width="2" opacity=".28"/>'
        .. table.concat(arrows) .. table.concat(pulseRings) .. '<circle cx="'
        .. string.format("%.1f", endX)
        .. '" cy="' .. string.format("%.1f", endY)
        .. '" r="5" fill="currentColor" stroke="#fff" stroke-width="1"/></svg>'
        .. '<div class="sarn-ar-guide-label" style="left:' .. string.format("%.1f", labelLeft)
        .. 'px;top:' .. string.format("%.1f", labelTop) .. 'px;width:'
        .. string.format("%.1f", labelWidth) .. 'px">' .. SARN.escapeHtml(label) .. '</div>'
end

local function detectMockAction(definitions, scope, target, startX, startY, buttonSize, gap)
    for index, definition in ipairs(definitions) do
        local buttonLeft = startX + (index - 1) * (buttonSize + gap)
        local bounds = {
            left = buttonLeft,
            top = startY,
            right = buttonLeft + buttonSize,
            bottom = startY + buttonSize
        }
        local disabled = definition.requiresCoordinate and target.worldPosition == nil
            or (definition.action == "pin-children"
                and #SARNLocationCatalog.getChildren(target) == 0)
        if not disabled and cursorInside(bounds) then
            local actionKey = scope .. ":" .. tostring(target.id or target) .. ":" .. definition.key
            SARNArDrawing.selectedAction = {
                kind = definition.action ~= nil and "node-action" or "mock-action",
                action = definition.action,
                key = actionKey,
                scope = scope,
                title = definition.title,
                target = target
            }
            return actionKey
        end
    end
    return nil
end

local function drawMockActions(definitions, scope, target, selectedKey, className)
    local html = {}
    local now = SARNArDrawing.now or 0
    for _, definition in ipairs(definitions) do
        local actionKey = scope .. ":" .. tostring(target.id or target) .. ":" .. definition.key
        local disabled = definition.requiresCoordinate and target.worldPosition == nil
            or (definition.action == "pin-children"
                and #SARNLocationCatalog.getChildren(target) == 0)
        local selected = selectedKey == actionKey
        local activated = SARNArDrawing.activatedMockActionKey == actionKey
            and now < (SARNArDrawing.activatedMockActionUntil or 0)
        local pinState = getPinState(target, false)
        local toggled = definition.action == "pin-place" and pinState ~= nil and pinState.place
            or definition.action == "pin-children" and pinState ~= nil and pinState.children
        local iconHtml = definition.svg ~= nil
            and ('<svg viewBox="' .. definition.svg.viewBox
                .. '" xmlns="http://www.w3.org/2000/svg">' .. definition.svg.body .. '</svg>')
            or definition.icon
        html[#html + 1] = '<span class="sarn-ar-action'
            .. (selected and ' sarn-action-selected' or '')
            .. (activated and ' sarn-action-activated' or '')
            .. (toggled and ' sarn-action-toggled' or '')
            .. (disabled and ' sarn-action-disabled' or '') .. '">'
            .. iconHtml
            .. (selected and ('<span class="sarn-ar-action-tooltip">'
                .. SARN.escapeHtml(definition.title) .. '</span>') or '')
            .. '</span>'
    end
    return '<span class="sarn-ar-action-group ' .. className .. '">' .. table.concat(html) .. '</span>'
end

function SARNArDrawing.drawConfiguredLocation(target, pinned)
    local projected = SARNArDrawing.projectWorldPoint(target and target.worldPosition)
    if projected == nil
        or projected.x < 0.05 or projected.x > 0.95
        or projected.y < 0.05 or projected.y > 0.95 then
        return "", false
    end
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local x, y = projected.x * width, projected.y * height
    local targetId = target.id or target
    local compactLayout = SARNArDrawing.compactLayouts and SARNArDrawing.compactLayouts[targetId]
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
    if displayTarget.description ~= nil and tostring(displayTarget.description) ~= "" then
        details[#details + 1] = SARN.escapeHtml(displayTarget.description)
    end
    local left = compactLayout and compactLayout.left or x + 14
    local top = compactLayout and compactLayout.top or y - 11
    local compactWidth = compactLayout and compactLayout.width
        or math.max(30, 30 + longestLine * 7.2 + (pinned and 22 or 0))
    local compactHeight = math.max(22, #rawLines * 16)
    local viewBackgroundAlpha = 0.68
    local viewBorderAlpha = 1
    local viewBorderWidth = 1
    local viewRenderTopOffset = 0
    local parent = SARNLocationCatalog.getPrimaryParent(displayTarget)
    local children = SARNLocationCatalog.getChildren(displayTarget)
    local secondaryLabel = displayTarget.label ~= nil and tostring(displayTarget.label) or ""
    local titleExtraHeight = secondaryLabel ~= "" and 16 or 0
    local childrenBlockHeight = #children > 0 and 162 or 20
    local parentSelected = false
    local selectedChildIndex = nil
    local selectedNodeActionKey = nil
    local selectedChildrenActionKey = nil
    local candidate = false
    local expandedViewBounds = nil
    local compactBounds = {
        left = left - 6,
        top = top - 4,
        right = left + compactWidth + 6,
        bottom = top + compactHeight + 4
    }
    if not expanded then
        if cursorInside(compactBounds) and not SARNArDrawing.cursorInsideExpandedView then
            SARNArDrawing.candidateSeen = true
            candidate = true
            SARNArDrawing.selectedAction = {
                kind = "open-compact",
                target = target,
                bounds = compactBounds
            }
            if SARNArDrawing.hoveredTargetId == nil then
                if SARNArDrawing.candidateTargetId ~= targetId then
                    SARNArDrawing.candidateTargetId = targetId
                    SARNArDrawing.candidateSince = SARNArDrawing.now
                end
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
        local viewLeft = left - 12
        local viewBounds = {
            left = viewLeft,
            top = viewTop,
            right = viewLeft + 280,
            bottom = viewTop + 45 + parentHeight + titleExtraHeight
                + #details * 16 + childrenBlockHeight
        }
        if cursorInside(viewBounds) then
            SARNArDrawing.cursorInsideExpandedView = true
            SARNArDrawing.selectedAction = nil
        end
        expandedViewBounds = viewBounds
        if parent ~= nil then
            local parentBounds = {
                left = viewLeft + 10,
                top = viewTop + 8,
                right = viewLeft + 270,
                bottom = viewTop + 32
            }
            parentSelected = cursorInside(parentBounds)
            if parentSelected then
                SARNArDrawing.selectedAction = { kind = "open-parent", target = parent }
            end
        end
        local nodeActionSize, nodeActionGap = 26, 3
        local nodeActionsWidth = #nodeActionMocks * nodeActionSize
            + (#nodeActionMocks - 1) * nodeActionGap
        selectedNodeActionKey = detectMockAction(
            nodeActionMocks,
            "node",
            displayTarget,
            viewLeft + 270 - nodeActionsWidth,
            viewTop + 5 + parentHeight,
            nodeActionSize,
            nodeActionGap)

        local childrenActionSize, childrenActionGap = 24, 3
        local childrenActionsWidth = #childrenActionMocks * childrenActionSize
            + (#childrenActionMocks - 1) * childrenActionGap
        local childrenHeaderTop = viewTop + 9 + parentHeight + 27
            + titleExtraHeight + #details * 16
        if #children > 0 then
            selectedChildrenActionKey = detectMockAction(
                childrenActionMocks,
                "children",
                displayTarget,
                viewLeft + 270 - childrenActionsWidth,
                childrenHeaderTop - 2,
                childrenActionSize,
                childrenActionGap)
        end

        if #children > 0 then
            SARNArDrawing.childScrollByTargetId = SARNArDrawing.childScrollByTargetId or {}
            local maximumStart = math.max(1, #children - 4)
            local scrollStart = math.max(1, math.min(maximumStart,
                tonumber(SARNArDrawing.childScrollByTargetId[displayTarget.id]) or 1))
            local listTop = viewTop + 9 + parentHeight + 27
                + titleExtraHeight + #details * 16 + 24
            local listBounds = {
                left = viewLeft + 10,
                top = listTop,
                right = viewLeft + 270,
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
        local closeDelay = SARNConfiguration.detailsViewCloseDelaySeconds or 2
        local fadeProgress = math.min(1, outsideFor / closeDelay)
        local remainingStrength = 1 - fadeProgress * 0.7
        viewBackgroundAlpha = 0.68 * remainingStrength
        viewBorderAlpha = remainingStrength
        viewBorderWidth = remainingStrength
        if not inside and outsideFor >= closeDelay then
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
    local pinnedBadgeHtml = pinned and ('<span class="sarn-ar-pinned-badge"><svg viewBox="'
        .. pinIcon.viewBox .. '" xmlns="http://www.w3.org/2000/svg">'
        .. pinIcon.body .. '</svg></span>') or ""
    local guideHtml = expanded and expandedViewBounds ~= nil
        and drawNavigationGuide(displayTarget, expandedViewBounds, width, height, distance, x, y) or ""
    local parentHtml = ""
    if parent ~= nil then
        parentHtml = '<div class="sarn-ar-parent' .. (parentSelected and ' sarn-action-selected' or '')
            .. '">&#8593; Parent: ' .. SARN.escapeHtml(parent.name or "Location") .. '</div>'
    end
    local nodeActionsHtml = expanded and drawMockActions(
        nodeActionMocks, "node", displayTarget, selectedNodeActionKey, "sarn-ar-node-actions") or ""
    local childrenActionsHtml = expanded and #children > 0 and drawMockActions(
        childrenActionMocks, "children", displayTarget,
        selectedChildrenActionKey, "sarn-ar-children-actions") or ""
    local childrenHtml = ""
    if expanded then
        childrenHtml = '<div class="sarn-ar-children-header">Children: '
            .. tostring(#children) .. childrenActionsHtml .. '</div>'
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
    local underlineHtml = ""
    local linkX, linkY
    if expanded and expandedViewBounds ~= nil then
        linkX = math.max(expandedViewBounds.left, math.min(expandedViewBounds.right, x))
        linkY = math.max(expandedViewBounds.top, math.min(expandedViewBounds.bottom, y))
    else
        linkX = x <= left + compactWidth * 0.5 and left or left + compactWidth
        linkY = top + compactHeight + 2
        underlineHtml = '<span class="sarn-ar-label-underline" style="left:'
            .. string.format("%.1f", left) .. 'px;top:' .. string.format("%.1f", linkY)
            .. 'px;width:' .. string.format("%.1f", compactWidth)
            .. 'px;color:rgb(' .. color .. ')"></span>'
    end
    local linkDx, linkDy = linkX - x, linkY - y
    local linkLength = math.sqrt(linkDx * linkDx + linkDy * linkDy)
    local anchorHtml = '<span class="sarn-ar-anchor-dot" style="left:'
        .. string.format("%.1f", x) .. 'px;top:' .. string.format("%.1f", y)
        .. 'px;color:rgb(' .. color .. ')"></span>'
    if linkLength > 3 then
        anchorHtml = '<span class="sarn-ar-anchor-line" style="left:'
            .. string.format("%.1f", x) .. 'px;top:' .. string.format("%.1f", y)
            .. 'px;width:' .. string.format("%.1f", linkLength)
            .. 'px;color:rgb(' .. color .. ');transform:rotate('
            .. string.format("%.5f", math.atan(linkDy, linkDx)) .. 'rad)"></span>' .. anchorHtml
    end
    local html = anchorHtml .. underlineHtml
        .. '<div class="sarn-ar-object' .. (expanded and ' sarn-expanded' or '')
        .. (pinned and ' sarn-pinned' or '')
        .. (candidate and ' sarn-hover-ready' or '')
        .. '" style="left:' .. string.format("%.1f", left)
        .. 'px;top:' .. string.format("%.1f", top) .. 'px;color:rgb(' .. color .. ')">' 
        .. guideHtml
        .. '<div class="sarn-ar-compact">' .. markerHtml
        .. '<span class="sarn-ar-text"><span class="sarn-ar-compact-name">' .. lines[1]
        .. '</span>' .. (#lines > 1 and ('<br>' .. table.concat(lines, '<br>', 2)) or '')
        .. '</span>' .. pinnedBadgeHtml .. '</div>'
        .. '<div class="sarn-ar-details" style="transform:translate(-12px,-'
        .. tostring(expanded and viewRenderTopOffset or 0)
        .. 'px);background:rgba(3,12,18,'
        .. string.format("%.3f", viewBackgroundAlpha) .. ');border-color:rgba('
        .. color .. ',' .. string.format("%.3f", viewBorderAlpha) .. ');border-width:'
        .. string.format("%.2f", viewBorderWidth) .. 'px;box-shadow:0 0 7px rgba('
        .. color .. ',' .. string.format("%.3f", viewBorderAlpha) .. ')">' .. parentHtml
        .. '<div class="sarn-ar-details-title">' .. markerHtml
        .. '<span class="sarn-ar-text"><span class="sarn-ar-details-name">'
        .. SARN.escapeHtml(nameAndSize) .. '</span>'
        .. (secondaryLabel ~= "" and ('<br><span class="sarn-ar-details-secondary">'
            .. SARN.escapeHtml(secondaryLabel) .. '</span>') or '')
        .. '</span>' .. nodeActionsHtml .. '</div>'
        .. '<div class="sarn-ar-details-line">' .. table.concat(details, '<br>') .. '</div>'
        .. childrenHtml .. '</div></div>'
    return html, expanded
end
