local function initializeLiby4performance(controlUnit, systemApi, options)
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
    local adaptArRedrawFrequencyToFps = options.adaptArRedrawFrequencyToFps ~= false
    local maximumArRedrawPercentOfFps = math.max(1, math.min(100, tonumber(options.maximumArRedrawPercentOfFps) or 100))
    local contentRenderers = {}
    local state = {
        frames = 0, frameStartedAt = nil, fps = nil, history = {},
        nextRenderAt = nil, targetInterval = .1, targetFrequency = 10, drawFrequency = 10,
        refreshes = 0, refreshStartedAt = nil, refreshHz = 0
    }

    local function average(seconds)
        local first, total, count = math.max(1, #state.history - seconds + 1), 0, 0
        for index = first, #state.history do total, count = total + state.history[index], count + 1 end
        return count > 0 and total / count or nil
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
        local redrawLabel, targetLabel = string.format("%.1f Hz", state.refreshHz), string.format("%.0f Hz", state.targetFrequency)
        local style = 'position:absolute;' .. panel.horizontalSide .. ':' .. panel.horizontalOffset .. 'px;' .. panel.verticalSide .. ':' .. panel.verticalOffset .. 'px;box-sizing:border-box;padding:8px;color:#f2fbff;background:rgba(3,8,12,.5);border-left:1px solid rgba(100,225,255,.7);font:12px Arial,sans-serif;text-shadow:0 0 5px #000;'
        if panel.mode == "tiny" then return '<div style="' .. style .. 'width:' .. panel.width .. 'px;padding:6px 8px;white-space:nowrap;font-size:12px;text-shadow:1px 1px 0 #000;"><b>' .. fpsLabel .. '</b> | Target ' .. targetLabel .. ' | ' .. redrawLabel .. '</div>' end
        if panel.mode == "small" then return '<div style="' .. style .. 'width:' .. panel.width .. 'px;"><div style="display:flex;justify-content:space-between"><span>Performance</span><b>' .. fpsLabel .. '</b></div><div style="display:flex;justify-content:space-between;margin-top:4px;color:#c5dbe8;font-size:11px;white-space:nowrap;"><span>Draw target: ' .. targetLabel .. '</span><b style="font-size:12px">' .. redrawLabel .. '</b></div></div>' end
        local graph, scale = detailedGraph(panel.width - 20, 89)
        return '<div style="' .. style .. 'width:' .. panel.width .. 'px;padding:10px;font-size:14px;"><div style="display:flex;justify-content:space-between"><span>Performance</span><b>' .. fpsLabel .. '</b></div><div style="display:flex;justify-content:space-between;margin-top:4px;color:#d5e8f1;font-size:12px;"><span>Draw target: ' .. targetLabel .. '</span><span>AR ' .. redrawLabel .. '</span></div>' .. graph .. '<div style="display:flex;justify-content:space-between;margin-top:1px;color:#c5dbe8;font-size:11px;"><span>' .. math.min(60, #state.history) .. ' sec ago</span><span>Graph max ' .. scale .. ' FPS</span><span>now</span></div></div>'
    end
    local function adjustDrawingFrequency()
        local currentFps, referenceFps = average(5), average(60)
        if currentFps == nil or referenceFps == nil or referenceFps <= 0 then return end
        local redrawCap = currentFps * maximumArRedrawPercentOfFps / 100
        if not adaptArRedrawFrequencyToFps then state.targetFrequency, state.drawFrequency = redrawCap, redrawCap; return end
        if currentFps < referenceFps * .9 then
            local k = math.min(1, currentFps / referenceFps)
            state.targetFrequency = math.min(redrawCap, math.max(.01, state.targetFrequency * k))
        else
            state.targetFrequency = redrawCap
        end
        local gap, step = state.targetFrequency - state.drawFrequency, 0
        if math.abs(gap) >= 20 then step = 3 elseif math.abs(gap) >= 10 then step = 2 elseif math.abs(gap) > 0 then step = 1 end
        if gap > 0 then state.drawFrequency = math.min(state.targetFrequency, state.drawFrequency + step) elseif gap < 0 then state.drawFrequency = math.max(state.targetFrequency, state.drawFrequency - step) end
    end
    function performance.getRenderInfo()
        return {
            fps = state.fps,
            currentFps = average(5), referenceFps = average(60),
            targetInterval = state.targetInterval,
            targetHz = state.targetFrequency, drawHz = state.drawFrequency,
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
        state.refreshes = state.refreshes + 1
    end
    local function renderIfDue(now)
        if state.nextRenderAt == nil then performance.render(); state.nextRenderAt = now + state.targetInterval; return end
        if now < state.nextRenderAt then return end
        performance.render()
        repeat state.nextRenderAt = state.nextRenderAt + state.targetInterval until state.nextRenderAt > now
    end
    function performance.onUpdate()
        local now = systemApi.getArkTime()
        if state.refreshStartedAt == nil then state.refreshStartedAt = now elseif now - state.refreshStartedAt >= 1 then state.refreshHz, state.refreshes, state.refreshStartedAt = state.refreshes / (now - state.refreshStartedAt), 0, now end
        if state.frameStartedAt == nil then state.frameStartedAt, state.frames = now, 0 end
        state.frames = state.frames + 1
        if now - state.frameStartedAt >= 1 then state.fps = state.frames / (now - state.frameStartedAt); state.history[#state.history + 1] = state.fps; while #state.history > 60 do table.remove(state.history, 1) end; adjustDrawingFrequency(); state.frames, state.frameStartedAt = 0, now end
        state.targetInterval = 1 / math.max(.01, state.drawFrequency); renderIfDue(now)
    end
    function performance.onTimer(tag)
        if tag == "liby4performanceHud" then
            local now = systemApi.getArkTime()
            renderIfDue(now)
        end
    end
    function performance.start()
        systemApi.showScreen(true); performance.render(); state.nextRenderAt = systemApi.getArkTime() + state.targetInterval; controlUnit.setTimer("liby4performanceHud", .5)
    end
    return performance
end

return initializeLiby4performance
