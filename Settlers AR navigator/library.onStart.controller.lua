-- Draws and controls the Alt+5 SARN menu starter and its prototype menus.
-- Library dependencies: SARN, SARNLocationCatalog, and SARNArDrawing.
SARNController = SARNController or {}
SARNController.menuOpen = SARNController.menuOpen == true
SARNController.hidden = SARNController.hidden == true
SARNController.shortcutShown = SARNController.shortcutShown == true
SARNController.activeMenu = SARNController.activeMenu or "main"

local controllerAnchorDistance = 1000000
local controllerUiScale = 1.5

local topMenuIcons = {
    locations = {
        viewBox = "0 0 20.6 21.3",
        body = '<path d="M13 7.6C10.5 5 7.8 2.9 5.6 1.5 3.1 0 1.4-.4.6.4c-.8.8-.4 2.5 1.1 5 1.4 2.2 3.5 4.8 6.1 7.4 4.1 4.1 8.9 7.6 11.3 7.6.4 0 .8-.1 1.1-.4C21.9 18.3 17.9 12.5 13 7.6zM19.6 19.4c-.8.8-5.4-1.5-11.1-7.2-2.6-2.5-4.7-5.1-6-7.3C1 2.6.9 1.4 1.2 1.1c.1-.1.3-.2.5-.2.7 0 1.7.4 3.4 1.4 2.2 1.4 4.8 3.5 7.3 6 5.7 5.6 8 10.3 7.2 11.1z"/><polygon points="4.9,11.5 4.1,15.5 .1,16.4 4.2,17.2 5.1,21.2 5.8,17.2 9.8,16.3 5.8,15.5"/><polygon points="16,5.8 16.6,8.4 17.1,5.8 19.7,5.2 17.1,4.7 16.5,2.1 16,4.7 13.4,5.3"/>'
    },
    pins = {
        viewBox = "0 0 2.82 2.82",
        body = '<polygon points="2.48 .88 1.95 .34 1.25 .87 1.96 1.57"/><polygon points="0 2.83 1.05 1.42 1.4 1.78"/><polygon points="1.98 0 2 .27 2.56 .82 2.83 .84"/><polygon points="1.32 1.5 1.94 2.11 1.88 1.65 1.18 .94 .72 .9"/>'
    },
    settings = {
        viewBox = "0 0 373.5 373.6",
        body = '<path d="M334 153.7l28-27.3-33-59-47.5 7.3c-14.8-13-32.3-20.1-44.9-26.9L220.2 1.6h-64.5L141.4 45C124 54.2 105 62.3 90.8 74.9L49 62.7l-37.5 61.7 31.8 31.7c-6.7 19.7-5 40.5-1.7 65.9l-28.8 28.7 35.8 59.7c13.8-5.5 27.8-9.1 42.2-11.4 13.1 15.4 32 20.1 48.4 29.3l9.8 40.3h72.4c4.3-15.6 6.5-28.4 12.4-42.1 18.3-3.7 30.9-14.5 42.6-22.8l50.9 5.9c13.6-18.9 25.1-38 33.3-57.8L332.2 218c3.3-21.1.4-42.3 1.8-64.3zM187.5 256.7a68.8 68.8 0 1 1 0-137.6 68.8 68.8 0 0 1 0 137.6z"/>'
    },
    hud = {
        viewBox = "0 0 300 300",
        body = '<path d="M288.2 51.9H14.7C6.6 51.9 0 58.5 0 66.6v166.5C0 241.9 7.1 249 15.9 249h272.3c6.5 0 11.8-5.3 11.8-11.8V63.8c0-6.6-5.3-11.9-11.8-11.9zM285.8 109H156V86.8h129.8V109zm0 50.6H156v-22.2h129.8v22.2zm0 51.7H156V189h129.8v22.3zM30.2 182.5c14-22.5 23-17.5 28.3-25.7-8-14.5-7-39.2 2.6-54.3 9.5-14.8 28.2-12.7 38.7.7 10.5 13.5 8 39.6 3.2 53.4 7 6.5 12 8.8 28.2 26l14 22.3h-129l14-22.4z"/>'
    },
    save = {
        viewBox = "0 0 35 35",
        body = '<rect height="21.2" width="24" x="5.2" y="13.7"/><polygon points="30.9,0 30.9,10 3.4,10 3.4,0 -0.3,0 -0.3,34.9 3.4,34.9 3.4,12 30.9,12 30.9,34.9 34.6,34.9 34.6,0"/><polygon points="25.6,0 25.6,5.3 21,5.3 21,0 5.2,0 5.2,8.3 29.1,8.3 29.1,0"/>'
    }
}

local quickVisibilityIcons = {
    planets = {
        viewBox = "0 0 32 32",
        body = '<circle cx="16" cy="16" r="8"/><path d="M3 18c4 5 18 8 26 1l-1.5-2C20 22 9 20 5 16z"/>'
    },
    satellites = {
        viewBox = "0 0 32 32",
        body = '<path d="M22.5 4.5A12 12 0 1 0 27 25 13.5 13.5 0 0 1 22.5 4.5z"/>'
    },
    area = {
        viewBox = "0 0 32 32",
        body = '<circle cx="16" cy="7" r="4"/><circle cx="7" cy="24" r="4"/><circle cx="25" cy="24" r="4"/><path d="M16 11v5M16 16L8 21M16 16l8 5" fill="none" stroke="currentColor" stroke-width="3"/>'
    },
    nearby = {
        viewBox = "0 0 32 32",
        body = '<circle cx="16" cy="16" r="3"/><path d="M9 16a7 7 0 0 1 7-7M6 16A10 10 0 0 1 16 6M23 16a7 7 0 0 1-7 7M26 16a10 10 0 0 1-10 10" fill="none" stroke="currentColor" stroke-width="3"/>'
    }
}

local function ui(value)
    return value * controllerUiScale
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

local function inside(x, y, bounds)
    return bounds ~= nil and x >= bounds.left and x <= bounds.right
        and y >= bounds.top and y <= bounds.bottom
end

local function bounds(left, top, width, height)
    return { left = left, top = top, right = left + width, bottom = top + height }
end

local function screenWorldAnchor(screenX, screenY)
    local cx, cy, cz = vector(SARN.call(system, "getCameraWorldPos"))
    local fx, fy, fz = normalise(vector(SARN.call(system, "getCameraWorldForward")))
    local rx, ry, rz = normalise(vector(SARN.call(system, "getCameraWorldRight")))
    local ux, uy, uz = normalise(vector(SARN.call(system, "getCameraWorldUp")))
    if cx == nil or fx == nil or rx == nil or ux == nil then return nil end
    local verticalFov = tonumber(SARN.call(system, "getCameraVerticalFov")) or math.rad(60)
    local horizontalFov = tonumber(SARN.call(system, "getCameraHorizontalFov")) or math.rad(90)
    if verticalFov > math.pi then verticalFov = math.rad(verticalFov) end
    if horizontalFov > math.pi then horizontalFov = math.rad(horizontalFov) end
    local horizontal = (screenX - 0.5) * 2 * math.tan(horizontalFov * 0.5)
    local vertical = (0.5 - screenY) * 2 * math.tan(verticalFov * 0.5)
    local dx, dy, dz = normalise(fx + rx * horizontal + ux * vertical,
        fy + ry * horizontal + uy * vertical, fz + rz * horizontal + uz * vertical)
    if dx == nil then return nil end
    return { cx + dx * controllerAnchorDistance, cy + dy * controllerAnchorDistance,
        cz + dz * controllerAnchorDistance }
end

local function isControllerRendered()
    if SARNArDrawing == nil or type(SARNArDrawing.projectWorldPoint) ~= "function" then return false end
    if SARNController.hidden or not SARNController.shortcutShown then return false end
    local anchor = SARNController.menuOpen and SARNController.worldAnchor
        or SARNController.followAnchor
    return anchor ~= nil and SARNArDrawing.projectWorldPoint(anchor) ~= nil
end

function SARNController.showFromShortcut()
    if isControllerRendered() then
        SARNController.menuOpen = false
        SARNController.hidden = true
        SARNController.shortcutShown = false
        SARNController.followAnchor = nil
        SARNController.worldAnchor = nil
        SARNController.activeMenu = "main"
        return false
    end

    local anchor = screenWorldAnchor(0.5, 0.7)
    if anchor == nil then return false end
    SARNController.menuOpen = false
    SARNController.hidden = false
    SARNController.shortcutShown = true
    SARNController.followAnchor = anchor
    SARNController.worldAnchor = anchor
    SARNController.activeMenu = "main"
    return true
end

local function buttonHtml(className, label, selected, actionBounds, icon)
    local style = "left:" .. string.format("%.1f", actionBounds.left) .. "px;top:"
        .. string.format("%.1f", actionBounds.top) .. "px;width:"
        .. string.format("%.1f", actionBounds.right - actionBounds.left) .. "px;height:"
        .. string.format("%.1f", actionBounds.bottom - actionBounds.top) .. "px;"
    local iconHtml = icon and ('<svg class="sarn-controller-menu-icon" viewBox="'
        .. icon.viewBox .. '">' .. icon.body .. '</svg>') or ""
    return '<div class="sarn-controller-button ' .. className
        .. (selected and ' selected' or '') .. '" style="' .. style .. '">'
        .. iconHtml .. '<span>' .. SARN.escapeHtml(label) .. '</span></div>'
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

local function quickToggleHtml(item, checked, selected, actionBounds)
    local style = "left:" .. string.format("%.1f", actionBounds.left) .. "px;top:"
        .. string.format("%.1f", actionBounds.top) .. "px;width:"
        .. string.format("%.1f", actionBounds.right - actionBounds.left) .. "px;height:"
        .. string.format("%.1f", actionBounds.bottom - actionBounds.top) .. "px;"
    return '<div class="sarn-quick-toggle' .. (checked and ' active' or '')
        .. (selected and ' hover' or '') .. '" style="' .. style .. '">'
        .. '<svg viewBox="' .. item.icon.viewBox .. '">' .. item.icon.body .. '</svg>'
        .. '<span>' .. SARN.escapeHtml(item.label) .. '</span>'
        .. '<i>' .. (checked and 'X' or '') .. '</i></div>'
end


local function settingNumber(value)
    value = tonumber(value) or 0
    if math.abs(value - math.floor(value)) < 0.001 then return tostring(math.floor(value)) end
    return string.format("%.1f", value)
end

function SARNController.getStyles()
    return [[<style>
.sarn-controller{position:absolute;left:0;top:0;z-index:9000;font-family:Arial,sans-serif;color:#e8eef0;font-size:20px;font-weight:bold;pointer-events:none}
.sarn-controller-button{position:absolute;box-sizing:border-box;text-align:center;background:rgba(5,18,24,.82);color:#e8eef0;border:1.5px solid rgba(112,225,255,.48);text-shadow:0 1.5px 3px #000;filter:drop-shadow(0 0 6px rgba(62,214,255,.28))}
.sarn-controller-starter{position:absolute;box-sizing:border-box;text-align:center;color:#e8eef0;text-shadow:0 1.5px 3px #000;filter:drop-shadow(0 0 6px rgba(62,214,255,.28))}
.sarn-controller-shape{position:absolute;left:0;top:0;width:100%;height:100%}
.sarn-controller-shape polygon{fill:rgba(5,18,24,.82);stroke:rgba(112,225,255,.48);stroke-width:1.5}
.sarn-controller-starter.main{display:flex;align-items:center;justify-content:center;gap:15px;font-size:27px;letter-spacing:1.5px}
.sarn-controller-starter.main>span{display:inline-flex;align-items:center;justify-content:center;height:36px;line-height:36px}
.sarn-controller-starter.hide{display:flex;flex-direction:column;align-items:center;justify-content:center;font-size:18px;font-weight:normal;line-height:17px}
.sarn-controller-starter>span{position:relative}
.sarn-controller-hide-arrow{font-size:30px;line-height:23px}
.sarn-controller-button.selected{background:rgba(16,70,85,.94);border-color:#55e8ff;filter:drop-shadow(0 0 10.5px rgba(62,214,255,.75));color:#fff}
.sarn-controller-starter.hover{filter:drop-shadow(0 0 10.5px rgba(62,214,255,.75));color:#fff}
.sarn-controller-starter.hover .sarn-controller-shape polygon{fill:rgba(16,70,85,.94);stroke:#55e8ff}
.sarn-controller-starter.active .sarn-controller-shape polygon{fill:rgba(19,99,119,.96);stroke:#7af0ff}
.sarn-controller-gem{font-size:33px;color:#55e8ff;transform:translateY(-3px)}
.sarn-controller-button{display:flex;align-items:center;justify-content:center;padding:6px 12px}
.sarn-controller-menu-icon{width:24px;height:24px;margin-right:9px;fill:currentColor;flex:none;filter:drop-shadow(0 1px 2px #000)}
.sarn-controller-button.primary{clip-path:polygon(8% 0,92% 0,100% 50%,92% 100%,8% 100%,0 50%);justify-content:flex-start;text-align:left;padding:4px 12px 4px 15px;line-height:20px}
.sarn-controller-button.primary>span{white-space:normal}
.sarn-controller-button.sub{font-size:18px;background:rgba(7,23,31,.9)}
.sarn-controller-button.disabled{color:#75909a;background:rgba(5,18,24,.65);border-color:rgba(112,225,255,.20)}
.sarn-controller-button.checked{color:#65efff}
.sarn-settings-row{position:absolute;box-sizing:border-box;background:rgba(5,18,24,.90);border:1.5px solid rgba(112,225,255,.32);color:#cfeef5;font:17px Arial,sans-serif;font-weight:normal;text-shadow:0 1.5px 3px #000;display:flex;align-items:center;padding-left:12px}
.sarn-pin-row{padding-right:48px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.sarn-settings-row.selected{background:rgba(16,70,85,.96);border-color:#55e8ff;filter:drop-shadow(0 0 9px rgba(62,214,255,.7));color:#fff}
.sarn-settings-control{position:absolute;box-sizing:border-box;background:rgba(4,28,34,.92);border:1.5px solid rgba(112,225,255,.45);display:flex;align-items:center;justify-content:center;color:#e8eef0}
.sarn-settings-control.selected{background:rgba(16,70,85,.96);border-color:#55e8ff;filter:drop-shadow(0 0 9px rgba(62,214,255,.7))}
.sarn-settings-control svg{width:100%;height:100%;fill:#dff8ff}
.sarn-settings-control.checkbox span{width:23px;height:23px;box-sizing:border-box;border:1.5px solid #dff8ff;text-align:center;font:bold 17px/21px Arial,sans-serif;color:#55e8ff}
.sarn-settings-value{position:absolute;box-sizing:border-box;background:rgba(4,36,34,.92);border:1.5px solid rgba(112,225,255,.28);display:flex;align-items:center;justify-content:center;color:#fff;font:20px Arial,sans-serif}
.sarn-settings-message{position:absolute;box-sizing:border-box;padding:10.5px 13.5px;background:rgba(5,18,24,.96);border:1.5px solid #55e8ff;color:#dff8ff;font:18px Arial,sans-serif;text-shadow:0 1.5px 3px #000;text-align:center;display:flex;align-items:center;justify-content:center}
.sarn-settings-message.error{border-color:#ffb24a;color:#ffd59c}
.sarn-quick-toggle{position:absolute;box-sizing:border-box;background:transparent;border:0;color:#dff8ff;display:flex;align-items:center;justify-content:center;gap:7px;padding:6px 24px 6px 7px;font:14px Arial,sans-serif;font-weight:normal;text-shadow:0 1.5px 3px #000}
.sarn-quick-toggle.active{background:rgba(19,99,119,.50);color:#fff}
.sarn-quick-toggle.hover{background:rgba(16,70,85,.38);filter:drop-shadow(0 0 8px rgba(62,214,255,.72));color:#fff}
.sarn-quick-toggle.active.hover{background:rgba(19,99,119,.68)}
.sarn-quick-toggle svg{width:22px;height:22px;fill:currentColor;flex:none}
.sarn-quick-toggle>span{white-space:nowrap}
.sarn-quick-toggle>i{position:absolute;right:5px;top:5px;width:15px;height:15px;box-sizing:border-box;border:1px solid #dff8ff;color:#55e8ff;font:bold 11px/13px Arial,sans-serif;font-style:normal;text-align:center}
.sarn-quick-divider{position:absolute;width:1px;background:rgba(185,235,247,.58)}
</style>]]
end

function SARNController.draw()
    local width = SARNArDrawing.screenWidth or tonumber(SARN.call(system, "getScreenWidth")) or 1920
    local height = SARNArDrawing.screenHeight or tonumber(SARN.call(system, "getScreenHeight")) or 1080
    local cursorX, cursorY = width * 0.5, height * 0.5
    SARNController.selectedAction = nil

    if SARNController.hidden or not SARNController.shortcutShown then return "" end

    local anchorX, anchorY
    if not SARNController.menuOpen then
        local projected = SARNController.followAnchor
            and SARNArDrawing.projectWorldPoint(SARNController.followAnchor) or nil
        if projected == nil then return "" end
        anchorX, anchorY = projected.x * width, projected.y * height
    else
        local projected = SARNArDrawing.projectWorldPoint(SARNController.worldAnchor)
        if projected == nil then return "" end
        anchorX, anchorY = projected.x * width, projected.y * height
    end

    local main = bounds(anchorX - ui(82), anchorY - ui(28), ui(164), ui(56))
    local hide = bounds(anchorX - ui(82), anchorY + ui(27), ui(164), ui(31))
    local mainHovered = inside(cursorX, cursorY, main)
    local hideHovered = inside(cursorX, cursorY, hide)
    if hideHovered then
        SARNController.selectedAction = { kind = "hide" }
    elseif mainHovered then
        SARNController.selectedAction = { kind = "toggle" }
    end

    local quickParts = {}
    if not SARNController.menuOpen then
        local values = SARNSettings.getValues()
        local quickItems = {
            { label = "Planets", checked = values.showSystemPlanets,
                key = "toggle-planets", icon = quickVisibilityIcons.planets, width = ui(70) },
            { label = "Satellites", checked = values.showSatellites,
                key = "toggle-satellites", icon = quickVisibilityIcons.satellites, width = ui(80) },
            { label = "Places of current area", checked = values.showCurrentAreaPlaces,
                key = "toggle-current-area-places", icon = quickVisibilityIcons.area,
                width = ui(140) },
            { label = "Nearby areas", checked = values.showNearbyAreas,
                key = "toggle-nearby-areas", icon = quickVisibilityIcons.nearby,
                width = ui(100) },
            { label = "Places of nearby areas", checked = values.showNearbyAreaPlaces,
                key = "toggle-nearby-area-places", icon = quickVisibilityIcons.area,
                width = ui(140) }
        }
        local quickHeight = ui(42)
        local quickTotalWidth = 0
        for _, item in ipairs(quickItems) do quickTotalWidth = quickTotalWidth + item.width end
        local quickLeft = anchorX - quickTotalWidth * 0.5
        local quickTop = main.top - quickHeight - ui(7)
        local nextQuickLeft = quickLeft
        for index, item in ipairs(quickItems) do
            local itemBounds = bounds(nextQuickLeft, quickTop, item.width, quickHeight)
            nextQuickLeft = nextQuickLeft + item.width
            local selected = inside(cursorX, cursorY, itemBounds)
            if selected then
                SARNController.selectedAction = { kind = "setting", key = item.key }
            end
            quickParts[#quickParts + 1] = quickToggleHtml(
                item, item.checked, selected, itemBounds)
            if index > 1 then
                quickParts[#quickParts + 1] = '<div class="sarn-quick-divider" style="left:'
                    .. string.format("%.1f", itemBounds.left) .. 'px;top:'
                    .. string.format("%.1f", itemBounds.top + ui(5)) .. 'px;height:'
                    .. string.format("%.1f", quickHeight - ui(10)) .. 'px"></div>'
            end
        end
    end

    local parts = {
        '<div class="sarn-controller">',
        '<div class="sarn-controller-starter main'
            .. (mainHovered and ' hover' or '') .. (SARNController.menuOpen and ' active' or '')
            .. '" style="left:' .. string.format("%.1f", main.left) .. 'px;top:'
            .. string.format("%.1f", main.top) .. 'px;width:' .. string.format("%.1f", ui(164))
            .. 'px;height:' .. string.format("%.1f", ui(56)) .. 'px">'
            .. '<svg class="sarn-controller-shape" viewBox="0 0 164 56" preserveAspectRatio="none">'
            .. '<polygon points="23,0 141,0 164,28 141,56 23,56 0,28"/></svg>'
            .. '<span class="sarn-controller-gem">&#9672;</span><span>SARN</span></div>',
        '<div class="sarn-controller-starter hide' .. (hideHovered and ' hover' or '')
            .. '" style="left:' .. string.format("%.1f", hide.left) .. 'px;top:'
            .. string.format("%.1f", hide.top) .. 'px;width:' .. string.format("%.1f", ui(164))
            .. 'px;height:' .. string.format("%.1f", ui(31)) .. 'px">'
            .. '<svg class="sarn-controller-shape" viewBox="0 0 164 31" preserveAspectRatio="none">'
            .. '<polygon points="23,0 141,0 118,31 46,31"/></svg>'
            .. '<span>Hide</span><span class="sarn-controller-hide-arrow">&#9662;</span></div>'
    }
    for _, quickPart in ipairs(quickParts) do parts[#parts + 1] = quickPart end

    if SARNController.menuOpen then
        local labels = { "Locations", "Pins", "HUD", "Settings", "Save to databank" }
        local keys = { "locations", "pins", "hud", "settings", "save" }
        local menuWidth, menuHeight, gap = ui(118), ui(34), ui(4)
        local menuLeft = main.left + ui(23)
        local menuTop = main.top - (#labels * menuHeight + (#labels - 1) * gap)
        local submenu = SARNController.activeMenu or "main"
        local pinEntries = submenu == "pins" and SARNArDrawing.getPinMenuEntries() or {}
        local settingsRows = {
            { label = "detailsViewCloseDelaySeconds", kind = "number",
                valueKey = "detailsViewCloseDelaySeconds", decrement = "details-dec",
                increment = "details-inc" },
            { label = "adaptArRedrawFrequencyToFps", kind = "checkbox",
                valueKey = "adaptArRedrawFrequencyToFps", action = "toggle-adapt" },
            { label = "maximumArRedrawPercentOfFps", kind = "number",
                valueKey = "maximumArRedrawPercentOfFps", decrement = "maximum-dec",
                increment = "maximum-inc" },
            { label = "Groups can become current area", kind = "checkbox",
                valueKey = "allowGroupsAsCurrentArea", action = "toggle-group-current" },
        }
        local hudRows = {
            { label = "Settlers AR Navigator", valueKey = "showSarnHudPanel",
                action = "toggle-hud-status" },
            { label = "Visible Markers", valueKey = "showVisibleMarkersHudPanel",
                action = "toggle-hud-markers" },
            { label = "Pinned Locations", valueKey = "showPinnedLocationsHudPanel",
                action = "toggle-hud-pins" },
            { label = "Show off-screen markers", valueKey = "showOffscreenMarkersInHud",
                action = "toggle-hud-offscreen" },
            { label = "Area entry message", valueKey = "showAreaEntryNotifications",
                action = "toggle-hud-area-entry" },
            { label = "Area exit message", valueKey = "showAreaExitNotifications",
                action = "toggle-hud-area-exit" },
            { label = "HUD font size", kind = "number", valueKey = "hudFontSize",
                decrement = "hud-font-dec", increment = "hud-font-inc" }
        }
        local subWidth = menuWidth
        local locationsWidth = ui(300)
        local pinsWidth = ui(240)
        local hudWidth = ui(250)
        local settingsWidth = ui(180)
        for _, setting in ipairs(settingsRows) do
            local controlsWidth = setting.kind == "checkbox" and ui(42) or ui(104)
            settingsWidth = math.max(settingsWidth,
                math.min(ui(360), ui(16) + #setting.label * 8.5 + controlsWidth))
        end
        for _, entry in ipairs(pinEntries) do
            pinsWidth = math.max(pinsWidth,
                math.min(ui(360), ui(55) + #tostring(entry.label or "") * 8.5))
        end
        local subLeft = menuLeft + menuWidth - subWidth * 0.30
        local subTop = menuTop - menuHeight * 0.25
        local locationsHeight = 9 * menuHeight + 8 * gap
        local hudHeight = #hudRows * menuHeight + (#hudRows - 1) * gap
        local settingsHeight = #settingsRows * menuHeight + (#settingsRows - 1) * gap
        local pinsRowCount = #pinEntries > 0 and (#pinEntries + 1) or 1
        local pinsHeight = pinsRowCount * menuHeight + (pinsRowCount - 1) * gap
        if submenu == "locations" then
            subTop = math.min(subTop, hide.bottom - locationsHeight)
        elseif submenu == "hud" then
            subTop = math.min(subTop, hide.bottom - hudHeight)
        elseif submenu == "settings" then
            subTop = math.min(subTop, hide.bottom - settingsHeight)
        elseif submenu == "pins" then
            subTop = math.min(subTop, hide.bottom - pinsHeight)
        end
        local submenuHovered = false
        if submenu == "locations" then
            submenuHovered = inside(cursorX, cursorY,
                bounds(subLeft, subTop, locationsWidth, locationsHeight))
        elseif submenu == "hud" then
            submenuHovered = inside(cursorX, cursorY,
                bounds(subLeft, subTop, hudWidth, hudHeight))
        elseif submenu == "settings" then
            submenuHovered = inside(cursorX, cursorY,
                bounds(subLeft, subTop, settingsWidth, settingsHeight))
        elseif submenu == "pins" then
            submenuHovered = inside(cursorX, cursorY,
                bounds(subLeft, subTop, pinsWidth, pinsHeight))
        end
        for index, label in ipairs(labels) do
            local itemBounds = bounds(menuLeft,
                menuTop + (index - 1) * (menuHeight + gap), menuWidth, menuHeight)
            local selected = not submenuHovered and inside(cursorX, cursorY, itemBounds)
            if selected then
                SARNController.selectedAction = keys[index] == "save"
                    and { kind = "setting", key = "save-databank" }
                    or { kind = "submenu", key = keys[index] }
            end
            parts[#parts + 1] = buttonHtml("primary", label, selected, itemBounds,
                topMenuIcons[keys[index]])
        end

        if submenu == "locations" then
            local values = SARNSettings.getValues()
            local locationSettings = {
                { label = "Planets", checked = values.showSystemPlanets,
                    key = "toggle-planets" },
                { label = "Satellites", checked = values.showSatellites,
                    key = "toggle-satellites" },
                { label = "Places of current area", checked = values.showCurrentAreaPlaces,
                    key = "toggle-current-area-places" },
                { label = "Nearby areas", checked = values.showNearbyAreas,
                    key = "toggle-nearby-areas" },
                { label = "Places of nearby areas", checked = values.showNearbyAreaPlaces,
                    key = "toggle-nearby-area-places" }
            }
            for index, item in ipairs(locationSettings) do
                local row = bounds(subLeft, subTop + (index - 1) * (menuHeight + gap),
                    locationsWidth, menuHeight)
                local selected = inside(cursorX, cursorY, row)
                if selected then
                    SARNController.selectedAction = { kind = "setting", key = item.key }
                end
                parts[#parts + 1] = '<div class="sarn-settings-row'
                    .. (selected and ' selected' or '') .. '" style="left:'
                    .. string.format("%.1f", row.left) .. 'px;top:'
                    .. string.format("%.1f", row.top) .. 'px;width:'
                    .. tostring(locationsWidth) .. 'px;height:' .. tostring(menuHeight) .. 'px">'
                    .. SARN.escapeHtml(item.label) .. '</div>'
                local checkbox = bounds(row.right - ui(31), row.top + ui(3), ui(28), ui(28))
                parts[#parts + 1] = checkboxHtml(item.checked, selected, checkbox)
            end
            local locationRanges = {
                { label = "nearbyAtmoRangeKm", valueKey = "nearbyAtmoRangeKm",
                    decrement = "nearby-atmo-dec", increment = "nearby-atmo-inc" },
                { label = "nearbySpaceRangeKm", valueKey = "nearbySpaceRangeKm",
                    decrement = "nearby-space-dec", increment = "nearby-space-inc" },
                { label = "maximumNearbyPlaces", valueKey = "maximumNearbyPlaces",
                    decrement = "nearby-count-dec", increment = "nearby-count-inc" }
            }
            for index, setting in ipairs(locationRanges) do
                local rowIndex = index + #locationSettings
                local row = bounds(subLeft,
                    subTop + (rowIndex - 1) * (menuHeight + gap), locationsWidth, menuHeight)
                parts[#parts + 1] = '<div class="sarn-settings-row" style="left:'
                    .. string.format("%.1f", row.left) .. 'px;top:'
                    .. string.format("%.1f", row.top) .. 'px;width:'
                    .. tostring(locationsWidth) .. 'px;height:' .. tostring(menuHeight) .. 'px">'
                    .. SARN.escapeHtml(setting.label) .. '</div>'
                local decrement = bounds(row.right - ui(94), row.top + ui(3), ui(28), ui(28))
                local valueBounds = bounds(row.right - ui(64), row.top + ui(3), ui(34), ui(28))
                local increment = bounds(row.right - ui(28), row.top + ui(3), ui(28), ui(28))
                local decrementSelected = inside(cursorX, cursorY, decrement)
                local incrementSelected = inside(cursorX, cursorY, increment)
                if decrementSelected then
                    SARNController.selectedAction = { kind = "setting", key = setting.decrement }
                elseif incrementSelected then
                    SARNController.selectedAction = { kind = "setting", key = setting.increment }
                end
                parts[#parts + 1] = triangleButtonHtml("left", decrementSelected, decrement)
                parts[#parts + 1] = '<div class="sarn-settings-value" style="left:'
                    .. string.format("%.1f", valueBounds.left) .. 'px;top:'
                    .. string.format("%.1f", valueBounds.top) .. 'px;width:'
                    .. string.format("%.1f", valueBounds.right - valueBounds.left) .. 'px;height:'
                    .. string.format("%.1f", valueBounds.bottom - valueBounds.top) .. 'px">'
                    .. settingNumber(values[setting.valueKey]) .. '</div>'
                parts[#parts + 1] = triangleButtonHtml("right", incrementSelected, increment)
            end
            local knownIndex = #locationSettings + #locationRanges + 1
            local knownBounds = bounds(subLeft,
                subTop + (knownIndex - 1) * (menuHeight + gap), locationsWidth, menuHeight)
            local knownSelected = inside(cursorX, cursorY, knownBounds)
            if knownSelected then
                SARNController.selectedAction = { kind = "menu-action", key = "mock-known" }
            end
            parts[#parts + 1] = buttonHtml("sub", "Known space", knownSelected, knownBounds)
        elseif submenu == "hud" then
            local values = SARNSettings.getValues()
            for index, item in ipairs(hudRows) do
                local row = bounds(subLeft, subTop + (index - 1) * (menuHeight + gap),
                    hudWidth, menuHeight)
                local selected = false
                local decrement, valueBounds, increment
                if item.kind == "number" then
                    decrement = bounds(row.right - ui(94), row.top + ui(3), ui(28), ui(28))
                    valueBounds = bounds(row.right - ui(64), row.top + ui(3), ui(34), ui(28))
                    increment = bounds(row.right - ui(28), row.top + ui(3), ui(28), ui(28))
                    local decrementSelected = inside(cursorX, cursorY, decrement)
                    local incrementSelected = inside(cursorX, cursorY, increment)
                    selected = decrementSelected or incrementSelected
                    if decrementSelected then
                        SARNController.selectedAction = { kind = "setting", key = item.decrement }
                    elseif incrementSelected then
                        SARNController.selectedAction = { kind = "setting", key = item.increment }
                    end
                else
                    selected = inside(cursorX, cursorY, row)
                    if selected then
                        SARNController.selectedAction = { kind = "setting", key = item.action }
                    end
                end
                parts[#parts + 1] = '<div class="sarn-settings-row'
                    .. (selected and ' selected' or '') .. '" style="left:'
                    .. string.format("%.1f", row.left) .. 'px;top:'
                    .. string.format("%.1f", row.top) .. 'px;width:'
                    .. tostring(hudWidth) .. 'px;height:' .. tostring(menuHeight) .. 'px">'
                    .. SARN.escapeHtml(item.label) .. '</div>'
                if item.kind == "number" then
                    local decrementSelected = inside(cursorX, cursorY, decrement)
                    local incrementSelected = inside(cursorX, cursorY, increment)
                    parts[#parts + 1] = triangleButtonHtml("left", decrementSelected, decrement)
                    parts[#parts + 1] = '<div class="sarn-settings-value" style="left:'
                        .. string.format("%.1f", valueBounds.left) .. 'px;top:'
                        .. string.format("%.1f", valueBounds.top) .. 'px;width:'
                        .. string.format("%.1f", valueBounds.right - valueBounds.left) .. 'px;height:'
                        .. string.format("%.1f", valueBounds.bottom - valueBounds.top) .. 'px">'
                        .. settingNumber(values[item.valueKey]) .. '</div>'
                    parts[#parts + 1] = triangleButtonHtml("right", incrementSelected, increment)
                else
                    local checkbox = bounds(row.right - ui(31), row.top + ui(3), ui(28), ui(28))
                    parts[#parts + 1] = checkboxHtml(values[item.valueKey], selected, checkbox)
                end
            end
        elseif submenu == "settings" then
            local values = SARNSettings.getValues()
            for index, setting in ipairs(settingsRows) do
                local row = bounds(subLeft, subTop + (index - 1) * (menuHeight + gap),
                    settingsWidth, menuHeight)
                local rowSelected = setting.kind == "checkbox" and inside(cursorX, cursorY, row)
                parts[#parts + 1] = '<div class="sarn-settings-row'
                    .. (rowSelected and ' selected' or '') .. '" style="left:'
                    .. string.format("%.1f", row.left) .. 'px;top:'
                    .. string.format("%.1f", row.top) .. 'px;width:'
                    .. tostring(settingsWidth) .. 'px;height:' .. tostring(menuHeight) .. 'px">'
                    .. SARN.escapeHtml(setting.label) .. '</div>'
                if setting.kind == "number" then
                    local decrement = bounds(row.right - ui(94), row.top + ui(3), ui(28), ui(28))
                    local valueBounds = bounds(row.right - ui(64), row.top + ui(3), ui(34), ui(28))
                    local increment = bounds(row.right - ui(28), row.top + ui(3), ui(28), ui(28))
                    local decrementSelected = inside(cursorX, cursorY, decrement)
                    local incrementSelected = inside(cursorX, cursorY, increment)
                    if decrementSelected then
                        SARNController.selectedAction = { kind = "setting", key = setting.decrement }
                    elseif incrementSelected then
                        SARNController.selectedAction = { kind = "setting", key = setting.increment }
                    end
                    parts[#parts + 1] = triangleButtonHtml("left", decrementSelected, decrement)
                    parts[#parts + 1] = '<div class="sarn-settings-value" style="left:'
                        .. string.format("%.1f", valueBounds.left) .. 'px;top:'
                        .. string.format("%.1f", valueBounds.top) .. 'px;width:'
                        .. string.format("%.1f", valueBounds.right - valueBounds.left) .. 'px;height:'
                        .. string.format("%.1f", valueBounds.bottom - valueBounds.top) .. 'px">'
                        .. settingNumber(values[setting.valueKey]) .. '</div>'
                    parts[#parts + 1] = triangleButtonHtml("right", incrementSelected, increment)
                else
                    local checkbox = bounds(row.right - ui(31), row.top + ui(3), ui(28), ui(28))
                    local selected = rowSelected
                    if selected then
                        SARNController.selectedAction = { kind = "setting", key = setting.action }
                    end
                    parts[#parts + 1] = checkboxHtml(values[setting.valueKey], selected, checkbox)
                end
            end
        elseif submenu == "pins" then
            if #pinEntries == 0 then
                local emptyBounds = bounds(subLeft, subTop, pinsWidth, menuHeight)
                parts[#parts + 1] = buttonHtml("sub disabled", "No pinned locations",
                    false, emptyBounds)
            else
                for index, entry in ipairs(pinEntries) do
                    local row = bounds(subLeft, subTop + (index - 1) * (menuHeight + gap),
                        pinsWidth, menuHeight)
                    local selected = inside(cursorX, cursorY, row)
                    if selected then
                        SARNController.selectedAction = { kind = "pin", targetId = entry.targetId,
                            mode = entry.mode }
                    end
                    parts[#parts + 1] = '<div class="sarn-settings-row sarn-pin-row'
                        .. (selected and ' selected' or '') .. '" style="left:'
                        .. string.format("%.1f", row.left) .. 'px;top:'
                        .. string.format("%.1f", row.top) .. 'px;width:'
                        .. string.format("%.1f", pinsWidth) .. 'px;height:'
                        .. string.format("%.1f", menuHeight) .. 'px">'
                        .. SARN.escapeHtml(entry.label) .. '</div>'
                    local checkbox = bounds(row.right - ui(31), row.top + ui(3), ui(28), ui(28))
                    parts[#parts + 1] = checkboxHtml(true, selected, checkbox)
                end
                local clearIndex = #pinEntries + 1
                local clearBounds = bounds(subLeft,
                    subTop + (clearIndex - 1) * (menuHeight + gap), pinsWidth, menuHeight)
                local clearSelected = inside(cursorX, cursorY, clearBounds)
                if clearSelected then
                    SARNController.selectedAction = { kind = "clear-pins" }
                end
                parts[#parts + 1] = buttonHtml("sub", "Remove all pins", clearSelected, clearBounds)
            end
        end
        local notification = SARNController.notification
        local now = tonumber(SARN.call(system, "getArkTime")) or 0
        if notification ~= nil and now < (notification.untilTime or 0) then
            local messageWidth = ui(360)
            local messageLeft = menuLeft + menuWidth * 0.5 - messageWidth * 0.5
            parts[#parts + 1] = '<div class="sarn-settings-message'
                .. (notification.error and ' error' or '') .. '" style="left:'
                .. string.format("%.1f", messageLeft) .. 'px;top:'
                .. string.format("%.1f", menuTop - ui(42)) .. 'px;width:'
                .. string.format("%.1f", messageWidth) .. 'px;height:'
                .. string.format("%.1f", ui(36)) .. 'px">'
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
        SARNController.shortcutShown = false
        SARNController.worldAnchor = nil
        SARNController.activeMenu = "main"
        return true
    elseif action.kind == "toggle" then
        SARNController.menuOpen = not SARNController.menuOpen
        if SARNController.menuOpen then
            SARNController.worldAnchor = SARNController.followAnchor
        else
            SARNController.worldAnchor = nil
            SARNController.activeMenu = "main"
        end
        return true
    elseif action.kind == "submenu" then
        SARNController.activeMenu = action.key
        return true
    elseif action.kind == "pin" then
        SARNArDrawing.setPinMode(action.targetId, action.mode, false)
        return true
    elseif action.kind == "clear-pins" then
        SARNArDrawing.clearPins()
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
        elseif action.key == "toggle-satellites" then
            SARNSettings.apply({ showSatellites = not values.showSatellites })
        elseif action.key == "toggle-current-area-places" then
            SARNSettings.apply({ showCurrentAreaPlaces = not values.showCurrentAreaPlaces })
        elseif action.key == "toggle-nearby-areas" then
            SARNSettings.apply({ showNearbyAreas = not values.showNearbyAreas })
        elseif action.key == "toggle-nearby-area-places" then
            SARNSettings.apply({ showNearbyAreaPlaces = not values.showNearbyAreaPlaces })
        elseif action.key == "toggle-hud-status" then
            SARNSettings.apply({ showSarnHudPanel = not values.showSarnHudPanel })
        elseif action.key == "toggle-hud-markers" then
            SARNSettings.apply({ showVisibleMarkersHudPanel =
                not values.showVisibleMarkersHudPanel })
        elseif action.key == "toggle-hud-pins" then
            SARNSettings.apply({ showPinnedLocationsHudPanel =
                not values.showPinnedLocationsHudPanel })
        elseif action.key == "toggle-hud-offscreen" then
            SARNSettings.apply({ showOffscreenMarkersInHud =
                not values.showOffscreenMarkersInHud })
        elseif action.key == "toggle-hud-area-entry" then
            SARNSettings.apply({ showAreaEntryNotifications =
                not values.showAreaEntryNotifications })
        elseif action.key == "toggle-hud-area-exit" then
            SARNSettings.apply({ showAreaExitNotifications =
                not values.showAreaExitNotifications })
        elseif action.key == "hud-font-dec" then
            SARNSettings.apply({ hudFontSize = math.max(9, values.hudFontSize - 1) })
        elseif action.key == "hud-font-inc" then
            SARNSettings.apply({ hudFontSize = math.min(24, values.hudFontSize + 1) })
        elseif action.key == "toggle-group-current" then
            SARNSettings.apply({ allowGroupsAsCurrentArea =
                not values.allowGroupsAsCurrentArea })
        elseif action.key == "toggle-adapt" then
            SARNSettings.apply({ adaptArRedrawFrequencyToFps =
                not values.adaptArRedrawFrequencyToFps })
            local restarted = type(SARNRestartPerformance) == "function"
                and pcall(SARNRestartPerformance)
            if not restarted then SARNPerformanceNeedsRestart = true end
        elseif action.key == "maximum-dec" then
            SARNSettings.apply({ maximumArRedrawPercentOfFps =
                math.max(1, values.maximumArRedrawPercentOfFps - 5) })
            local restarted = type(SARNRestartPerformance) == "function"
                and pcall(SARNRestartPerformance)
            if not restarted then SARNPerformanceNeedsRestart = true end
        elseif action.key == "maximum-inc" then
            SARNSettings.apply({ maximumArRedrawPercentOfFps =
                math.min(100, values.maximumArRedrawPercentOfFps + 5) })
            local restarted = type(SARNRestartPerformance) == "function"
                and pcall(SARNRestartPerformance)
            if not restarted then SARNPerformanceNeedsRestart = true end
        elseif action.key == "nearby-atmo-dec" then
            SARNSettings.apply({ nearbyAtmoRangeKm = math.max(1, values.nearbyAtmoRangeKm - 1) })
        elseif action.key == "nearby-atmo-inc" then
            SARNSettings.apply({ nearbyAtmoRangeKm = math.min(100000,
                values.nearbyAtmoRangeKm + 1) })
        elseif action.key == "nearby-space-dec" then
            SARNSettings.apply({ nearbySpaceRangeKm = math.max(1,
                values.nearbySpaceRangeKm - 10) })
        elseif action.key == "nearby-space-inc" then
            SARNSettings.apply({ nearbySpaceRangeKm = math.min(100000,
                values.nearbySpaceRangeKm + 10) })
        elseif action.key == "nearby-count-dec" then
            SARNSettings.apply({ maximumNearbyPlaces = math.max(1,
                values.maximumNearbyPlaces - 1) })
        elseif action.key == "nearby-count-inc" then
            SARNSettings.apply({ maximumNearbyPlaces = math.min(100,
                values.maximumNearbyPlaces + 1) })
        elseif action.key == "save-databank" then
            local saved, reason = SARNSettings.save()
            local text
            if saved then
                text = "Data saved to databank."
                system.print("[SARN] " .. text)
                SARNController.notification = { text = text, error = false,
                    untilTime = (tonumber(SARN.call(system, "getArkTime")) or 0) + 5 }
            else
                text = reason == "missing"
                    and "Databank is not available. Link a Databank element to the Control Unit."
                    or "Could not save data to the linked Databank."
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
        end
        return true
    end
    return false
end
