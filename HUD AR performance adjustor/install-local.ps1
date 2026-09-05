[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DuRoot
)

$ErrorActionPreference = 'Stop'
$sourceDirectory = Join-Path $PSScriptRoot 'src\du lua library\liby'
$luaRoot = Join-Path $DuRoot 'Game\data\lua'
$destinationDirectory = Join-Path $luaRoot 'liby'

if (-not (Test-Path -LiteralPath $sourceDirectory -PathType Container)) { throw "Library source directory is missing: $sourceDirectory" }
if (-not (Test-Path -LiteralPath $luaRoot -PathType Container)) { throw "DU Lua directory does not exist: $luaRoot" }
New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
$obsoleteImageModule = Join-Path $destinationDirectory 'example-image-html.lua'
if (Test-Path -LiteralPath $obsoleteImageModule -PathType Leaf) {
    Remove-Item -LiteralPath $obsoleteImageModule -Force
    Write-Host "Removed obsolete module: $obsoleteImageModule"
}
$files = Get-ChildItem -LiteralPath $sourceDirectory -Filter '*.lua' -File
foreach ($file in $files) {
    $destinationFile = Join-Path $destinationDirectory $file.Name
    Copy-Item -LiteralPath $file.FullName -Destination $destinationFile -Force
    Write-Host "Installed: $destinationFile"
}
