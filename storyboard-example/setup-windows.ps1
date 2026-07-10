[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$VenvPath = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvPath "Scripts\python.exe"
$Requirements = Join-Path $PSScriptRoot "requirements.txt"

Write-Host "Two Second Witness — Windows 11 setup" -ForegroundColor Cyan
Write-Host "Repository: $RepoRoot"

if (-not (Test-Path $VenvPython)) {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        Write-Host "Creating .venv with the Python launcher..."
        & py -3.12 -m venv $VenvPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Python 3.12 was not available; trying the launcher's default Python..." -ForegroundColor Yellow
            & py -m venv $VenvPath
        }
    }
    elseif (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Host "Creating .venv with python.exe..."
        & python -m venv $VenvPath
    }
    else {
        throw "Python was not found. Install it with: winget install --id Python.Python.3.12 -e"
    }
}

if (-not (Test-Path $VenvPython)) {
    throw "The virtual environment could not be created at $VenvPath"
}

Write-Host "Upgrading pip..."
& $VenvPython -m pip install --upgrade pip

Write-Host "Installing storyboard dependencies..."
& $VenvPython -m pip install -r $Requirements

Write-Host "Checking FFmpeg..."
if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
    $FfmpegVersion = (& ffmpeg -version | Select-Object -First 1)
    Write-Host $FfmpegVersion -ForegroundColor Green
}
else {
    $BundledFfmpeg = & $VenvPython -c "import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())"
    Write-Host "System FFmpeg was not found. The build will use:" -ForegroundColor Yellow
    Write-Host $BundledFfmpeg
}

Write-Host "Checking fonts..."
$FontDirectory = Join-Path $env:WINDIR "Fonts"
$FontCandidates = @("segoeui.ttf", "arial.ttf", "segoeuib.ttf", "arialbd.ttf")
foreach ($FontName in $FontCandidates) {
    $FontPath = Join-Path $FontDirectory $FontName
    if (Test-Path $FontPath) {
        Write-Host "Found $FontPath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host "Build the example:"
Write-Host "  .\storyboard-example\build-on-windows.ps1 -Mode Example"
Write-Host "Build the full trailer:"
Write-Host "  .\storyboard-example\build-on-windows.ps1 -Mode Full"
