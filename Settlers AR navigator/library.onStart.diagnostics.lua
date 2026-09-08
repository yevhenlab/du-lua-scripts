-- Measures successful event-handler instruction and elapsed-time usage for SARN HUD diagnostics.
-- Library dependencies: none.
SARNDiagnostics = SARNDiagnostics or { samples = {}, peakPercent = 0 }

function SARNDiagnostics.beginMeasurement()
    return {
        instructions = system.getInstructionCount(),
        time = system.getArkTime()
    }
end

function SARNDiagnostics.finishMeasurement(name, measurement)
    local instructionLimit = tonumber(system.getInstructionLimit()) or 0
    local instructions = math.max(0, (tonumber(system.getInstructionCount()) or 0) - measurement.instructions)
    local elapsedMilliseconds = math.max(0, (system.getArkTime() - measurement.time) * 1000)
    local percent = instructionLimit > 0 and instructions / instructionLimit * 100 or 0
    SARNDiagnostics.samples[name] = {
        instructions = instructions,
        instructionLimit = instructionLimit,
        percent = percent,
        elapsedMilliseconds = elapsedMilliseconds
    }
    SARNDiagnostics.peakPercent = math.max(SARNDiagnostics.peakPercent or 0, percent)
    return SARNDiagnostics.samples[name]
end

function SARNDiagnostics.getSample(name)
    return SARNDiagnostics.samples[name] or { percent = 0, elapsedMilliseconds = 0 }
end
