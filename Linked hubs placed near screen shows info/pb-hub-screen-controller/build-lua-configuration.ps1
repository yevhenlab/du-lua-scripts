<##
Builds a complete Dual Universe Programming Board configuration directly from
this controller's Lua filter files. No exported JSON template is required.

Examples:
  .\build-lua-configuration.ps1
  .\build-lua-configuration.ps1 -CopyToClipboard
  .\build-lua-configuration.ps1 -OutputPath C:\temp\hsc.json
##>
[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'pb-hub-screen-controller.generated.json'),
    [switch]$CopyToClipboard
)

$ErrorActionPreference = 'Stop'
$linkSlotCount = 100
$screenSlotNumber = 6

function Read-LuaFile([string]$Name) {
    $path = Join-Path $PSScriptRoot $Name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required Lua file is missing: $path"
    }
    return Get-Content -LiteralPath $path -Raw
}

function New-Slot([string]$Name) {
    return [pscustomobject][ordered]@{
        name = $Name
        type = [pscustomobject][ordered]@{
            events = @()
            methods = @()
        }
    }
}

function New-Handler(
    [int]$Key,
    [string]$SlotKey,
    [string]$Signature,
    [object[]]$FilterArgs,
    [string]$Code
) {
    return [pscustomobject][ordered]@{
        code = $Code
        filter = [pscustomobject][ordered]@{
            args = @($FilterArgs)
            signature = $Signature
            slotKey = $SlotKey
        }
        key = [string]$Key
    }
}

$slots = [ordered]@{}

for ($slotIndex = 0; $slotIndex -lt $linkSlotCount; $slotIndex++) {
    $slotNumber = $slotIndex + 1
    $slotName = if ($slotNumber -eq $screenSlotNumber) {
        'screen'
    } else {
        "slot$slotNumber"
    }
    $slots[[string]$slotIndex] = New-Slot $slotName
}

# Built-in control-unit slots use the negative keys expected by DU exports.
$slots['-1'] = New-Slot 'unit'
$slots['-3'] = New-Slot 'player'
$slots['-2'] = New-Slot 'construct'
$slots['-4'] = New-Slot 'system'
$slots['-5'] = New-Slot 'library'

$handlers = [System.Collections.Generic.List[object]]::new()
$nextKey = 0

$handlers.Add((New-Handler $nextKey '-5' 'onStart()' @() (
    Read-LuaFile 'library.onStart.lua'
)))
$nextKey++
$handlers.Add((New-Handler $nextKey '-5' 'onStart()' @() (
    Read-LuaFile 'library.onStart.storage.lua'
)))
$nextKey++
$handlers.Add((New-Handler $nextKey '-5' 'onStart()' @() (
    Read-LuaFile 'library.onStart.screen.lua'
)))
$nextKey++
$handlers.Add((New-Handler $nextKey '-1' 'onStart()' @() (
    Read-LuaFile 'unit.onStart.lua'
)))
$nextKey++
$handlers.Add((New-Handler $nextKey '-1' 'onTimer(tag)' @(
    [pscustomobject]@{ value = 'hscScreenDelivery' }
) (Read-LuaFile 'unit.onTimer.hubWaypoint.lua')))
$nextKey++
$handlers.Add((New-Handler $nextKey '-1' 'onTimer(tag)' @(
    [pscustomobject]@{ value = 'hscContainerRefresh' }
) (Read-LuaFile 'unit.onTimer.containerRefresh.lua')))
$nextKey++

for ($slotIndex = 0; $slotIndex -lt $linkSlotCount; $slotIndex++) {
    $slotNumber = $slotIndex + 1
    $handlers.Add((New-Handler $nextKey ([string]$slotIndex) `
        'onContentUpdate()' @() "hsc.onLinkedHubContentUpdate(slot$slotNumber)"))
    $nextKey++
}

$configuration = [pscustomobject][ordered]@{
    slots = [pscustomobject]$slots
    handlers = $handlers.ToArray()
    methods = @()
    events = @()
}

$json = $configuration | ConvertTo-Json -Depth 20 -Compress
[System.IO.File]::WriteAllText(
    $OutputPath,
    $json,
    [System.Text.UTF8Encoding]::new($false)
)

if ($CopyToClipboard) {
    Set-Clipboard -Value $json
}

Write-Host "Generated: $OutputPath"
Write-Host "Slots: $(@($configuration.slots.psobject.Properties).Count)"
Write-Host "Handlers: $($configuration.handlers.Count)"
if ($CopyToClipboard) { Write-Host 'Copied configuration to clipboard.' }
