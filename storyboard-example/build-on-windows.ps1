[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("Example", "Full", "Both")]
    [string]$Mode = "Example",

    [Parameter()]
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$VenvPython = Join-Path $RepoRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $VenvPython)) {
    Write-Host "The Python environment is missing. Running setup first..." -ForegroundColor Yellow
    & (Join-Path $PSScriptRoot "setup-windows.ps1")
}

if (-not (Test-Path $VenvPython)) {
    throw "Setup did not create $VenvPython"
}

Set-Location $RepoRoot

if ($Clean) {
    $TemporaryDirectories = @(
        "storyboard-example\.build",
        "trailer\generated",
        "trailer\v2_generated",
        "trailer\.render",
        "trailer\.render_v2"
    )
    foreach ($Directory in $TemporaryDirectories) {
        if (Test-Path $Directory) {
            Write-Host "Removing $Directory"
            Remove-Item -Recurse -Force $Directory
        }
    }
}

$StartTime = Get-Date

if ($Mode -eq "Example" -or $Mode -eq "Both") {
    Write-Host "Building the 15-second storyboard example..." -ForegroundColor Cyan
    & $VenvPython ".\storyboard-example\build.py"
    if ($LASTEXITCODE -ne 0) {
        throw "The storyboard example build failed with exit code $LASTEXITCODE"
    }
}

if ($Mode -eq "Full" -or $Mode -eq "Both") {
    Write-Host "Building the complete 79-second trailer..." -ForegroundColor Cyan
    & $VenvPython ".\trailer\build_trailer_v2.py"
    if ($LASTEXITCODE -ne 0) {
        throw "The full trailer build failed with exit code $LASTEXITCODE"
    }
}

$Elapsed = (Get-Date) - $StartTime
Write-Host ""
Write-Host ("Build completed in {0:hh\:mm\:ss}." -f $Elapsed) -ForegroundColor Green

if ($Mode -eq "Example" -or $Mode -eq "Both") {
    Write-Host "Example output: storyboard-example\output\two_second_witness_storyboard_example.mp4"
}
if ($Mode -eq "Full" -or $Mode -eq "Both") {
    Write-Host "Full output: trailer\two_second_witness_trailer.mp4"
}
