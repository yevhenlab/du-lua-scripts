-- Defines SARN's exported visual distances, colours, and target dimensions.
-- Library dependencies: none.
markerColor = "232,238,240" --export
highlightMarkerColor = "255,230,40" --export
detailsViewCloseDelaySeconds = 2 --export
showSystemPlanets = true --export
adaptArRedrawFrequencyToFps = true --export -- adapt AR redraw frequency to FPS
maximumArRedrawPercentOfFps = 100 --export -- cap AR redraw rate to 1-100% of FPS

SARNConfiguration = {
    markerColor = markerColor,
    highlightMarkerColor = highlightMarkerColor,
    detailsViewCloseDelaySeconds = math.max(0.1, tonumber(detailsViewCloseDelaySeconds) or 2),
    showSystemPlanets = showSystemPlanets ~= false,
    adaptArRedrawFrequencyToFps = adaptArRedrawFrequencyToFps ~= false,
    maximumArRedrawPercentOfFps = math.max(1,
        math.min(100, tonumber(maximumArRedrawPercentOfFps) or 100)),
    childColorPaleFactor = 0.15
}
