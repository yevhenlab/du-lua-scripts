-- Draws and controls the look-down SARN menu starter and its prototype menus.
-- Library dependencies: SARN, SARNLocationCatalog, and SARNArDrawing.
SARNController = SARNController or {}
SARNController.menuOpen = SARNController.menuOpen == true
SARNController.hidden = SARNController.hidden == true
SARNController.activeMenu = SARNController.activeMenu or "main"

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function vector(value)
    local x, y, z = SARN.components(value)
    return x, y, z
end

local function normalise(x, y, z)
    local length = x and math.sqrt(x * x + y * y + z * z) or 0
    if length <= 0 then return nil end
    return x / length, y / length, z / length
end

local function referenceUp(playerPosition)
    local ux, uy, uz = normalise(vector(SARN.call(player, "getWorldUp")))
    if ux ~= nil then return ux, uy, uz end
    local current = playerPosition and SARNLocationCatalog.getCurrentTarget(playerPosition) or nil
    local body = current and SARNLocationCatalog.getNearestCoordinateBody(current) or nil
    local px, py, pz = vector(playerPosition)
    local bx, by, bz = vector(body and body.worldPosition)
    if px ~= nil and bx ~= nil then return normalise(px - bx, py - by, pz - bz) end
    return nil
end

local function cameraPitchDegrees()
    local playerPosition = SARN.call(player, "getWorldPosition")
        or SARN.call(system, "getCameraWorldPos")
    local fx, fy, fz = vector(SARN.call(system, "getCameraWorldForward"))
    local ux, uy, uz = referenceUp(playerPosition)
    fx, fy, fz = normalise(fx, fy, fz)
    if ux == nil or fx == nil then return nil end
    return math.deg(math.asin(clamp(fx * ux + fy * uy + fz * uz, -1, 1)))
end

local function inside(x, y, bounds)
    return bounds ~= nil and x >= bounds.left and x <= bounds.right
        and y >= bounds.top and y <= bounds.bottom
end

local function bounds(left, top, width, height)
    return { left = left, top = top, right = left + width, bottom = top + height }
end

local function followWorldAnchor()
    local cx, cy, cz = vector(SARN.call(system, "getCameraWorldPos"))
    local fx, fy, fz = normalise(vector(SARN.call(system, "getCameraWorldForward")))
    local playerPosition = SARN.call(player, "getWorldPosition") or { cx, cy, cz }
    local ux, uy, uz = referenceUp(playerPosition)
    if cx == nil or fx == nil or ux == nil then return nil end
    local vertical = fx * ux + fy * uy + fz * uz
    local hx, hy, hz = normalise(fx - ux * vertical, fy - uy * vertical, fz - uz * vertical)
    if hx == nil then return nil end
    local angle = math.rad(65)
    local dx = hx * math.cos(angle) - ux * math.sin(angle)
    local dy = hy * math.cos(angle) - uy * math.sin(angle)
    local dz = hz * math.cos(angle) - uz * math.sin(angle)
    local distance = 4
    return { cx + dx * distance, cy + dy * distance, cz + dz * distance }
end

local function buttonHtml(className, label, selected, actionBounds)
    local style = "left:" .. string.format("%.1f", actionBounds.left) .. "px;top:"
        .. string.format("%.1f", actionBounds.top) .. "px;width:"
        .. string.format("%.1f", actionBounds.right - actionBounds.left) .. "px;height:"
        .. string.format("%.1f", actionBounds.bottom - actionBounds.top) .. "px;"
    return '<div class="sarn-controller-button ' .. className
        .. (selected and ' selected' or '') .. '" style="' .. style .. '">'
        .. SARN.escapeHtml(label) .. '</div>'
end

local function triangleButtonHtml(direction, selected, actionBounds)
    local points = direction == "left" and "19,6 8,14 19,22" or "9,6 20,14 9,22"
    local style = "left:" .. string.format("%.1f", actionBounds.left) .. "px;top:"
        .. string.format("%.1f", actionBounds.top) .. "px;width:"
        .. string.format("%.1f", actionBounds.right - actionBounds.left) .. "px;height:"
        .. string.format("%.1f", actionBounds.bottom - actionBounds.top) .. "px;"
    return '<div class="sarn-settings-control' .. (selected and ' selected' or '')
        .. '" style="' .. style .. '"><svg viewBox="0 0 28 28">'
        .. '<polygon points="' .. points .. '"/></svg></div>'
end

local function checkboxHtml(checked, selected, actionBounds)
    local style = "left:" .. string.format("%.1f", actionBounds.left) .. "px;top:"
        .. string.format("%.1f", actionBounds.top) .. "px;width:"
        .. string.format("%.1f", actionBounds.right - actionBounds.left) .. "px;height:"
        .. string.format("%.1f", actionBounds.bottom - actionBounds.top) .. "px;"
    return '<div class="sarn-settings-control checkbox' .. (selected and ' selected' or '')
        .. '" style="' .. style .. '"><span>' .. (checked and 'X' or '') .. '</span></div>'
end


local function settingNumber(value)
    value = tonumber(value) or 0
    if math.abs(value - math.floor(value)) < 0.001 then return tostring(math.floor(value)) end
    return string.format("%.1f", value)
end

function SARNController.getStyles()
    return [[<style>
.sarn-controller{position:absolute;left:0;top:0;z-index:9000;font-family:Arial,sans-serif;color:#e8eef0;font-size:13px;font-weight:bold;pointer-events:none}
.sarn-controller-button{position:absolute;box-sizing:border-box;text-align:center;background:rgba(5,18,24,.82);color:#e8eef0;border:1px solid rgba(112,225,255,.48);text-shadow:0 1px 2px #000;filter:drop-shadow(0 0 4px rgba(62,214,255,.28))}
.sarn-controller-starter{position:absolute;box-sizing:border-box;text-align:center;color:#e8eef0;text-shadow:0 1px 2px #000;filter:drop-shadow(0 0 4px rgba(62,214,255,.28))}
.sarn-controller-shape{position:absolute;left:0;top:0;width:100%;height:100%}
.sarn-controller-shape polygon{fill:rgba(5,18,24,.82);stroke:rgba(112,225,255,.48);stroke-width:1;vector-effect:non-scaling-stroke}
.sarn-controller-starter.main{display:flex;align-items:center;justify-content:center;gap:10px;font-size:18px;letter-spacing:1px}
.sarn-controller-starter.main>span{display:inline-flex;align-items:center;justify-content:center;height:24px;line-height:24px}
.sarn-controller-starter.hide{display:flex;flex-direction:column;align-items:center;justify-content:center;font-size:12px;font-weight:normal;line-height:11px}
.sarn-controller-starter>span{position:relative}
.sarn-controller-hide-arrow{font-size:20px;line-height:15px}
.sarn-controller-button.selected{background:rgba(16,70,85,.94);border-color:#55e8ff;filter:drop-shadow(0 0 7px rgba(62,214,255,.75));color:#fff}
.sarn-controller-starter.hover{filter:drop-shadow(0 0 7px rgba(62,214,255,.75));color:#fff}
.sarn-controller-starter.hover .sarn-controller-shape polygon{fill:rgba(16,70,85,.94);stroke:#55e8ff}
.sarn-controller-starter.active .sarn-controller-shape polygon{fill:rgba(19,99,119,.96);stroke:#7af0ff}
.sarn-controller-gem{font-size:22px;color:#55e8ff;transform:translateY(-2px)}
.sarn-controller-button{display:flex;align-items:center;justify-content:center;padding:4px 8px}
.sarn-controller-button.primary{clip-path:polygon(8% 0,92% 0,100% 50%,92% 100%,8% 100%,0 50%)}
.sarn-controller-button.sub{font-size:12px;background:rgba(7,23,31,.9)}
.sarn-controller-button.checked{color:#65efff}
.sarn-settings-row{position:absolute;box-sizing:border-box;background:rgba(5,18,24,.90);border:1px solid rgba(112,225,255,.32);color:#cfeef5;font:11px Arial,sans-serif;font-weight:normal;text-shadow:0 1px 2px #000;display:flex;align-items:center;padding-left:8px}
.sarn-settings-row.selected{background:rgba(16,70,85,.96);border-color:#55e8ff;filter:drop-shadow(0 0 6px rgba(62,214,255,.7));color:#fff}
.sarn-settings-control{position:absolute;box-sizing:border-box;background:rgba(4,28,34,.92);border:1px solid rgba(112,225,255,.45);display:flex;align-items:center;justify-content:center;color:#e8eef0}
.sarn-settings-control.selected{background:rgba(16,70,85,.96);border-color:#55e8ff;filter:drop-shadow(0 0 6px rgba(62,214,255,.7))}
.sarn-settings-control svg{width:100%;height:100%;fill:#dff8ff}
.sarn-settings-control.checkbox span{width:15px;height:15px;box-sizing:border-box;border:1px solid #dff8ff;text-align:center;font:bold 11px/14px Arial,sans-serif;color:#55e8ff}
.sarn-settings-value{position:absolute;box-sizing:border-box;background:rgba(4,36,34,.92);border:1px solid rgba(112,225,255,.28);display:flex;align-items:center;justify-content:center;color:#fff;font:13px Arial,sans-serif}
.sarn-settings-message{position:absolute;box-sizing:border-box;padding:7px 9px;background:rgba(5,18,24,.96);border:1px solid #55e8ff;color:#dff8ff;font:12px Arial,sans-serif;text-shadow:0 1px 2px #000}
.sarn-settings-message.error{border-color:#ffb24a;color:#ffd59c}
</style>]]
end

function SARNController.draw()
    local width = SARNArDrawing.screenWidth or tonumber(SARN.call(system, "getScreenWidth")) or 1920
    local height = SARNArDrawing.screenHeight or tonumber(SARN.call(system, "getScreenHeight")) or 1080
    local cursorX, cursorY = width * 0.5, height * 0.5
    local pitch = cameraPitchDegrees()
    local lookingDown = pitch == nil or pitch <= -55
    SARNController.selectedAction = nil

    if SARNController.hidden then
        if pitch ~= nil and pitch > -35 then SARNController.hidden = false end
        return ""
    end
    if not SARNController.menuOpen and not lookingDown then return "" end

    if SARNController.menuOpen then
        if SARNController.lookingAway then
            SARNController.followAnchor = followWorldAnchor()
            if not lookingDown then return "" end
            SARNController.worldAnchor = SARNController.followAnchor
            SARNController.lookingAway = false
        elseif pitch ~= nil and pitch > -40 then
            SARNController.lookingAway = true
            SARNController.followAnchor = followWorldAnchor()
            return ""
        end
    end

    local anchorX, anchorY
    if not SARNController.menuOpen then
        SARNController.followAnchor = followWorldAnchor()
        local projected = SARNController.followAnchor
            and SARNArDrawing.projectWorldPoint(SARNController.followAnchor) or nil
        if projected == nil then return "" end
        anchorX, anchorY = projected.x * width, projected.y * height
    elseif SARNController.worldAnchor ~= nil then
        local projected = SARNArDrawing.projectWorldPoint(SARNController.worldAnchor)
        if projected == nil then return "" end
        anchorX, anchorY = projected.x * width, projected.y * height
        SARNController.lastAnchorX, SARNController.lastAnchorY = anchorX, anchorY
    else
        anchorX, anchorY = SARNController.lastAnchorX or cursorX,
            SARNController.lastAnchorY or cursorY
    end

    local main = bounds(anchorX - 82, anchorY - 28, 164, 56)
    local hide = bounds(anchorX - 82, anchorY + 27, 164, 31)
    local mainHovered = inside(cursorX, cursorY, main)
    local hideHovered = inside(cursorX, cursorY, hide)
    if hideHovered then
        SARNController.selectedAction = { kind = "hide" }
    elseif mainHovered then
        SARNController.selectedAction = { kind = "toggle" }
    end

    local parts = {
        '<div class="sarn-controller">',
        '<div class="sarn-controller-starter main'
            .. (mainHovered and ' hover' or '') .. (SARNController.menuOpen and ' active' or '')
            .. '" style="left:' .. string.format("%.1f", main.left) .. 'px;top:'
            .. string.format("%.1f", main.top) .. 'px;width:164px;height:56px">'
            .. '<svg class="sarn-controller-shape" viewBox="0 0 164 56" preserveAspectRatio="none">'
            .. '<polygon points="23,0 141,0 164,28 141,56 23,56 0,28"/></svg>'
            .. '<span class="sarn-controller-gem">&#9672;</span><span>SARN</span></div>',
        '<div class="sarn-controller-starter hide' .. (hideHovered and ' hover' or '')
            .. '" style="left:' .. string.format("%.1f", hide.left) .. 'px;top:'
            .. string.format("%.1f", hide.top) .. 'px;width:164px;height:31px">'
            .. '<svg class="sarn-controller-shape" viewBox="0 0 164 31" preserveAspectRatio="none">'
            .. '<polygon points="23,0 141,0 118,31 46,31"/></svg>'
            .. '<span>Hide</span><span class="sarn-controller-hide-arrow">&#9662;</span></div>'
    }

    if SARNController.menuOpen then
        local labels = { "Locations", "Pins", "Settings" }
        local keys = { "locations", "pins", "settings" }
        local menuWidth, menuHeight, gap = 118, 34, 4
        local menuLeft = main.left + 23
        local menuTop = main.top - (#labels * menuHeight + (#labels - 1) * gap)
        local submenu = SARNController.activeMenu or "main"
        local subWidth = menuWidth
        local subLeft = menuLeft + menuWidth - subWidth * 0.30
        local subTop = menuTop - menuHeight * 0.25
        local settingsHeight = 6 * menuHeight + 5 * gap
        if submenu == "settings" then
            subTop = math.min(subTop, hide.bottom - settingsHeight)
        end
        local submenuHovered = false
        if submenu == "settings" then
            submenuHovered = inside(cursorX, cursorY,
                bounds(subLeft, subTop, 360, settingsHeight))
        elseif submenu ~= "main" then
            for index = 1, 3 do
                local itemBounds = bounds(subLeft, subTop + (index - 1) * (menuHeight + gap),
                    subWidth, menuHeight)
                if inside(cursorX, cursorY, itemBounds) then submenuHovered = true end
            end
        end
        for index, label in ipairs(labels) do
            local itemBounds = bounds(menuLeft,
                menuTop + (index - 1) * (menuHeight + gap), menuWidth, menuHeight)
            local selected = not submenuHovered and inside(cursorX, cursorY, itemBounds)
            if selected then SARNController.selectedAction = { kind = "submenu", key = keys[index] } end
            parts[#parts + 1] = buttonHtml("primary", label, selected, itemBounds)
        end

        if submenu == "settings" then
            local settingsWidth = 360
            local values = SARNSettings.getValues()
            local settingsRows = {
                "detailsViewCloseDelaySeconds",
                "showSystemPlanets",
                "adaptArRedrawFrequencyToFps",
                "maximumArRedrawPercentOfFps"
            }
            for index, label in ipairs(settingsRows) do
                local row = bounds(subLeft, subTop + (index - 1) * (menuHeight + gap),
                    settingsWidth, menuHeight)
                local rowSelected = (index == 2 or index == 3)
                    and inside(cursorX, cursorY, row)
                parts[#parts + 1] = '<div class="sarn-settings-row'
                    .. (rowSelected and ' selected' or '') .. '" style="left:'
                    .. string.format("%.1f", row.left) .. 'px;top:'
                    .. string.format("%.1f", row.top) .. 'px;width:'
                    .. tostring(settingsWidth) .. 'px;height:' .. tostring(menuHeight) .. 'px">'
                    .. SARN.escapeHtml(label) .. '</div>'
                if index == 1 or index == 4 then
                    local decrement = bounds(row.right - 94, row.top + 3, 28, 28)
                    local valueBounds = bounds(row.right - 64, row.top + 3, 34, 28)
                    local increment = bounds(row.right - 28, row.top + 3, 28, 28)
                    local decrementSelected = inside(cursorX, cursorY, decrement)
                    local incrementSelected = inside(cursorX, cursorY, increment)
                    if decrementSelected then
                        SARNController.selectedAction = {
                            kind = "setting", key = index == 1 and "details-dec" or "maximum-dec" }
                    elseif incrementSelected then
                        SARNController.selectedAction = {
                            kind = "setting", key = index == 1 and "details-inc" or "maximum-inc" }
                    end
                    parts[#parts + 1] = triangleButtonHtml("left", decrementSelected, decrement)
                    parts[#parts + 1] = '<div class="sarn-settings-value" style="left:'
                        .. string.format("%.1f", valueBounds.left) .. 'px;top:'
                        .. string.format("%.1f", valueBounds.top) .. 'px;width:34px;height:28px">'
                        .. settingNumber(index == 1 and values.detailsViewCloseDelaySeconds
                            or values.maximumArRedrawPercentOfFps) .. '</div>'
                    parts[#parts + 1] = triangleButtonHtml("right", incrementSelected, increment)
                else
                    local checkbox = bounds(row.right - 31, row.top + 3, 28, 28)
                    local selected = rowSelected
                    if selected then
                        SARNController.selectedAction = { kind = "setting",
                            key = index == 2 and "toggle-planets" or "toggle-adapt" }
                    end
                    parts[#parts + 1] = checkboxHtml(
                        index == 2 and values.showSystemPlanets
                            or (index == 3 and values.adaptArRedrawFrequencyToFps),
                        selected, checkbox)
                end
            end
            local saveBounds = bounds(subLeft,
                subTop + 4 * (menuHeight + gap), settingsWidth, menuHeight)
            local backBounds = bounds(subLeft,
                subTop + 5 * (menuHeight + gap), settingsWidth, menuHeight)
            local saveSelected = inside(cursorX, cursorY, saveBounds)
            local backSelected = inside(cursorX, cursorY, backBounds)
            if saveSelected then
                SARNController.selectedAction = { kind = "setting", key = "save-settings" }
            elseif backSelected then
                SARNController.selectedAction = { kind = "menu-action", key = "back" }
            end
            parts[#parts + 1] = buttonHtml("sub", "Save to databank", saveSelected, saveBounds)
            parts[#parts + 1] = buttonHtml("sub", "Back", backSelected, backBounds)
        elseif submenu ~= "main" then
            local subLabels, subActions
            if submenu == "pins" then
                subLabels = { "Pinned places", "Clear view", "Back" }
                subActions = { "mock-pinned", "mock-clear", "back" }
            else
                subLabels = { "Known space", "Nearby", "Back" }
                subActions = { "mock-known", "mock-nearby", "back" }
            end
            for index, label in ipairs(subLabels) do
                local itemBounds = bounds(subLeft, subTop + (index - 1) * (menuHeight + gap),
                    subWidth, menuHeight)
                local selected = inside(cursorX, cursorY, itemBounds)
                if selected then
                    SARNController.selectedAction = { kind = "menu-action", key = subActions[index] }
                end
                parts[#parts + 1] = buttonHtml("sub", label, selected, itemBounds)
            end
        end
        local notification = SARNController.notification
        local now = tonumber(SARN.call(system, "getArkTime")) or 0
        if notification ~= nil and now < (notification.untilTime or 0) then
            parts[#parts + 1] = '<div class="sarn-settings-message'
                .. (notification.error and ' error' or '') .. '" style="left:'
                .. string.format("%.1f", subLeft) .. 'px;top:'
                .. string.format("%.1f", subTop - 42) .. 'px;width:360px;height:36px">'
                .. SARN.escapeHtml(notification.text) .. '</div>'
        end
    end
    parts[#parts + 1] = "</div>"
    return table.concat(parts)
end

function SARNController.activateSelectedAction()
    local action = SARNController.selectedAction
    if type(action) ~= "table" then return false end
    if action.kind == "hide" then
        SARNController.menuOpen = false
        SARNController.hidden = true
        SARNController.worldAnchor = nil
        SARNController.lookingAway = false
        SARNController.activeMenu = "main"
        return true
    elseif action.kind == "toggle" then
        SARNController.menuOpen = not SARNController.menuOpen
        if SARNController.menuOpen then
            SARNController.worldAnchor = SARNController.followAnchor
            SARNController.lookingAway = false
            SARNController.lastAnchorX = SARNArDrawing.screenWidth * 0.5
            SARNController.lastAnchorY = SARNArDrawing.screenHeight * 0.5
        else
            SARNController.worldAnchor = nil
            SARNController.lookingAway = false
            SARNController.activeMenu = "main"
        end
        return true
    elseif action.kind == "submenu" then
        SARNController.activeMenu = action.key
        return true
    elseif action.kind == "setting" then
        local values = SARNSettings.getValues()
        if action.key == "details-dec" then
            SARNSettings.apply({ detailsViewCloseDelaySeconds =
                math.max(0.1, values.detailsViewCloseDelaySeconds - 0.5) })
        elseif action.key == "details-inc" then
            SARNSettings.apply({ detailsViewCloseDelaySeconds =
                math.min(10, values.detailsViewCloseDelaySeconds + 0.5) })
        elseif action.key == "toggle-planets" then
            local enabled = not values.showSystemPlanets
            SARNSettings.apply({ showSystemPlanets = enabled })
            SARNLocationCatalog.setShowSystemPlanets(enabled)
        elseif action.key == "toggle-adapt" then
            SARNSettings.apply({ adaptArRedrawFrequencyToFps =
                not values.adaptArRedrawFrequencyToFps })
            SARNPerformanceNeedsRestart = true
        elseif action.key == "maximum-dec" then
            SARNSettings.apply({ maximumArRedrawPercentOfFps =
                math.max(1, values.maximumArRedrawPercentOfFps - 5) })
            SARNPerformanceNeedsRestart = true
        elseif action.key == "maximum-inc" then
            SARNSettings.apply({ maximumArRedrawPercentOfFps =
                math.min(100, values.maximumArRedrawPercentOfFps + 5) })
            SARNPerformanceNeedsRestart = true
        elseif action.key == "save-settings" then
            local saved, reason = SARNSettings.save()
            local text
            if saved then
                text = "Settings saved to Databank."
                system.print("[SARN] " .. text)
                SARNController.notification = { text = text, error = false,
                    untilTime = (tonumber(SARN.call(system, "getArkTime")) or 0) + 5 }
            else
                text = reason == "missing"
                    and "Cannot save settings. Link a Databank element to the Control Unit."
                    or "Could not save settings to the linked Databank."
                system.print("[SARN] " .. text)
                SARNController.notification = { text = text, error = true,
                    untilTime = (tonumber(SARN.call(system, "getArkTime")) or 0) + 7 }
            end
        end
        return true
    elseif action.kind == "menu-action" then
        if action.key == "toggle-planets" then
            SARNLocationCatalog.setShowSystemPlanets(
                not SARNLocationCatalog.getShowSystemPlanets())
        elseif action.key == "back" then
            SARNController.activeMenu = "main"
        end
        return true
    end
    return false
end
