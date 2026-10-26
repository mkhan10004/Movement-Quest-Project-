$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force 'evidence' | Out-Null
flutter --version | Tee-Object 'evidence/flutter_version.txt'
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed.' }
dart format lib test tool
if ($LASTEXITCODE -ne 0) { throw 'Formatting failed.' }
flutter analyze 2>&1 | Tee-Object 'evidence/analysis_output.txt'
if ($LASTEXITCODE -ne 0) { throw 'Analyze failed; fix errors before continuing.' }
flutter test --coverage 2>&1 | Tee-Object 'evidence/flutter_tests.txt'
if ($LASTEXITCODE -ne 0) { throw 'Tests failed.' }
dart run tool/evaluate_helper.dart | Tee-Object 'evidence/helper_results.json'
if ($LASTEXITCODE -ne 0) { throw 'Helper evaluation failed.' }
Write-Host 'Automated checks completed. Two-device/offline checks still need real evidence.'
