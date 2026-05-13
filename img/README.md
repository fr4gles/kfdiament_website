# Folder na grafiki

## Wymagane pliki (po uruchomieniu skryptu optymalizacji)

| Plik | Generowany przez | Wymiary | Status |
|---|---|---|---|
| `logo.png` | **Ty zapisujesz** | min. 512×512 | **źródło — wymagane** |
| `logo.webp` | `scripts/optimize-logo.ps1` | 512×512 | wymagane (auto) |
| `logo-1024.webp` | skrypt | 1024×1024 | wymagane (auto — hero LCP) |
| `logo-96.webp` | skrypt | 96×96 | wymagane (auto — nav/footer) |
| `favicon-32.png` | skrypt | 32×32 | wymagane (auto) |
| `apple-touch-icon.png` | skrypt | 180×180 | wymagane (auto) |
| `og.jpg` | **dorób ręcznie** | 1200×630 | do dorobienia (social preview) |
| `realizacja-01.jpg` … | **ręcznie** | 800×1000 (4:5) | opcjonalne (galeria) |

> Pamiętaj: nazwa repo to `kfdiament_website` (nie `kfdiament_webiste`). Lokalna ścieżka projektu zawiera literówkę `D:\kfdiament_webiste\` ale GitHub remote ma poprawną nazwę.

## Workflow

1. **Zapisz oryginał logo** (klient czatu → "Zapisz obraz jako…") jako:
   ```
   D:\kfdiament_webiste\img\logo.png
   ```
   Zalecane: 512×512 PNG, przezroczyste tło.

2. **Uruchom skrypt optymalizacji** z katalogu głównego repo:
   ```powershell
   pwsh -File scripts/optimize-logo.ps1
   ```
   Skrypt produkuje wszystkie WebP + favicony naraz. Auto-wykrywa
   `ImageMagick` (zalecane) lub `sharp` przez `npx`. Jeśli żadnego
   nie ma — wskazuje komendę instalacji.

3. **Odśwież stronę** (Ctrl+F5).

## Dlaczego WebP

| Format | Wielkość (512×512 logo) | Wsparcie |
|---|---|---|
| PNG (oryginał) | ~80-150 KB | 100% |
| **WebP** (q=85) | **~15-30 KB** | 97%+ przeglądarek (od 2020) |
| AVIF | ~10-20 KB | 92%+ (od 2022) |

HTML używa `<picture>` z WebP source + PNG fallback — więc nawet bez
WebP strona działa, ale 97% userów dostanie ~5× mniejszy obrazek.

## Galeria realizacji

Patrz `README.md` w głównym katalogu repo, sekcja "Galeria realizacji".
