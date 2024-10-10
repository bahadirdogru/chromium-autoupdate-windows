# Chromium Autoupdate Windows

Bu PowerShell betiği, Windows üzerinde `Hibbiki.Chromium` paketini kurar, kuruluysa güncelleme kontrolü yapar ve varsa günceller. Betik ayrıca Windows Görev Zamanlayıcı'ya kendisini ekleyerek her gün saat 12:00'de otomatik olarak çalıştırılmasını sağlar.

## Kullanım

### 1. Betiği Çalıştırma
Betiği çalıştırmadan önce, PowerShell'in yönetici haklarıyla çalıştığından emin olun. Betik otomatik olarak kendisini yönetici olarak çalıştırmayı deneyecektir, ancak gerekirse manuel olarak da yönetici haklarıyla çalıştırabilirsiniz.

```bash
powershell -File "install.ps1"
```
### 2. Günlük Kontrolleri Planlama
Betiği ilk çalıştırdığınızda, otomatik olarak Görev Zamanlayıcı'ya günlük kontrol işlemi eklenir. Bu görev her gün saat 12:00'de Hibbiki.Chromium güncellemesi kontrolünü gerçekleştirir ve gerekiyorsa güncelleme yapar.

### Gereksinimler
- Windows işletim sistemi
- PowerShell (Yönetici haklarıyla çalıştırılmalıdır)
- winget paket yöneticisi
