# Configuration
$ImageName = "cpp-linux-orig:latest"
$ThresholdGB = 2.0

Write-Host "Verifying image size for: $ImageName"

# Get image size string (e.g. "4.49GB" or "900MB")
$ImageSizeString = docker images $ImageName --format "{{.Size}}"
if (-not $ImageSizeString) {
    Write-Error "ERROR: Could not retrieve image size for $ImageName"
    exit 1
}

$ImageSizeGB = 0.0
if ($ImageSizeString -match '([\d\.]+)\s*GB') {
    $ImageSizeGB = [double]$matches[1]
} elseif ($ImageSizeString -match '([\d\.]+)\s*MB') {
    $ImageSizeGB = [double]$matches[1] / 1024
} else {
    Write-Error "ERROR: Could not parse image size string '$ImageSizeString'"
    exit 1
}

$ImageSizeGB = [math]::Round($ImageSizeGB, 2)

Write-Host "Current Size: $ImageSizeGB GB"
Write-Host "Threshold: $ThresholdGB GB"

if ($ImageSizeGB -gt $ThresholdGB) {
    Write-Error "ERROR: Image size ($ImageSizeGB GB) exceeds threshold ($ThresholdGB GB)!"
    exit 1
}

Write-Host "SUCCESS: Image size ($ImageSizeGB GB) is within threshold ($ThresholdGB GB)."
