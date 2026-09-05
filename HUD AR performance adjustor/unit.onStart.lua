-- User-facing adaptive-rendering setting.
reduceArFrequencyOnFpsDrop = true --export -- reduce AR redraw rate after FPS drops

-- Load the panel-free adaptive renderer.
local initializeLiby4performance = require("liby.liby4performance")
hudAr = initializeLiby4performance(_G, unit, system, player, {
    reduceArFrequencyOnFpsDrop = reduceArFrequencyOnFpsDrop
})

-- Register drawing functions defined in the PB Library handler.
-- setContentRenderer sets the main overlay; addContentRenderer adds another.
hudAr.setContentRenderer(drawExampleCircle)

-- Show the custom example overlay now; this also starts the refresh timer.
hudAr.start()
