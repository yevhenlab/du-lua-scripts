[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'industry-builder-helper.generated.json'),
    [switch]$CopyToClipboard
)

$ErrorActionPreference = 'Stop'
$linkSlotCount = 100

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
    $slots[[string]$slotIndex] = New-Slot "slot$($slotIndex + 1)"
}

$slots['-1'] = New-Slot 'unit'
$slots['-3'] = New-Slot 'player'
$slots['-2'] = New-Slot 'construct'
$slots['-4'] = New-Slot 'system'
$slots['-5'] = New-Slot 'library'

$configuration = [pscustomobject][ordered]@{
    slots = [pscustomobject]$slots
    handlers = @(
        New-Handler 0 '-5' 'onStart()' @() (Read-LuaFile 'library.onStart.lua')
        New-Handler 1 '-1' 'onStart()' @() (Read-LuaFile 'unit.onStart.lua')
        New-Handler 2 '-1' 'onTimer(tag)' @(
            [pscustomobject]@{ value = 'ibhHudClock' }
        ) (Read-LuaFile 'unit.onTimer.hudClock.lua')
        New-Handler 3 '-1' 'onTimer(tag)' @(
            [pscustomobject]@{ value = 'ibhNewElementSearch' }
        ) (Read-LuaFile 'unit.onTimer.elementSearch.lua')
        New-Handler 4 '-4' 'onUpdate()' @() (Read-LuaFile 'system.onUpdate.lua')
        New-Handler 5 '-4' 'onActionStart(action)' @(
            [pscustomobject]@{ value = 'leftmouse' }
        ) (Read-LuaFile 'system.onActionStart.leftmouse.lua')
        New-Handler 6 '-1' 'onTimer(tag)' @(
            [pscustomobject]@{ value = 'ibhDoneClick' }
        ) (Read-LuaFile 'unit.onTimer.doneClick.lua')
    )
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
Write-Host "Link slots: $linkSlotCount"
if ($CopyToClipboard) { Write-Host 'Copied configuration to clipboard.' }
