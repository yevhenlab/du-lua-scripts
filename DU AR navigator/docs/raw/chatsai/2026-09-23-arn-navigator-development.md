# ARN navigator development chat archive

Date: 2026-09-23  
Scope: the AR Navigator work discussed before this archive was requested.

## Purpose and naming

- The project began as Settlers AR Navigator (SARN) and was then generalized into ARN so it can serve any Dual Universe server.
- Runtime branding remains configurable in one place: the current defaults use `SARN` and the `Settlers` HUD prefix, while the installed Lua folder remains `arn`.
- No backward compatibility with older `sarn` identifiers is required.

## Catalog and locations

- ARN is a known-place catalog navigator; it does not discover Radar contacts.
- A location node has one semantic `type`; the old node `kind` was removed from node data and icon selection now uses `type`.
- Nodes may retain a DU `id`, literal `owner` text, coordinates, `areaRadius`, planet/satellite radius data, optional label and icon, and child nodes.
- `moon` was renamed to `satellite` throughout catalog and code.
- Standard DU locations live in `arn/locations.lua`; custom server locations are attached through `locations-registry.lua` and registered modules such as `locations-settlers.lua`.
- Registered custom modules attach their data by path/key without modifying the standard catalog. Their runtime `sourceId` is assigned from registry order: standard locations are `0`; custom modules are `1+`. Detailed-view filtering can use the source ID while showing a friendly module label or its file path when the label is absent or empty.
- An excluded node skips its whole branch before it is loaded, indexed, bounded, or rendered. Registered modules can additionally disable existing catalog branches by `id` or full path; all such disabling rules combine.
- Missing optional custom files and library dependencies must fail safely rather than prevent the PB from starting.
- Standard planet/satellite catalog data is checked against the game atlas. Atlas fallback data remains available for planetoid coordinates when the atlas is unavailable, but catalog nodes carry their own planet data.

## Parentage and grouping

- Atlas satellite relationships are authoritative even when a database export places satellites under Helios. Satellites should be nested below their planets for logical navigation.
- Coordinate-less grouping nodes are valid catalog areas. They receive calculated bounds from descendants; they are not automatically transparent.
- A group with one descendant remains transparent. A group with a calculated bounds centre/radii can show an AR marker and area ellipses, but it should not automatically expose its children.
- Nodes were grouped to make large Alioth/Haven/market/outpost lists manageable. Grouping is logical and separate from nearby visibility.

## Bounds, current area, and nearby selection

- Each node calculates `boundsCenter` and three calculated bounds radii (`boundsRadiusX/Y/Z`) recursively.
- A leaf starts from its own coordinate and `areaRadius`, when present. A parent combines child bounds plus its own coordinate and `areaRadius`.
- There is no intended singular `boundsRadius` property. `areaRadius` stays as catalog input, while current-area detection and ellipses use the calculated centre and three radii.
- A player enters an area when the player position is within the calculated bounds expanded by the configured multiplier; the final requested multiplier is `1.75`.
- Area entry does not make an AR marker visible at that distance. Current-area detection and AR visibility are separate rules.
- Nearby real visibility uses the configured range: defaults 5 km in atmosphere and 50 km in space. The game PB can read atmospheric density, and the temporary HUD density display was removed.
- `maximumNearbyPlaces` defaults to 10, is stored in the Databank, and belongs in Locations settings.
- Efficient context selection was agreed as follows: when in an area, use the current node's parent children as sibling-area candidates, preselecting centres within `visibleRange × 2 × 1.2`; then inspect only direct places of selected context areas and retain places within the real visible range; finally sort globally by player distance and limit to the maximum. This avoids recursively testing an entire catalog.
- Nearby-area markers should appear only when that area contributes at least one actual in-range direct place. Preselection alone must not show an area marker.
- Coordinate-less groups can become current only when the optional setting permits it; the later requested behaviour was to keep groups from becoming current by default and expose this as a Settings checkbox.

## AR rendering

- Markers show known places with name, size when available, owner when catalog provides it, and label when applicable.
- No icon means no substitute dot icon.
- Visible AR labels, connector lines, and ellipses are drawn in the full-screen SVG overlay, not as individual HTML HUD objects.
- Bounds are represented as a 3D ellipsoid through 2–3 projected dashed ellipses per object. Dash motion remains animated; each ellipse independently changes orientation, direction, and speed slowly and randomly.
- Ellipse drawing is suspended when projected size exceeds three quarters of the smaller screen dimension and resumes below two thirds. Ellipses follow the calculated X/Y/Z bounds and scale in projection with distance.
- Coordinate-less nodes with calculated bounds must render their own marker/ellipses from `boundsCenter`; only nodes with neither an own coordinate nor calculated centre need the fallback child behaviour.

## HUD and menus

- `Alt+5` toggles ARN on only when it is off or culled; when it is currently on and visible, the next press turns it off. The old look-down opening behavior was removed. The SARN menu shortcut changed from Alt+9 to Alt+5.
- Menu Back items were removed because the menus remain clickable.
- Main menu includes Locations, Pins, Settings, HUD, and Save to databank, each with an appropriate icon. Save is central-menu level because it persists more than Settings.
- HUD panels are separate: Settlers AR Navigator/current area, Visible Markers, and Pinned Locations. Each sizes to content, has its own coloured left divider, a background image, and settings to show/hide it. Pinned panel is hidden when there are no pins.
- Shared HUD background image has progressively been shifted upward and made more transparent. The latest committed opacity is 25%.
- HUD font size is configurable, default 14. HUD panel text shadows were increased.
- The Visible Markers panel lists active areas and places grouped by context area. Place indices use a two-character slot so names align. The old trailing parent/dot line was removed.
- Grey/off-screen filtering applies to the HUD. If an area and all its listed places are grey, hide that entire section; retain an area when at least one listed place is on screen.
- Planetoids have their own section below a separator. Satellites are shown as sub-items of their planets. Off-screen-marker preference also affects whether planetoids appear in this list.
- Area and sub-place colours distinguish the current area from nearby areas, consistently in AR and the HUD.
- The quick switcher above the central ARN control duplicates menu state. Current agreed switches are: Planets, Satellites, Places of current area, Nearby areas, and Places of nearby areas. It hides while the ARN menu is open.
- `Places of nearby areas` depends on `Nearby areas`.

## Details view and interaction

- Detailed-view child action buttons use the same size as place actions.
- Existing relevant child actions are set/view and pin. Do not add the previously rejected third action.
- Child list sorting includes satellites first, then the rest, and shows descendant counts where useful.
- Detailed view has three-state sort controls for name and distance (ascending, descending, default) plus a source filter (All, Dual Universe, registered module labels). The source filter is wired to the runtime source IDs.
- The coordinate-copy actions were combined into one position-to-point action that writes both coordinates in one chat message.
- A chat `::pos` message can be copied through the game's standard chat behavior, but no special custom copy feature is required.

## Pins and persistence

- Pins list entries use `ParentName > Name`, support unpin checkboxes and Clear all, and say none are pinned when empty.
- Databank stores pins, detail close delay, Locations/HUD/Settings values, and liby4performance values. A missing Databank displays a centred message near the main Save action.
- Pins have a persisted distance limit. Default is unlimited (`∞`), then 1–5 km, 10/15/20/30/50/100/150 km, 1–5 su, 10/15/20/30/50/100/150/200/300/500 su, then unlimited again.
- The pin range only controls extra visibility granted by being pinned. Ordinary visibility can still render a node.
- A pin row is bright only when its represented AR object is actually on screen; otherwise it is greyed, including nodes hidden by the pin range. Parent/children pin rows are bright when an applicable direct child is on screen.

## Area notifications

- Area-entry and area-exit HUD notifications each have their own HUD checkbox.
- Entry label text is two lines: `Parent > Node` only, never the full path.
- Animation: enter from screen centre to one-third height over 0.5 s, fade in to 50% light green; remain 1.5 s; move upward and fade out over 0.5 s in dark grey. Text has a shadow.

## Defaults agreed late in the discussion

- AR redraw maximum: 80%.
- Detail-view close delay: 1.5 seconds.
- Default quick visibility switches on: Planets, Places of current area, Nearby areas.
- Default quick visibility switches off: Satellites, Places of nearby areas.

## Recent completed work

- `v0.11.0`: standard missing planetoids added; custom-module branch disabling added.
- `v0.12.0`: persisted pin distance limit added.
- `v0.12.2`: pinned-HUD visibility dimming added and shared HUD background image opacity reduced to 25%.
- Mini-project-only commit for v0.12.2: `16a4146` (`Settlers AR Navigator v0.12.2`).

## Open follow-up topics

- Continue balancing and curating the place hierarchy, especially Alioth groups, as new locations arrive.
- Test the HUD visibility/context rules in-game and adjust only from observed behavior.
- Decide later whether to calculate/use more precise area geometry beyond the current ellipsoid approximation.
