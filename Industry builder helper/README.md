# Industry Builder Helper

Current first step: find the linked construct Core Unit regardless of which of
the Programming Board's 100 link slots contains it.

## Install

Run:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

Paste the generated configuration into the Programming Board, link the Core
and optionally a Databank, then start the board. The Lua chat reports the discovered slots and local
element ID, or that no Core was found. The exported
`debugElements` parameter controls these messages and is enabled by default.

After discovery, later helper code can use:

```lua
ibh.core
ibh.coreSlot
ibh.coreSlotIndex
```

Core detection checks both the element class name and the Core-specific
`getElementIdList` method.

The HUD displays compact PB uptime using one suitable unit. The exported
`version` appears right-aligned below it. A dedicated timer refreshes the
fixed-position label every 0.5 seconds.

Increase the patch version for every code change.

The HUD also keeps the five most recent added-element groups, newest first.
`ibh.recordAddedElements(elements)` adds detected elements. Nearby additions
share a group; a delay greater than the adaptive group gap starts a new group.

The exported `newElementSearchSeconds` parameter sets the detection interval
and defaults to 3 seconds. Startup records the Core's current element IDs as
the baseline. Each timer scan adds newly appearing IDs to the HUD.
Displayed elements retain their local IDs. If a later scan no longer finds an
ID on the Core, its existing HUD entry is marked `(removed)` in place.
Names are also refreshed during each scan, so renamed elements update in place.
Element identity combines local ID, construct-local position, and class. If a
reused local ID has a different position or class, the old entry stays removed
and a new HUD entry is created.
Added Industry elements appear in a second HUD column with an 84%-opaque dark
background. Each card shows the
Industry name and either `no product` or the current product's display name,
per-batch quantity, unit volume, unit mass, and recipe ingredients with amounts.
Industry and recipe data refresh with the element-search timer.
Each Industry has a subtle bordered background. Its name remains flush left,
while related product, output, and recipe data is indented by 6 px. Component
spacing belongs to the list container rather than every row, and checkboxes use
an 18 px glyph. The Industry column is 300 px wide. Output rows stay on one
line, reserve the right edge for compact capacity such as `1.5kL`, and shorten
long container names with an ellipsis.

Each recipe component has a checkbox. It becomes checked when the tracked
Industry has an IN link from a candidate container whose suspected incoming
products include that component. Component rows show the suspected produced
amount available through linked source containers against the recipe-required
amount. The Industry card also lists every container
found on its OUT plug. When an output container is directly linked to the PB,
the HUD uses its measured maximum volume; otherwise it uses a saved class
capacity when available. When maximum output volume is known, the HUD shows how many whole
product units fit and their occupied volume against maximum volume. It also
suggests a 70%-capacity Maintain target, rounded down to a whole production-batch
multiple so the Industry does not target a partial batch. This value is only a
displayed suggestion and is not applied automatically. Both capacity-detail
lines are indented beneath their output Container row.

All PB slots are checked at startup and every element-search interval. When
startup diagnostics are enabled, each directly linked Container prints Core
`getElementClassById` and its measured maximum volume on one line. Periodic slot
checks do not repeat this startup diagnostic. Direct-link identification uses
the current `getLocalId()` API.

The exported `debugPbStartInfo` checkbox defaults to `false`. It controls the
startup `DB container data:` and `Linked elements:` chat sections without
disabling Databank loading, capacity learning, or persistence.

The Databank keeps a separate persistent Container-capacity catalog under
`databankKey .. ":container-capacities"`. Each record identifies a Container
variant by `getElementClassById`, and contains its measured `maxVolume`, or `?`
when that class was seen through the Core but has never been directly measured.
Startup loads every saved class
into PB memory before checking linked slots. Directly linked Containers add new
classes or update changed volumes; records for currently unlinked Container
classes are preserved. Consequently, an Industry OUT container discovered only
through the Core can show its assumed maximum volume in the HUD when its class
was measured earlier. Unknown class markers are saved silently when discovered;
startup prints a `DB container data:` heading and one class/volume line per
record. A separate `Linked elements:` heading precedes the same compact details
for containers currently linked to the PB. Container Hubs are never stored in
the capacity catalog. Their effective volume is the sum of all linked non-hub
Container capacities; this aggregate is used when an Industry has the Hub on an
IN or OUT plug. Legacy catalog records are printed as ignored during migration.

Every tracked, present element receives one cyan dot at the position reported
by the Core. The dot remains enabled at any distance. A construct-horizontal
ellipse is shown within `arEllipseDistanceMeters` (50 m by default). Its
radius is based primarily on `core.getElementMassById`: under 50 kg is 0.3 m;
50–149 kg is 0.7 m; 150–449 kg is 1 m; 450–999 kg is 1.5 m;
1–14.999 t is 2 m; 15–99.999 t is 3 m; and 100 t or
more is 4 m. Ellipse rendering does not produce chat diagnostics.
Geometry uses only Core position and orientation; linked-element discovery,
bounding-box APIs, labels, diagnostic axis dots, and wireframe prisms are not
used.
Projected screen positions stay normalized and are rendered as percentages,
matching the original AR-label implementation without converting through the
reported pixel resolution. AR elements are attached directly to the screen
root because DU does not reliably resolve percentage positions inside an
absolutely positioned `inset` wrapper.

When a Databank is linked, tracked groups are stored under the exported
`databankKey`. Each record contains local ID, construct-local position,
display name, class, identity key data, and timestamps. Startup restores the
five saved groups and reconciles them with the Core before continuing normal
new-element detection. Databank writes are skipped when the payload is
unchanged.

A performance panel below the right-side game UI estimates FPS from the
per-frame System update event. It displays current FPS and graph scale. Rolling
60/30/15/5-second averages sit above their matching positions on the timeline.
Thirty vertical bars summarize the latest 60 seconds, with a distinct color for
each age segment, and the panel HTML refreshes once per second. The panel also
displays the measured AR redraw frequency in updates per second (`Hz`).

AR projection refresh is adaptive to camera angular speed. It idles at the
exported `arIdleRefreshSeconds` interval (0.2 seconds, or 5 redraws per
second) and smoothly approaches `arMinimumRefreshSeconds` (0.033 seconds, or
about 30 redraws per second) as the camera approaches
`arFullSpeedDegreesPerSecond` (45 degrees per second). HUD HTML remains cached
between its regular 0.5-second updates. The exported
`arMotionCurveExponent` defaults to `0.5`, making refresh frequency rise
quickly with small camera movements and flatten near the maximum rate.
Construct-relative player movement participates in the same curve and reaches
the maximum contribution at `arFullPlayerSpeedMetersPerSecond` (5 m/s by
default).

For every ingredient required by a tracked Industry product, the helper scans
configured Industry and Transfer Unit products and follows their Core OUT plug
maps to destination containers. Candidate source containers receive muted,
ingredient-colored construct-aligned wireframe boxes within 50 m. Prism
dimensions are half the earlier ellipse-based size, using a thin 40%-opaque
stroke. A container with several needed products receives slightly nested
colored boxes. A larger ingredient-colored center dot with a pale ring and the
needed-resource name on an opaque dark label remain visible at any distance.
All candidate wireframes are rendered before candidate dots and labels, keeping
the text layer unobstructed.

Within `arSourceLabelDistanceMeters` (30 m), a candidate label shows the
container name and local ID beside the dot, remaining IN and OUT capacity,
needed products first, and other configured incoming products. IN availability
is gray. OUT availability is green when `1 + OUT links + assumed resource
types` is below `maximumOutputLinks` (20 by default), red when OUT links have
reached the limit, and yellow otherwise. The first needed resource is bold.
Container AR text uses a 14 px font. Detail cards start 60% transparent at
30 m, become smoothly more opaque, and are fully opaque within 5 m. The far
product-name label disappears as soon as the detail card appears. Because Core Lua cannot read inventory directly,
all displayed resource quantities are suspected-content estimates rather than
current container inventory.

Candidate labels are rendered from farthest to nearest. Consequently, nearer
dots and detail cards are emitted last, appear above overlapping distant cards,
and also receive the stronger distance-based opacity.

Close Container labels show `plug IN` and `plug OUT` above the deduplicated
Container name, followed by the resource list. The detail block is vertically
positioned so the AR dot aligns with the Container-name row. The Container name
is rendered as a bold 17 px title above the resource list. The exported
`showArRectanglePrisms` checkbox defaults to `false` and controls whether
resource-colored AR wireframe prisms are rendered around candidate Containers.

The exported `reduceArFrequencyOnFpsDrop` checkbox defaults to `true`. Once
enough FPS history exists, the last five-second average is compared separately
with the 15-, 30-, and 60-second averages. The largest positive percentage drop
reduces the adaptive AR target frequency by the same percentage. Incomplete
comparison windows and FPS improvements do not reduce AR frequency.

Resource estimates also inspect every producer feeding the same product into a
candidate container. If any producer uses Run mode and saved container capacity
is known, the estimate is `floor(maxVolume / resourceUnitVolume)`. If every
producer uses Maintain mode, the estimate is the largest Maintain target rather
than their sum. Make X, mixed Maintain/Make X, and Run with unknown capacity
fall back to the summed current `unitsProduced` value. These estimates feed both
the AR resource label and the HUD component-availability column.

Topology discovery is processed incrementally on System update frames rather
than in the three-second element-search timer. The exported
`sourceScanBatchSize` defaults to three construct elements per frame, which
prevents large Industry layouts from exceeding the PB instruction budget in a
single execution.

When a tracked Industry is running, has a recipe, has an OUT Container, and
all recipe components have linked source Containers, a `DONE` AR button appears
0.8 m above its Core coordinate within 10 m. Aim the crosshair at the button and press the left mouse
button to remove that Industry from tracking. Its HUD card and resource-source
highlights are removed, while sources still needed by other tracked Industries
remain visible. The updated tracking list is saved to the Databank.

Each Industry card shows the current Core Industry state beside its name;
`Running` is highlighted green. Chat reports once when a tracked Industry is
observed running and once when its `DONE` button is first drawn on screen.
The button uses a raised beveled face and depth shadow. A translucent radial
wall behind it fades to clear at a projected one-metre world-space radius.
Clicking depresses the button immediately; the tracking action follows after
0.3 seconds so the pressed state remains visible briefly.
