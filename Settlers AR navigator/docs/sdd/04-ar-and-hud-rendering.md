# 4. AR and HUD Rendering

## AR rendering

SARN renders known catalog places only when their normalized world coordinate projects inside the supported screen area. When an icon definition exists, its inline SVG replaces the dot; otherwise SARN uses the dot as a fallback. Labels use configurable colour and black text shadow for readability. SVG icons use a multidirectional black drop shadow with one-pixel offsets and two-pixel central blur. The icon wrapper uses an explicit eight-pixel right margin to separate it from the location name in compact and detailed views; this avoids relying on unsupported flex-gap rendering.

The initial mapping uses `icon-planet` for planets, the same planet artwork without its two decorative stars as `icon-moon`, and the protected `icon-sanctuary-moon` for Sanctuary and Haven.

The configured location label includes its size and distance. Owner information and the optional catalog `label` appear on later lines. Different location kinds may use different compact-to-average detail sets.

The HUD identifies the deepest current catalog area. That current area is contextual information and is not drawn as an AR marker while the player remains inside it.

Pointing at a compact AR icon and label expands it at the same projected world anchor into a semi-opaque rectangular details view. The expanded view and original label form one hover region: it remains expanded while the pointer is anywhere inside the rectangle and returns to the compact icon and label when the pointer leaves. The first practical version shows location details only; parent and child navigation controls are added after this hover behavior is verified in game.

While the cursor highlights a compact label, `leftmouse` opens its detailed view immediately. This selection remains available while another detailed view is open, allowing a direct click-to-switch without waiting for the previous view's close delay. The short hover delay remains as a non-click fallback.

The compact and detailed headers share the same visual identity: a vertically centred location SVG on the left, the location name and distance on the first line, and its secondary label on the second line. The detailed view keeps its action buttons overlaid at the right and retains all other parent, metadata, and children content below the shared header.

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

The rendering budget normally keeps the visible AR-object count in the 5–20 range. A player may temporarily request more objects, subject to screen culling and performance limits.

## Interaction

An AR object is intended to respond when the player points at it with the cursor. Pointed and selected objects can be highlighted. Planned actions include:

- report planet-relative or world-space coordinates in Lua chat;
- set waypoint;
- pin location;
- zoom into or reveal sub-locations;
- inspect additional location details.

The waypoint action uses `system.setWaypoint()` for the displayed node and reports `Waypoint set to "Name".` in Lua chat. DU Lua has no clipboard API, so two coordinate actions instead report planet-relative and normalized world-space positions in Lua chat. Planet-relative output uses the displayed node or its nearest planet/moon ancestor from the SARN catalog before attempting an atlas-based closest-body fallback. A missing body identity is reported as `[SARN] "Name": unknown body ID; use world coordinates.`

The details view reserves two icon-only action groups. Four 26-pixel square node-context actions sit at the right of the current-location title: Set waypoint, Pin location, Show planet coordinate, and Show space coordinate. Five 24-pixel children-context actions sit at the right of the Children heading; the first is Pin children and the remaining four are unassigned mocks. Icons come from DU's SVG assets. The groups are positioned as overlays, so their larger controls do not change either row's height or move surrounding text. Idle button backgrounds and borders are transparent. SARN calculates each button's screen rectangle and highlights its border and background from the fixed aiming cursor; it does not use CSS hover. A highlighted button displays a floating title above it, and `leftmouse` activates the selected action. An action that needs coordinates is gray and partially transparent when the node has none; it does not highlight or react to clicks.

SARN derives travel progress from `player.getWorldPosition()` and the player's world or absolute velocity, without requiring a linked Core Unit. A selected or pinned destination can show closing speed and estimated arrival time. ETA is shown only while the player is moving toward the location at a meaningful closing speed; otherwise the view reports that the player is stationary or moving away.

Pinning keeps a chosen location represented in AR independently of normal hierarchy selection. A pinned location uses the normal compact-label presentation with a pin icon placed to the right of its text. Its location SVG and pin icon are vertically centred against the complete label. Pin state initially lives in Lua session memory.

The node-context action group assigns actions for Set waypoint and Pin location. Set waypoint affects only the displayed node because DU supports one active waypoint; it is not a children-context action. A future control on an individual child-list row may set that child as the active waypoint. Pin location toggles the displayed node's persistent AR representation, and a future control on each child row may pin that individual child.

The children-context action group is hidden when the displayed node has no children. Otherwise, it assigns Pin children, which pins every direct child for AR visibility without recursively pinning all deeper descendants. If both the node and its children are pinned, SARN represents the state as `place + children`.

The HUD contains a normal-font pinned-locations panel similar in structure to the temporary diagnostic panel. Each entry names the node and identifies its mode as `place`, `children`, or `place + children`. Persistence across Programming Board restarts remains a separate decision.

The first practical interaction test uses the fixed screen-centre aiming cursor as its pointer. `system.getMousePosX()` and `system.getMousePosY()` report separate flight/free-look input in this control mode and therefore must not control hover. When the screen centre enters a compact marker's padded screen rectangle, the marker receives a visible border. Remaining there for 0.5 seconds replaces it with a semi-opaque details rectangle at the same projected position. The details view has a fixed 280-pixel border-box width, and its tracked hit rectangle matches its visible dimensions. It remains open for the configurable `detailsViewCloseDelaySeconds`, initially two seconds, after the pointer leaves. During that interval, its background, border opacity, border thickness, and border glow fade to 30% of their original strength; its icon and text remain fully visible. The view uses the same marker-coloured border glow as the highlighted compact label. SARN does not rely on CSS `:hover`, because DU HUD HTML does not expose normal browser pointer events reliably and `system.setScreen()` replaces the rendered document during refreshes.

When the displayed location has a parent, a 24-pixel parent navigation row and a five-pixel gap appear above the current-location title. The card also compensates for the title's internal vertical alignment by another eight pixels, leaving the current location icon and name at the compact label's original vertical position. SARN stores this complete top offset when the card opens. Pointing the screen-centre cursor at the parent row highlights it. A `leftmouse` action replaces the card content with the parent location while preserving the original AR object's world-coordinate anchor and stored card corner. Navigation changes card content, not its anchor or layout origin; therefore moving to a root parent without its own parent row does not shift the card downward or force the cursor outside it.

The card reports the displayed location's number of direct children. When children exist, a four-pixel gap separates the heading from a fixed five-row, 120-pixel list below the location details. Pointing at a populated row highlights it, and `leftmouse` replaces the card content with that child while preserving the card's original AR anchor and stored corner. A one-second navigation bridge temporarily treats the previous card rectangle as active when the replacement card becomes shorter, giving the player time to move the pointer into the new content. Lists with more than five children show their visible range and a mouse-wheel indicator. Wheel input is captured on frame updates and changes the list offset only while the screen-centre cursor is inside the children-list rectangle. Scroll offsets are retained separately for each displayed location.

During interaction diagnosis, the HUD retains the last 20 view and scroll samples. View samples report the screen-centre pointer, visible card rectangle, inside/outside state, and elapsed outside time. List samples report the displayed location, visible child range, highlighted child, raw wheel direction, and resulting scroll offset. This diagnostic panel is temporary and must be removed after the view and scrolling behaviour are confirmed.

## Look-down controller

SARN provides a controller only while the player looks down by about 55 degrees or more. Before deployment, its world position follows the player's yaw at a fixed 65-degree downward direction; vertical camera movement therefore moves the aiming cursor between its six-corner SARN toggle and trapezoidal Hide control. Opening captures that nearby world-space anchor, so the deployed controls remain attached to the game world. Closing returns the starter to directional-following mode. While the menu is open, normal location markers and detailed AR views are suppressed so they do not compete with its controls.

A trapezoidal Hide control forms the symmetrical lower part of the controller. It shares the SARN button's width and aligned sloping edges, with its downward arrow centred below the Hide text. Both silhouettes use inline SVG polygons because DU HUD rendering does not reliably apply CSS polygon clipping. Hiding suppresses the complete starter until the player looks above roughly 35 degrees and then looks down again. Menus, submenus, and controls never extend below this edge. An open menu is not clamped to a screen edge: raising the view above roughly 40 degrees downward makes it leave the screen while preserving its open submenu state. While invisible it follows the player's horizontal direction; looking down past roughly 55 degrees captures that new direction and reveals the still-open menu again.

The prototype main menu vertically stacks Locations, Pins, and Settings directly against the flat top of the SARN starter. Its width equals the distance between the starter's two upper corners. Its equally sized vertical submenus open toward the right, overlap their parent menu by 30% of the submenu width, and begin 25% of one button height above the parent menu's top. They remain above the Hide baseline. A submenu hitbox has priority in the overlap, suppressing both highlighting and activation of the parent item underneath it. They demonstrate manual centre-cursor highlighting and click navigation.

The Settings view exposes `detailsViewCloseDelaySeconds`, `showSystemPlanets`, `adaptArRedrawFrequencyToFps`, and `maximumArRedrawPercentOfFps`. Boolean values use checkboxes, and their complete setting row is clickable. The details delay changes in 0.5-second steps from 0.1 to 10 seconds, and the redraw percentage changes in five-point steps from 1% to 100%, using paired triangular controls. The complete settings panel shifts upward as needed so its bottom never extends below the Hide control. Changes apply to the current session; redraw-policy changes rebuild only the performance scheduler.

Save to Databank writes all four settings under `sarn:settings:v1`. On startup, valid stored values override exported PB parameters; missing values retain their parameter defaults. If no Databank is linked, saving reports the requirement in Lua chat and in a temporary AR message attached above the settings view.

## HUD

The HUD identifies SARN with its version, reports total and currently visible known places, and shows the number of unique loaded places at each graph depth. Root locations are depth 1. A location reachable through multiple parent paths is counted once at its shallowest reachable depth. Construct-size totals are not shown.

## Separation of responsibilities

- `arDrawing`: projects world points and creates location AR HTML.
- `controller`: draws the look-down menu starter, keeps its interaction state, and dispatches controller actions.
- `hudDrawing`: creates HUD HTML.
- `renderer`: selects catalog targets and combines their AR and HUD drawing.
- `locationCatalog`: loads the initial high-level location list and will become the graph loader.
- shared helpers: coordinate conversion, safe API calls, formatting, and diagnostics.
