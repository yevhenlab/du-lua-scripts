# Settlers AR Navigator

SARN renders AR assistance only for known, established places stored in `sarn/locations.lua`. It does not scan Radar contacts. A Databank is optional and stores player-selected runtime settings.

Each visible place is shown as a dot with:

- `Construct name [size]`
- `owner-p: Name`, `owner-org: Name`, or `owner: unknown`
- Optional supporting `label`

## Setup

1. Install `liby/liby4performance.lua` from `../HUD AR performance adjustor/src/du lua library` into the DU client `Game/data/lua` directory.
2. Install the SARN location catalog:

```powershell
.\install-local.ps1
```

3. Edit `<DU Root>/Game/data/lua/sarn/locations.lua` for standard locations or `locations-settlers.lua` for Settlers destinations. Each location uses `name`, `label`, `kind`, `coordinate`, `ownerId`, `atlasBody`, and `areaRadius`; optional `icon` and `excluded` fields override the kind icon or suppress its AR object.
4. Build and paste the generated Programming Board configuration:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

No linked Radar or Core is required. A linked Databank is optional; the Settings menu can save runtime overrides that replace exported PB parameter defaults on later starts.
