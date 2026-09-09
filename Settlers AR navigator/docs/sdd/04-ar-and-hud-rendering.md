# 4. AR and HUD Rendering

## AR rendering

SARN renders known catalog places only when their normalized world coordinate projects inside the supported screen area. When an icon definition exists, its inline SVG replaces the dot; otherwise SARN uses the dot as a fallback. Labels use configurable colour and black text shadow for readability.

The initial mapping uses `icon-planet` for planets, the same planet artwork without its two decorative stars as `icon-moon`, and the protected `icon-sanctuary-moon` for Sanctuary and Haven.

The configured location label includes its size and distance. Owner information and the optional catalog `label` appear on later lines. Different location kinds may use different compact-to-average detail sets.

The HUD identifies the deepest current catalog area. That current area is contextual information and is not drawn as an AR marker while the player remains inside it.

Pointing at a compact AR icon and label expands it at the same projected world anchor into a semi-opaque rectangular details view. The expanded view and original label form one hover region: it remains expanded while the pointer is anywhere inside the rectangle and returns to the compact icon and label when the pointer leaves. The first practical version shows location details only; parent and child navigation controls are added after this hover behavior is verified in game.

## Overlap order

Before AR HTML is emitted, selected objects are sorted from farthest to nearest by player distance. The renderer emits distant objects first and close objects last, so standard HTML paint order keeps the closer marker and label on top where objects overlap.

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

- copy coordinates;
- set waypoint;
- zoom into or reveal sub-locations;
- inspect additional location details.

The first practical interaction test uses the fixed screen-centre aiming cursor as its pointer. `system.getMousePosX()` and `system.getMousePosY()` report separate flight/free-look input in this control mode and therefore must not control hover. When the screen centre enters a compact marker's padded screen rectangle, the marker receives a visible border. Remaining there for 0.5 seconds replaces it with a semi-opaque details rectangle at the same projected position. The details view has a fixed 280-pixel border-box width, and its tracked hit rectangle matches its visible dimensions. It remains open for a one-second grace period after the pointer leaves. During that second, only its background fades to 30% of its original opacity; the icon, text, border, and border glow remain fully opaque. The view uses the same marker-coloured border glow as the highlighted compact label. SARN does not rely on CSS `:hover`, because DU HUD HTML does not expose normal browser pointer events reliably and `system.setScreen()` replaces the rendered document during refreshes.

When the displayed location has a parent, a 24-pixel parent navigation row and a five-pixel gap appear above the current-location title. The card also compensates for the title's internal vertical alignment by another eight pixels, leaving the current location icon and name at the compact label's original vertical position. SARN stores this complete top offset when the card opens. Pointing the screen-centre cursor at the parent row highlights it. A `leftmouse` action replaces the card content with the parent location while preserving the original AR object's world-coordinate anchor and stored card corner. Navigation changes card content, not its anchor or layout origin; therefore moving to a root parent without its own parent row does not shift the card downward or force the cursor outside it.

The card reports the displayed location's number of direct children. When children exist, a fixed five-row, 120-pixel list appears below the location details. Pointing at a populated row highlights it, and `leftmouse` replaces the card content with that child while preserving the card's original AR anchor and stored corner. A one-second navigation bridge temporarily treats the previous card rectangle as active when the replacement card becomes shorter, giving the player time to move the pointer into the new content. Lists with more than five children show their visible range and a mouse-wheel indicator. Wheel input is captured on frame updates and changes the list offset only while the screen-centre cursor is inside the children-list rectangle. Scroll offsets are retained separately for each displayed location.

During interaction diagnosis, the HUD retains the last 20 view and scroll samples. View samples report the screen-centre pointer, visible card rectangle, inside/outside state, and elapsed outside time. List samples report the displayed location, visible child range, highlighted child, raw wheel direction, and resulting scroll offset. This diagnostic panel is temporary and must be removed after the view and scrolling behaviour are confirmed.

## HUD

The HUD identifies SARN with its version, reports total and currently visible known places, and shows the number of unique loaded places at each graph depth. Root locations are depth 1. A location reachable through multiple parent paths is counted once at its shallowest reachable depth. Construct-size totals are not shown.

## Separation of responsibilities

- `arDrawing`: projects world points and creates location AR HTML.
- `hudDrawing`: creates HUD HTML.
- `renderer`: selects catalog targets and combines their AR and HUD drawing.
- `locationCatalog`: loads the initial high-level location list and will become the graph loader.
- shared helpers: coordinate conversion, safe API calls, formatting, and diagnostics.
