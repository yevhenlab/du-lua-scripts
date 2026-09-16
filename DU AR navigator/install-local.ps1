[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$DuRoot
)

$ErrorActionPreference = 'Stop'
if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
$librarySourceRoot = Join-Path $PSScriptRoot 'src\du lua library'
$libraryNames = @('arn', 'liby')

if (-not $DuRoot) {
    $commonPaths = @(
        (Join-Path $env:ProgramData 'DualUniverse'),
        'C:\ProgramData\DualUniverse',
        (Join-Path ${env:ProgramFiles(x86)} 'Steam\steamapps\common\Dual Universe'),
        'C:\Program Files (x86)\Steam\steamapps\common\Dual Universe'
    )
    foreach ($path in $commonPaths) {
        if ($path -and (Test-Path -LiteralPath (Join-Path $path 'Game\data\lua') -PathType Container)) {
            $DuRoot = $path
            break
        }
    }
}

if (-not $DuRoot) {
    throw "Dual Universe installation path not found. Please specify -DuRoot '<Path to Dual Universe>'."
}

$luaRoot = Join-Path $DuRoot 'Game\data\lua'
if (-not (Test-Path -LiteralPath $luaRoot -PathType Container)) {
    throw "DU Lua directory does not exist: $luaRoot"
}

foreach ($libraryName in $libraryNames) {
    $sourceDirectory = Join-Path $librarySourceRoot $libraryName
    if (-not (Test-Path -LiteralPath $sourceDirectory -PathType Container)) {
        throw "Library source directory is missing: $sourceDirectory"
    }
    $destinationDirectory = Join-Path $luaRoot $libraryName
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    $files = Get-ChildItem -LiteralPath $sourceDirectory -Filter '*.lua' -File
    foreach ($file in $files) {
        $destinationFile = Join-Path $destinationDirectory $file.Name
        Copy-Item -LiteralPath $file.FullName -Destination $destinationFile -Force
        Write-Host "Installed: $destinationFile"
    }
}
