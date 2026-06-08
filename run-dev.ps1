<#
run-dev.ps1
Starts the backend (uvicorn) and a simple static server for the frontend
in two new PowerShell windows. Run this from the repository root.

Usage (PowerShell):
  .\run-dev.ps1

Prerequisites:
- Python (accessible via the `py` launcher or `python` on PATH)
- Dependencies installed (`pip install -r requirements.txt`)
#>

function Find-PythonLauncher {
    if (Get-Command py -ErrorAction SilentlyContinue) { return 'py' }
    if (Get-Command python -ErrorAction SilentlyContinue) { return 'python' }
    return $null
}

$python = Find-PythonLauncher
if (-not $python) {
    Write-Host "Python not found. Install Python or ensure 'py' or 'python' is on PATH." -ForegroundColor Yellow
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$backendCmd = "cd '$scriptDir\backend'; $python -3 -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload"
$frontendCmd = "cd '$scriptDir\frontend'; $python -3 -m http.server 8080"

Write-Host "Launching backend..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit","-Command", $backendCmd

Start-Sleep -Milliseconds 300

Write-Host "Launching frontend..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit","-Command", $frontendCmd

Write-Host "Backend should be at: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Frontend should be at: http://localhost:8080" -ForegroundColor Cyan
