-- Renders only known locations loaded from the ARN Lua catalog.
-- Library dependencies: ARNLocationCatalog, ARNArDrawing, ARNController, and ARNHudDrawing.
ARNRenderer = ARNRenderer or {}

function ARNRenderer.getHtml()
    if ARNArDrawing == nil or ARNLocationCatalog == nil
        or ARNController == nil or ARNHudDrawing == nil then
        return ""
    end
    local parts = {}
    local foregroundParts = {}
    local rendered = 0
    local markerEntries = {}
    ARNArDrawing.beginFrame()
    local cameraPosition = system.getCameraWorldPos()
    local visibleTargets, currentTarget, nearbyRanks, nearbyInfo =
        ARNLocationCatalog.getVisibleTargets(cameraPosition)
    local renderTargets = {}
    local seen = {}
    for _, target in ipairs(visibleTargets) do
        renderTargets[#renderTargets + 1] = target
        seen[target.id] = true
    end
    for _, target in ipairs(ARNLocationCatalog.getConfiguredTargets()) do
        if not seen[target.id] and ARNArDrawing.isTargetPinned(target) then
            renderTargets[#renderTargets + 1] = target
            seen[target.id] = true
        end
    end
    table.sort(renderTargets, function(first, second)
        return (ARN.distance(cameraPosition, first.displayPosition or first.worldPosition) or 0)
            > (ARN.distance(cameraPosition, second.displayPosition or second.worldPosition) or 0)
    end)
    if not ARNController.menuOpen then
        ARNArDrawing.prepareCompactLayout(renderTargets)
        for _, target in ipairs(renderTargets) do
            local html, expanded = ARNArDrawing.drawConfiguredLocation(
                target, ARNArDrawing.isTargetPinned(target))
            markerEntries[#markerEntries + 1] = {
                target = target,
                nearbyRank = nearbyRanks and nearbyRanks[target.id] or nil,
                onScreen = html ~= ""
            }

            if html ~= "" then
                rendered = rendered + 1
                local destination = expanded and foregroundParts or parts
                destination[#destination + 1] = html
            end
        end
    end
    ARNArDrawing.endFrame()
    local pinnedEntries = ARNArDrawing.getPinnedEntries()
    return ARNArDrawing.getStyles()
        .. ARNController.getStyles()
        .. ARNHudDrawing.drawCatalogStatus(rendered, currentTarget, #renderTargets, pinnedEntries, markerEntries, nearbyInfo)
        .. table.concat(parts)
        .. table.concat(foregroundParts)
        .. ARNController.draw()
end
