local function initializeLiby4performance(environment, controlUnit, systemApi, playerApi, options)
    options = options or {}
    local performance = {}
    local mode = string.lower(tostring(options.panelMode or "small"))
    if mode ~= "none" and mode ~= "tiny" and mode ~= "detailed" then mode = "small" end
    local horizontalSide = string.lower(tostring(options.panelHorizontalSide or "right"))
    if horizontalSide ~= "left" then horizontalSide = "right" end
    local verticalSide = string.lower(tostring(options.panelVerticalSide or "top"))
    if verticalSide ~= "bottom" then verticalSide = "top" end
    local widths = { tiny = 178, small = 210, detailed = 252 }
    local panel = {
        mode = mode, horizontalSide = horizontalSide,
        horizontalOffset = math.max(0, tonumber(options.panelHorizontalOffset) or 70),
        verticalSide = verticalSide,
        verticalOffset = math.max(0, tonumber(options.panelVerticalOffset) or 400),
        width = widths[mode]
    }
    local allowFpsCut = options.reduceArFrequencyOnFpsDrop ~= false
    local contentRenderers = {}
    local state = {
        frames = 0, frameStartedAt = nil, fps = nil, history = {}, reduction = 0,
        lastRenderedAt = nil, lastCameraAt = nil, lastCamera = nil, lastPlayer = nil,
        angularSpeed = 0, playerSpeed = 0, targetInterval = .2,
        refreshes = 0, refreshStartedAt = nil, refreshHz = 0
    }

    local function components(vector)
        if vector == nil then return nil end
        local x, y, z = tonumber(vector.x or vector[1]), tonumber(vector.y or vector[2]), tonumber(vector.z or vector[3])
        if x == nil or y == nil or z == nil then return nil end
        return x, y, z
    end
    local function distance(left, right)
        local lx, ly, lz = components(left); local rx, ry, rz = components(right)
        if lx == nil or rx == nil then return 0 end
        local dx, dy, dz = lx - rx, ly - ry, lz - rz
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end
    local function angle(left, right)
        local lx, ly, lz = components(left); local rx, ry, rz = components(right)
        if lx == nil or rx == nil then return 0 end
        local ll, rl = math.sqrt(lx * lx + ly * ly + lz * lz), math.sqrt(rx * rx + ry * ry + rz * rz)
        if ll == 0 or rl == 0 then return 0 end
        return math.deg(math.acos(math.max(-1, math.min(1, (lx * rx + ly * ry + lz * rz) / (ll * rl)))))
    end
    local function average(seconds)
        local first, total, count = math.max(1, #state.history - seconds + 1), 0, 0
        for index = first, #state.history do total, count = total + state.history[index], count + 1 end
        return count > 0 and total / count or nil
    end
    local function reduction()
        if #state.history < 5 then return 0 end
        local recent, largest = average(5), 0
        for _, seconds in ipairs({ 15, 30, 60 }) do
            if #state.history >= seconds then
                local baseline = average(seconds)
                if baseline and baseline > 0 then largest = math.max(largest, (baseline - recent) / baseline) end
            end
        end
        return math.max(0, math.min(.95, largest))
    end
    local function detailedGraph(width, height)
        local first, maximum = math.max(1, #state.history - 59), 60
        for index = first, #state.history do maximum = math.max(maximum, state.history[index]) end
        maximum = math.ceil(maximum / 30) * 30
        local bars, index, bar = "", first, 0
        local barCount = math.ceil((#state.history - first + 1) / 2)
        local labelAreaHeight = 20
        local plotHeight = math.max(1, height - labelAreaHeight - 2)
        while index <= #state.history do
            local total, count = state.history[index], 1
            if index + 1 <= #state.history then total, count = total + state.history[index + 1], 2 end
            local x = barCount == 1 and width / 2
                or 2 + bar * (width - 4) / (barCount - 1)
            local barHeight = math.max(1, math.min(
                plotHeight,
                total / count / maximum * plotHeight
            ))
            local color = bar >= 27 and '#f1f5f7' or bar >= 22 and '#9bdcf8' or bar >= 15 and '#b9cbd4' or '#91a1aa'
            bars = bars .. string.format('<line x1="%.1f" y1="%d" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="3"/>', x, height - 2, x, height - 2 - barHeight, color)
            index, bar = index + 2, bar + 1
        end
        local function label(seconds) local value = average(seconds); return value and string.format("%.0f fps", value) or "- fps" end
        local labels = '<text x="1" y="11" fill="#91a1aa">' .. label(60) .. '</text>'
            .. '<text x="' .. width * .5 .. '" y="11" text-anchor="middle" fill="#b9cbd4">' .. label(30) .. '</text>'
            .. '<text x="' .. width * .75 .. '" y="11" text-anchor="middle" fill="#9bdcf8">' .. label(15) .. '</text>'
            .. '<text x="' .. (width - 1) .. '" y="11" text-anchor="end" fill="#f1f5f7">' .. label(5) .. '</text>'
        return '<svg width="' .. width .. '" height="' .. height .. '" viewBox="0 0 ' .. width .. ' ' .. height .. '" style="display:block;margin-top:4px;"><g style="font-family:Arial,sans-serif;font-size:11px">' .. labels .. '</g><line x1="0" y1="' .. (height - 2) .. '" x2="' .. width .. '" y2="' .. (height - 2) .. '" stroke="rgba(185,215,225,.2)" stroke-width="1"/>' .. bars .. '</svg>', maximum
    end
    local function panelHtml()
        if panel.mode == "none" then return "" end
        local fpsLabel = state.fps and string.format("%.0f FPS", state.fps) or "Measuring..."
        local redrawLabel, cutLabel = string.format("%.1f Hz", state.refreshHz), string.format("%.0f%%", state.reduction * 100)
        local style = 'position:absolute;' .. panel.horizontalSide .. ':' .. panel.horizontalOffset .. 'px;' .. panel.verticalSide .. ':' .. panel.verticalOffset .. 'px;box-sizing:border-box;padding:8px;color:#f2fbff;background:rgba(3,8,12,.5);border-left:1px solid rgba(100,225,255,.7);font:12px Arial,sans-serif;text-shadow:0 0 5px #000;'
        if panel.mode == "tiny" then return '<div style="' .. style .. 'width:' .. panel.width .. 'px;padding:6px 8px;white-space:nowrap;font-size:12px;text-shadow:1px 1px 0 #000;"><b>' .. fpsLabel .. '</b> | Cut ' .. cutLabel .. ' | ' .. redrawLabel .. '</div>' end
        if panel.mode == "small" then return '<div style="' .. style .. 'width:' .. panel.width .. 'px;"><div style="display:flex;justify-content:space-between"><span>Performance</span><b>' .. fpsLabel .. '</b></div><div style="display:flex;justify-content:space-between;margin-top:4px;color:#c5dbe8;font-size:11px;white-space:nowrap;"><span>Draw: cut ' .. cutLabel .. '</span><b style="font-size:12px">' .. redrawLabel .. '</b></div><div style="margin-top:2px;color:#c5dbe8;font-size:11px;white-space:nowrap;">Camera: ' .. string.format("%.1f deg/s", state.angularSpeed) .. ' | Player: ' .. string.format("%.1f m/s", state.playerSpeed) .. '</div></div>' end
        local graph, scale = detailedGraph(panel.width - 20, 89)
        local luaMemoryKb = collectgarbage("count")
        return '<div style="' .. style .. 'width:' .. panel.width .. 'px;padding:10px;font-size:14px;"><div style="display:flex;justify-content:space-between"><span>Performance</span><b>' .. fpsLabel .. '</b></div><div style="display:flex;justify-content:space-between;margin-top:4px;color:#d5e8f1;font-size:12px;"><span>Drawing reduction: ' .. cutLabel .. '</span><span>AR ' .. redrawLabel .. '</span></div>' .. graph .. '<div style="display:flex;justify-content:space-between;margin-top:1px;color:#c5dbe8;font-size:11px;"><span>' .. math.min(60, #state.history) .. ' sec ago</span><span>Graph max ' .. scale .. ' FPS</span><span>now</span></div><div style="margin-top:5px;color:#c5dbe8;font-size:11px;white-space:nowrap;">Camera: ' .. string.format("%.1f deg/s", state.angularSpeed) .. ' | Player: ' .. string.format("%.1f m/s", state.playerSpeed) .. '</div><div style="margin-top:2px;color:#c5dbe8;font-size:11px;white-space:nowrap;">Lua memory: ' .. string.format("%.1f KB", luaMemoryKb) .. '</div></div>'
    end
    function performance.getRenderInfo()
        return {
            fps = state.fps,
            drawingReduction = state.reduction,
            targetInterval = state.targetInterval,
            targetHz = 1 / state.targetInterval,
            currentHz = state.refreshHz
        }
    end
    function performance.setContentRenderer(renderer)
        contentRenderers = type(renderer) == "function" and { renderer } or {}
    end
    function performance.addContentRenderer(renderer)
        if type(renderer) == "function" then
            contentRenderers[#contentRenderers + 1] = renderer
        end
    end
    function performance.render()
        local content = ""
        for _, renderer in ipairs(contentRenderers) do
            local ok, html = pcall(renderer, performance.getRenderInfo())
            if ok and type(html) == "string" then content = content .. html end
        end
        systemApi.setScreen(content .. panelHtml())
        state.lastRenderedAt, state.refreshes = systemApi.getArkTime(), state.refreshes + 1
    end
    function performance.onUpdate()
        local now = systemApi.getArkTime()
        if state.refreshStartedAt == nil then state.refreshStartedAt = now elseif now - state.refreshStartedAt >= 1 then state.refreshHz, state.refreshes, state.refreshStartedAt = state.refreshes / (now - state.refreshStartedAt), 0, now end
        if state.frameStartedAt == nil then state.frameStartedAt, state.frames = now, 0 end
        state.frames = state.frames + 1
        if now - state.frameStartedAt >= 1 then state.fps = state.frames / (now - state.frameStartedAt); state.history[#state.history + 1] = state.fps; while #state.history > 60 do table.remove(state.history, 1) end; state.reduction = reduction(); state.frames, state.frameStartedAt = 0, now end
        local camera, position = systemApi.getCameraWorldForward(), playerApi.getPosition() or playerApi.getWorldPosition()
        if state.lastCameraAt and state.lastCamera then
            local elapsed = now - state.lastCameraAt
            if elapsed > 0 then
                local smoothing = math.min(1, elapsed * 8)
                state.angularSpeed = state.angularSpeed + (angle(state.lastCamera, camera) / elapsed - state.angularSpeed) * smoothing
                if state.lastPlayer and components(position) then state.playerSpeed = state.playerSpeed + (distance(state.lastPlayer, position) / elapsed - state.playerSpeed) * smoothing end
            end
        end
        state.lastCameraAt, state.lastCamera, state.lastPlayer = now, camera, position
        local motion = math.min(1, math.max(state.angularSpeed / 45, state.playerSpeed / 5)) ^ .5
        local frequency = 5 + (1 / .033 - 5) * motion
        if allowFpsCut then frequency = frequency * (1 - state.reduction) end
        state.targetInterval = 1 / math.max(.5, frequency)
        if state.lastRenderedAt == nil or now - state.lastRenderedAt >= state.targetInterval then performance.render() end
    end
    function performance.onTimer(tag)
        if tag == "liby4performanceHud" then
            local now = systemApi.getArkTime()
            if state.lastRenderedAt == nil or now - state.lastRenderedAt >= state.targetInterval then
                performance.render()
            end
        end
    end
    function performance.start()
        systemApi.showScreen(true); performance.render(); controlUnit.setTimer("liby4performanceHud", .5)
    end
    return performance
end

return initializeLiby4performance
