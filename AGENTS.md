# Accuracy

Before making a factual claim to the user—especially a claim that something was checked, exists, changed, succeeded, or completed—verify it using available evidence. Never present an assumption, inference, incomplete check, or unverified result as fact. If certainty is unavailable, state the uncertainty clearly. Never claim to have performed a check or action that was not actually performed.

# Project organization

Keep each independent Dual Universe Lua mini-project in its own folder directly
under `Lua-scripts`.

Use a descriptive multi-word folder name for a mini-project. Treat a reusable
library as a first-class library project with its own folder, documentation,
installation instructions, and explicit public API; do not create a hidden or
project-specific dependency.

# File names and installable projects

Name event source files after their Dual Universe location and event:
`library.onStart.lua`, `unit.onStart.lua`, `unit.onTimer.<tag>.lua`,
`system.onUpdate.lua`, and `system.onActionStart.<action>.lua`. Use descriptive
names for ordinary support files.

An installable mini-project should include its source files, a
`build-lua-configuration.ps1` builder, a committed `*.generated.json`
configuration, and a README. The README must state the purpose, required
links, installation steps, exported settings, dependencies, and runtime
behavior.

# Architecture and names

Keep event-specific orchestration and project logic in Unit and System layers.
Use Library layers for focused shared operations, repeated actions, parsing,
data transformations, storage formats, and rendering helpers. Keep a
reasonable balance: do not move all project logic into a library, and do not
duplicate a reusable operation across event handlers.

# Built-in Control Unit slots and event filters

Treat a slot's filters as independent event handlers, not as a guaranteed
execution sequence. Do not rely on an ordering between filters from different
slots; make handlers safe if related events arrive in either order.

- `library`: shared project code and reusable helpers. Put no gameplay-event
  orchestration here unless the configured library filter explicitly requires
  it.
- `unit`: the Control Unit's own lifecycle and timers. Use `onStart` for
  initialization, `onStop` for shutdown, and `onTimer.<tag>` for named timers.
- `system`: the active player's client/system interaction with the unit.
  `onActionStart`, `onActionStop`, and `onActionLoop` handle bound actions;
  `onUpdate` is the regular update callback; `onInputText` receives text;
  `onCameraChanged` reacts to camera changes; `onFlush` is a runtime flush
  callback. `onStart` and `onStop` provide its lifecycle hooks.
- `construct`: the construct containing the Control Unit. `onDocked` and
  `onUndocked` react when this construct docks or undocks; `onPlayerBoarded`
  and `onVRStationEntered` identify entering players; `onConstructDocked`
  reacts when another construct docks to this one; `onPvPTimer` reacts when
  its PvP timer changes. It also has `onStart` and `onStop` lifecycle hooks.
- `player`: the current player's avatar context. `onParentChanged` handles a
  change of parent construct; it also has `onStart` and `onStop` lifecycle
  hooks.

Use the slot that owns the event for event-specific orchestration. Put
generic, reusable operations in `library`; do not use `system.onUpdate` for
work that can be event-driven or timer-driven.

Program helpers belong in `library`, not `system`. Use `system` only for
player/client event handling. A System handler that needs a helper should call
a Library helper.

At the beginning of every `library.onStart` source file, add a comment that
states its Library dependencies, including `none` when it has none. At the
beginning of every `unit.onStart` source file, add a comment listing the
Library functions or namespaces it depends on. Keep these comments current
when dependencies change.

Give project and library namespaces descriptive CamelCase names that explain
their responsibility. Do not derive opaque two- or three-letter acronyms from
project titles merely to shorten names.

# Exported settings

Export only settings that a normal user may reasonably need to adjust for
installation, physical layout, gameplay behavior, or an intentional feature
choice. Keep implementation constants, internal limits, serialization formats,
and visual fine-tuning private unless users have a clear reason to change them.
Avoid overwhelming users with exported parameters. Keep diagnostics disabled by
default and expose them only when they are useful for setup or troubleshooting.

# API errors and capability probing

Validate required linked elements and required APIs during startup. A missing
method on a known required element is a defect or setup error: report it
clearly and fix the code or configuration; do not hide it with `pcall`.

Use `pcall` only for a narrow, recoverable capability probe on an unknown
element when that probe is genuinely needed to determine what the element is.
Do not wrap routine calls to known Dual Universe APIs in generic `getMethod()`
or `call()` helpers.

# Dual Universe reference data

Before writing or changing Dual Universe Lua that calls an Element API, consult
`du lua info/f1-lua-element-api-index.json`. Treat it as the primary local
reference for the recovered in-game F1 documentation: verify the element type,
method/event name, parameters, and deprecation status before using an API.
State uncertainty when the needed API is absent or ambiguous rather than
inventing a method.

For HUD, AR, or other interface-visual requests where a suitable raster image
is unavailable or cannot be embedded, search `du lua info/svg-index.json`
before proposing a new visual. Use its `key`, `tags`, `usageTags`,
`visualMotifs`, and `recommendedContexts` to locate relevant Dual Universe SVG
assets, then inspect the selected standalone file under `du lua info/svg/`.
The visual metadata is editorial search assistance, not an official guarantee
of an asset's meaning or of runtime compatibility.

# Dual Universe Lua deprecations

Do not use deprecated Dual Universe Lua methods in new or modified code.

- Use `getLocalId()` instead of deprecated `getId()`.
- Use `getState()` instead of deprecated `getStatus()`.

When working with existing helpers or libraries, search their implementation for deprecated calls instead of checking only the newly created filter files.

# Lua formatting

Prefer compact one-line Lua statements when they remain understandable. Do not
split calls, concatenations, conditions, assignments, or tables across multiple
lines merely because they contain several parts. Split lines only when the
expression is genuinely long or complex, or when a local value is reused or
meaningfully clarifies the surrounding logic.
