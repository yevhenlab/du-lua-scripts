# AR Navigator

ARN renders AR assistance only for known, established places stored in `arn/locations.lua`. It does not scan Radar contacts. A Databank is optional and stores selected runtime settings and pins. Runtime branding is configured in `library.onStart.configuration.lua`: `applicationShortName = "SARN"` controls the controller, chat tag, warnings, and Databank namespace, while `applicationNamePrefix = "Settlers"` controls the HUD title prefix. These defaults display `Settlers AR Navigator`.

Each visible place is shown as a dot with:

- `Construct name [size]`
- `Owner: Name` when the catalog provides an owner
- Optional supporting `label`

## Setup

1. Install ARN and its packaged `liby4slots.lua` and `liby4performance.lua` dependencies:

```powershell
.\install-local.ps1
```

2. Edit `<DU Root>/Game/data/lua/arn/locations.lua` for standard locations or `locations-settlers.lua` for Settlers destinations; register custom attachment mappings in `locations-registry.lua`. See `locations-example.lua` for a commented custom-catalog template and every supported node field. Each real place may retain its DU `id` and uses a single semantic `type`, `name`, `label`, `coordinate`, literal `owner`, `atlasBody`, and `areaRadius`; planet and satellite nodes also define `radius` and `atmosphereRadius` for the limited fallback atlas. Optional `icon` overrides the type icon; `excluded = true` skips that node and its complete descendant branch during catalog loading.
3. Build and paste the generated Programming Board configuration:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

No linked Radar or Core is required. A linked Databank is optional; the main-menu Save to databank action stores all Locations, HUD, and Settings menu values, plus pins, for later starts.
