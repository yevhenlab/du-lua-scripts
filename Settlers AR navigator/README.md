# Settlers AR Navigator

SARN renders AR assistance only for known, established places stored in `sarn/locations.lua`. It does not scan Radar contacts. A Databank is optional and stores selected runtime settings and pins.

Each visible place is shown as a dot with:

- `Construct name [size]`
- `Owner: Name` when the catalog provides an owner
- Optional supporting `label`

## Setup

1. Install `liby/liby4performance.lua` from `../HUD AR performance adjustor/src/du lua library` into the DU client `Game/data/lua` directory.
2. Install the SARN location catalog:

```powershell
.\install-local.ps1
```

3. Edit `<DU Root>/Game/data/lua/sarn/locations.lua` for standard locations or `locations-settlers.lua` for Settlers destinations. Each real place may retain its DU `id` and uses structural `type`, semantic `kind`, `name`, `label`, `coordinate`, literal `owner`, `atlasBody`, and `areaRadius`; planet and satellite nodes also define `radius` and `atmosphereRadius` for the limited fallback atlas. Optional `icon` and `excluded` fields override the kind icon or suppress its AR object.
4. Build and paste the generated Programming Board configuration:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

No linked Radar or Core is required. A linked Databank is optional; the main-menu Save to databank action stores all Locations and Settings menu values, plus pins, for later starts.
