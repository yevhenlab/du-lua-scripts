# liby4performance PB example

This is a smaller example PB based on the HUD AR performance adjustor. It has a circle, a timer-driven counter, and HTML loaded from another installed Lua module.

## Install dependencies

Install these modules into the Dual Universe client Lua `liby` folder before using this example:

- `liby.liby4performance.withpanel`
- `liby.example-rectangle-content-html`

From the parent project, run `../install-local.ps1 -DuRoot "<your Dual Universe folder>"`. It installs both modules.

## Build and import

Run `./build-lua-configuration.ps1 -CopyToClipboard`, then paste the generated configuration into a Programming Board. The configuration needs only the built-in `unit`, `player`, `system`, and `library` slots.

`unit.onStart.lua` is the setup point: configure `panelMode`, placement, `adaptArRedrawFrequencyToFps`, and `maximumArRedrawPercentOfFps`, then register renderers. `system.onUpdate.lua` forwards game frames to the library. The two Unit timer files show the adaptive library timer and an independent custom timer.
