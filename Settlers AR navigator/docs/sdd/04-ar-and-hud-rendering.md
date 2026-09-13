# 4. AR and HUD Rendering

## AR rendering

SARN renders known catalog places only when their normalized world coordinate projects inside the supported screen area. When an icon definition exists, its inline SVG replaces the dot; otherwise SARN uses the dot as a fallback. Labels use configurable colour and black text shadow for readability. SVG icons use a multidirectional black drop shadow with one-pixel offsets and two-pixel central blur. The icon wrapper uses an explicit eight-pixel right margin to separate it from the location name in compact and detailed views; this avoids relying on unsupported flex-gap rendering.

The initial mapping uses `icon-planet` for planets, the same planet artwork without its two decorative stars as `icon-moon`, and the protected `icon-sanctuary-moon` for Sanctuary and Haven.

The configured location label includes its size and distance. Owner information and the optional catalog `label` appear on later lines. Different location kinds may use different compact-to-average detail sets.

The HUD identifies the deepest current catalog area. That current area is contextual information and is not drawn as an AR marker while the player remains inside it.

Pointing at a compact AR icon and label expands it at the same projected world anchor into a semi-opaque rectangular details view. The expanded view and original label form one hover region: it remains expanded while the pointer is anywhere inside the rectangle and returns to the compact icon and label when the pointer leaves. The first practical version shows location details only; parent and child navigation controls are added after this hover behavior is verified in game.

While the cursor highlights a compact label, `leftmouse` opens its detailed view immediately. This selection remains available while another detailed view is open, allowing a direct click-to-switch without waiting for the previous view's close delay. The short hover delay remains as a non-click fallback.

The compact and detailed headers share the same visual identity: a vertically centred location SVG on the left, the location name and distance on the first line, and its secondary label on the second line. The detailed view keeps its action buttons overlaid at the right and retains all other parent, metadata, and children content below the shared header. A child row that itself has direct children appends their count, for example `Markets (10 descendants)`. The detailed child list displays satellites first and preserves the catalog order among all other entries.

The detailed view has a five-pixel left alignment correction so its icon and location name remain at the compact label's screen coordinates when the view expands.

## Overlap order

Before AR HTML is emitted, selected objects are sorted from farthest to nearest by player distance. The renderer emits distant objects first and close objects last, so standard HTML paint order keeps the closer marker and label on top where objects overlap.

An expanded details view is removed from that ordinary distance-based paint order and emitted in a final foreground pass. It also uses an explicit foreground stacking level, so no compact AR label can cover the active view.

Compact labels receive non-overlapping screen-space slots near their true projected coordinates. The nearest locations choose first, while more distant labels move to the next free position. A small dot remains at the exact projected coordinate. A translucent diagonal leader connects the dot to the nearer lower corner of a horizontal line beneath the complete compact label. Hover detection uses the separated label rectangle, preventing several overlapping labels from competing for the same cursor position.

When navigation changes the details view to a location outside the central `0.35`–`0.65` screen region, the foreground view draws a translucent guide from its nearest border toward that location. Repeated chevrons show direction, and a fully visible endpoint dot identifies the location by name and distance. An on-screen target uses its projected position; an off-screen or rearward target is placed on the global `0.05`–`0.95` safe-screen edge using the camera orientation.

Three thick marker-coloured rings continuously pulse around the guide endpoint. Over 3.6 seconds, each 4.5-pixel ring begins at the five-pixel dot radius with 75% opacity, expands to a 70-pixel radius, and fades to zero. Their phase comes from the global Ark time, so changing the detailed-view location does not restart the animation.

## Distance scaling

When multiple visible objects share the same location kind and hierarchy level, their AR markers and text scale with player distance: farther objects are smaller and closer objects are larger. This reinforces depth and reduces label overlap without making a distant high-level area appear less important than a nearby lower-level area.

The scale curve and its minimum/maximum readable sizes require in-game visual tuning.

## Hierarchical colour

The default AR-object colour is very light gray (`232,238,240`). An explicit location `color` always wins. Without an explicit colour, a root uses the default and a child inherits its parent colour blended 15% toward the default. Repeating this at each depth makes descendants progressively paler. The initial catalog assigns a distinct editable colour to every planet and leaves moon colours unset so they inherit automatically.

For example, cyan planet markers use cyan, their moons use a slightly paler cyan, and deeper locations use progressively paler versions. The amount of blending per depth and its maximum limit require in-game tuning. Selection and hover highlighting override this inherited display colour.

When a location is shared by geographical and virtual collections, its geographical branch supplies its canonical inherited colour; virtual collections do not recolour it.

## Hierarchical visibility

AR favours the relevant hierarchy level rather than rendering the full location tree. A visible parent suppresses its descendants by default; as the player approaches, the child locations can replace or augment the parent. The switching calculation must be tuned practically using distance, hierarchy depth, and the size or boundary of both parent and child areas.

The context node is the deepest location whose `areaRadius` contains the player. When several containing nodes have equal depth, the node with the nearest centre wins. A node without a valid positive radius cannot become context.

The context node is visible. Its direct parent is visible unless the context node is a planet or system: a satellite therefore shows its planet parent, while a planet does not automatically show its system and a system does not automatically show Known Space. Known Space and system nodes have no baseline visibility. Only direct planet children of a system participate in the `showSystemPlanets` baseline; satellites never inherit global system visibility. A satellite appears only through context, `showCurrentNodeChildren`, the range-limited nearby selection, or an explicit pin. These visibility groups are independent.

The rendering budget normally keeps the visible AR-object count in the 5–20 range. A player may temporarily request more objects, subject to screen culling and performance limits.

## Interaction

An AR object is intended to respond when the player points at it with the cursor. Pointed and selected objects can be highlighted. Planned actions include:

- report planet-relative or world-space coordinates in Lua chat;
- set waypoint;
- pin location;
- zoom into or reveal sub-locations;
- inspect additional location details.

The waypoint action uses `system.setWaypoint()` for the displayed node and reports `Waypoint set to "Name".` in Lua chat. DU Lua has no clipboard API, so one coordinate action reports both the planet-relative and normalized world-space positions in a single Lua chat message. Planet-relative output uses the displayed node or its nearest planet/moon ancestor from the SARN catalog before attempting an atlas-based closest-body fallback. A missing body identity is shown as `planet: unavailable (unknown body ID)` while the same message still provides the world coordinate.

The details view reserves two icon-only action groups. Three 26-pixel square node-context actions sit at the right of the current-location title: Set waypoint, Pin location, and Show coordinates. The combined coordinate action uses DU's `icon_position_to_point`. Five equally sized 26-pixel children-context actions sit at the right of the Children heading; the first is Pin children and the remaining four are unassigned mocks. Icons come from DU's SVG assets. The groups are positioned as overlays, so their larger controls do not change either row's height or move surrounding text. Idle button backgrounds and borders are transparent. SARN calculates each button's screen rectangle and highlights its border and background from the fixed aiming cursor; it does not use CSS hover. A highlighted button displays a floating title above it, and `leftmouse` activates the selected action. An action that needs coordinates is gray and partially transparent when the node has none; it does not highlight or react to clicks.

SARN derives travel progress from `player.getWorldPosition()` and the player's world or absolute velocity, without requiring a linked Core Unit. A selected or pinned destination can show closing speed and estimated arrival time. ETA is shown only while the player is moving toward the location at a meaningful closing speed; otherwise the view reports that the player is stationary or moving away.

Pinning keeps a chosen location represented in AR independently of normal hierarchy selection. A pinned location uses the normal compact-label presentation with a pin icon placed to the right of its text. Its location SVG and pin icon are vertically centred against the complete label. Pin state initially lives in Lua session memory.

The node-context action group assigns actions for Set waypoint and Pin location. Set waypoint affects only the displayed node because DU supports one active waypoint; it is not a children-context action. A future control on an individual child-list row may set that child as the active waypoint. Pin location toggles the displayed node's persistent AR representation, and a future control on each child row may pin that individual child.

The children-context action group is hidden when the displayed node has no children. Otherwise, it assigns Pin children, which pins every direct child for AR visibility without recursively pinning all deeper descendants. If both the node and its children are pinned, SARN represents the state as `place + children`.

The main HUD panel contains a `PINNED LOCATIONS` section below the marker summary. Each entry names the node and identifies its mode as `place`, `children`, or `place + children`. It shows up to five entries followed by `+ N more`, preventing pins from making the HUD excessively tall. Section boundaries use a one-pixel dark line followed immediately by a one-pixel bright inner line, producing a shallow beveled edge. The SARN Pins menu expands each active mode into its own checked row using `ParentName > Name`; root locations use only their own name, and a children pin appends `children`. Its submenu is wider than the primary menu and grows from a 240-unit base width according to the longest label, up to 360 units, while reserving space for the checkbox. Clicking anywhere on a checked row immediately removes that pin mode. If pins remain, `Remove all pins` is the final action; if no pins exist, the menu instead shows a disabled `No pinned locations` row. Submenus have no Back item because their parent menu remains visible and clickable. Pin state persists through the optional linked Databank.

The first practical interaction test uses the fixed screen-centre aiming cursor as its pointer. `system.getMousePosX()` and `system.getMousePosY()` report separate flight/free-look input in this control mode and therefore must not control hover. When the screen centre enters a compact marker's padded screen rectangle, the marker receives a visible border. Remaining there for 0.5 seconds replaces it with a semi-opaque details rectangle at the same projected position. The details view has a fixed 280-pixel border-box width, and its tracked hit rectangle matches its visible dimensions. It remains open for the configurable `detailsViewCloseDelaySeconds`, initially two seconds, after the pointer leaves. During that interval, its background, border opacity, border thickness, and border glow fade to 30% of their original strength; its icon and text remain fully visible. The view uses the same marker-coloured border glow as the highlighted compact label. SARN does not rely on CSS `:hover`, because DU HUD HTML does not expose normal browser pointer events reliably and `system.setScreen()` replaces the rendered document during refreshes.

When the displayed location has a parent, a 24-pixel parent navigation row and a five-pixel gap appear above the current-location title. The card also compensates for the title's internal vertical alignment by another eight pixels, leaving the current location icon and name at the compact label's original vertical position. SARN stores this complete top offset when the card opens. Pointing the screen-centre cursor at the parent row highlights it. A `leftmouse` action replaces the card content with the parent location while preserving the original AR object's world-coordinate anchor and stored card corner. Navigation changes card content, not its anchor or layout origin; therefore moving to a root parent without its own parent row does not shift the card downward or force the cursor outside it.

The card reports the displayed location's number of direct children. When children exist, a four-pixel gap separates the heading from a fixed five-row, 120-pixel list below the location details. Pointing at a populated row highlights it, and `leftmouse` replaces the card content with that child while preserving the card's original AR anchor and stored corner. A one-second navigation bridge temporarily treats the previous card rectangle as active when the replacement card becomes shorter, giving the player time to move the pointer into the new content. Lists with more than five children show their visible range and a mouse-wheel indicator. Wheel input is captured on frame updates and changes the list offset only while the screen-centre cursor is inside the children-list rectangle. Scroll offsets are retained separately for each displayed location.

## Look-down controller

SARN provides a controller only after the player presses Alt+5 (`option5`). Its six-corner SARN toggle opens and closes the menu while retaining the shortcut-created world-space anchor. While the menu is open, normal location markers and detailed AR views are suppressed so they do not compete with its controls.

Alt+5 reveals or repositions the controller horizontally at screen centre and vertically 30% above the screen bottom. The shortcut creates a world-space anchor along the corresponding camera ray at a 1,000-kilometre distance. It also reveals a starter previously suppressed with Hide. Camera pitch and look-down state do not reveal, hide, reposition, or otherwise control the SARN UI.

A trapezoidal Hide control forms the symmetrical lower part of the controller. It shares the SARN button's width and aligned sloping edges, with its downward arrow centred below the Hide text. Both silhouettes use inline SVG polygons because DU HUD rendering does not reliably apply CSS polygon clipping. Hiding suppresses the complete starter until Alt+5 is pressed again. Menus, submenus, and controls never extend below this edge. An open menu is not clamped to a screen edge; if camera movement takes its fixed world anchor outside the screen, the menu remains open but is not rendered until that anchor is visible again or Alt+5 repositions it.

The complete SARN controller tree is rendered at native 150% dimensions, including starter shapes, menus, submenus, controls, typography, spacing, borders, and hitboxes. It does not use a CSS scale transform, so SVG shapes, borders, and text render directly at their final size, while interaction uses the same screen coordinates. The prototype main menu vertically stacks Locations, Pins, Settings, and Save to databank directly against the flat top of the SARN starter. Save to databank is a global action below Settings because it persists multiple kinds of SARN data, including supported settings and pins. Its width equals the distance between the starter's two upper corners. Its equally sized vertical submenus open toward the right, overlap their parent menu by 30% of the submenu width, and begin 25% of one button height above the parent menu's top. They remain above the Hide baseline. A submenu hitbox has priority in the overlap, suppressing both highlighting and activation of the parent item underneath it. They demonstrate manual centre-cursor highlighting and click navigation.

Each top-level menu button has a related embedded SVG icon: a system-map symbol for Locations, a pin for Pins, a gear for Settings, and a save symbol for Save to databank. Main-menu content is left-aligned. Its fixed-size icon column remains vertically centred while labels may wrap onto multiple lines, including the two-line Save to databank label.

The Locations view exposes four independent, immediately applied checkbox groups: `Planets`, `Satellites`, `Area places`, and `Nearby`. The same synchronized controls appear in a borderless quick strip above the closed SARN starter, with icons, vertical separators, hover feedback, and a half-transparent enabled background. The strip is hidden while the full menu is open. `Planets` shows the active star system's direct planet children. `Satellites` shows the direct satellite children of the planet whose surface is closest to the player. `Area places` selects the nearest coordinate-bearing, non-celestial direct children of the current node. `Nearby` selects non-celestial children within the active range and traverses coordinate-less organizational groups. A positive Control Unit atmosphere density selects `nearbyAtmoRangeKm`, default 5 km, while zero density selects `nearbySpaceRangeKm`, default 50 km. Both ranges are adjusted in the Locations menu, in one-kilometre and ten-kilometre steps respectively. Area places and Nearby are each independently limited by `maximumNearbyPlaces`. All Locations values are persisted by Save to Databank and restored at startup when present.

The Settings view exposes `detailsViewCloseDelaySeconds`, `adaptArRedrawFrequencyToFps`, `maximumArRedrawPercentOfFps`, and `maximumNearbyPlaces`. The nearby limit defaults to 10 and changes one place at a time from 1 to 100. Its width is calculated from the longest setting label plus the space required by that row's checkbox or numeric controls, within defined minimum and maximum widths. The performance adaptation value uses a complete clickable checkbox row. The details delay changes in 0.5-second steps from 0.1 to 10 seconds, and the redraw percentage changes in five-point steps from 1% to 100%, using paired triangular controls. The complete settings panel shifts upward as needed so its bottom never extends below the Hide control. Changes apply to the current session; redraw-policy changes rebuild the performance scheduler during the action.

Save to Databank writes every Locations and Settings menu value under `sarn:settings:v1`, and writes stable hierarchical location keys plus their place/children pin modes under `sarn:pins:v1`. On startup, valid stored settings override their exported PB parameters; missing values retain their parameter defaults. Pins are restored after the location catalog has initialized. Saving displays a horizontally centred result message above the main menu. If no Databank is linked, it reports the requirement in Lua chat and in that temporary AR message.

## HUD

The HUD identifies SARN with its version from the top-left corner at matching 18-pixel X and Y offsets, shows the current area on its second line, and then reports `Visible markers: X / Y`, where `X` is the number rendered inside the screen culling area and `Y` is the de-duplicated set currently eligible for AR drawing before projection and culling. While the SARN menu is open and suppressing location rendering, this count is replaced by `AR markers hidden — ` followed by a bold red `SARN menu open` warning. Its panel background uses 50% opacity. A shadow-free, 35%-opaque `novean_logo` fallback watermark is drawn first behind the content at 125% of the panel dimensions, centred horizontally and aligned to the panel top. The oversized watermark is clipped to the panel. Current-area context uses the compact hierarchy format `Parent › Current`; root nodes show only their own name and an unmatched position reports `Deep space`. The Reference Axes visualization and its orientation calculations are no longer part of SARN. Player Planet/Parent diagnostics and construct-size totals are not shown.

## Separation of responsibilities

- `arDrawing`: projects world points and creates location AR HTML.
- `controller`: draws the Alt+5 menu starter, keeps its interaction state, renders the live pin controls, and dispatches controller actions.
- `hudDrawing`: creates HUD HTML.
- `renderer`: selects catalog targets and combines their AR and HUD drawing.
- `locationCatalog`: loads the initial high-level location list and will become the graph loader.
- shared helpers: coordinate conversion, safe API calls, formatting, and diagnostics.
