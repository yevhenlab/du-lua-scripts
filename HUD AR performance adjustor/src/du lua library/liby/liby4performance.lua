local function initializeLiby4performance(environment, controlUnit, systemApi, playerApi, options)
    options = options or {}
    local performance, contentRenderers = {}, {}
    local allowFpsCut = options.reduceArFrequencyOnFpsDrop ~= false
    local state = { frames = 0, frameStartedAt = nil, fps = nil, history = {}, reduction = 0, lastRenderedAt = nil, lastCameraAt = nil, lastCamera = nil, lastPlayer = nil, angularSpeed = 0, playerSpeed = 0, targetInterval = .2, refreshes = 0, refreshStartedAt = nil, refreshHz = 0 }
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
    function performance.getRenderInfo() return { fps = state.fps, drawingReduction = state.reduction, targetInterval = state.targetInterval, targetHz = 1 / state.targetInterval, currentHz = state.refreshHz } end
    function performance.setContentRenderer(renderer) contentRenderers = type(renderer) == "function" and { renderer } or {} end
    function performance.addContentRenderer(renderer) if type(renderer) == "function" then contentRenderers[#contentRenderers + 1] = renderer end end
    function performance.render()
        local content = ""
        for _, renderer in ipairs(contentRenderers) do
            local ok, html = pcall(renderer, performance.getRenderInfo())
            if ok and type(html) == "string" then content = content .. html end
        end
        systemApi.setScreen(content)
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
            if state.lastRenderedAt == nil or now - state.lastRenderedAt >= state.targetInterval then performance.render() end
        end
    end
    function performance.start() systemApi.showScreen(true); performance.render(); controlUnit.setTimer("liby4performanceHud", .5) end
    return performance
end

return initializeLiby4performance
