[CmdletBinding()]
param([string]$OutputPath = (Join-Path $PSScriptRoot 'example.generated.json'), [switch]$CopyToClipboard)
$ErrorActionPreference = 'Stop'
function Read-LuaFile([string]$Name) { Get-Content -LiteralPath (Join-Path $PSScriptRoot $Name) -Raw }
function New-Slot([string]$Name) { [pscustomobject][ordered]@{ name = $Name; type = [pscustomobject][ordered]@{ events = @(); methods = @() } } }
function New-Handler([int]$Key, [string]$SlotKey, [string]$Signature, [object[]]$FilterArgs, [string]$Code) { [pscustomobject][ordered]@{ code = $Code; filter = [pscustomobject][ordered]@{ args = @($FilterArgs); signature = $Signature; slotKey = $SlotKey }; key = [string]$Key } }
$slots = [ordered]@{ '-1' = New-Slot 'unit'; '-4' = New-Slot 'system'; '-5' = New-Slot 'library' }
$configuration = [pscustomobject][ordered]@{ slots = [pscustomobject]$slots; handlers = @(
    New-Handler 0 '-5' 'onStart()' @() (Read-LuaFile 'library.onStart.lua')
    New-Handler 1 '-1' 'onStart()' @() (Read-LuaFile 'unit.onStart.lua')
    New-Handler 2 '-1' 'onTimer(tag)' @([pscustomobject]@{ value = 'liby4performanceHud' }) (Read-LuaFile 'unit.onTimer.liby4performanceHud.lua')
    New-Handler 3 '-1' 'onTimer(tag)' @([pscustomobject]@{ value = 'exampleCounter' }) (Read-LuaFile 'unit.onTimer.exampleCounter.lua')
    New-Handler 4 '-4' 'onUpdate()' @() (Read-LuaFile 'system.onUpdate.lua')
); methods = @(); events = @() }
$json = $configuration | ConvertTo-Json -Depth 20 -Compress
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.UTF8Encoding]::new($false))
if ($CopyToClipboard) { Set-Clipboard -Value $json }
Write-Host "Generated: $OutputPath"
