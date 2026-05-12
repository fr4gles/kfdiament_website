# KFDIAMENT — strona-wizytówka

Statyczna jednoplikowa strona-wizytówka firmy **KFDIAMENT Obrębski Motyka Spółka jawna**
(cięcie i wiercenie diamentowe betonu, osadzanie kotew chemicznych — cała Polska).

## Stack i charakter

- Czysty HTML5 + CSS + vanilla JS (jeden plik `index.html`)
- Google Fonts: **Big Shoulders Display**, **Manrope**, **JetBrains Mono**
- Bez frameworków, bez build-stepu, bez npm
- Hostowanie: GitHub + Cloudflare Pages (free tier)
- Design: premium industrial, paleta **antique brass + warm cream + warm black** (pod
  brand colors logo)

## Struktura plików

```
.
├── index.html       — cała strona (HTML + CSS + JS inline)
├── robots.txt       — pozwala indeksować, wskazuje sitemapę
├── sitemap.xml      — jeden URL (strona główna)
├── README.md        — ten plik
├── .gitignore       — system files, edytor, Cloudflare local
└── img/             — folder na assety graficzne (do uzupełnienia)
    ├── logo.png     — logo firmy (gold-on-black piła tarczowa, 512×512+)
    └── og.jpg       — Open Graph preview (1200×630)
```

## 👀 Lokalny podgląd (przed deployem)

Strona jest **w pełni statyczna** — nie wymaga żadnego serwera. Masz 3 opcje:

### Opcja 1 — najszybsza: double-click

W Eksploratorze Windows kliknij dwa razy na `index.html`. Otworzy się
w domyślnej przeglądarce. Wszystko zadziała oprócz dwóch drobiazgów:

- Google Fonts mogą się ładować ciut wolniej (brak prefetch przy `file://`)
- Niektóre przeglądarki blokują `file://` iframe → mapa Google **może się
  nie pokazać** (otworzy się dopiero po wrzuceniu na realny serwer)

### Opcja 2 — zalecana: prosty serwer HTTP

Jeśli masz Pythona (Windows ma najczęściej domyślnie):

```powershell
# w folderze repo:
python -m http.server 8000
```

Następnie otwórz [http://localhost:8000](http://localhost:8000). Tu wszystko
działa 1:1 jak na produkcji (w tym mapa Google).

Jeśli nie masz Pythona, ale masz Node.js:

```powershell
npx serve .
# albo
npx http-server -p 8000
```

### Opcja 3 — VS Code: Live Server

W VS Code zainstaluj rozszerzenie **Live Server** (Ritwick Dey) →
prawym przyciskiem na `index.html` → **Open with Live Server**.
Bonus: automatyczne odświeżanie po każdym zapisie.

### Co testować w przeglądarce

- [ ] Telefony są klikalne (kliknięcie otwiera „Zadzwoń do…")
- [ ] Maile są klikalne (mailto otwiera klienta poczty z gotowym tematem)
- [ ] Mapa Google się ładuje (tylko Opcja 2/3)
- [ ] Animacja reveal działa przy scrollowaniu
- [ ] Layout nie psuje się przy zmianie szerokości okna (resize)
- [ ] DevTools → Lighthouse → uruchom audyt

---

## 🚀 Pierwszy deploy w 3 krokach

### 1) Wrzuć logo + uruchom skrypt optymalizacji

**A)** Plik źródłowy zapisz jako `img/logo.png` (zalecane **512×512** lub większe,
PNG z przezroczystym tłem).

**B)** Uruchom skrypt optymalizacji — wygeneruje wszystkie warianty WebP + favicony
za jednym kliknięciem:

```powershell
pwsh -File scripts/optimize-logo.ps1
```

Skrypt auto-wykrywa narzędzia: **ImageMagick** (zalecane — `winget install ImageMagick.ImageMagick`)
albo **sharp** przez `npx` (wymaga Node.js). Generuje:

- `img/logo.webp` (512×512, ~20-30 KB) — używane w nav/footer/JSON-LD
- `img/logo-1024.webp` (1024×1024, ~50 KB) — hero LCP candidate, preload
- `img/logo-96.webp` (96×96, ~5 KB) — nav/footer thumbnail (retina)
- `img/favicon-32.png` — favicon
- `img/apple-touch-icon.png` (180×180) — iOS bookmark

HTML używa `<picture>` z WebP source + PNG fallback — jeśli **nie** uruchomisz
skryptu, strona dalej działa (PNG fallback), tylko bez performance win.

> **Dlaczego WebP**: ~5× mniejsze pliki niż PNG przy zachowaniu jakości. Wsparcie:
> 97%+ przeglądarek od 2020 r.

### 2) Push do GitHuba

Repozytorium jest już zainicjalizowane i wskazuje na zdalny remote.
Po wrzuceniu loga:

```bash
git add img/logo.png
git commit -m "feat: add company logo"
git push -u origin master
```

### 3) Cloudflare Pages

1. Wejdź na [dash.cloudflare.com](https://dash.cloudflare.com/) → **Workers & Pages → Create application → Pages → Connect to Git**
2. Podłącz repozytorium `fr4gles/kfdiament_website`
3. Konfiguracja buildu:

   | Pole | Wartość |
   |---|---|
   | Framework preset | **None** |
   | Build command | _(puste)_ |
   | Build output directory | `/` |
   | Root directory | `/` |

4. **Deploy**. Po ~30 sekundach dostaniesz adres `https://kfdiament-website.pages.dev`.

Każdy push do `master` triggeruje nowy deploy automatycznie.

### 4) Custom domain `kfdiament.pl`

W Cloudflare Pages:

1. Wejdź w deployment → **Custom domains → Set up a custom domain**
2. Wpisz `kfdiament.pl` (i osobno `www.kfdiament.pl`)
3. Cloudflare poprosi o ustawienie rekordów DNS:
   - Apex domain: rekord `CNAME` (przez Cloudflare DNS) na `kfdiament-website.pages.dev`
   - `www`: rekord `CNAME` na to samo
4. Jeśli domena jest już w Cloudflare DNS — pójdzie automatycznie. Jeśli jest
   gdzie indziej (np. nazwa.pl, OVH) — zmień nameservery na cloudflare'owe
   (poda je panel) **albo** dodaj rekordy ręcznie przez rejestratora.
5. SSL: Cloudflare wygeneruje certyfikat automatycznie (Let's Encrypt). Trwa to
   1-15 min.

## ✏️ Edycja treści

Cała treść siedzi w `index.html`. Najczęstsze edycje:

| Co zmienić | Gdzie szukać |
|---|---|
| Numery telefonów | szukaj `tel:+48511478232` (4 miejsca + JSON-LD) |
| E-mail | szukaj `kontakt@kfdiament.pl` (kilka miejsc) |
| Tekst hero | sekcja `<header class="hero">` |
| Tekst „O nas" | sekcja `id="o-nas"` |
| Opisy usług | sekcja `id="uslugi"` |
| Sprzęt Hilti | sekcja `id="sprzet"` |
| Adres / NIP | footer + JSON-LD `LocalBusiness` |
| Mailto-presety (subject/pola formularza) | obiekt `queries` w `<script>` na końcu |

## 🖼️ Galeria realizacji — podmiana placeholderów na zdjęcia

Sekcja **Realizacje** ma 3 karty z CSS-owymi placeholderami (industrialny pattern
z subtelnym czerwono-złotym akcentem). Aby podmienić na własne zdjęcia:

1. Wrzuć JPG/WEBP do folderu `img/` — np. `img/realizacja-01.jpg` (zalecane:
   **800×1000px**, aspect ratio 4:5)
2. W `index.html`, znajdź `<article class="gal-card placeholder reveal">`
3. **Usuń** klasy `placeholder` i `placeholder-pattern-2` / `placeholder-pattern-3`
4. **Dodaj** atrybut `style`:

```html
<!-- BYŁO: -->
<article class="gal-card placeholder reveal">

<!-- MA BYĆ: -->
<article class="gal-card reveal" style="background-image: url('img/realizacja-01.jpg')">
```

Powtórz dla 3 kart. Galleria wygląda najlepiej gdy wszystkie 3 zdjęcia mają
podobny ton kolorystyczny (np. wszystkie close-up'y betonu / sprzętu).

## 🗺️ Mapa Google

Mapa jest osadzona przez **darmowy embed iframe** Google Maps — **bez API key,
bez kosztów, bez limitów**. Mapa pokazuje siedzibę Grunwaldzka 9, Grybów.

Żeby zmienić lokalizację — w `index.html` znajdź `iframe src="https://maps.google.com/maps?q=...`
i zmień parametr `q=` na nowy adres (URL-encoded).

## 🔍 SEO

Strona ma kompletny SEO bundle:

- **Schema.org JSON-LD**: 3 schematy — `LocalBusiness` (z `hasOfferCatalog`
  i wszystkimi 3 usługami jako `Service`), `Organization`, `WebSite`
- **Open Graph + Twitter Card** — preview przy udostępnianiu w social media
- **`<title>`, `<meta description>`** — zoptymalizowane długości
- **Hreflang `pl` + `x-default`** — sygnał wersji językowej
- **Canonical URL**
- **`robots.txt`** — pozwala indeksować + wskazuje sitemap
- **`sitemap.xml`** — pojedynczy URL z `lastmod`
- **Strukturalna hierarchia** `h1 → h2 → h3` + semantyczny HTML (`<nav>`,
  `<header>`, `<section>`, `<article>`, `<aside>`, `<footer>`)
- **`alt`** na wszystkich obrazach (puste dla dekoracyjnych, gdzie wordmark
  obok dubluje znaczenie — zgodnie z WCAG)
- **`prefers-reduced-motion`** — wszystkie animacje wyłączone dla osób
  z preferencją zredukowanego ruchu

### Po pierwszym deployu zrób:

1. **Google Search Console** ([search.google.com/search-console](https://search.google.com/search-console)):
   - Dodaj `kfdiament.pl` jako property
   - Zweryfikuj (najprościej: rekord TXT w Cloudflare DNS)
   - Wyślij `sitemap.xml`
2. **Google Business Profile** ([business.google.com](https://www.google.com/business/)):
   - Dodaj firmę (NIP, adres, telefony, godziny, zdjęcia z realizacji)
   - To ważniejsze niż SEO klasyczne dla lokalnych usług budowlanych
3. **Walidacja Schema.org**: wrzuć URL na [validator.schema.org](https://validator.schema.org/)
4. **Walidacja Rich Results**: [search.google.com/test/rich-results](https://search.google.com/test/rich-results)

## 🎨 Kolory / brandowanie

Wszystkie kolory są w CSS custom properties w `:root`. Aktualna paleta — **antique brass + warm cream + warm black** — była dobrana pod brand colors logo.

```css
--accent:       #a8842c;   /* antique brass — primary gold */
--accent-hover: #7d5f1c;   /* deeper bronze */
--bg:           #f5f1e8;   /* warm cream paper */
--fg:           #1a1614;   /* warm near-black */
```

Pełen wariant **dark theme** (premium night) jest w komentarzu na początku
sekcji `<style>` w `index.html` — wystarczy podmienić 11 wartości w `:root` żeby
przełączyć.

## 📱 Responsive

Strona działa od **320px do 1920px+**. Główny breakpoint: **900px**. Drobne
adjustacje na **600px / 768px**. Hero logo znika na ekranach < 480px (headline
ważniejszy od dekoracji).

## ⚡ Performance

- **Bez build-stepu** = brak czasu kompilacji, deploy w sekundy
- **Brak runtime'u JS** poza vanilla mailto-generator + IntersectionObserver
- **Google Fonts** ładowane z `preconnect` (najszybsza metoda dla self-CDN-fontów)
- **`loading="lazy"`** na obrazach poniżej fold + iframe Google Maps
- Spodziewany **Lighthouse** (po deployu na Cloudflare):
  - Performance: 95-100
  - Accessibility: 95-100
  - Best Practices: 95-100
  - SEO: 100

## 🛠️ Co warto dodać dalej

- [ ] **`img/logo.png`** — wrzucić logo (warunek konieczny przed pierwszym pushem)
- [ ] **`img/og.jpg`** — preview 1200×630 do social media (logo + napis +
      industrialne tło). Bez tego linki w Messengerze/LinkedInie wyglądają nago.
- [ ] **Galeria** — 3+ realne zdjęcia z realizacji (zob. sekcja wyżej)
- [ ] **Favicon set** — obecnie jeden PNG; warto wygenerować pełen pakiet
      (`favicon.ico`, `apple-touch-icon.png` 180×180, `icon-192.png`,
      `icon-512.png`) np. przez [realfavicongenerator.net](https://realfavicongenerator.net)
- [ ] **Google Business Profile** — dla lokalnego SEO ważniejsze niż meta-tagi
- [ ] **Cloudflare Web Analytics** — darmowe, bez cookies, bez bannera RODO
      (Pages → Settings → Analytics)
- [ ] **Page rules** w Cloudflare — przekierowanie `www.kfdiament.pl` →
      `kfdiament.pl` (lub odwrotnie — wybierz jedno)
- [ ] **Strony usług** (rozważyć w przyszłości): `/ciecie-betonu`, `/wiercenie`,
      `/osadzanie-kotew` — osobne podstrony pomogą w SEO long-tail

## 🔗 Linki przydatne

- [Cloudflare Pages docs](https://developers.cloudflare.com/pages/)
- [Google Search Console](https://search.google.com/search-console)
- [Schema.org validator](https://validator.schema.org/)
- [Rich Results Test](https://search.google.com/test/rich-results)
- [Lighthouse — Chrome DevTools](https://developer.chrome.com/docs/lighthouse/overview/)

---

© 2026 KFDIAMENT Obrębski Motyka Spółka jawna · NIP 7343669611
