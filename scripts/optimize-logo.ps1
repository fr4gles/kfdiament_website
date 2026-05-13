<#
.SYNOPSIS
  Optymalizuje img/logo.png do kompletu plików (WebP + PNG fallback + favicony).

.DESCRIPTION
  Bierze img/logo.png (źródło, zalecane 512x512 lub większe) i tworzy:
    img/logo.webp           — 512x512 WebP (główny używany w nav, footer)
    img/logo-1024.webp      — 1024x1024 WebP (hero, LCP candidate)
    img/logo-96.webp        — 96x96 WebP (nav thumbnail, retina-ready)
    img/favicon-32.png      — 32x32 PNG favicon
    img/apple-touch-icon.png — 180x180 PNG (iOS bookmark icon)

  Skrypt PRÓBUJE kolejno: ImageMagick → ffmpeg → npx sharp.
  Jeśli żadne narzędzie nie jest dostępne — wyświetla instrukcję instalacji.

.EXAMPLE
  pwsh -File scripts/optimize-logo.ps1
  pwsh -File scripts/optimize-logo.ps1 -Source "C:\Downloads\moje-logo.png"

.NOTES
  Wymaga JEDNEGO Z poniższych narzędzi (zalecane: ffmpeg lub ImageMagick):
    1. ImageMagick                    — https://imagemagick.org/
       Instalacja: winget install ImageMagick.ImageMagick
    2. ffmpeg (zwykle juz zainstalowane jako dependency innych narzedzi)
       Instalacja: winget install Gyan.FFmpeg
    3. Node.js + sharp (auto-install)
       Instalacja Node.js: winget install OpenJS.NodeJS
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

# Wykryj dostępne narzędzia (kolejność preferencji: magick → ffmpeg → sharp przez node+npm).
# sharp wymaga obu node + npm (do instalacji), nie samego npx — niektore Node-shimy
# (volta, nvm-windows) podstawia jeden bez drugiego, wiec sprawdzamy osobno.
$haveMagick = $null -ne (Get-Command magick -ErrorAction SilentlyContinue)
$haveFfmpeg = $null -ne (Get-Command ffmpeg -ErrorAction SilentlyContinue)
$haveNode   = $null -ne (Get-Command node   -ErrorAction SilentlyContinue)
$haveNpm    = $null -ne (Get-Command npm    -ErrorAction SilentlyContinue)
$haveSharp  = $haveNode -and $haveNpm

Write-Host "Available tools:"
Write-Host "  ImageMagick (magick): $haveMagick"
Write-Host "  ffmpeg:               $haveFfmpeg"
Write-Host "  node:                 $haveNode"
Write-Host "  npm:                  $haveNpm"
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

function Convert-WithFfmpeg {
  param($Src, $Dst, $Size, $Format, $Quality)
  # Zachowaj proporcje (force_original_aspect_ratio=decrease), potem dopaduj do kwadratu
  # przezroczystym tłem, żeby wynik mial dokladnie ${Size}x${Size} bez zniekształceń.
  # format=rgba przed pad — pad domyślnie nie ma alpha-channel jeśli źródło jest RGB.
  $filter = "scale=${Size}:${Size}:force_original_aspect_ratio=decrease:flags=lanczos,format=rgba,pad=${Size}:${Size}:(ow-iw)/2:(oh-ih)/2:color=black@0"
  if ($Format -eq "webp") {
    & ffmpeg -y -loglevel error -i $Src -vf $filter -c:v libwebp -quality $Quality -compression_level 6 $Dst
  } else {
    & ffmpeg -y -loglevel error -i $Src -vf $filter $Dst
  }
  return $LASTEXITCODE -eq 0
}

function Get-TempDir {
  # Cross-platform: [System.IO.Path]::GetTempPath() respektuje TMPDIR (Linux/macOS)
  # i ${env:TEMP}/${env:TMP} (Windows). $env:TEMP nie istnieje na pwsh dla Unix.
  return [System.IO.Path]::GetTempPath()
}

function Convert-WithSharp {
  param($Src, $Dst, $Size, $Format, $Quality)
  # Install sharp do tymczasowego katalogu (npx -p nie zawsze dziala z natywnymi modulami)
  if (-not $script:sharpDir) {
    $script:sharpDir = Join-Path (Get-TempDir) "kfd-sharp-pkg"
    if (-not (Test-Path (Join-Path $script:sharpDir "node_modules/sharp"))) {
      Write-Host "    (instaluje sharp jednorazowo do $script:sharpDir...)" -ForegroundColor DarkGray
      New-Item -ItemType Directory -Force -Path $script:sharpDir | Out-Null
      Push-Location $script:sharpDir
      try {
        & npm install --silent --no-save sharp 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
          throw "npm install sharp failed (exit code $LASTEXITCODE). Sprawdz polaczenie sieci / proxy / dostepnosc rejestru npm."
        }
      } finally { Pop-Location }
    }
  }
  # sharp options per format — webp ma `effort`, png ma `compressionLevel`.
  # Wspolne `quality` przekazujemy tylko dla webp; dla png lossless + max compression
  # (favicon-32 = ostry pixel art, kazda strata jakosci widoczna).
  $opts = if ($Format -eq 'webp') {
    "{ quality: $Quality, effort: 6 }"
  } else {
    "{ compressionLevel: 9 }"
  }
  $code = @"
const sharp = require('$($script:sharpDir.Replace('\','/'))/node_modules/sharp');
sharp('$($Src.Replace('\','/'))').
  resize($Size, $Size, { fit: 'contain', background: { r:0,g:0,b:0,alpha:0 } }).
  $Format($opts).
  toFile('$($Dst.Replace('\','/'))').
  then(() => process.exit(0)).
  catch(e => { console.error(e); process.exit(1); });
"@
  $tmp = Join-Path (Get-TempDir) "kfd-sharp-$(Get-Random).js"
  Set-Content -Path $tmp -Value $code -Encoding UTF8
  & node $tmp
  $result = $LASTEXITCODE -eq 0
  Remove-Item $tmp -ErrorAction SilentlyContinue
  return $result
}

# Wybierz strategię konwersji (kolejnosc preferencji: magick > ffmpeg > sharp).
# sharp wymaga jednoczesnie node + npm — jeden bez drugiego nie wystarczy.
$converter = $null
if ($haveMagick) {
  $converter = "magick"
  Write-Host "Using: ImageMagick" -ForegroundColor Green
} elseif ($haveFfmpeg) {
  $converter = "ffmpeg"
  Write-Host "Using: ffmpeg (libwebp + scaler)" -ForegroundColor Green
} elseif ($haveSharp) {
  $converter = "sharp"
  Write-Host "Using: sharp (pierwsze uruchomienie zainstaluje sharp do TEMP, ~30 MB)" -ForegroundColor Green
} elseif ($haveNode -or $haveNpm) {
  $missing = if (-not $haveNode) { 'node' } else { 'npm' }
  Write-Host "ERROR: Sciezka 'sharp' wymaga obu: node + npm. Brakuje: $missing" -ForegroundColor Red
  Write-Host "Zainstaluj pelny Node.js (zawiera npm): winget install OpenJS.NodeJS"
  exit 1
} else {
  Write-Host "ERROR: Brak dostepnego narzedzia do konwersji obrazow." -ForegroundColor Red
  Write-Host ""
  Write-Host "Zainstaluj jedno z (kazda opcja dziala):"
  Write-Host "  winget install ImageMagick.ImageMagick    (zalecane)"
  Write-Host "  winget install Gyan.FFmpeg                 (lekkie)"
  Write-Host "  winget install OpenJS.NodeJS               (ciezsze ale wszechstronne)"
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
    } elseif ($converter -eq "ffmpeg") {
      $ok = Convert-WithFfmpeg -Src $sourcePath -Dst $dst -Size $t.Size -Format $t.Format -Quality $t.Quality
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
