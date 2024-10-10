# Admin hakları kontrolü
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltinRole]::Administrator
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    
    return $principal.IsInRole($adminRole)
}

# Eğer admin hakları yoksa, scripti yeniden admin olarak çalıştır
if (-not (Test-Admin)) {
    Write-Host "Bu betik yönetici hakları gerektiriyor. Tekrar yönetici olarak çalıştırılıyor..."
    Start-Process powershell -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Chromium güncelleme betiği
$scriptContent = @'
# Kurulum ve güncelleme kontrolü için package ID
$packageId = "Hibbiki.Chromium"

# Kurulu olup olmadığını kontrol et
$installedPackage = winget list --id $packageId

if ($installedPackage -like "*No installed package found*") {
    # Kurulu değilse yükle
    Write-Host "Chromium yüklü değil, kuruluyor..."
    winget install --id $packageId --silent
    Write-Host "Chromium başarıyla yüklendi."
} else {
    # Kuruluysa güncelleme kontrolü yap
    Write-Host "Chromium yüklü, güncellemeler kontrol ediliyor..."
    $updateAvailable = winget upgrade --id $packageId
    
    if ($updateAvailable -like "*No applicable update found*") {
        Write-Host "Chromium güncel, herhangi bir güncelleme bulunamadı."
    } else {
        Write-Host "Chromium için güncelleme bulundu, güncellemeyi yüklüyorum..."
        winget upgrade --id $packageId --silent
        Write-Host "Güncelleme başarıyla yüklendi."
    }
}
'@

# Betiği C:/chromium.ps1 dosyasına kaydet
$scriptPath = "C:/chromium.ps1"
Set-Content -Path $scriptPath -Value $scriptContent -Force
Write-Host "Betiğin içeriği $scriptPath konumuna başarıyla kaydedildi."

# Görev Zamanlayıcı'ya günlük görev eklemek
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $scriptPath"
$trigger = New-ScheduledTaskTrigger -Daily -At 12pm  # Her gün öğlen 12:00'de çalışması için
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

# Yeni görev zamanlayıcı ekleniyor
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "Chromium Güncelleme Kontrolü"
Write-Host "Chromium güncelleme kontrolü için günlük görev başarıyla eklendi."
