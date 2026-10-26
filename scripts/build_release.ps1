$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not (Test-Path 'android')) { & "$PSScriptRoot/prepare_android.ps1" }
& "$PSScriptRoot/verify.ps1"
flutter build apk --release 2>&1 | Tee-Object 'evidence/apk_build.txt'
if ($LASTEXITCODE -ne 0) { throw 'APK build failed.' }
Copy-Item 'build/app/outputs/flutter-apk/app-release.apk' 'submission/app-release.apk' -Force
Write-Host 'APK copied to submission/. Install and launch it before submitting.'
