local function initializeLiby4performance(controlUnit, systemApi, options)
    options = options or {}
    local performance, contentRenderers = { version = "0.2.2" }, {}
    local adaptArRedrawFrequencyToFps = options.adaptArRedrawFrequencyToFps ~= false
    local maximumArRedrawPercentOfFps = math.max(1, math.min(100, tonumber(options.maximumArRedrawPercentOfFps) or 100))
    local minimumArRedrawFrequency = math.max(.5, tonumber(options.minimumArRedrawFrequency) or 2)
    local state = { frames = 0, frameStartedAt = nil, fps = nil, history = {}, nextRenderAt = nil, targetInterval = .1, targetFrequency = 10, drawFrequency = 10, refreshes = 0, refreshStartedAt = nil, refreshHz = 0 }
    local scheduledTasks, activeJobs, jobsByName = {}, {}, {}
    local taskCursor, jobCursor, preferJob = 1, 1, false
    local minimumWorkSteps = math.max(1, math.floor(tonumber(options.minimumWorkStepsPerUpdate) or 1))
    local maximumWorkSteps = math.max(minimumWorkSteps, math.floor(tonumber(options.maximumWorkStepsPerUpdate) or 4))
    local maximumWorkSeconds = math.max(0, tonumber(options.maximumWorkSecondsPerUpdate) or .002)
    local priorityAgingPerUpdate = math.max(1, tonumber(options.priorityAgingPerUpdate) or 25)
    state.workSteps, state.workStartedAt, state.workHz, state.updateNumber = 0, nil, 0, 0
    state.currentWorkBudget = maximumWorkSteps
    local function average(seconds)
        local first, total, count = math.max(1, #state.history - seconds + 1), 0, 0
        for index = first, #state.history do total, count = total + state.history[index], count + 1 end
        return count > 0 and total / count or nil
    end
    local function adjustDrawingFrequency()
        local currentFps, referenceFps = average(5), average(60)
        if currentFps == nil or referenceFps == nil or referenceFps <= 0 then return end
        local redrawCap = math.max(minimumArRedrawFrequency,
            currentFps * maximumArRedrawPercentOfFps / 100)
        if not adaptArRedrawFrequencyToFps then state.targetFrequency, state.drawFrequency = redrawCap, redrawCap; return end
        if currentFps < referenceFps * .9 then
            local k = math.min(1, currentFps / referenceFps)
            state.targetFrequency = math.max(minimumArRedrawFrequency, redrawCap * k)
        else
            state.targetFrequency = redrawCap
        end
        local gap, step = state.targetFrequency - state.drawFrequency, 0
        if math.abs(gap) >= 20 then step = 3 elseif math.abs(gap) >= 10 then step = 2 elseif math.abs(gap) > 0 then step = 1 end
        if gap > 0 then state.drawFrequency = math.min(state.targetFrequency, state.drawFrequency + step) elseif gap < 0 then state.drawFrequency = math.max(state.targetFrequency, state.drawFrequency - step) end
    end
    local function reportError(owner, message)
        owner.error = tostring(message)
        if type(owner.onError) == "function" then
            pcall(owner.onError, owner.error, owner.name)
        elseif type(options.onError) == "function" then
            pcall(options.onError, owner.name, owner.error)
        end
    end
    local function removeTask(name)
        for index = #scheduledTasks, 1, -1 do
            if scheduledTasks[index].name == name then
                table.remove(scheduledTasks, index)
                if taskCursor > index then taskCursor = taskCursor - 1 end
            end
        end
        if taskCursor > #scheduledTasks then taskCursor = 1 end
    end
    local function removeActiveJob(job)
        for index = #activeJobs, 1, -1 do
            if activeJobs[index] == job then
                table.remove(activeJobs, index)
                if jobCursor > index then jobCursor = jobCursor - 1 end
                break
            end
        end
        if jobCursor > #activeJobs then jobCursor = 1 end
    end
    local function registerTask(name, seconds, callback, onError, immediate, once)
        assert(type(name) == "string" and name ~= "", "task name is required")
        assert(type(callback) == "function", "task callback must be a function")
        removeTask(name)
        local period = math.max(0, tonumber(seconds) or 0)
        local currentTime = systemApi.getArkTime()
        local task = {
            name = name,
            period = period,
            callback = callback,
            onError = onError,
            once = once == true,
            lastUpdateRun = -1,
            nextRunAt = immediate and currentTime or currentTime + period
        }
        scheduledTasks[#scheduledTasks + 1] = task
        return task
    end
    function performance.everyFrame(name, callback, onError)
        return registerTask(name, 0, callback, onError, true, false)
    end
    function performance.every(name, seconds, callback, onError)
        assert(tonumber(seconds) ~= nil and tonumber(seconds) > 0, "task period must be greater than zero")
        return registerTask(name, seconds, callback, onError, false, false)
    end
    function performance.once(name, callback, onError)
        return registerTask(name, 0, callback, onError, true, true)
    end
    function performance.removeTask(name)
        local count = #scheduledTasks
        removeTask(name)
        return #scheduledTasks < count
    end
    function performance.cancelJob(name)
        local job = jobsByName[name]
        if job == nil or job.status ~= "running" then return false end
        job.status = "cancelled"
        removeActiveJob(job)
        return true
    end
    function performance.startJob(name, worker, onDone, onError, priority)
        assert(type(name) == "string" and name ~= "", "job name is required")
        assert(type(worker) == "function", "job worker must be a function")
        performance.cancelJob(name)
        local job = {
            name = name,
            status = "running",
            progress = nil,
            result = nil,
            error = nil,
            onDone = onDone,
            onError = onError,
            priority = tonumber(priority) or 0,
            lastRunUpdate = state.updateNumber
        }
        function job:yield(progress)
            return coroutine.yield(progress)
        end
        job.thread = coroutine.create(function()
            return worker(job)
        end)
        jobsByName[name] = job
        activeJobs[#activeJobs + 1] = job
        return job
    end
    function performance.getJobInfo(name)
        local job = jobsByName[name]
        if job == nil then return nil end
        return {
            name = job.name,
            status = job.status,
            progress = job.progress,
            result = job.result,
            error = job.error
        }
    end
    local function runOneTask(currentTime)
        local count = #scheduledTasks
        if count == 0 then return false end
        for _ = 1, count do
            if taskCursor > #scheduledTasks then taskCursor = 1 end
            local task = scheduledTasks[taskCursor]
            taskCursor = taskCursor + 1
            if task ~= nil and task.lastUpdateRun ~= state.updateNumber
                and currentTime >= task.nextRunAt then
                task.lastUpdateRun = state.updateNumber
                local ok, result = pcall(task.callback)
                if ok then task.result = result else reportError(task, result) end
                if task.once then
                    removeTask(task.name)
                elseif task.period > 0 then
                    repeat task.nextRunAt = task.nextRunAt + task.period until task.nextRunAt > currentTime
                else
                    task.nextRunAt = currentTime
                end
                return true
            end
        end
        return false
    end
    local function runOneJob()
        local count = #activeJobs
        if count == 0 then return false end
        local highestPriority = -math.huge
        for _, candidate in ipairs(activeJobs) do
            if candidate.status == "running" then
                local age = math.max(
                    0,
                    state.updateNumber - candidate.lastRunUpdate
                )
                candidate.effectivePriority = candidate.priority
                    + age * priorityAgingPerUpdate
                highestPriority = math.max(
                    highestPriority,
                    candidate.effectivePriority
                )
            end
        end
        for _ = 1, count do
            if jobCursor > #activeJobs then jobCursor = 1 end
            local job = activeJobs[jobCursor]
            jobCursor = jobCursor + 1
            if job ~= nil and job.status == "running"
                and job.effectivePriority == highestPriority then
                job.lastRunUpdate = state.updateNumber
                local ok, value = coroutine.resume(job.thread)
                if not ok then
                    job.status = "failed"
                    reportError(job, value)
                    removeActiveJob(job)
                elseif coroutine.status(job.thread) == "dead" then
                    job.status = "completed"
                    job.result = value
                    removeActiveJob(job)
                    if type(job.onDone) == "function" then
                        local doneOk, doneError = pcall(job.onDone, value, job.name)
                        if not doneOk then reportError(job, doneError) end
                    end
                else
                    job.progress = value
                end
                return true
            end
        end
        return false
    end
    local function getWorkBudget()
        local recent, reference = average(5), average(60)
        local ratio = 1
        if recent ~= nil and reference ~= nil and reference > 0
            and recent < reference * .9 then
            ratio = math.max(0, math.min(1, recent / reference))
        end
        return math.max(minimumWorkSteps, math.floor(maximumWorkSteps * ratio + .5))
    end
    local function runScheduledWork(currentTime)
        local budget = getWorkBudget()
        state.currentWorkBudget = budget
        local startedAt = systemApi.getArkTime()
        for _ = 1, budget do
            local ran
            if preferJob then
                ran = runOneJob()
                if not ran then ran = runOneTask(currentTime) end
            else
                ran = runOneTask(currentTime)
                if not ran then ran = runOneJob() end
            end
            preferJob = not preferJob
            if not ran then break end
            state.workSteps = state.workSteps + 1
            if maximumWorkSeconds > 0
                and systemApi.getArkTime() - startedAt >= maximumWorkSeconds then
                break
            end
        end
    end
    function performance.getRenderInfo() return { fps = state.fps, currentFps = average(5), referenceFps = average(60), history = state.history, targetInterval = state.targetInterval, targetHz = state.targetFrequency, drawHz = state.drawFrequency, currentHz = state.refreshHz, workHz = state.workHz, workBudget = state.currentWorkBudget, activeJobs = #activeJobs, scheduledTasks = #scheduledTasks, lastRenderError = state.lastRenderError } end
    function performance.setContentRenderer(renderer) contentRenderers = type(renderer) == "function" and { renderer } or {} end
    function performance.addContentRenderer(renderer) if type(renderer) == "function" then contentRenderers[#contentRenderers + 1] = renderer end end
    function performance.render()
        local content = {}
        for _, renderer in ipairs(contentRenderers) do
            local ok, html = pcall(renderer, performance.getRenderInfo())
            if ok and type(html) == "string" then
                content[#content + 1] = html
            elseif not ok then
                state.lastRenderError = tostring(html)
                if type(options.onError) == "function" then
                    pcall(options.onError, "renderer", state.lastRenderError)
                end
            end
        end
        systemApi.setScreen(table.concat(content))
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
        state.updateNumber = state.updateNumber + 1
        if state.refreshStartedAt == nil then state.refreshStartedAt = now elseif now - state.refreshStartedAt >= 1 then state.refreshHz, state.refreshes, state.refreshStartedAt = state.refreshes / (now - state.refreshStartedAt), 0, now end
        if state.workStartedAt == nil then state.workStartedAt = now elseif now - state.workStartedAt >= 1 then state.workHz, state.workSteps, state.workStartedAt = state.workSteps / (now - state.workStartedAt), 0, now end
        if state.frameStartedAt == nil then state.frameStartedAt, state.frames = now, 0 end
        state.frames = state.frames + 1
        if now - state.frameStartedAt >= 1 then state.fps = state.frames / (now - state.frameStartedAt); state.history[#state.history + 1] = state.fps; while #state.history > 60 do table.remove(state.history, 1) end; adjustDrawingFrequency(); state.frames, state.frameStartedAt = 0, now end
        state.targetInterval = 1 / math.max(minimumArRedrawFrequency, state.drawFrequency)
        local latestUsefulRender = now + state.targetInterval
        if state.nextRenderAt ~= nil and state.nextRenderAt > latestUsefulRender then
            state.nextRenderAt = latestUsefulRender
        end
        renderIfDue(now); runScheduledWork(now)
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
