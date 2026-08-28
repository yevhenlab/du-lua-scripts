# Linked Hub Production Screen

This project contains a Dual Universe Programming Board controller that shows
nearby Container Hubs and their products on a Screen grid.

The working source and installation guide are in
[`pb-hub-screen-controller`](pb-hub-screen-controller/README.md).

The PowerShell builder creates a complete paste-ready PB configuration directly
from the Lua files. It does not require an exported JSON template.

```powershell
cd "pb-hub-screen-controller"
.\build-lua-configuration.ps1 -CopyToClipboard
```

Paste the result with the Programming Board action **Paste Lua configuration
from clipboard**. After pasting, review the exported debug parameters and adjust
the four grid-margin parameters for the physical size and usable area of your
Screen.
