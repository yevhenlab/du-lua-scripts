-- Library dependencies: initializeLiby4performance, drawExampleCircle, drawExampleCounter, drawExampleExternalHtml.
panelMode = "small" --export -- none, tiny, small, or detailed
panelHorizontalSide = "right" --export -- left or right
panelHorizontalOffset = 70 --export -- pixels from the horizontal side
panelVerticalSide = "top" --export -- top or bottom
panelVerticalOffset = 400 --export -- pixels from the vertical side
adaptArRedrawFrequencyToFps = true --export -- adapt AR redraw frequency to FPS
maximumArRedrawPercentOfFps = 100 --export -- cap AR redraw rate to 1-100% of FPS

exampleCounter = 0
local initializeLiby4performance = require("liby/liby4performance.withpanel")
hudAr = initializeLiby4performance(unit, system, {
    panelMode = panelMode, panelHorizontalSide = panelHorizontalSide,
    panelHorizontalOffset = panelHorizontalOffset, panelVerticalSide = panelVerticalSide,
    panelVerticalOffset = panelVerticalOffset,
    adaptArRedrawFrequencyToFps = adaptArRedrawFrequencyToFps,
    maximumArRedrawPercentOfFps = maximumArRedrawPercentOfFps
})
hudAr.setContentRenderer(drawExampleCircle)
hudAr.addContentRenderer(drawExampleCounter)
hudAr.addContentRenderer(drawExampleExternalHtml)
hudAr.start()
unit.setTimer("exampleCounter", 0.2)
