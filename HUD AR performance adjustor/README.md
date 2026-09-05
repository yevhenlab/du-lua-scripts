# HUD, AR performance adjustor

`liby4performance` measures client FPS and motion, then adapts the redraw rate
of HUD/AR content returned by its registered renderers. It does not draw a
performance panel itself.

## Install and import

Install the library into the DU client Lua folder:

```powershell
./install-local.ps1 -DuRoot '<DU installation>'
```

Then run `./build-lua-configuration.ps1 -CopyToClipboard` and import the JSON.
The PB needs only the built-in `unit`, `system`, and `player` links.

The only exported setting chooses whether FPS drops reduce the adaptive redraw
rate.

## First renderer

The main PB contains only the first circle renderer in
`library.onStart.drawings.lua`. Add your own functions there, then register
them in `unit.onStart.lua` with `hudAr.setContentRenderer(...)` or
`hudAr.addContentRenderer(...)`.

`system.onUpdate.lua` forwards frame updates for measurement and adaptive
redraw scheduling. `unit.onTimer.hudArClock.lua` forwards the library timer.

## Full example

See [example](example/README.md) for the separate, larger PB example with a
counter, external HTML module, independent timer, and performance panel. It
uses `liby.liby4performance.withpanel`, which is the preserved panel version.
