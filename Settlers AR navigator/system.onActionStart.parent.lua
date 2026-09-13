-- Reveals SARN with Alt+5 or activates the highlighted controller/location interaction.
-- Library dependencies: SARNController and SARNArDrawing.
if action == "option5" and SARNController ~= nil then
    local ok, shownOrError = pcall(SARNController.showFromShortcut)
    if not ok then system.print("[SARN] Shortcut failed: " .. tostring(shownOrError)) end
elseif action == "leftmouse" and SARNArDrawing ~= nil then
    local ok, errorMessage = pcall(function()
        local handled = SARNController ~= nil and SARNController.activateSelectedAction()
        if not handled then SARNArDrawing.activateSelectedAction() end
    end)
    if not ok then system.print("[SARN] AR action failed: " .. tostring(errorMessage)) end
end
