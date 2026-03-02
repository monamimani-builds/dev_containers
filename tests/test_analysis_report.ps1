$reportFile = "conductor/tracks/optimize_cpp_devcontainer_20260302/analysis.md"

if (-not (Test-Path $reportFile)) {
    Write-Error "ERROR: Analysis report file not found!"
    exit 1
}

$content = Get-Content $reportFile -Raw
if ($content -notmatch "## Actual Size Breakdown") {
    Write-Host "ERROR: Analysis report is missing 'Actual Size Breakdown' section!"
    exit 1
}

Write-Host "SUCCESS: Analysis report is complete."
