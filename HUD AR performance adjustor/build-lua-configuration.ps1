[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'hud-ar-performance-adjustor.generated.json'),
    [switch]$CopyToClipboard
)

$ErrorActionPreference = 'Stop'

function Read-LuaFile([string]$Name) {
    Get-Content -LiteralPath (Join-Path $PSScriptRoot $Name) -Raw
}

function New-Slot([string]$Name) {
    [pscustomobject][ordered]@{ name = $Name; type = [pscustomobject][ordered]@{ events = @(); methods = @() } }
}

function New-Handler([int]$Key, [string]$SlotKey, [string]$Signature, [object[]]$FilterArgs, [string]$Code) {
    [pscustomobject][ordered]@{
        code = $Code
        filter = [pscustomobject][ordered]@{ args = @($FilterArgs); signature = $Signature; slotKey = $SlotKey }
        key = [string]$Key
    }
}

$slots = [ordered]@{
    '-1' = New-Slot 'unit'
    '-3' = New-Slot 'player'
    '-4' = New-Slot 'system'
    '-5' = New-Slot 'library'
}
$libraryCode = Read-LuaFile 'library.onStart.drawings.lua'
$configuration = [pscustomobject][ordered]@{
    slots = [pscustomobject]$slots
    handlers = @(
        New-Handler 0 '-5' 'onStart()' @() $libraryCode
        New-Handler 1 '-1' 'onStart()' @() (Read-LuaFile 'unit.onStart.lua')
        New-Handler 2 '-1' 'onTimer(tag)' @([pscustomobject]@{ value = 'liby4performanceHud' }) (Read-LuaFile 'unit.onTimer.hudArClock.lua')
        New-Handler 3 '-4' 'onUpdate()' @() (Read-LuaFile 'system.onUpdate.lua')
    )
    methods = @()
    events = @()
}
$json = $configuration | ConvertTo-Json -Depth 20 -Compress
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.UTF8Encoding]::new($false))
if ($CopyToClipboard) { Set-Clipboard -Value $json }
Write-Host "Generated: $OutputPath"
