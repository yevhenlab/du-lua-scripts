-- Composes AR-target and HUD-status HTML for the adaptive screen renderer.
-- Library dependencies:
-- - SARNArDrawing from library.onStart.arDrawing.lua.
-- - SARNHudDrawing from library.onStart.hudDrawing.lua.
-- - SARNConstructCatalog from library.onStart.constructCatalog.lua.
SARNRenderer = SARNRenderer or {}

function SARNRenderer.getHtml()
    -- Construct AR drawing is intentionally disabled while radar discovery is profiled.
    return SARNHudDrawing.drawCatalogStatus(SARNConstructCatalog.getStatistics())
end
