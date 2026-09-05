-- User-facing adaptive-rendering setting.
adaptArRedrawFrequencyToFps = true --export -- adapt AR redraw frequency to FPS
maximumArRedrawPercentOfFps = 100 --export -- cap AR redraw rate to 1-100% of FPS

-- Load the panel-free adaptive renderer.
local initializeLiby4performance = require("liby.liby4performance")
hudAr = initializeLiby4performance(unit, system, {
    adaptArRedrawFrequencyToFps = adaptArRedrawFrequencyToFps,
    maximumArRedrawPercentOfFps = maximumArRedrawPercentOfFps
})

-- Register drawing functions defined in the PB Library handler.
-- setContentRenderer sets the main overlay; addContentRenderer adds another.
hudAr.setContentRenderer(drawExampleCircle)

-- Show the custom example overlay now; this also starts the refresh timer.
hudAr.start()
