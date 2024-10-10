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
