# GitHub API endpoint
$apiUrl = "https://api.github.com/repos/Hibbiki/chromium-win64/releases/latest"
$installDir = "$env:LOCALAPPDATA\Chromium"
$currentVersionFile = "$installDir\version.txt"
$chromiumExePath = "${env:ProgramFiles}\Chromium\Application\chrome.exe"

function Get-CurrentVersion {
    if (Test-Path $currentVersionFile) {
        return Get-Content $currentVersionFile
    }
    # Dosya yoksa kurulu Chromium'dan versiyon kontrolü yap
    elseif (Test-Path $chromiumExePath) {
        $version = (Get-Item $chromiumExePath).VersionInfo.FileVersion
        return $version
    }
    return $null
}

function Install-Chromium {
    param (
        [string]$downloadUrl,
        [string]$version
    )
    
    try {
        if ([string]::IsNullOrEmpty($downloadUrl)) {
            throw "İndirme URL'si bulunamadı!"
        }

        Write-Host "Chromium indiriliyor..."
        $tempFile = "$env:TEMP\chromium_installer.exe"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
        
        if (-not (Test-Path $tempFile)) {
            throw "İndirme başarısız oldu!"
        }

        Write-Host "Chromium kuruluyor..."
        $process = Start-Process -FilePath $tempFile -ArgumentList "/silent" -Wait -PassThru
        
        if ($process.ExitCode -ne 0) {
            throw "Kurulum başarısız oldu! Exit code: $($process.ExitCode)"
        }
        
        # Versiyon bilgisini kaydet
        if (-not (Test-Path $installDir)) {
            New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        }
        $version | Out-File $currentVersionFile -Force
        
        Write-Host "Kurulum tamamlandı."
        Remove-Item $tempFile -Force
        return $true
    }
    catch {
        Write-Host "Hata oluştu: $_" -ForegroundColor Red
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
        return $false
    }
}

try {
    $headers = @{
        "Accept" = "application/vnd.github.v3+json"
        "User-Agent" = "PowerShell Script"
    }
    
    Write-Host "Güncellemeler kontrol ediliyor..."
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    $latestVersion = $response.tag_name
    $currentVersion = Get-CurrentVersion
    
    # İndirme URL'sini bul (sync installer'ı tercih et)
    $downloadUrl = ($response.assets | Where-Object { $_.name -like "*mini_installer.sync.exe" }).browser_download_url
    
    if (-not $currentVersion) {
        Write-Host "Chromium kurulu değil. Kuruluyor..."
        if (Install-Chromium -downloadUrl $downloadUrl -version $latestVersion) {
            Write-Host "Kurulum başarılı!" -ForegroundColor Green
        }
    }
    elseif ($currentVersion -ne $latestVersion) {
        Write-Host "Yeni sürüm bulundu: $latestVersion" -ForegroundColor Yellow
        Write-Host "Mevcut sürüm: $currentVersion"
        if (Install-Chromium -downloadUrl $downloadUrl -version $latestVersion) {
            Write-Host "Güncelleme başarılı!" -ForegroundColor Green
        }
    }
    else {
        Write-Host "Chromium güncel: $currentVersion" -ForegroundColor Green
    }
}
catch {
    Write-Host "Hata oluştu: $_" -ForegroundColor Red
}
