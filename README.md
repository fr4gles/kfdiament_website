# KFDIAMENT — strona-wizytówka

Statyczna jednoplikowa strona-wizytówka firmy **KFDIAMENT Obrębski Motyka Spółka jawna**
(cięcie i wiercenie diamentowe betonu, osadzanie kotew chemicznych — cała Polska).

## Stack i charakter

- Czysty HTML5 + CSS + vanilla JS (jeden plik `index.html`)
- Self-hosted variable woff2 z `/fonts/`: **Big Shoulders Display**, **Manrope**, **JetBrains Mono** (latin + latin-ext, ~180 KB total). Bez Google Fonts CDN — wszystko same-origin (lepszy performance + GDPR-friendly, zero requestów do third-party).
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
w domyślnej przeglądarce. Wszystko zadziała oprócz jednego drobiazgu:

- Niektóre przeglądarki blokują `file://` iframe → mapa Google **może się
  nie pokazać** (otworzy się dopiero po wrzuceniu na realny serwer)

Fonty są self-hosted z `/fonts/` (same-origin) — ładują się tak samo
przy `file://` jak na produkcji.

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

Skrypt auto-wykrywa narzędzia (preferowana kolejność):
**ImageMagick** (`winget install ImageMagick.ImageMagick`) → **ffmpeg**
(`winget install Gyan.FFmpeg`, zwykle już zainstalowany jako zależność
innych narzędzi) → **sharp** przez `npx`/`npm` (wymaga Node.js,
auto-instaluje się jednorazowo do `%TEMP%`). Skrypt używa pierwszego
dostępnego — wszystkie 3 dają identyczny output. Generuje:

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

### 3) Cloudflare Pages — pierwszy deploy

1. Wejdź na [dash.cloudflare.com](https://dash.cloudflare.com/) → **Workers & Pages → Create application → Pages → Connect to Git**
2. Autoryzuj GitHub, wybierz repozytorium `fr4gles/kfdiament_website`
3. Konfiguracja buildu:

   | Pole | Wartość |
   |---|---|
   | Project name | `kfdiament` (lub dowolne) |
   | Production branch | `master` |
   | Framework preset | **None** |
   | Build command | _(puste)_ |
   | Build output directory | `/` |
   | Root directory | `/` |
   | Environment variables | _(brak — strona jest 100% statyczna)_ |

4. **Save and Deploy**. Po ~30 sekundach dostaniesz adres `https://kfdiament.pages.dev` (lub `kfdiament-xyz.pages.dev` jeśli nazwa zajęta).

Każdy `git push origin master` triggeruje nowy deploy automatycznie. Każdy push do innych branchy daje **preview deployment** z osobnym URL — dobre do testowania PR-ów.

### Co plik `_headers` robi automatycznie

W repozytorium jest plik `_headers` — Cloudflare Pages go automatycznie czyta i ustawia HTTP nagłówki:

- **Security**: HSTS (force HTTPS rok+), X-Content-Type-Options, Referrer-Policy, Permissions-Policy (blokuje camera/microphone/geolocation, opt-out z FLoC)
- **Cache**: fonty/obrazki = 1 rok immutable (Cloudflare CDN cache), HTML = 10 min must-revalidate (szybkie propagowanie zmian)

Nie wymaga konfiguracji — działa po pierwszym deployu.

### 4) Konfiguracja Cloudflare po pierwszym deployu (KRYTYCZNE)

Po tym jak strona już chodzi na `kfdiament.pages.dev`, zrób te 4 kroki w Cloudflare Dashboard:

#### A. Email Address Obfuscation (anti-spam)

Dashboard → Twoja strefa → **Scrape Shield → Email Address Obfuscation: ON**

Cloudflare automatycznie obfuskuje WSZYSTKIE emaile w HTML (włącznie z JSON-LD)
zamieniając na `<a data-cfemail="hex...">[email&nbsp;protected]</a>` + auto-deszyfracja
przez ich JS po stronie usera. Bot scrapery widzą hex junk. **2. warstwa** ochrony
po `email-obf` pattern z `index.html`.

#### B. SSL/TLS — Full (strict)

Dashboard → SSL/TLS → Overview → **Full (strict)**.
Plus włącz: **Always Use HTTPS**, **HTTP Strict Transport Security (HSTS)** (już mamy w `_headers`, ale CF dodaje warstwę edge).

#### C. Cloudflare Web Analytics (darmowe, bez RODO bannera)

Dashboard → Analytics & Logs → **Web Analytics → Add a site**.
Skopiuj snippet i wstaw do `index.html` przed `</body>` (lub włącz "Automatic setup" jeśli korzystasz z Cloudflare proxy).

Daje:
- Real User Monitoring (RUM): Core Web Vitals (LCP, INP, CLS) z prawdziwego ruchu
- Stats odwiedzin bez cookies, bez bannera RODO
- Top pages, referrers, countries

#### D. Auto Minify + Brotli + HTTP/3

Dashboard → Speed → Optimization:
- **Brotli**: ON (kompresja lepsza niż gzip)
- **Early Hints**: ON (preload HTTP/3 hints)
- **0-RTT Connection Resumption**: ON
- Auto Minify: HTML/CSS/JS już są zminifikowane (inline) — można zostawić ON, nie zaszkodzi

---

### 5) Custom domain `kfdiament.pl`

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

Powtórz dla 3 kart. Galeria wygląda najlepiej gdy wszystkie 3 zdjęcia mają
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

### Po pierwszym deployu zrób (full post-deploy checklist):

**SEO setup** (godzina pracy, jednorazowo):

1. **Google Search Console** ([search.google.com/search-console](https://search.google.com/search-console)):
   - Dodaj `kfdiament.pl` jako property (domain property zalecane)
   - Zweryfikuj: rekord TXT w Cloudflare DNS (kopiuj-wklej)
   - **Submit sitemap**: `https://kfdiament.pl/sitemap.xml`
   - Włącz email alerts dla błędów crawlowania
2. **Bing Webmaster Tools** ([bing.com/webmasters](https://www.bing.com/webmasters)):
   - Import property z Search Console (1 klik), submit sitemap
3. **Google Business Profile** ⭐ NAJWAŻNIEJSZE dla lokalnego biznesu
   ([business.google.com](https://www.google.com/business/)):
   - Dodaj firmę: nazwa "KFDIAMENT Obrębski Motyka Sp. j.", kategoria "Firma budowlana / wyburzeniowa", adres Grunwaldzka 9 33-330 Grybów, telefony, godziny pracy, link do `kfdiament.pl`
   - Wrzuć zdjęcia (z realizacji, sprzętu, zespołu) — Google to indeksuje
   - Po weryfikacji listing pojawia się w **Google Maps Local Pack** + Knowledge Panel
4. **Walidacja Schema.org**: [validator.schema.org](https://validator.schema.org/) z URL — sprawdza 3 schematy (LocalBusiness, Organization, WebSite)
5. **Rich Results Test**: [search.google.com/test/rich-results](https://search.google.com/test/rich-results) — pokaże jak Google renderuje rich snippets

**Performance verification** (15 min, jednorazowo):

6. **Lighthouse** (Chrome DevTools → Lighthouse): mobile + desktop, expected 95-100/95-100/95-100/100
7. **PageSpeed Insights** ([pagespeed.web.dev](https://pagespeed.web.dev)): real-world Core Web Vitals
8. **Cloudflare Speed Test** (Dashboard → Speed → Test) — measurement z różnych regionów

**Sprawdzenie maila** (5 min):

9. Otwórz `kfdiament.pl`, kliknij `kontakt@kfdiament.pl` w sekcji Kontakt → powinien otworzyć klient poczty z poprawnym adresem
10. Kliknij każdą z 4 mailto-cards → każda powinna dać inny temat + szablon body
11. **View page source** (Ctrl+U) — wyszukaj `kontakt@kfdiament.pl` → powinno być **tylko w JSON-LD**, nie w body HTML (Cloudflare obfuscation + nasz `email-obf` pattern)

**Maintenance (raz na miesiąc / kwartał):**

12. Search Console → Coverage (czy wszystko zaindeksowane bez błędów)
13. Cloudflare Analytics → Top pages + referrers (skąd przychodzą)
14. Google Business Profile → odpowiadać na opinie + dodawać nowe zdjęcia z realizacji
15. Aktualizacja fontów: `scripts/optimize-logo.ps1` (jeśli zmiana loga), self-hosted woff2 nie wymaga update — będą działać latami

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
- **Self-hosted fonty** (variable woff2) preloadowane z `/fonts/` — zero third-party requestów, same-origin <50 ms load
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
