-- Renders only known locations loaded from the SARN Lua catalog.
-- Library dependencies: SARNConstructCatalog, SARNArDrawing, and SARNHudDrawing.
SARNRenderer = SARNRenderer or {}

function SARNRenderer.getHtml()
    local parts = {}
    local rendered = 0
    for _, target in ipairs(SARNConstructCatalog.getConfiguredTargets()) do
        local html = SARNArDrawing.drawConfiguredLocation(target)
        if html ~= "" then
            rendered = rendered + 1
            parts[#parts + 1] = html
        end
    end
    return SARNHudDrawing.drawCatalogStatus(SARNConstructCatalog.getStatistics(), rendered)
        .. table.concat(parts)
end
