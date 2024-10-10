# Chromium Autoupdate Windows

This PowerShell script installs the `Hibbiki.Chromium` package on Windows, checks for updates if it's already installed, and updates it if necessary. The script also adds itself to Windows Task Scheduler to run automatically every day at 12:00 PM to check for updates.

## Usage

### 1. Running the Script
Before running the script, make sure PowerShell is running with administrative privileges. The script will attempt to run itself with administrative rights if needed. The script saves itself to `C:/chromium.ps1` and schedules a task in Task Scheduler.

```bash
powershell -File "install.ps1"
```
### 2. Scheduling Daily Update Checks
When you first run the script, it automatically adds a daily update check to Task Scheduler. This task will check for updates for `Hibbiki.Chromium` every day at 12:00 PM and install any available updates.

### Requirements
- Windows operating system
- PowerShell (must be run with administrator privileges)
- winget package manager (included by default in Windows 10 and above, except for IoT systems)

### Installing Winget (Optional)
```bash
Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
Add-AppxPackage -Path "https://aka.ms/winget-cli"
```
