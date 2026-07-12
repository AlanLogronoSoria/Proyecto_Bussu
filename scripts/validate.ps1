# Andes Mobility — Environment Validation
# Run before starting development or deployment

Write-Host "=== Andes Mobility Environment Validation ===" -ForegroundColor Green

# Check Flutter
try {
  $v = flutter --version 2>&1 | Select-Object -First 1
  Write-Host "  Flutter: $v" -ForegroundColor Gray
} catch { Write-Host "  ERROR: Flutter not found" -ForegroundColor Red; exit 1 }

# Check required env vars (development)
$checkVars = @("SUPABASE_URL", "SUPABASE_ANON_KEY")
$mockMode = $env:ENABLE_MOCK_AUTH -ne "false"

if (-not $mockMode) {
  foreach ($var in $checkVars) {
    $val = [Environment]::GetEnvironmentVariable($var)
    if (-not $val) { Write-Host "  WARNING: $var not set (mock mode active)" -ForegroundColor Yellow }
    else { Write-Host "  $var: OK" -ForegroundColor Gray }
  }
} else {
  Write-Host "  Mock mode active (no backend required)" -ForegroundColor Cyan
}

# Production safety checks
$isProd = [Environment]::GetEnvironmentVariable("IS_PRODUCTION")
if ($isProd -eq "true" -and $mockMode) {
  Write-Host "  CRITICAL: IS_PRODUCTION=true with ENABLE_MOCK_AUTH=true" -ForegroundColor Red
  exit 1
}

# Check Supabase CLI
try {
  supabase --version 2>&1 | Out-Null
  Write-Host "  Supabase CLI: OK" -ForegroundColor Gray
} catch { Write-Host "  Supabase CLI: not installed (optional)" -ForegroundColor Yellow }

# Run analysis
Write-Host "`nRunning flutter analyze..." -ForegroundColor Cyan
flutter analyze 2>&1 | Select-String "issues found" | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

# Run tests
Write-Host "Running flutter test..." -ForegroundColor Cyan
flutter test 2>&1 | Select-String "All tests passed" | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }

Write-Host "`n=== Validation Complete ===" -ForegroundColor Green
