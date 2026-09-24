# ARN HUD, interaction, pins, and persistence

Source: [2026-09-23 ARN development chat archive](../raw/chatsai/2026-09-23-arn-navigator-development.md).

## HUD and quick switches

- Separate content-sized panels: navigator/current area, Visible Markers, Pinned Locations.
- Pinned Locations hides when no pins exist.
- Each panel has its own coloured left divider, background image, and HUD visibility preference.
- Current shared background image opacity is 25%.
- HUD default font size is 14; panel text uses a stronger shadow.
- Quick switches, duplicated in Locations: Planets, Satellites, Places of current area, Nearby areas, Places of nearby areas. The last depends on Nearby areas.
- Defaults: Planets, Places of current area, and Nearby areas on; Satellites and Places of nearby areas off.

## AR and details

- SVG draws markers, lines, and 2–3 animated dashed ellipses per node.
- Ellipses represent the calculated three-axis bounds and suspend above 3/4 of the shorter screen dimension, resuming below 2/3.
- Child action buttons match place action size. Useful child actions are set/view and pin.
- Child lists sort satellites first and can show descendant counts. Name/distance sort controls each cycle ascending, descending, default.

## Pins and persistence

- Databank persists pins and all Locations, HUD, and Settings values.
- Pin extra-visibility distance defaults to unlimited and cycles through agreed km/su ranges.
- The pin range does not block normal non-pin visibility.
- Pinned HUD rows grey out when their marker is not actually on screen. A children row remains bright when an applicable direct child is on screen.

## Notifications

- Entry and exit notifications are independently configurable in HUD.
- Show `Parent > Node` on its own line, not full hierarchy.
- Enter: 0.5 s move/fade in; 1.5 s dwell; 0.5 s move/fade out. Use light green entering and dark grey leaving, with text shadow.
