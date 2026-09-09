# Settlers AR Navigator

SARN renders AR assistance only for known, established places stored in `sarn/constructs.lua`. It does not scan Radar contacts or use a Databank.

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

3. Edit `<DU Root>/Game/data/lua/sarn/constructs.lua`. Supported fields are `id`, `name`, `ownerId`, `coordinate`, `color`, `label`, `coreSize`, and optional `size`.
4. Build and paste the generated Programming Board configuration:

```powershell
.\build-lua-configuration.ps1 -CopyToClipboard
```

No linked Radar, Core, or Databank is required.
