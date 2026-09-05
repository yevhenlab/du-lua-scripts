# HUD, AR performance adjustor

`liby4performance` measures client FPS and adapts the redraw rate of HUD/AR
content returned by its registered renderers. It does not draw a performance
panel itself.

## Install and import

Install the library into the DU client Lua folder:

```powershell
./install-local.ps1 -DuRoot '<DU installation>'
```

Then run `./build-lua-configuration.ps1 -CopyToClipboard` and import the JSON.
The PB needs only the built-in `unit` and `system` links.

The exported `adaptArRedrawFrequencyToFps` setting chooses the redraw mode.
When enabled, FPS controls the AR redraw rate. When disabled, AR redraws on
every `onUpdate` callback, subject to `maximumArRedrawPercentOfFps`. That
setting caps redraws to 1–100% of current FPS; out-of-range values are clamped.

## First renderer

The main PB contains only the first circle renderer in
`library.onStart.drawings.lua`. Add your own functions there, then register
them in `unit.onStart.lua` with `hudAr.setContentRenderer(...)` or
`hudAr.addContentRenderer(...)`.

`system.onUpdate.lua` forwards frame updates for measurement and adaptive
redraw scheduling. `unit.onTimer.hudArClock.lua` forwards the library timer.
The initial redraw rate is 10 Hz. Once per second, the library compares the
latest five seconds of FPS with the available history, up to 60 seconds. It
lowers the redraw target proportionally when current FPS is below 90% of that
reference; otherwise, it targets the current FPS. The
actual redraw frequency approaches that target by 3, 2, or 1 Hz per second,
depending on the size of the gap.

## Full example

See [example](example/README.md) for the separate, larger PB example with a
counter, external HTML module, independent timer, and performance panel. It
uses `liby.liby4performance.withpanel`, which is the preserved panel version.
Its small and detailed panels show the FPS-derived draw target, achieved AR
redraw rate, and FPS history.
Its redraw scheduler keeps the requested cadence across game frames, even when
the target is not an exact multiple of the client update rate.
