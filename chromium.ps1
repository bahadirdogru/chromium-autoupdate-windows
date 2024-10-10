# Package ID for installation and update check
$packageId = "Hibbiki.Chromium"

# Check if it is installed
$installedPackage = winget list --id $packageId

if ($installedPackage -like "*No installed package found*") {
    # If not installed, install it
    Write-Host "Chromium is not installed, installing..."
    winget install --id $packageId --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Chromium has been successfully installed."
    } else {
        Write-Host "An error occurred while installing Chromium."
    }
} else {
    # If installed, check for updates
    Write-Host "Chromium is installed, checking for updates..."
    $updateAvailable = winget upgrade --id $packageId
    
    if ($updateAvailable -like "*No applicable update found*") {
        Write-Host "Chromium is up to date, no updates found."
    } else {
        Write-Host "Update found for Chromium, installing the update..."
        winget upgrade --id $packageId --silent
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Update has been successfully installed."
        } else {
            Write-Host "An error occurred while installing the update."
        }
    }
}
