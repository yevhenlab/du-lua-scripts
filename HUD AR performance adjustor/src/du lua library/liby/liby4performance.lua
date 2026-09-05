local function initializeLiby4performance(controlUnit, systemApi, options)
    options = options or {}
    local performance, contentRenderers = {}, {}
    local adaptArRedrawFrequencyToFps = options.adaptArRedrawFrequencyToFps ~= false
    local maximumArRedrawPercentOfFps = math.max(1, math.min(100, tonumber(options.maximumArRedrawPercentOfFps) or 100))
    local state = { frames = 0, frameStartedAt = nil, fps = nil, history = {}, nextRenderAt = nil, targetInterval = .1, targetFrequency = 10, drawFrequency = 10, refreshes = 0, refreshStartedAt = nil, refreshHz = 0 }
    local function average(seconds)
        local first, total, count = math.max(1, #state.history - seconds + 1), 0, 0
        for index = first, #state.history do total, count = total + state.history[index], count + 1 end
        return count > 0 and total / count or nil
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
    function performance.getRenderInfo() return { fps = state.fps, currentFps = average(5), referenceFps = average(60), targetInterval = state.targetInterval, targetHz = state.targetFrequency, drawHz = state.drawFrequency, currentHz = state.refreshHz } end
    function performance.setContentRenderer(renderer) contentRenderers = type(renderer) == "function" and { renderer } or {} end
    function performance.addContentRenderer(renderer) if type(renderer) == "function" then contentRenderers[#contentRenderers + 1] = renderer end end
    function performance.render()
        local content = ""
        for _, renderer in ipairs(contentRenderers) do
            local ok, html = pcall(renderer, performance.getRenderInfo())
            if ok and type(html) == "string" then content = content .. html end
        end
        systemApi.setScreen(content)
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
    function performance.start() systemApi.showScreen(true); performance.render(); state.nextRenderAt = systemApi.getArkTime() + state.targetInterval; controlUnit.setTimer("liby4performanceHud", .5) end
    return performance
end

return initializeLiby4performance
