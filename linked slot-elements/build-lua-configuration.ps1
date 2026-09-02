<##
Builds a Dual Universe Programming Board test configuration for liby4slots.

Examples:
  .\build-lua-configuration.ps1
  .\build-lua-configuration.ps1 -CopyToClipboard
  .\build-lua-configuration.ps1 -OutputPath C:\temp\liby4slots.json
##>
[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PSScriptRoot 'liby4slots.generated.json'),
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
        New-Handler 0 '-1' 'onStart()' @() (
            Read-LuaFile 'unit.onStart.lua'
        )
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
Write-Host "Slots: $(@($configuration.slots.psobject.Properties).Count)"
Write-Host "Handlers: $($configuration.handlers.Count)"
if ($CopyToClipboard) { Write-Host 'Copied configuration to clipboard.' }
