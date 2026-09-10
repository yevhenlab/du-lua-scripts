-- Activates the highlighted controller first, then a location interaction.
-- Library dependencies: SARNController and SARNArDrawing.
if action == "leftmouse" and SARNArDrawing ~= nil then
    local ok, errorMessage = pcall(function()
        local handled = SARNController ~= nil and SARNController.activateSelectedAction()
        if not handled then SARNArDrawing.activateSelectedAction() end
    end)
    if not ok then system.print("[SARN] AR action failed: " .. tostring(errorMessage)) end
end
