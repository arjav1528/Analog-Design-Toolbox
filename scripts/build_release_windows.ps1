$ErrorActionPreference = "Stop"

$Version = if ($args.Count -gt 0) { $args[0] } else { "1.0.0" }

if (-not (Get-Command flutter_distributor -ErrorAction SilentlyContinue)) {
    throw "flutter_distributor not found. Install with: dart pub global activate flutter_distributor"
}

flutter_distributor package `
  --platform windows `
  --targets exe `
  --artifact-name adt-setup-$Version

Write-Host "Done. EXE installer available under dist\"
