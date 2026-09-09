<## Builds the known-location-only SARN Programming Board configuration. ##>
[CmdletBinding()]
param([string]$OutputPath, [switch]$CopyToClipboard)

$ErrorActionPreference = 'Stop'
if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
if (-not $OutputPath) { $OutputPath = Join-Path $PSScriptRoot 'settlers-ar-navigator.generated.json' }
function Read-LuaFile([string]$Name) { Get-Content -LiteralPath (Join-Path $PSScriptRoot $Name) -Raw }
function New-Slot([string]$Name) {
    [pscustomobject][ordered]@{ name = $Name; type = [pscustomobject][ordered]@{ events = @(); methods = @() } }
}
function New-Handler([int]$Key, [string]$SlotKey, [string]$Signature, [string]$Code, [object[]]$FilterArgs = @()) {
    [pscustomobject][ordered]@{
        code = $Code
        filter = [pscustomobject][ordered]@{ args = @($FilterArgs); signature = $Signature; slotKey = $SlotKey }
        key = [string]$Key
    }
}

$slots = [ordered]@{}
for ($index = 0; $index -lt 100; $index++) { $slots[[string]$index] = New-Slot "slot$($index + 1)" }
$slots['-1'] = New-Slot 'unit'
$slots['-2'] = New-Slot 'construct'
$slots['-3'] = New-Slot 'player'
$slots['-4'] = New-Slot 'system'
$slots['-5'] = New-Slot 'library'
$handlers = @(
    (New-Handler 0 '-5' 'onStart()' (Read-LuaFile 'library.onStart.configuration.lua'))
    (New-Handler 1 '-5' 'onStart()' (Read-LuaFile 'library.onStart.helpers.lua'))
    (New-Handler 2 '-5' 'onStart()' (Read-LuaFile 'library.onStart.constructCatalog.lua'))
    (New-Handler 3 '-5' 'onStart()' (Read-LuaFile 'library.onStart.arDrawing.lua'))
    (New-Handler 4 '-5' 'onStart()' (Read-LuaFile 'library.onStart.hudDrawing.lua'))
    (New-Handler 5 '-5' 'onStart()' (Read-LuaFile 'library.onStart.renderer.lua'))
    (New-Handler 6 '-1' 'onStart()' (Read-LuaFile 'unit.onStart.lua'))
    (New-Handler 7 '-1' 'onTimer(tag)' (Read-LuaFile 'unit.onTimer.performance.lua') @(
        [pscustomobject]@{ value = 'liby4performanceHud' }
    ))
    (New-Handler 8 '-4' 'onUpdate()' (Read-LuaFile 'system.onUpdate.lua'))
)
$configuration = [pscustomobject][ordered]@{ slots = [pscustomobject]$slots; handlers = $handlers; methods = @(); events = @() }
$json = $configuration | ConvertTo-Json -Depth 20 -Compress
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.UTF8Encoding]::new($false))
if ($CopyToClipboard) { Set-Clipboard -Value $json }
Write-Host "Generated: $OutputPath"
