<#
.SYNOPSIS
  Optymalizuje img/logo.png do kompletu plików (WebP + PNG fallback + favicony).

.DESCRIPTION
  Bierze img/logo.png (źródło, zalecane 512x512 lub większe) i tworzy:
    img/logo.webp           — 512x512 WebP (głowny używany w nav, footer)
    img/logo-1024.webp      — 1024x1024 WebP (hero, LCP candidate)
    img/logo-96.webp        — 96x96 WebP (nav thumbnail, retina-ready)
    img/favicon-32.png      — 32x32 PNG favicon
    img/apple-touch-icon.png — 180x180 PNG (iOS bookmark icon)

  Skrypt PRÓBUJE kolejno: ImageMagick → cwebp + ffmpeg → npx sharp-cli.
  Jeśli żadne narzędzie nie jest dostępne — wyświetla instrukcję instalacji.

.EXAMPLE
  pwsh -File scripts/optimize-logo.ps1
  pwsh -File scripts/optimize-logo.ps1 -Source "C:\Downloads\moje-logo.png"

.NOTES
  Wymaga JEDNEGO Z poniższych narzędzi:
    1. ImageMagick (zalecane)         — https://imagemagick.org/
       Instalacja: winget install ImageMagick.ImageMagick
    2. Node.js + sharp-cli            — https://nodejs.org/
       Instalacja: nic, używa npx
    3. cwebp (libwebp) + ffmpeg
#>

[CmdletBinding()]
param(
  [string]$Source = "img/logo.png",
  [string]$OutputDir = "img"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

function Resolve-RepoPath {
  param([string]$Path)
  if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
  return Join-Path $repoRoot $Path
}

$sourcePath = Resolve-RepoPath $Source
$outDir = Resolve-RepoPath $OutputDir

Write-Host ""
Write-Host "==> KFDIAMENT logo optimizer" -ForegroundColor Cyan
Write-Host "Source:   $sourcePath"
Write-Host "Output:   $outDir"
Write-Host ""

if (-not (Test-Path $sourcePath)) {
  Write-Host "ERROR: Brak pliku zrodlowego: $sourcePath" -ForegroundColor Red
  Write-Host ""
  Write-Host "Zapisz logo jako $sourcePath (zalecane: 512x512 PNG, kwadrat, przezroczyste tlo)"
  exit 1
}

if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

# Wykryj dostępne narzędzia
$haveMagick = $null -ne (Get-Command magick -ErrorAction SilentlyContinue)
$haveCwebp  = $null -ne (Get-Command cwebp  -ErrorAction SilentlyContinue)
$haveFfmpeg = $null -ne (Get-Command ffmpeg -ErrorAction SilentlyContinue)
$haveNpx    = $null -ne (Get-Command npx    -ErrorAction SilentlyContinue)

Write-Host "Available tools:"
Write-Host "  ImageMagick (magick): $haveMagick"
Write-Host "  cwebp:                $haveCwebp"
Write-Host "  ffmpeg:               $haveFfmpeg"
Write-Host "  npx (Node.js):        $haveNpx"
Write-Host ""

# Definicja targetów wyjściowych
$targets = @(
  @{ Name = "logo.webp";              Size = 512;  Format = "webp"; Quality = 85 }
  @{ Name = "logo-1024.webp";         Size = 1024; Format = "webp"; Quality = 88 }
  @{ Name = "logo-96.webp";           Size = 96;   Format = "webp"; Quality = 90 }
  @{ Name = "favicon-32.png";         Size = 32;   Format = "png";  Quality = 100 }
  @{ Name = "apple-touch-icon.png";   Size = 180;  Format = "png";  Quality = 100 }
)

function Convert-WithMagick {
  param($Src, $Dst, $Size, $Format, $Quality)
  $cmd = if ($Format -eq "webp") {
    @("magick", $Src, "-resize", "${Size}x${Size}", "-strip", "-define", "webp:method=6", "-quality", "$Quality", $Dst)
  } else {
    @("magick", $Src, "-resize", "${Size}x${Size}", "-strip", "-quality", "$Quality", $Dst)
  }
  & $cmd[0] @($cmd[1..($cmd.Length-1)])
  return $LASTEXITCODE -eq 0
}

function Convert-WithSharp {
  param($Src, $Dst, $Size, $Format, $Quality)
  $code = @"
const sharp = require('sharp');
sharp('$Src')
  .resize($Size, $Size, { fit: 'contain', background: { r:0,g:0,b:0,alpha:0 } })
  .$Format({ quality: $Quality, effort: 6 })
  .toFile('$Dst')
  .then(() => process.exit(0))
  .catch(e => { console.error(e); process.exit(1); });
"@
  $tmp = Join-Path $env:TEMP "kfd-sharp-$(Get-Random).js"
  Set-Content -Path $tmp -Value $code -Encoding UTF8
  & npx --yes -p sharp node $tmp
  $result = $LASTEXITCODE -eq 0
  Remove-Item $tmp -ErrorAction SilentlyContinue
  return $result
}

# Wybierz strategię konwersji
$converter = $null
if ($haveMagick) {
  $converter = "magick"
  Write-Host "Using: ImageMagick" -ForegroundColor Green
} elseif ($haveNpx) {
  $converter = "sharp"
  Write-Host "Using: sharp (via npx, pierwsze uruchomienie pobierze ~30 MB)" -ForegroundColor Green
} else {
  Write-Host "ERROR: Brak dostepnego narzedzia do konwersji obrazow." -ForegroundColor Red
  Write-Host ""
  Write-Host "Zainstaluj jedno z (zalecam ImageMagick):"
  Write-Host "  winget install ImageMagick.ImageMagick"
  Write-Host "  -- lub --"
  Write-Host "  Zainstaluj Node.js z https://nodejs.org/ (npx bedzie dostepne)"
  exit 1
}

# Konwertuj
$successCount = 0
$failedCount = 0
$totalSourceBytes = (Get-Item $sourcePath).Length
$totalOutputBytes = 0

foreach ($t in $targets) {
  $dst = Join-Path $outDir $t.Name
  $shortDst = $dst.Replace("$repoRoot\", "").Replace("\", "/")

  Write-Host -NoNewline ("  -> {0,-26}" -f $shortDst)

  $ok = $false
  try {
    if ($converter -eq "magick") {
      $ok = Convert-WithMagick -Src $sourcePath -Dst $dst -Size $t.Size -Format $t.Format -Quality $t.Quality
    } elseif ($converter -eq "sharp") {
      $ok = Convert-WithSharp -Src $sourcePath -Dst $dst -Size $t.Size -Format $t.Format -Quality $t.Quality
    }
  } catch {
    $ok = $false
    Write-Host " FAIL ($($_.Exception.Message))" -ForegroundColor Red
  }

  if ($ok -and (Test-Path $dst)) {
    $sizeKB = [math]::Round((Get-Item $dst).Length / 1KB, 1)
    $totalOutputBytes += (Get-Item $dst).Length
    Write-Host " ${sizeKB} KB" -ForegroundColor Green
    $successCount++
  } else {
    Write-Host " FAIL" -ForegroundColor Red
    $failedCount++
  }
}

Write-Host ""
Write-Host "==> Podsumowanie:" -ForegroundColor Cyan
Write-Host "  Sukces:           $successCount / $($targets.Count)"
Write-Host "  Zrodlo:           $([math]::Round($totalSourceBytes / 1KB, 1)) KB"
Write-Host "  Wynik (suma):     $([math]::Round($totalOutputBytes / 1KB, 1)) KB"
if ($successCount -eq $targets.Count) {
  Write-Host ""
  Write-Host "OK. Wszystkie assety wygenerowane." -ForegroundColor Green
  Write-Host "Nastepny krok:"
  Write-Host "  git add img/"
  Write-Host "  git commit -m 'feat: add optimized logo assets'"
  Write-Host "  git push"
} else {
  Write-Host ""
  Write-Host "Nie wszystkie pliki sie wygenerowaly — sprawdz logi powyzej." -ForegroundColor Yellow
  exit 1
}
