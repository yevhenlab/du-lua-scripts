-- Forwards the scheduled HUD refresh to liby4performance.
-- Library dependencies: ARNPerformance initialized by unit.onStart.lua.
local ok, errorMessage = pcall(ARNPerformance.onTimer, tag)
if not ok then
    system.print(ARN.chatPrefix() .. "Renderer timer disabled after error: " .. tostring(errorMessage))
    ARNPerformance.onTimer = function() end
end
