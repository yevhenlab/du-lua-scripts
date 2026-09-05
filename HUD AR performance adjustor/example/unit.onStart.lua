-- Library dependencies: initializeLiby4performance, drawExampleCircle, drawExampleCounter, drawExampleExternalHtml.
panelMode = "small" --export -- none, tiny, small, or detailed
panelHorizontalSide = "right" --export -- left or right
panelHorizontalOffset = 70 --export -- pixels from the horizontal side
panelVerticalSide = "top" --export -- top or bottom
panelVerticalOffset = 400 --export -- pixels from the vertical side
reduceArFrequencyOnFpsDrop = true --export -- reduce AR redraw rate after FPS drops

exampleCounter = 0
local initializeLiby4performance = require("liby.liby4performance.withpanel")
hudAr = initializeLiby4performance(_G, unit, system, player, {
    panelMode = panelMode, panelHorizontalSide = panelHorizontalSide,
    panelHorizontalOffset = panelHorizontalOffset, panelVerticalSide = panelVerticalSide,
    panelVerticalOffset = panelVerticalOffset,
    reduceArFrequencyOnFpsDrop = reduceArFrequencyOnFpsDrop
})
hudAr.setContentRenderer(drawExampleCircle)
hudAr.addContentRenderer(drawExampleCounter)
hudAr.addContentRenderer(drawExampleExternalHtml)
hudAr.start()
unit.setTimer("exampleCounter", 0.2)
