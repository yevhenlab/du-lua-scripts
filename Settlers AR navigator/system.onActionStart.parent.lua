-- Reveals ARN with Alt+5 or activates the highlighted controller/location interaction.
-- Library dependencies: ARNController and ARNArDrawing.
if action == "option5" and ARNController ~= nil then
    local ok, shownOrError = pcall(ARNController.showFromShortcut)
    if not ok then system.print(ARN.chatPrefix() .. "Shortcut failed: " .. tostring(shownOrError)) end
elseif action == "leftmouse" and ARNArDrawing ~= nil then
    local ok, errorMessage = pcall(function()
        local handled = ARNController ~= nil and ARNController.activateSelectedAction()
        if not handled then ARNArDrawing.activateSelectedAction() end
    end)
    if not ok then system.print(ARN.chatPrefix() .. "AR action failed: " .. tostring(errorMessage)) end
end
