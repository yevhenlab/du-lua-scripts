-- Activates the currently highlighted SARN details-view navigation row.
-- Library dependencies: SARNArDrawing initialized by library.onStart.arDrawing.lua.
if action == "leftmouse" and SARNArDrawing ~= nil then
    local ok, errorMessage = pcall(SARNArDrawing.activateSelectedAction)
    if not ok then system.print("[SARN] Parent navigation failed: " .. tostring(errorMessage)) end
end
