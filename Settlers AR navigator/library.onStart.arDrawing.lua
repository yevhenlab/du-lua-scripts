-- Projects known world locations and draws interactive compact or hovered AR labels.
-- Library dependencies: ARN helpers and ARNConfiguration.
ARNArDrawing = ARNArDrawing or {}
ARNArDrawing.hoveredTargetId = nil
ARNArDrawing.hoveredBounds = nil
ARNArDrawing.hoveredSeen = false
ARNArDrawing.hoverOutsideSince = nil
ARNArDrawing.candidateTargetId = nil
ARNArDrawing.candidateSince = nil
ARNArDrawing.candidateSeen = false
ARNArDrawing.pins = ARNArDrawing.pins or {}
ARNArDrawing.childSortStateByTargetId = ARNArDrawing.childSortStateByTargetId or {}

local waypointIcon = {
    viewBox = "0 0 26 26",
    body = '<rect height="2" width="7.5" x="18.5" y="12"/><rect height="7.5" width="2" x="14.3" y="16.2"/><rect height="7.5" width="2" x="14.3" y="2.3"/><path d="M7.5 4.2L3.7 2.7l1.5 2.8C-1 7.9.7 13.6.7 13.6.6 10.2 4.5 8.4 6 7.8l.5 3.1 3.8-5.6z"/><polygon points="8.9,14 12,14 12,12 8.9,12"/><rect height="8.2" width="8.2" y="14.4"/><path d="M17.7 3.9v1.5c2.6.8 4.6 2.9 5.4 5.5h1.4c-.8-3.5-3.4-6.1-6.8-7zM23.2 15.2c-.7 2.7-2.8 4.9-5.5 5.7v1.4c3.4-.9 6.1-3.7 6.9-7.2z"/>'
}
local pinIcon = {
    viewBox = "0 0 2.82 2.82",
    body = '<polygon points="2.48 .88 1.95 .34 1.25 .87 1.96 1.57"/><polygon points="0 2.83 1.05 1.42 1.4 1.78"/><polygon points="1.98 0 2 .27 2.56 .82 2.83 .84"/><polygon points="1.32 1.5 1.94 2.11 1.88 1.65 1.18 .94 .72 .9"/>'
}
local coordinatesIcon = {
    viewBox = "0 0 15.8 15.1",
    body = '<path d="M0 15.1v-4.6h4v4H1.4v.7H0zm2.7-2v-1.3H1.4v1.3h1.3zM10 10.4V15H6v-4.6h4zm-1.3 1.4H7.3v2h1.3v-2zM.5 9.6c.9-2.5 3.9-3.9 5.2-4.3l.5 3.2 2.1-3.2L10 2.8 7.3 1.6 3.3 0l1.5 2.8C.5 4.5-.1 7.7 0 9.6h.5zM13.3 10.4h2.3v1.3h-2.3v.3h1c.4 0 .8.1 1.1.4s.4.6.4 1.1-.1.8-.4 1.1-.6.4-1 .4h-2.3v-1.3h2.3v-.3h-1c-.4 0-.8-.1-1.1-.4s-.4-.6-.4-1.1.1-.8.4-1.1.6-.4 1-.4z"/><polygon points="11.1,3 9.5,5.4 9.5,9.4 15.8,9.4 15.8,3"/>'
}

local nodeActionMocks = {
    { key = "set-waypoint", title = "Set waypoint", action = "set-waypoint",
        requiresCoordinate = true, svg = waypointIcon },
    { key = "pin-place", title = "Pin location", action = "pin-place",
        requiresCoordinate = true, svg = pinIcon },
    { key = "coordinates", title = "Show coordinates", action = "coordinates",
        requiresCoordinate = true, svg = coordinatesIcon }
}

local childrenActionMocks = {
    { key = "pin-children", title = "Pin children", action = "pin-children", svg = pinIcon },
    { key = "children-name-order", action = "cycle-children-name-order" },
    { key = "children-distance-order", action = "cycle-children-distance-order" },
    { key = "children-source-filter", action = "cycle-children-source-filter", icon = "&#9661;" }
}

local function pointInside(x, y, bounds)
    return bounds ~= nil and x ~= nil and y ~= nil
        and x >= bounds.left and x <= bounds.right
        and y >= bounds.top and y <= bounds.bottom
end

local function cursorHitMode(bounds)
    for _, candidate in ipairs(ARNArDrawing.cursorCandidates or {}) do
        if pointInside(candidate.x, candidate.y, bounds) then return candidate.name end
    end
    return nil
end

local function cursorInside(bounds)
    return cursorHitMode(bounds) ~= nil
end

local function getPinState(target, create)
    local targetId = target and target.id
    if targetId == nil then return nil end
    local state = ARNArDrawing.pins[targetId]
    if state == nil and create then
        state = { target = target, place = false, children = false }
        ARNArDrawing.pins[targetId] = state
    end
    return state
end

local function togglePin(target, mode)
    local state = getPinState(target, true)
    if state == nil then return false end
    state[mode] = not state[mode]
    if not state.place and not state.children then ARNArDrawing.pins[target.id] = nil end
    return state[mode]
end
local function getChildSortState(target, create)
    local targetId = target and target.id
    if targetId == nil then return nil end
    local state = ARNArDrawing.childSortStateByTargetId[targetId]
    if state == nil and create then
        state = { name = 0, distance = 0, sourceIndex = 0 }
        ARNArDrawing.childSortStateByTargetId[targetId] = state
    end
    return state
end

function ARNArDrawing.isTargetPinned(target)
    local ownState = getPinState(target, false)
    if ownState ~= nil and ownState.place then return true end
    for _, state in pairs(ARNArDrawing.pins) do
        if state.children and state.target ~= nil then
            for _, child in ipairs(ARNLocationCatalog.getChildren(state.target)) do
                if child.id == target.id then return true end
            end
        end
    end
    return false
end

function ARNArDrawing.getPinnedEntries()
    local entries = {}
    for _, state in pairs(ARNArDrawing.pins) do
        if state.target ~= nil and (state.place or state.children) then
            entries[#entries + 1] = {
                name = state.target.name or "Location",
                mode = state.place and state.children and "place + children"
                    or (state.place and "place" or "children"),
                color = state.target.visibilityColor or state.target.color
            }
        end
    end
    table.sort(entries, function(first, second)
        return string.lower(tostring(first.name)) < string.lower(tostring(second.name))
    end)
    return entries
end

function ARNArDrawing.getPinMenuEntries()
    local entries = {}
    for targetId, state in pairs(ARNArDrawing.pins) do
        if state.target ~= nil then
            local name = tostring(state.target.name or "Location")
            local parent = ARNLocationCatalog.getPrimaryParent(state.target)
            local qualifiedName = parent ~= nil
                and (tostring(parent.name or "Location") .. " > " .. name) or name
            if state.place then
                entries[#entries + 1] = {
                    targetId = targetId, mode = "place", label = qualifiedName
                }
            end
            if state.children then
                entries[#entries + 1] = {
                    targetId = targetId, mode = "children", label = qualifiedName .. " children"
                }
            end
        end
    end
    table.sort(entries, function(first, second)
        local firstLabel, secondLabel = string.lower(first.label), string.lower(second.label)
        if firstLabel == secondLabel then return first.mode < second.mode end
        return firstLabel < secondLabel
    end)
    return entries
end

function ARNArDrawing.setPinMode(targetId, mode, enabled)
    if mode ~= "place" and mode ~= "children" then return false end
    local state = ARNArDrawing.pins[targetId]
    if state == nil then return false end
    state[mode] = enabled == true
    if not state.place and not state.children then ARNArDrawing.pins[targetId] = nil end
    return true
end

function ARNArDrawing.clearPins()
    ARNArDrawing.pins = {}
end

function ARNArDrawing.getPersistedPins()
    local entries = {}
    for _, state in pairs(ARNArDrawing.pins) do
        local persistenceKey = state.target and state.target.persistenceKey
        if persistenceKey ~= nil then
            if state.place then
                entries[#entries + 1] = { key = persistenceKey, mode = "place" }
            end
            if state.children then
                entries[#entries + 1] = { key = persistenceKey, mode = "children" }
            end
        end
    end
    table.sort(entries, function(first, second)
        if first.key == second.key then return first.mode < second.mode end
        return first.key < second.key
    end)
    return entries
end

function ARNArDrawing.restorePins(entries)
    ARNArDrawing.pins = {}
    for _, entry in ipairs(type(entries) == "table" and entries or {}) do
        local target = ARNLocationCatalog.getTargetByPersistenceKey(entry.key)
        if target ~= nil and (entry.mode == "place" or entry.mode == "children") then
            local state = getPinState(target, true)
            state[entry.mode] = true
        end
    end
end

function ARNArDrawing.beginFrame()
    local screenWidth = tonumber(ARN.call(system, "getScreenWidth")) or 1920
    local screenHeight = tonumber(ARN.call(system, "getScreenHeight")) or 1080
    -- With the normal locked game view, the visible aiming cursor is fixed at screen centre.
    -- getMousePosX/Y describes separate flight/free-look input and must not drive AR hover.
    local candidates = {
        { name = "screenCenter", x = screenWidth * 0.5, y = screenHeight * 0.5 }
    }
    ARNArDrawing.cursorCandidates = candidates
    ARNArDrawing.screenWidth = screenWidth
    ARNArDrawing.screenHeight = screenHeight
    ARNArDrawing.selectedAction = nil
    ARNArDrawing.cursorInsideExpandedView = false
    ARNArDrawing.childrenListHovered = false
    ARNArDrawing.now = tonumber(ARN.call(system, "getArkTime")) or 0
    ARNArDrawing.hoveredSeen = false
    ARNArDrawing.candidateSeen = false
end

function ARNArDrawing.endFrame()
    if ARNArDrawing.hoveredTargetId ~= nil and not ARNArDrawing.hoveredSeen then
        ARNArDrawing.hoveredTargetId = nil
        ARNArDrawing.hoveredBounds = nil
        ARNArDrawing.hoverOutsideSince = nil
        ARNArDrawing.viewContentTarget = nil
        ARNArDrawing.viewTopOffset = nil
        ARNArDrawing.navigationBounds = nil
        ARNArDrawing.navigationUntil = nil
    end
    if ARNArDrawing.candidateTargetId ~= nil and not ARNArDrawing.candidateSeen then
        ARNArDrawing.candidateTargetId = nil
        ARNArDrawing.candidateSince = nil
    end
end

function ARNArDrawing.captureMouseWheel()
    local wheel = tonumber(ARN.call(system, "getMouseWheel")) or 0
    local previous = ARNArDrawing.previousMouseWheel or 0
    if ARNArDrawing.childrenListHovered and wheel ~= 0 and previous == 0 then
        ARNArDrawing.pendingMouseWheel = (ARNArDrawing.pendingMouseWheel or 0) + (wheel > 0 and 1 or -1)
    end
    ARNArDrawing.previousMouseWheel = wheel
end

function ARNArDrawing.activateSelectedAction()
    local action = ARNArDrawing.selectedAction
    if type(action) ~= "table" or action.target == nil then return false end
    if action.kind == "open-compact" then
        local target = action.target
        ARNArDrawing.hoveredTargetId = target.id or target
        ARNArDrawing.hoveredBounds = action.bounds
        ARNArDrawing.viewContentTarget = target
        ARNArDrawing.viewTopOffset =
            (ARNLocationCatalog.getPrimaryParent(target) ~= nil and 29 or 0) + 8
        ARNArDrawing.hoverOutsideSince = nil
        ARNArDrawing.navigationBounds = action.bounds
        ARNArDrawing.navigationUntil =
            (tonumber(ARN.call(system, "getArkTime")) or ARNArDrawing.now or 0) + 1
        ARNArDrawing.candidateTargetId = nil
        ARNArDrawing.candidateSince = nil
        return true
    end
    if action.kind == "node-action" then
        ARNArDrawing.activatedMockActionKey = action.key
        ARNArDrawing.activatedMockActionUntil =
            (tonumber(ARN.call(system, "getArkTime")) or ARNArDrawing.now or 0) + 0.5
        local target = action.target
        local name = tostring(target.name or "Location")
        if action.action == "set-waypoint" then
            local waypoint = type(target.sourceCoordinate) == "string" and target.sourceCoordinate
                or ARN.worldPositionString(target.worldPosition)
            if waypoint == nil then return false end
            local ok = pcall(system.setWaypoint, waypoint, true)
            if ok then system.print(ARN.chatPrefix() .. 'Waypoint set to "' .. name .. '".') end
            return ok
        elseif action.action == "coordinates" then
            local coordinateBody = ARNLocationCatalog.getNearestCoordinateBody(target)
            local planetCoordinate = ARN.bodyRelativePositionString(
                target.worldPosition, coordinateBody)
            if planetCoordinate == nil then
                planetCoordinate = ARN.closestPlanetPositionString(target.worldPosition)
            end
            local worldCoordinate = ARN.worldPositionString(target.worldPosition)
            if worldCoordinate == nil then return false end
            system.print(ARN.chatPrefix() .. '"' .. name .. '" | planet: '
                .. (planetCoordinate or "unavailable (unknown body ID)")
                .. ' | world: ' .. worldCoordinate)
            return true
        elseif action.action == "pin-place" then
            local pinned = togglePin(target, "place")
            system.print(ARN.chatPrefix() .. '"' .. name .. '" ' .. (pinned and "pinned." or "unpinned."))
            return true
        elseif action.action == "pin-children" then
            local pinned = togglePin(target, "children")
            system.print(ARN.chatPrefix() .. 'Children of "' .. name .. '" '
                .. (pinned and "pinned." or "unpinned."))
            return true
        elseif action.action == "cycle-children-name-order" then
            local state = getChildSortState(target, true)
            state.name = (state.name + 1) % 3
            if state.name ~= 0 then state.distance = 0 end
            ARNArDrawing.childScrollByTargetId = ARNArDrawing.childScrollByTargetId or {}
            ARNArDrawing.childScrollByTargetId[target.id] = 1
            return true
        elseif action.action == "cycle-children-distance-order" then
            local state = getChildSortState(target, true)
            state.distance = (state.distance + 1) % 3
            if state.distance ~= 0 then state.name = 0 end
            ARNArDrawing.childScrollByTargetId = ARNArDrawing.childScrollByTargetId or {}
            ARNArDrawing.childScrollByTargetId[target.id] = 1
            return true
        elseif action.action == "cycle-children-source-filter" then
            local state = getChildSortState(target, true)
            local sourceCount = #ARNLocationCatalog.getSources()
            state.sourceIndex = ((tonumber(state.sourceIndex) or 0) + 1) % (sourceCount + 1)
            ARNArDrawing.childScrollByTargetId = ARNArDrawing.childScrollByTargetId or {}
            ARNArDrawing.childScrollByTargetId[target.id] = 1
            return true
        end
        return false
    end
    if action.kind == "mock-action" then
        ARNArDrawing.activatedMockActionKey = action.key
        ARNArDrawing.activatedMockActionUntil =
            (tonumber(ARN.call(system, "getArkTime")) or ARNArDrawing.now or 0) + 0.5
        return true
    end
    if action.kind ~= "open-parent" and action.kind ~= "open-child" then return false end
    ARNArDrawing.navigationBounds = ARNArDrawing.hoveredBounds
    ARNArDrawing.navigationUntil = (tonumber(ARN.call(system, "getArkTime")) or ARNArDrawing.now or 0) + 1
    ARNArDrawing.viewContentTarget = action.target
    ARNArDrawing.hoverOutsideSince = nil
    ARNArDrawing.candidateTargetId = nil
    ARNArDrawing.candidateSince = nil
    return true
end

function ARNArDrawing.projectWorldPoint(point)
    local x, y, z = ARN.components(point)
    local projected = x ~= nil and ARN.call(library, "getPointOnScreen", { x, y, z }) or nil
    local sx, sy, sz = ARN.components(projected)
    if sx == nil or sy == nil or sz == 0 or sx < 0 or sx > 1 or sy < 0 or sy > 1 then return nil end
    return { x = sx, y = sy }
end

local function displayPosition(target)
    return target and (target.displayPosition or target.worldPosition) or nil
end

local function compactLayoutSize(target, cameraPosition, pinned)
    local name = tostring(target.name or "Location")
    if target.coreSize ~= nil and target.coreSize ~= "?" then
        name = name .. " [" .. tostring(target.coreSize) .. "]"
    end
    local distance = ARN.distance(cameraPosition, displayPosition(target))
    if distance ~= nil then name = name .. " | " .. ARN.formatDistance(distance) end
    local longest = #name
    local lineCount = 1
    if target.owner ~= nil and tostring(target.owner) ~= "" then
        local owner = "Owner: " .. tostring(target.owner)
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

function ARNArDrawing.prepareCompactLayout(targets)
    local width = ARNArDrawing.screenWidth or tonumber(ARN.call(system, "getScreenWidth")) or 1920
    local height = ARNArDrawing.screenHeight or tonumber(ARN.call(system, "getScreenHeight")) or 1080
    local cameraPosition = ARN.call(system, "getCameraWorldPos")
    local safeLeft, safeRight = width * 0.05, width * 0.95
    local safeTop, safeBottom = height * 0.05, height * 0.95
    local occupied = {}
    local layouts = {}

    -- Targets arrive farthest-first for paint order. Allocate nearest-first so the
    -- most relevant labels retain the slots closest to their projected points.
    for targetIndex = #targets, 1, -1 do
        local target = targets[targetIndex]
        local projected = ARNArDrawing.projectWorldPoint(displayPosition(target))
        if projected ~= nil and projected.x >= 0.05 and projected.x <= 0.95
            and projected.y >= 0.05 and projected.y <= 0.95 then
            local anchorX, anchorY = projected.x * width, projected.y * height
            local labelWidth, labelHeight = compactLayoutSize(
                target, cameraPosition, ARNArDrawing.isTargetPinned(target))
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
    ARNArDrawing.compactLayouts = layouts
end

function ARNArDrawing.getStyles()
    return [=[
<style>
.arn-ar-object{position:absolute;z-index:2;font:13px Arial,sans-serif;line-height:16px;white-space:nowrap;pointer-events:none}
.arn-ar-anchor-line{position:absolute;z-index:0;height:2px;background:currentColor;opacity:.62;transform-origin:0 50%;pointer-events:none}
.arn-ar-label-underline{position:absolute;z-index:1;height:2px;background:currentColor;opacity:.78;pointer-events:none}
.arn-ar-anchor-dot{position:absolute;z-index:1;width:5px;height:5px;margin:-3px 0 0 -3px;border:1px solid #e8fbff;border-radius:50%;background:currentColor;box-shadow:0 0 5px currentColor;pointer-events:none}
.arn-ar-compact{display:flex;align-items:flex-start}
.arn-ar-object.arn-hover-ready .arn-ar-compact{margin:-4px -6px;padding:3px 5px;background:rgba(3,12,18,.58);border:1px solid currentColor;box-shadow:0 0 7px currentColor}
.arn-ar-pinned-badge{display:inline-flex;width:14px;height:22px;margin-left:8px;align-items:center;justify-content:center;align-self:center;flex:none}
.arn-ar-pinned-badge svg{width:14px;height:14px;fill:currentColor;filter:drop-shadow(0 1px 2px #000)}
.arn-ar-details{display:none;width:280px;box-sizing:border-box;padding:8px 10px;color:inherit;background:rgba(3,12,18,.68);border:1px solid currentColor;box-shadow:0 0 7px currentColor;white-space:nowrap;overflow:visible}
.arn-ar-object.arn-expanded{z-index:1000}
.arn-ar-object.arn-expanded .arn-ar-compact{display:none}
.arn-ar-object.arn-expanded .arn-ar-details{display:block}
.arn-ar-bounds{position:fixed;left:0;top:0;width:100vw;height:100vh;overflow:hidden;pointer-events:none;z-index:0}
.arn-ar-guide{position:fixed;left:0;top:0;width:100vw;height:100vh;overflow:hidden;pointer-events:none}
.arn-ar-guide-label{position:fixed;padding:2px 5px;color:inherit;background:rgba(3,12,18,.72);border:1px solid currentColor;font-weight:bold;text-shadow:-2px -2px 2px #000,2px -2px 2px #000,-2px 2px 2px #000,2px 2px 2px #000,0 0 6px #000}
.arn-ar-parent{height:24px;box-sizing:border-box;margin-bottom:5px;padding:3px 5px;color:#d8edf3;border:1px solid rgba(216,237,243,.42);background:rgba(20,40,50,.48);font-weight:bold}
.arn-ar-parent.arn-action-selected{color:#fff;border-color:currentColor;background:rgba(45,85,100,.82);box-shadow:0 0 7px currentColor}
.arn-ar-children-header{position:relative;display:flex;align-items:center;height:20px;box-sizing:border-box;padding-top:2px;color:#9fc5d2;font-weight:bold}
.arn-ar-children-list{height:120px;margin-top:4px;box-sizing:border-box;background:rgba(7,22,29,.52);box-shadow:inset 0 0 0 1px rgba(216,237,243,.35);overflow:hidden}
.arn-ar-child{height:24px;box-sizing:border-box;padding:3px 6px;color:#d8edf3;border-bottom:1px solid rgba(216,237,243,.14);overflow:hidden;text-overflow:ellipsis}
.arn-ar-child.arn-action-selected{color:#fff;background:rgba(45,85,100,.88);border:1px solid currentColor;box-shadow:inset 0 0 6px currentColor}
.arn-ar-children-footer{height:18px;box-sizing:border-box;padding-top:2px;color:#85aeba;text-align:center;font-size:11px}
.arn-ar-icon{display:inline-block;align-self:center;flex:none;margin-right:8px;color:inherit;filter:drop-shadow(-1px -1px .5px #000) drop-shadow(1px -1px .5px #000) drop-shadow(-1px 1px .5px #000) drop-shadow(1px 1px .5px #000) drop-shadow(0 0 2px #000)}
.arn-ar-text{text-shadow:-2px -2px 2px #000,2px -2px 2px #000,-2px 2px 2px #000,2px 2px 2px #000,0 0 6px #000}
.arn-ar-compact-name{font-weight:bold}
.arn-ar-details-title{position:relative;display:flex;align-items:center;margin-bottom:5px}
.arn-ar-details-title .arn-ar-text{min-width:0;padding-right:117px;overflow:hidden;text-overflow:ellipsis}
.arn-ar-details-name{font-weight:bold}
.arn-ar-details-secondary{font-weight:normal}
.arn-ar-details-line{color:#d8edf3;text-shadow:0 1px 2px #000}
.arn-ar-action-group{position:absolute;right:0;top:-3px;display:flex;align-items:center;gap:3px;flex:none}
.arn-ar-action{position:relative;display:flex;align-items:center;justify-content:center;width:26px;height:26px;box-sizing:border-box;color:#d8edf3;background:transparent;border:1px solid transparent;border-radius:4px;font:18px Arial,sans-serif;line-height:24px;text-shadow:0 1px 2px #000}
.arn-ar-action svg{width:18px;height:18px;fill:currentColor;filter:drop-shadow(0 1px 2px #000)}
.arn-ar-children-actions{top:-2px}
.arn-ar-action.arn-action-selected{color:#fff;background:rgba(45,85,100,.94);border-color:currentColor;box-shadow:0 0 7px currentColor}
.arn-ar-action.arn-action-activated{color:#061219;background:rgba(216,237,243,.96);border-color:#fff;box-shadow:0 0 9px currentColor}
.arn-ar-action.arn-action-toggled{color:#fff;background:rgba(45,85,100,.72);box-shadow:inset 0 0 0 1px currentColor}
.arn-ar-action.arn-action-disabled{color:#8b969a;opacity:.32;background:transparent;border-color:transparent;box-shadow:none}
.arn-ar-action-tooltip{position:absolute;right:-1px;bottom:calc(100% + 5px);padding:2px 5px;color:#fff;background:rgba(3,12,18,.94);border:1px solid currentColor;font:11px Arial,sans-serif;line-height:14px;white-space:nowrap;text-shadow:0 1px 2px #000}
</style>
]=]
end

local function drawMarker(target)
    local definition = target and target.iconDefinition
    if type(definition) ~= "table" then return "" end
    local size = 22
    local scale = math.max(0.1, math.min(1, tonumber(definition.scale) or 1))
    local body = definition.body
    if scale ~= 1 then
        local offset = 150 * (1 - scale)
        body = '<g transform="translate(' .. string.format("%.2f", offset) .. ' '
            .. string.format("%.2f", offset) .. ') scale(' .. string.format("%.3f", scale) .. ')">'
            .. body .. '</g>'
    end
    return '<span class="arn-ar-icon" style="width:' .. tostring(size) .. 'px;height:'
        .. tostring(size) .. 'px">'
        .. '<svg width="' .. tostring(size) .. '" height="' .. tostring(size)
        .. '" viewBox="' .. ARN.escapeHtml(definition.viewBox)
        .. '" fill="currentColor" xmlns="http://www.w3.org/2000/svg">' .. body .. '</svg></span>'
end

local function projectWorldPointRaw(point)
    local x, y, z = ARN.components(point)
    local projected = x ~= nil and ARN.call(library, "getPointOnScreen", { x, y, z }) or nil
    local sx, sy, sz = ARN.components(projected)
    if sx == nil or sy == nil or sz == nil then return nil end
    return { x = sx, y = sy, visible = sz ~= 0 }
end

local function drawBoundsRings(target, color, width, height)
    local center = target and target.boundsCenter
    local radiusX = tonumber(target and target.boundsRadiusX)
    local radiusY = tonumber(target and target.boundsRadiusY)
    local radiusZ = tonumber(target and target.boundsRadiusZ)
    if center == nil or radiusX == nil or radiusY == nil or radiusZ == nil
        or radiusX <= 0 or radiusY <= 0 or radiusZ <= 0 then return "" end

    local seed = tonumber(target.id) or 0
    local now = ARNArDrawing.now or 0
    local function driftingAngle(phaseSeed, basePeriod, amplitude, variationPeriod)
        -- Base rate is 2x; the smooth field changes it between 1.5x and 2.5x.
        local phase = 2 * now / basePeriod
            - 0.5 * variationPeriod / basePeriod * math.cos(now / variationPeriod + phaseSeed)
            + 0.32 * math.sin(now / (variationPeriod * 1.61) + phaseSeed * 1.17)
        return math.sin(phase + phaseSeed) * amplitude
    end
    local planes = {
        { { 1, 0, 0 }, { 0, 1, 0 } },
        { { 1, 0, 0 }, { 0, 0, 1 } }
    }
    local paths = {}
    local segments = 24
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for ringIndex, plane in ipairs(planes) do
        local ringSeed = seed + ringIndex * 97.31
        local rotationX = (ringSeed % 37) * 0.13 + driftingAngle(ringSeed, 5.5, 0.55, 13)
        local rotationY = (ringSeed % 53) * 0.11 + driftingAngle(ringSeed * 0.7, 7, 0.48, 17)
        local rotationZ = (ringSeed % 71) * 0.09 + driftingAngle(ringSeed * 1.3, 9, 0.42, 21)
        local cosX, sinX = math.cos(rotationX), math.sin(rotationX)
        local cosY, sinY = math.cos(rotationY), math.sin(rotationY)
        local cosZ, sinZ = math.cos(rotationZ), math.sin(rotationZ)
        local function rotate(x, y, z)
            local y1, z1 = y * cosX - z * sinX, y * sinX + z * cosX
            local x2, z2 = x * cosY + z1 * sinY, -x * sinY + z1 * cosY
            return x2 * cosZ - y1 * sinZ, x2 * sinZ + y1 * cosZ, z2
        end
        local current = {}
        for index = 0, segments do
            local angle = (index / segments) * math.pi * 2
            local cosine, sine = math.cos(angle), math.sin(angle)
            local unitX = plane[1][1] * cosine + plane[2][1] * sine
            local unitY = plane[1][2] * cosine + plane[2][2] * sine
            local unitZ = plane[1][3] * cosine + plane[2][3] * sine
            local offsetX, offsetY, offsetZ = rotate(unitX, unitY, unitZ)
            local point = {
                x = center.x + offsetX * radiusX,
                y = center.y + offsetY * radiusY,
                z = center.z + offsetZ * radiusZ
            }
            local projected = projectWorldPointRaw(point)
            if projected ~= nil and projected.visible then
                local screenX, screenY = projected.x * width, projected.y * height
                minX, maxX = math.min(minX, screenX), math.max(maxX, screenX)
                minY, maxY = math.min(minY, screenY), math.max(maxY, screenY)
                current[#current + 1] = string.format("%.1f,%.1f", screenX, screenY)
            elseif #current > 1 then
                paths[#paths + 1] = '<polyline points="' .. table.concat(current, " ") .. '"/>'
                current = {}
            else
                current = {}
            end
        end
        if #current > 1 then paths[#paths + 1] = '<polyline points="' .. table.concat(current, " ") .. '"/>' end
    end
    if #paths == 0 then return "" end
    local screenLimit = math.min(width, height)
    local projectedSize = math.max(maxX - minX, maxY - minY)
    local ringKey = tostring(target.id or target.name or target)
    ARNArDrawing.boundsRingsSuppressed = ARNArDrawing.boundsRingsSuppressed or {}
    local suppressed = ARNArDrawing.boundsRingsSuppressed[ringKey] == true
    if suppressed then
        if projectedSize < screenLimit * (2 / 3) then
            ARNArDrawing.boundsRingsSuppressed[ringKey] = nil
        else
            return ""
        end
    elseif projectedSize > screenLimit * (3 / 4) then
        ARNArDrawing.boundsRingsSuppressed[ringKey] = true
        return ""
    end
    local dashOffset = (((ARNArDrawing.now or 0) * 1.5) % 16) / 16 * 52
    return '<svg class="arn-ar-bounds" viewBox="0 0 ' .. tostring(width) .. ' ' .. tostring(height)
        .. '" fill="none" stroke="rgb(' .. tostring(color) .. ')" stroke-width="1.5"'
        .. ' stroke-dasharray="7 6" stroke-dashoffset="' .. string.format("%.2f", dashOffset)
        .. '" stroke-linecap="round" opacity=".5">'
        .. table.concat(paths) .. '</svg>'
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
    local tx, ty, tz = ARN.components(point)
    local cx, cy, cz = ARN.components(ARN.call(system, "getCameraWorldPos"))
    local rx, ry, rz = ARN.components(ARN.call(system, "getCameraWorldRight"))
    local ux, uy, uz = ARN.components(ARN.call(system, "getCameraWorldUp"))
    if tx == nil or cx == nil or rx == nil or ux == nil then return 0, 1 end
    local dx, dy, dz = tx - cx, ty - cy, tz - cz
    local screenX = dx * rx + dy * ry + dz * rz
    local screenY = -(dx * ux + dy * uy + dz * uz)
    if math.abs(screenX) + math.abs(screenY) < 0.000001 then return 0, 1 end
    return screenX, screenY
end

local function drawNavigationGuide(displayTarget, viewBounds, width, height, distance, anchorX, anchorY)
    local position = displayPosition(displayTarget)
    if position == nil then return "" end
    local raw = projectWorldPointRaw(position)
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
        directionX, directionY = cameraDirectionToTarget(position)
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
    if distance ~= nil then label = label .. " | " .. ARN.formatDistance(distance) end
    local labelWidth = math.max(90, math.min(260, #label * 7.2 + 12))
    local labelLeft = endX > width * 0.5 and endX - labelWidth - 10 or endX + 10
    labelLeft = math.max(safeBounds.left, math.min(safeBounds.right - labelWidth, labelLeft))
    local labelTop = math.max(safeBounds.top, math.min(safeBounds.bottom - 22, endY - 11))
    local pulseRings = {}
    local pulseDuration = 3.6
    local pulseTime = (ARNArDrawing.now or 0) / pulseDuration
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
    return '<svg class="arn-ar-guide" viewBox="0 0 ' .. tostring(width) .. ' ' .. tostring(height)
        .. '"><line x1="' .. string.format("%.1f", startX) .. '" y1="'
        .. string.format("%.1f", startY) .. '" x2="' .. string.format("%.1f", endX)
        .. '" y2="' .. string.format("%.1f", endY)
        .. '" stroke="currentColor" stroke-width="2" opacity=".28"/>'
        .. table.concat(arrows) .. table.concat(pulseRings) .. '<circle cx="'
        .. string.format("%.1f", endX)
        .. '" cy="' .. string.format("%.1f", endY)
        .. '" r="5" fill="currentColor" stroke="#fff" stroke-width="1"/></svg>'
        .. '<div class="arn-ar-guide-label" style="left:' .. string.format("%.1f", labelLeft)
        .. 'px;top:' .. string.format("%.1f", labelTop) .. 'px;width:'
        .. string.format("%.1f", labelWidth) .. 'px">' .. ARN.escapeHtml(label) .. '</div>'
end

local function actionPresentation(definition, target)
    local state = getChildSortState(target, false) or { name = 0, distance = 0 }
    if definition.action == "cycle-children-name-order" then
        if state.name == 1 then
            return "Name order: A to Z", '<span style="font-size:9px">A&#8594;Z</span>', true
        elseif state.name == 2 then
            return "Name order: Z to A", '<span style="font-size:9px">Z&#8594;A</span>', true
        end
        return "Name order: default", '<span style="font-size:11px">A&#8645;</span>', false
    elseif definition.action == "cycle-children-distance-order" then
        if state.distance == 1 then
            return "Distance: near to far", '<span style="font-size:9px">N&#8594;F</span>', true
        elseif state.distance == 2 then
            return "Distance: far to near", '<span style="font-size:9px">F&#8594;N</span>', true
        end
        return "Distance: default", '<span style="font-size:11px">D&#8645;</span>', false
    elseif definition.action == "cycle-children-source-filter" then
        local sources = ARNLocationCatalog.getSources()
        local sourceIndex = tonumber(state.sourceIndex) or 0
        local source = sourceIndex > 0 and sources[sourceIndex] or nil
        if source ~= nil then
            return "Source: " .. tostring(source.label or source.module or source.sourceId),
                '<span style="font-size:10px">' .. tostring(source.sourceId) .. '</span>', true
        end
        return "Source: All", definition.icon, false
    end
    return definition.title, definition.icon, false
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
                and #ARNLocationCatalog.getChildren(target) == 0)
        if not disabled and cursorInside(bounds) then
            local actionKey = scope .. ":" .. tostring(target.id or target) .. ":" .. definition.key
            local title = actionPresentation(definition, target)
            ARNArDrawing.selectedAction = {
                kind = definition.action ~= nil and "node-action" or "mock-action",
                action = definition.action,
                key = actionKey,
                scope = scope,
                title = title,
                target = target
            }
            return actionKey
        end
    end
    return nil
end

local function drawMockActions(definitions, scope, target, selectedKey, className)
    local html = {}
    local now = ARNArDrawing.now or 0
    for _, definition in ipairs(definitions) do
        local actionKey = scope .. ":" .. tostring(target.id or target) .. ":" .. definition.key
        local disabled = definition.requiresCoordinate and target.worldPosition == nil
            or (definition.action == "pin-children"
                and #ARNLocationCatalog.getChildren(target) == 0)
        local selected = selectedKey == actionKey
        local activated = ARNArDrawing.activatedMockActionKey == actionKey
            and now < (ARNArDrawing.activatedMockActionUntil or 0)
        local pinState = getPinState(target, false)
        local title, presentedIcon, sortToggled = actionPresentation(definition, target)
        local toggled = definition.action == "pin-place" and pinState ~= nil and pinState.place
            or definition.action == "pin-children" and pinState ~= nil and pinState.children
            or sortToggled
        local iconHtml = definition.svg ~= nil
            and ('<svg viewBox="' .. definition.svg.viewBox
                .. '" xmlns="http://www.w3.org/2000/svg">' .. definition.svg.body .. '</svg>')
            or presentedIcon or ""
        html[#html + 1] = '<span class="arn-ar-action'
            .. (selected and ' arn-action-selected' or '')
            .. (activated and ' arn-action-activated' or '')
            .. (toggled and ' arn-action-toggled' or '')
            .. (disabled and ' arn-action-disabled' or '') .. '">'
            .. iconHtml
            .. (selected and ('<span class="arn-ar-action-tooltip">'
                .. ARN.escapeHtml(title) .. '</span>') or '')
            .. '</span>'
    end
    return '<span class="arn-ar-action-group ' .. className .. '">' .. table.concat(html) .. '</span>'
end

function ARNArDrawing.drawConfiguredLocation(target, pinned)
    local projected = ARNArDrawing.projectWorldPoint(displayPosition(target))
    if projected == nil
        or projected.x < 0.05 or projected.x > 0.95
        or projected.y < 0.05 or projected.y > 0.95 then
        return "", false
    end
    local width = tonumber(system.getScreenWidth()) or 1920
    local height = tonumber(system.getScreenHeight()) or 1080
    local x, y = projected.x * width, projected.y * height
    local targetId = target.id or target
    local compactLayout = ARNArDrawing.compactLayouts and ARNArDrawing.compactLayouts[targetId]
    local expanded = ARNArDrawing.hoveredTargetId == targetId
    local displayTarget = expanded and (ARNArDrawing.viewContentTarget or target) or target
    local color = displayTarget.visibilityColor or displayTarget.color or ARNConfiguration.markerColor
    local nameAndSize = tostring(displayTarget.name or "Location")
    if displayTarget.coreSize ~= nil and displayTarget.coreSize ~= "?" then
        nameAndSize = nameAndSize .. " [" .. tostring(displayTarget.coreSize) .. "]"
    end
    local cameraPosition = system.getCameraWorldPos()
    local distance = ARN.distance(cameraPosition, displayPosition(displayTarget))
    if distance ~= nil then nameAndSize = nameAndSize .. " | " .. ARN.formatDistance(distance) end
    local rawLines = { nameAndSize }
    if displayTarget.owner ~= nil and tostring(displayTarget.owner) ~= "" then
        rawLines[#rawLines + 1] = "Owner: " .. tostring(displayTarget.owner)
    end
    if displayTarget.label ~= nil and tostring(displayTarget.label) ~= "" then
        rawLines[#rawLines + 1] = tostring(displayTarget.label)
    end
    local lines = {}
    local longestLine = 0
    for _, line in ipairs(rawLines) do
        lines[#lines + 1] = ARN.escapeHtml(line)
        longestLine = math.max(longestLine, #line)
    end
    local details = {}
    details[#details + 1] = "Type: " .. ARN.escapeHtml(displayTarget.type or "location")
    if displayTarget.areaRadius ~= nil and displayTarget.areaRadius > 0 then
        details[#details + 1] = "Radius: " .. ARN.escapeHtml(ARN.formatDistance(displayTarget.areaRadius))
    end
    if displayTarget.owner ~= nil and tostring(displayTarget.owner) ~= "" then
        details[#details + 1] = ARN.escapeHtml("Owner: " .. tostring(displayTarget.owner))
    end
    if displayTarget.description ~= nil and tostring(displayTarget.description) ~= "" then
        details[#details + 1] = ARN.escapeHtml(displayTarget.description)
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
    local parent = ARNLocationCatalog.getPrimaryParent(displayTarget)
    local childSortState = getChildSortState(displayTarget, false)
        or { name = 0, distance = 0, sourceIndex = 0 }
    local allChildren = ARNLocationCatalog.getChildren(displayTarget)
    local childTotal = #allChildren
    local sources = ARNLocationCatalog.getSources()
    local sourceIndex = tonumber(childSortState.sourceIndex) or 0
    if sourceIndex < 0 or sourceIndex > #sources then sourceIndex = 0 end
    local sourceFilter = sourceIndex > 0 and sources[sourceIndex] or nil
    local children = {}
    for index, child in ipairs(allChildren) do
        if sourceFilter == nil or child.sourceId == sourceFilter.sourceId then
            children[#children + 1] = {
                child = child,
                originalIndex = index,
                distance = childSortState.distance ~= 0
                    and ARN.distance(cameraPosition, displayPosition(child)) or nil
            }
        end
    end
    table.sort(children, function(first, second)
        local firstSatellite = first.child.type == "satellite"
        local secondSatellite = second.child.type == "satellite"
        if firstSatellite ~= secondSatellite then return firstSatellite end
        if childSortState.name ~= 0 then
            local firstName = string.lower(tostring(first.child.name or ""))
            local secondName = string.lower(tostring(second.child.name or ""))
            if firstName ~= secondName then
                if childSortState.name == 1 then return firstName < secondName end
                return firstName > secondName
            end
        elseif childSortState.distance ~= 0 then
            if first.distance == nil then return false end
            if second.distance == nil then return true end
            if first.distance ~= second.distance then
                if childSortState.distance == 1 then return first.distance < second.distance end
                return first.distance > second.distance
            end
        end
        return first.originalIndex < second.originalIndex
    end)
    for index, entry in ipairs(children) do children[index] = entry.child end
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
        if cursorInside(compactBounds) and not ARNArDrawing.cursorInsideExpandedView then
            ARNArDrawing.candidateSeen = true
            candidate = true
            ARNArDrawing.selectedAction = {
                kind = "open-compact",
                target = target,
                bounds = compactBounds
            }
            if ARNArDrawing.hoveredTargetId == nil then
                if ARNArDrawing.candidateTargetId ~= targetId then
                    ARNArDrawing.candidateTargetId = targetId
                    ARNArDrawing.candidateSince = ARNArDrawing.now
                end
                if ARNArDrawing.now - (ARNArDrawing.candidateSince or ARNArDrawing.now) >= 0.5 then
                    ARNArDrawing.hoveredTargetId = targetId
                    ARNArDrawing.viewContentTarget = target
                    ARNArDrawing.viewTopOffset = (parent ~= nil and 29 or 0) + 8
                    ARNArDrawing.hoverOutsideSince = nil
                    ARNArDrawing.candidateTargetId = nil
                    ARNArDrawing.candidateSince = nil
                    expanded = true
                    candidate = false
                end
            end
        elseif ARNArDrawing.candidateTargetId == targetId then
            ARNArDrawing.candidateTargetId = nil
            ARNArDrawing.candidateSince = nil
        end
    end
    if expanded then
        local parentHeight = parent ~= nil and 29 or 0
        local viewTopOffset = ARNArDrawing.viewTopOffset or (parentHeight + 8)
        ARNArDrawing.viewTopOffset = viewTopOffset
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
            ARNArDrawing.cursorInsideExpandedView = true
            ARNArDrawing.selectedAction = nil
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
                ARNArDrawing.selectedAction = { kind = "open-parent", target = parent }
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

        local childrenActionSize, childrenActionGap = nodeActionSize, nodeActionGap
        local childrenActionsWidth = #childrenActionMocks * childrenActionSize
            + (#childrenActionMocks - 1) * childrenActionGap
        local childrenHeaderTop = viewTop + 9 + parentHeight + 27
            + titleExtraHeight + #details * 16
        if childTotal > 0 then
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
            ARNArDrawing.childScrollByTargetId = ARNArDrawing.childScrollByTargetId or {}
            local maximumStart = math.max(1, #children - 4)
            local scrollStart = math.max(1, math.min(maximumStart,
                tonumber(ARNArDrawing.childScrollByTargetId[displayTarget.id]) or 1))
            local listTop = viewTop + 9 + parentHeight + 27
                + titleExtraHeight + #details * 16 + 24
            local listBounds = {
                left = viewLeft + 10,
                top = listTop,
                right = viewLeft + 270,
                bottom = listTop + 120
            }
            local listHovered = cursorInside(listBounds)
            ARNArDrawing.childrenListHovered = listHovered
            local wheel = ARNArDrawing.pendingMouseWheel or 0
            if listHovered and wheel ~= 0 and #children > 5 then
                scrollStart = math.max(1, math.min(maximumStart,
                    scrollStart + (wheel > 0 and -1 or 1)))
                ARNArDrawing.childScrollByTargetId[displayTarget.id] = scrollStart
            end
            ARNArDrawing.pendingMouseWheel = 0
            if listHovered then
                local cursor = ARNArDrawing.cursorCandidates[1]
                local visibleRow = math.floor((cursor.y - listTop) / 24) + 1
                if visibleRow >= 1 and visibleRow <= 5 then
                    local childIndex = scrollStart + visibleRow - 1
                    if childIndex <= #children then
                        selectedChildIndex = childIndex
                        ARNArDrawing.selectedAction = { kind = "open-child", target = children[childIndex] }
                    end
                end
            end
            ARNArDrawing.currentChildScrollStart = scrollStart
        else
            ARNArDrawing.pendingMouseWheel = 0
            ARNArDrawing.currentChildScrollStart = 1
        end
        local insideNewView = cursorInside(viewBounds)
        local insideNavigationBridge = not insideNewView
            and ARNArDrawing.navigationBounds ~= nil
            and ARNArDrawing.now < (ARNArDrawing.navigationUntil or 0)
            and cursorInside(ARNArDrawing.navigationBounds)
        local inside = insideNewView or insideNavigationBridge
        if insideNewView or ARNArDrawing.now >= (ARNArDrawing.navigationUntil or math.huge) then
            ARNArDrawing.navigationBounds = nil
            ARNArDrawing.navigationUntil = nil
        end
        if inside then
            ARNArDrawing.hoverOutsideSince = nil
        elseif ARNArDrawing.hoverOutsideSince == nil then
            ARNArDrawing.hoverOutsideSince = ARNArDrawing.now
        end
        local outsideFor = ARNArDrawing.hoverOutsideSince ~= nil
            and math.max(0, ARNArDrawing.now - ARNArDrawing.hoverOutsideSince) or 0
        local closeDelay = ARNConfiguration.detailsViewCloseDelaySeconds or 2
        local fadeProgress = math.min(1, outsideFor / closeDelay)
        local remainingStrength = 1 - fadeProgress * 0.7
        viewBackgroundAlpha = 0.68 * remainingStrength
        viewBorderAlpha = remainingStrength
        viewBorderWidth = remainingStrength
        if not inside and outsideFor >= closeDelay then
            ARNArDrawing.hoveredTargetId = nil
            ARNArDrawing.hoveredBounds = nil
            ARNArDrawing.hoverOutsideSince = nil
            ARNArDrawing.viewContentTarget = nil
            ARNArDrawing.viewTopOffset = nil
            ARNArDrawing.navigationBounds = nil
            ARNArDrawing.navigationUntil = nil
        else
            ARNArDrawing.hoveredSeen = true
            ARNArDrawing.hoveredBounds = viewBounds
        end
    end
    local boundsHtml = drawBoundsRings(displayTarget, color, width, height)
    local markerHtml = drawMarker(displayTarget)
    local pinnedBadgeHtml = pinned and ('<span class="arn-ar-pinned-badge"><svg viewBox="'
        .. pinIcon.viewBox .. '" xmlns="http://www.w3.org/2000/svg">'
        .. pinIcon.body .. '</svg></span>') or ""
    local guideHtml = expanded and expandedViewBounds ~= nil
        and drawNavigationGuide(displayTarget, expandedViewBounds, width, height, distance, x, y) or ""
    local parentHtml = ""
    if parent ~= nil then
        parentHtml = '<div class="arn-ar-parent' .. (parentSelected and ' arn-action-selected' or '')
            .. '">&#8593; Parent: ' .. ARN.escapeHtml(parent.name or "Location") .. '</div>'
    end
    local nodeActionsHtml = expanded and drawMockActions(
        nodeActionMocks, "node", displayTarget, selectedNodeActionKey, "arn-ar-node-actions") or ""
    local childrenActionsHtml = expanded and childTotal > 0 and drawMockActions(
        childrenActionMocks, "children", displayTarget,
        selectedChildrenActionKey, "arn-ar-children-actions") or ""
    local childrenHtml = ""
    if expanded then
        local sourceSuffix = sourceFilter ~= nil
            and (' &#8212; ' .. ARN.escapeHtml(sourceFilter.label or sourceFilter.module)) or ""
        local childCount = sourceFilter ~= nil
            and (tostring(#children) .. "/" .. tostring(childTotal)) or tostring(#children)
        childrenHtml = '<div class="arn-ar-children-header">Children'
            .. sourceSuffix .. ': ' .. childCount .. childrenActionsHtml .. '</div>'
    end
    if expanded and #children > 0 then
        local scrollStart = ARNArDrawing.currentChildScrollStart or 1
        local rows = {}
        for childIndex = scrollStart, math.min(#children, scrollStart + 4) do
            local child = children[childIndex]
            local descendantCount = #ARNLocationCatalog.getChildren(child)
            local descendantSuffix = descendantCount > 0
                and " (" .. tostring(descendantCount) .. " descendants)" or ""
            rows[#rows + 1] = '<div class="arn-ar-child'
                .. (selectedChildIndex == childIndex and ' arn-action-selected' or '') .. '">&#8250; '
                .. ARN.escapeHtml(child.name or "Location")
                .. descendantSuffix .. '</div>'
        end
        childrenHtml = childrenHtml .. '<div class="arn-ar-children-list">'
            .. table.concat(rows) .. '</div><div class="arn-ar-children-footer">'
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
        underlineHtml = '<span class="arn-ar-label-underline" style="left:'
            .. string.format("%.1f", left) .. 'px;top:' .. string.format("%.1f", linkY)
            .. 'px;width:' .. string.format("%.1f", compactWidth)
            .. 'px;color:rgb(' .. color .. ')"></span>'
    end
    local linkDx, linkDy = linkX - x, linkY - y
    local linkLength = math.sqrt(linkDx * linkDx + linkDy * linkDy)
    local anchorHtml = '<span class="arn-ar-anchor-dot" style="left:'
        .. string.format("%.1f", x) .. 'px;top:' .. string.format("%.1f", y)
        .. 'px;color:rgb(' .. color .. ')"></span>'
    if linkLength > 3 then
        anchorHtml = '<span class="arn-ar-anchor-line" style="left:'
            .. string.format("%.1f", x) .. 'px;top:' .. string.format("%.1f", y)
            .. 'px;width:' .. string.format("%.1f", linkLength)
            .. 'px;color:rgb(' .. color .. ');transform:rotate('
            .. string.format("%.5f", math.atan(linkDy, linkDx)) .. 'rad)"></span>' .. anchorHtml
    end
    local html = boundsHtml .. anchorHtml .. underlineHtml
        .. '<div class="arn-ar-object' .. (expanded and ' arn-expanded' or '')
        .. (pinned and ' arn-pinned' or '')
        .. (candidate and ' arn-hover-ready' or '')
        .. '" style="left:' .. string.format("%.1f", left)
        .. 'px;top:' .. string.format("%.1f", top) .. 'px;color:rgb(' .. color .. ')">' 
        .. guideHtml
        .. '<div class="arn-ar-compact">' .. markerHtml
        .. '<span class="arn-ar-text"><span class="arn-ar-compact-name">' .. lines[1]
        .. '</span>' .. (#lines > 1 and ('<br>' .. table.concat(lines, '<br>', 2)) or '')
        .. '</span>' .. pinnedBadgeHtml .. '</div>'
        .. '<div class="arn-ar-details" style="transform:translate(-12px,-'
        .. tostring(expanded and viewRenderTopOffset or 0)
        .. 'px);background:rgba(3,12,18,'
        .. string.format("%.3f", viewBackgroundAlpha) .. ');border-color:rgba('
        .. color .. ',' .. string.format("%.3f", viewBorderAlpha) .. ');border-width:'
        .. string.format("%.2f", viewBorderWidth) .. 'px;box-shadow:0 0 7px rgba('
        .. color .. ',' .. string.format("%.3f", viewBorderAlpha) .. ')">' .. parentHtml
        .. '<div class="arn-ar-details-title">' .. markerHtml
        .. '<span class="arn-ar-text"><span class="arn-ar-details-name">'
        .. ARN.escapeHtml(nameAndSize) .. '</span>'
        .. (secondaryLabel ~= "" and ('<br><span class="arn-ar-details-secondary">'
            .. ARN.escapeHtml(secondaryLabel) .. '</span>') or '')
        .. '</span>' .. nodeActionsHtml .. '</div>'
        .. '<div class="arn-ar-details-line">' .. table.concat(details, '<br>') .. '</div>'
        .. childrenHtml .. '</div></div>'
    return html, expanded
end
