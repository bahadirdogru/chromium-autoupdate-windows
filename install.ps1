# Admin rights check
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltinRole]::Administrator
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    
    return $principal.IsInRole($adminRole)
}

# If admin rights are not present, restart the script as admin
if (-not (Test-Admin)) {
    Write-Host "This script requires administrator rights. Restarting as administrator..."
    Start-Process powershell -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Chromium update script
$scriptContent = @'
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
'@

# Save the script to C:/chromium.ps1
$scriptPath = "C:/chromium.ps1"
Set-Content -Path $scriptPath -Value $scriptContent -Force
Write-Host "The script content has been successfully saved to $scriptPath."

# Adding a daily task to Task Scheduler
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:/chromium.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 12pm  # To run every day at 12:00 PM
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

# Adding the new scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "Chromium Update Check"
Write-Host "Daily task for Chromium update check has been successfully added."