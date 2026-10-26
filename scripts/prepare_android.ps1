$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw 'Flutter is not on PATH. Add D:\mad\flutter\bin, then reopen PowerShell.' }
if (Test-Path 'android') { Write-Host 'Android folder already exists; leaving it untouched.'; exit 0 }
$tempProject = Join-Path ([IO.Path]::GetTempPath()) ('movement_quest_' + [guid]::NewGuid().ToString('N'))
flutter create --platforms=android --org edu.gsu.codingmaster --project-name movement_quest --no-pub $tempProject
if ($LASTEXITCODE -ne 0) { throw 'Flutter scaffold failed.' }
Copy-Item (Join-Path $tempProject 'android') '.' -Recurse
if (Test-Path (Join-Path $tempProject '.metadata')) { Copy-Item (Join-Path $tempProject '.metadata') '.' }
$manifest = 'android/app/src/main/AndroidManifest.xml'
(Get-Content $manifest -Raw).Replace('android:label="movement_quest"','android:label="Movement Quest"') | Set-Content $manifest
Remove-Item $tempProject -Recurse -Force
Write-Host 'Android runner generated. Existing lib/, tests and documents were preserved.'
