[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DuRoot
)

$ErrorActionPreference = 'Stop'

$sourceFile = Join-Path $PSScriptRoot `
    'src\du lua library\liby\liby4slots.lua'
$luaRoot = Join-Path $DuRoot 'Game\data\lua'
$destinationDirectory = Join-Path $luaRoot 'liby'
$destinationFile = Join-Path $destinationDirectory 'liby4slots.lua'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Library source is missing: $sourceFile"
}

if (-not (Test-Path -LiteralPath $luaRoot -PathType Container)) {
    throw "DU Lua directory does not exist: $luaRoot"
}

New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
Copy-Item -LiteralPath $sourceFile -Destination $destinationFile -Force

Write-Host "Installed: $destinationFile"
