-- Renders only known locations loaded from the SARN Lua catalog.
-- Library dependencies: SARNLocationCatalog, SARNArDrawing, SARNController, and SARNHudDrawing.
SARNRenderer = SARNRenderer or {}

function SARNRenderer.getHtml()
    local parts = {}
    local foregroundParts = {}
    local rendered = 0
    SARNArDrawing.beginFrame()
    local visibleTargets, currentTarget =
        SARNLocationCatalog.getVisibleTargets(system.getCameraWorldPos())
    local renderTargets = {}
    local seen = {}
    for _, target in ipairs(visibleTargets) do
        renderTargets[#renderTargets + 1] = target
        seen[target.id] = true
    end
    for _, target in ipairs(SARNLocationCatalog.getConfiguredTargets()) do
        if not seen[target.id] and SARNArDrawing.isTargetPinned(target) then
            renderTargets[#renderTargets + 1] = target
            seen[target.id] = true
        end
    end
    local cameraPosition = system.getCameraWorldPos()
    table.sort(renderTargets, function(first, second)
        return (SARN.distance(cameraPosition, first.worldPosition) or 0)
            > (SARN.distance(cameraPosition, second.worldPosition) or 0)
    end)
    if not SARNController.menuOpen then
        SARNArDrawing.prepareCompactLayout(renderTargets)
        for _, target in ipairs(renderTargets) do
            local html, expanded = SARNArDrawing.drawConfiguredLocation(
                target, SARNArDrawing.isTargetPinned(target))
            if html ~= "" then
                rendered = rendered + 1
                local destination = expanded and foregroundParts or parts
                destination[#destination + 1] = html
            end
        end
    end
    SARNArDrawing.endFrame()
    local pinnedEntries = SARNArDrawing.getPinnedEntries()
    return SARNArDrawing.getStyles()
        .. SARNController.getStyles()
        .. SARNHudDrawing.drawCatalogStatus(
        SARNLocationCatalog.getStatistics(), rendered, currentTarget)
        .. SARNHudDrawing.drawInteractionDebug(SARNArDrawing.getDebugLines())
        .. SARNHudDrawing.drawPinnedLocations(pinnedEntries)
        .. table.concat(parts)
        .. table.concat(foregroundParts)
        .. SARNController.draw()
end
