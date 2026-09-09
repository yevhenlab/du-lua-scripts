-- Renders only known locations loaded from the SARN Lua catalog.
-- Library dependencies: SARNLocationCatalog, SARNArDrawing, and SARNHudDrawing.
SARNRenderer = SARNRenderer or {}

function SARNRenderer.getHtml()
    local parts = {}
    local rendered = 0
    SARNArDrawing.beginFrame()
    local visibleTargets, currentTarget =
        SARNLocationCatalog.getVisibleTargets(system.getCameraWorldPos())
    for _, target in ipairs(visibleTargets) do
        local html = SARNArDrawing.drawConfiguredLocation(target)
        if html ~= "" then
            rendered = rendered + 1
            parts[#parts + 1] = html
        end
    end
    SARNArDrawing.endFrame()
    return SARNArDrawing.getStyles()
        .. SARNHudDrawing.drawCatalogStatus(
        SARNLocationCatalog.getStatistics(), rendered, currentTarget)
        .. SARNHudDrawing.drawInteractionDebug(SARNArDrawing.getDebugLines())
        .. table.concat(parts)
end
