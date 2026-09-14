-- Defines SARN's exported visual distances, colours, and target dimensions.
-- Library dependencies: none.
markerColor = "232,238,240" --export
highlightMarkerColor = "255,230,40" --export
detailsViewCloseDelaySeconds = 2 --export
showSystemPlanets = true --export
showSatellites = false --export
showCurrentAreaPlaces = true --export
showNearbyAreas = false --export
showNearbyAreaPlaces = false --export
nearbyAtmoRangeKm = 5 --export -- nearby-place range while the PB is in atmosphere
nearbySpaceRangeKm = 50 --export -- nearby-place range while the PB is in space
maximumNearbyPlaces = 10 --export
showSarnHudPanel = true --export
showVisibleMarkersHudPanel = true --export
showPinnedLocationsHudPanel = true --export
showOffscreenMarkersInHud = true --export
hudFontSize = 13 --export
showAreaEntryNotifications = true --export
showAreaExitNotifications = true --export
allowGroupsAsCurrentArea = false --export
adaptArRedrawFrequencyToFps = true --export -- adapt AR redraw frequency to FPS
maximumArRedrawPercentOfFps = 100 --export -- cap AR redraw rate to 1-100% of FPS

SARNConfiguration = {
    markerColor = markerColor,
    highlightMarkerColor = highlightMarkerColor,
    detailsViewCloseDelaySeconds = math.max(0.1, tonumber(detailsViewCloseDelaySeconds) or 2),
    showSystemPlanets = showSystemPlanets ~= false,
    showSatellites = showSatellites == true,
    showCurrentAreaPlaces = showCurrentAreaPlaces ~= false,
    showNearbyAreas = showNearbyAreas == true,
    showNearbyAreaPlaces = showNearbyAreaPlaces == true,
    nearbyAtmoRangeKm = math.max(1, tonumber(nearbyAtmoRangeKm) or 5),
    nearbySpaceRangeKm = math.max(1, tonumber(nearbySpaceRangeKm) or 50),
    maximumNearbyPlaces = math.max(1, math.floor(tonumber(maximumNearbyPlaces) or 10)),
    showSarnHudPanel = showSarnHudPanel ~= false,
    showVisibleMarkersHudPanel = showVisibleMarkersHudPanel ~= false,
    showPinnedLocationsHudPanel = showPinnedLocationsHudPanel ~= false,
    showOffscreenMarkersInHud = showOffscreenMarkersInHud ~= false,
    hudFontSize = math.max(9, math.min(24, math.floor(tonumber(hudFontSize) or 13))),
    showAreaEntryNotifications = showAreaEntryNotifications ~= false,
    showAreaExitNotifications = showAreaExitNotifications ~= false,
    allowGroupsAsCurrentArea = allowGroupsAsCurrentArea == true,
    adaptArRedrawFrequencyToFps = adaptArRedrawFrequencyToFps ~= false,
    maximumArRedrawPercentOfFps = math.max(1,
        math.min(100, tonumber(maximumArRedrawPercentOfFps) or 100)),
    childColorPaleFactor = 0.15
}
