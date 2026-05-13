# CLAUDE.md — kontekst projektu dla przyszłych sesji

Plik dla przyszłych iteracji Claude Code w tym repo. Kluczowe decyzje, konwencje, patterns z poprzednich sesji.

## Samouczenie — meta-reguła

Pod koniec każdej sesji wyciągnij wnioski i dopisz jako nowy `## NN. Tytuł` w sekcji Patterns niżej. Co wyciągać: findy Copilota, własne obserwacje, UX feedback klienta, observations o procesie. Format: anty-pattern → wzorzec → kiedy. Po dopisaniu commit + push.

---

## Czym jest projekt

Statyczna strona-wizytówka firmy KFDIAMENT Obrębski Motyka Spółka jawna (cięcie i wiercenie diamentowe betonu, wyburzenia konstrukcji, cała Polska, siedziba: Grybów, Grunwaldzka 9). Hosting: Cloudflare Pages (free tier), domena: kfdiament.pl. Remote: `fr4gles/kfdiament_website`.

## Stack — świadome ograniczenia

NIE jest to JS-framework. Świadomie:

- Jeden plik `index.html` (HTML+CSS+JS inline, ~3000 linii, ~100 KB). Nie rozbijać bez dobrego powodu.
- Vanilla JS (~180 linii: mailto generator, email obfuscation, hamburger z focus trap, scroll progress, IntersectionObserver).
- Bez build-stepu, bez `package.json`, bez npm/yarn/pnpm.
- Self-hosted woff2 w `/fonts/` — Big Shoulders + Manrope + JetBrains Mono (variable, latin + latin-ext, 6 plików, ~180 KB). NIE Google Fonts CDN (perf + GDPR).
- Bez CSS frameworków, bez bibliotek JS.

Powód: Cloudflare Pages preset = `None`, build pusty, output `/`. Wartość setupu = prostota.

## Struktura plików

```
.
├── index.html                — cała strona (~80 KB)
├── _headers                  — Cloudflare HTTP headers (security + cache)
├── README.md                 — dokumentacja dla człowieka
├── COMPARISON.md             — raport vs diamtar.pl
├── CLAUDE.md                 — TEN PLIK
├── robots.txt, sitemap.xml
├── .gitignore
├── scripts/
│   └── optimize-logo.ps1     — PNG → WebP w 3 rozmiarach (magick → ffmpeg → sharp)
├── fonts/                    — self-hosted variable woff2
│   ├── big-shoulders-latin.woff2          57 KB
│   ├── big-shoulders-latin-ext.woff2      44 KB
│   ├── manrope-latin.woff2                24 KB
│   ├── manrope-latin-ext.woff2            15 KB
│   ├── jetbrains-mono-latin.woff2         31 KB
│   └── jetbrains-mono-latin-ext.woff2     11 KB
└── img/
    ├── README.md             — workflow assetów
    ├── logo.png              — master (500×500, nowe min. 512×512)
    ├── logo.webp             — 512×512 (nav/footer via <picture>)
    ├── logo-1024.webp        — hero LCP, preload
    ├── logo-96.webp          — nav/footer thumbnail
    ├── favicon-32.png
    ├── apple-touch-icon.png  — 180×180
    ├── og.jpg                — 1200×630 social (ffmpeg)
    └── realizacja-XX.jpg     — opcjonalnie: galeria
```

## Branch strategy

- Główny branch to `master` (NIE `main`). Nie zmieniać.
- Praca na `feat/...`, `fix/...`, PR-y do `master`. Pierwszy branch: `feat/landing-page`.

## Paleta kolorów

Wszystkie kolory w CSS custom properties w `:root` w `<style>` w `index.html`. Nie hardkodować hex w komponentach — używać `var(--accent)` itd.

| zmienna | hex | rola |
|---|---|---|
| `--bg` | `#f5f1e8` | warm cream paper (główne tło, klimat betonu/papieru) |
| `--bg-2` | `#ebe5d6` | sekcje alternujące (kraft) |
| `--bg-3` | `#ddd4bf` | inset / głębsze surfaces |
| `--fg` | `#1a1614` | warm near-black (honoruje czerń logo) |
| `--muted` | `#5c5346` | warm graphite — drugorzędny tekst |
| `--line` | `#c9bfa6` | hairline border |
| `--line-strong` | `#8a7d5e` | strong divider, stroke SVG ikon |
| `--accent` | `#a8842c` | antique brass — primary gold (kontrast 4.6:1 = AA) |
| `--accent-hover` | `#7d5f1c` | deeper bronze, hover/active |
| `--accent-2` | `#c9a85a` | jaśniejszy gold (borders, highlights) |
| `--accent-deep` | `#5d4416` | darkest bronze (stamps, embossed) |

Decyzja: NIE Hilti red. Klient pokazał logo (gold-on-black piła z K&F monogramem), paleta zpivotowana pod brand identity. Dark theme wariant w komentarzu na początku `<style>`.

## Typografia (self-hosted)

- Big Shoulders Display (variable wght 500-900 + opsz 10-72) — display sans, industrial DNA. Dobrane po porównaniu z Bricolage Grotesque i Hanken Grotesk. Latin Extended-A z polskimi ogonkami (ą, ę, ł, ń, ó, ś, ź, ż). BRAK italic — używamy `color: var(--accent)` + heavier weight na `<em>`.
- Manrope — body. Geometryczny humanist sans, kontrast z condensed Big Shoulders.
- JetBrains Mono — etykiety techniczne (`/ 01`, spec lines). NIE do długich akapitów.

Hero h1: trzy-linijkowy, `clamp(2.8rem, 9.5vw, 8.2rem)`. Środkowe słowo `outline` (text-stroke jako em-units `0.018em` — skaluje proporcjonalnie, bez per-breakpoint overrides). Aktywne na wszystkich rozmiarach przez `@supports (-webkit-text-stroke)`. Trzecie `accent` (gold weight 900, BEZ italic).

Hero brand byline (między h1 a sub):
```html
<p class="hero__byline">
  <span class="hero__byline-text">
    <span class="hero__byline-key">Realizuje</span>
    <span class="hero__byline-brand">KFDIAMENT</span>
    <span class="hero__byline-sub">Obrębski · Motyka Sp. j.</span>
  </span>
</p>
```
Z 4px gold gradient bar `::before`. Architektoniczna tabliczka znamionowa.

## Struktura sekcji

1. Nav — fixed top, blur, 72px wysokości. 2 osobne klikalne phone buttons (`.nav__phones > .nav__phone × 2`). Breakpointy nav-specific: 1080px (linki znikają → hamburger), 820/640/540/460/400/360px (degradacja phones: 2 → 1 → 0). Mobile menu (≤1080px): hamburger toggle, slide-down z `.mobile-menu__phones` (2 gold pill buttons z pełnymi numerami) + 5 section links. `inert` (nie `hidden`) blokuje fokus/AT natychmiast. Focus trap: gdy menu open, `<main>` dostaje `inert`.
2. Hero — full vh, slow-spin logo absolute clamp(360px, 52vw, 720px), anchor do `--maxw` container, opacity 0.18, blend mode multiply. h1 3-spanowy: "Specjaliści w cięciu i wierceniu" / **"techniką diamentową"** (accent gold) / "betonu i żelbetu." + brand byline (link do #kontakt) + hero__sub (otwarcie "Zajmujemy się profesjonalną obróbką betonu oraz żelbetu...") + 2 CTA + 4 stats (Ø800mm / PL / 2. gen. DST 20-CA / Beton+Żelbet), grid 4→2 responsive, center-aligned (gap robi separator).
3. Marquee ticker — czarny pas między hero a o-nas, gold-accented "Cięcie diamentowe · Wiercenie do ⌀800mm · Wyburzenia · Sprzęt Hilti · Cała Polska" (5 items + duplikat dla seamless loop). 38s linear infinite, pauza on hover.
4. `#o-nas` — bg-2 + background "01", 5 akapitów + corner-card "Dlaczego my?". Para 2 mówi **"wiele lat doświadczenia"** — świadoma decyzja klienta (2026-05-14), NIE "3 lata" mimo że niektóre PDF-y od klienta nadal podają "3 lata". Patrz pattern #48.
5. `#uslugi` — bg + "02", 4 service cards (Cięcie betonu, Wiercenie otworów, Wyburzenia, Kotwy chemiczne) + banner "Inne zapytanie" /05 (full-width dark CTA, mailto query `ogolne`). Grid `repeat(auto-fit, minmax(320px, 1fr))` daje 4 kolumny ≥1280px, 2×2 medium, 1 col mobile.
6. `#realizacje` — bg-2 + "03", 3 gal-card z placeholderami.
7. `#sprzet` — bg-3 gradient, "HILTI" w tle, 2 spec-items (DST 20-CA piła ścienna 2. gen., DD500-CA wiertnica do ⌀800mm).
8. `#kontakt` — bg + "05". `section__head--kontakt` to 2-kolumnowy grid `1fr 1.3fr`: h2 z lewej, brand byline (`hero__byline--static`) z prawej. Niżej 4 contact-blocks (Telefon, E-mail, Siedziba z "Otwórz w Mapach Google" pill button, Zasięg) + 5 mailto-cards (Cięcie / Wiercenie / Wyburzenia / Kotwy chemiczne / Inne zapytanie — piąty `mailto-card--inverted`) + iframe Google Maps. Blok Zasięg ma 4-kolumnowy grid `52px auto auto 1fr` — ikona | text pair | mini-mapa | buffer 1fr. Mini-mapa Polski z Natural Earth 110m (45 punktów, CC0), `clamp(78px, 14vw, 110px)`, znika ≤380px.
9. Footer — bg-2, brand+dane+kontakt.

Persistent UI:
- Scroll progress bar — `<div id="scrollProgress">`, 3px gold gradient, requestAnimationFrame na scroll (passive).
- Klikalne section labels — `<a class="section-label" href="#sekcja">01 — Nazwa</a>`. Hover: indicator line 36→56px + accent-hover.

## Mailto-cards — pattern

Sekcja kontakt NIE ma `<form>`. 4 karty `<a class="mailto-card" data-mailto="KEY">`.

Kluczowy detal: fallback `href="#kontakt"` (NIE `mailto:...`) — żeby HTML nie zawierał literalnego mailto: dla botów. JS replace'uje na pełny `mailto:?subject=...&body=...` z `encodeURIComponent`.

Klucze: `ciecie`, `wiercenie`, `wyburzenia`, `ogolne`. `ogolne` ma tytuł "Inne zapytanie" w Kontakt, ale w Usługach triggeruje banner "Skontaktuj się z nami / Niestandardowy zakres prac".

Subjects (bez nawiasów/symboli):
- `Wycena - Cięcie betonu - zapytanie ze strony`
- `Wycena - Wiercenie otworów - zapytanie ze strony`
- `Wycena - Wyburzenia - zapytanie ze strony`
- `Kontakt ze strony - zapytanie ogólne`

Body kończy się stopką `Wiadomość wysłana ze strony kfdiament.pl`.

## Email obfuscation — pattern

Maile NIE w plain text w HTML. Pattern w 3 miejscach (contact-block, mailto note, footer):

```html
<a class="email-obf" data-u="kontakt" data-d="kfdiament.pl"
   href="#kontakt" rel="nofollow">kontakt [at] kfdiament [dot] pl</a>
```

JS po starcie:
```js
document.querySelectorAll('a.email-obf').forEach(el => {
  const addr = el.dataset.u + '@' + el.dataset.d;
  el.setAttribute('href', 'mailto:' + addr);
  el.textContent = addr;
  el.removeAttribute('rel');
});
```

JSON-LD email zostaje plain (SEO LocalBusiness wymaga). Cloudflare Email Obfuscation (Dashboard → Scrape Shield) jako warstwa 2 — pokrywa też JSON-LD.

## `_headers` (Cloudflare Pages)

Plik w root automatycznie czytany. Definiuje:
- Security: HSTS, X-Frame-Options, Referrer-Policy, Permissions-Policy (blokuje camera/mic/geolocation + FLoC opt-out)
- Long cache 1 rok immutable: `/fonts/*`, `/img/*` (CORS dla fontów)
- Short cache 600s must-revalidate: HTML root + `*.html`
- Medium cache 3600s: `robots.txt`, `sitemap.xml`

Semantyka: reguły mergeowane per żądanie (nie first-match — patrz pattern #37).

## Dane firmy (hardkodowane — NIE zmieniać bez prośby klienta)

- Nazwa: KFDIAMENT Obrębski Motyka Spółka jawna
- NIP: `7343669611`
- REGON: `54455908000000`
- Adres: Grunwaldzka 9, 33-330 Grybów
- Telefony: `+48 511 478 232`, `+48 511 478 182`
- E-mail: `kontakt@kfdiament.pl` (zawsze małą literą)

Dane w wielu miejscach: nav 2 phone buttons, footer, contact-blocks, JSON-LD `LocalBusiness`, hero stats. Przy zmianie — `grep` po starej wartości i podmieniaj wszędzie.

## Mapa Polski (Zasięg block)

Real outline z Natural Earth 110m admin_0_countries (CC0). Source: `github.com/martynafford/natural-earth-geojson`. 45 punktów, Mercator-projected (lon_scale = cos(lat_mid) dla ~52°N). ViewBox 0 0 24 24, stroke-width 0.55. Path: `M 21.35 5.25 L 21.44 6.76 ...`. NIE rysować ręcznie — Polak rozpozna fake.

Generator (jeśli update): pobrać `ne_110m_admin_0_countries.json` z [martynafford/natural-earth-geojson](https://github.com/martynafford/natural-earth-geojson), Pythonem wyekstrahować MultiPolygon Polski, sprojektować Mercatorem, zaokrąglić do 2 miejsc, złożyć SVG path. Aktualny path inline w `index.html` w bloku Zasięg.

## SEO setup

- 3 schematy JSON-LD: `LocalBusiness` z `hasOfferCatalog` (3 `Service`), `Organization`, `WebSite`
- Open Graph + Twitter Card (`og:image` 1200×630 — plik do dorobienia)
- `<title>` + `<meta description>` + canonical + hreflang `pl` + `x-default`
- `robots.txt` + `sitemap.xml`
- Semantic HTML5, hierarchia h1 → h2 → h3, alt texts WCAG
- `prefers-reduced-motion` obsługiwane (hero, marquee, slow-spin)

## Performance — micro-optymalizacje

- CSS inline (0 external stylesheets)
- JS inline na końcu body (nie blokuje render)
- Self-hosted fonts + preload (`big-shoulders-latin`, `big-shoulders-latin-ext`, `manrope-latin`)
- `<link rel="preload" as="image">` na logo-1024.webp (LCP candidate)
- `fetchpriority="high"` + `decoding="async"` na hero logu
- `loading="lazy"` na footer img + map iframe + off-fold
- `<picture>` WebP + PNG fallback (nav, hero, footer)
- `prefers-reduced-motion` wycina animacje
- SVG noise jako data URI (zero requestów na grain)
- `_headers` długi cache dla fontów/images, krótki dla HTML

Po deployu spodziewany Lighthouse: 95-100 / 95-100 / 95-100 / 100.

## Czego NIE robić

- NIE dodawać `<form>` kontaktowego — mailto-cards są szybsze (pre-fill), tańsze (zero backendu), bezpieczniejsze (brak XSS/spam vector).
- NIE Google Maps JS API — używamy darmowego embed iframe (`maps.google.com/maps?q=...&output=embed`).
- NIE emoji jako ikony — wszystkie ikony to SVG inline (Lucide-style, stroke).
- NIE stockowe obrazki — placeholdery CSS.
- NIE cookies banner / Google Analytics — Cloudflare Web Analytics (bez cookies, bez RODO).
- NIE `#000`/`#fff` — używać `var(--fg)` i `var(--bg)`.
- NIE rozbijać `index.html` na komponenty.
- NIE wracać do Google Fonts CDN — self-hosting świadomy (perf + GDPR).
- NIE rysować mapy Polski ręcznie — używać Natural Earth path.

---

# Patterns & lessons learned

## 1. CSS Cascade Order — same-specificity pułapka

Anty: pisać override `.foo--variant` bez sprawdzenia gdzie w pliku jest base `.foo`. W tym projekcie: `.contact-block--zasieg` w linii 754, base `.contact-block` w 1428 — same specificity (1 klasa), later wins → base nadpisywał override.

Pattern: sprawdź gdzie jest base (Grep), umieszczaj override PO base. Albo bumpuj specificity (`.foo.foo--variant` = 2 klasy = wygrywa). Stosować przy każdym `.block--modifier` w CSS > 500 linii.

## 2. Font self-hosting — anti-FOUT

Anty: `font-display: optional` z Google CDN (100ms za mało cross-origin, fallback permanent). `font-display: swap` z Google CDN — visible FOUT.

Pattern: self-host woff2 (`<link rel="preload">` + same-origin) + `font-display: swap` w @font-face + fallback @font-face z `size-adjust` + `ascent-override` (BigShouldersFallback z Arial Narrow / Bahnschrift Condensed). Variable woff2 = jeden plik per `unicode-range`, `font-weight: 100 900` w @font-face.

## 3. Pobieranie woff2 z Google Fonts

Anty: `curl fonts.googleapis.com/css2?...` → domyślnie TTF.

Pattern:
```bash
curl -H "User-Agent: Mozilla/5.0 ... Chrome/120" -H "Accept: text/css" \
  "https://fonts.googleapis.com/css2?family=..." | grep woff2
```
Z headerami Chrome dostajesz woff2 per unicode-range. Pobierz tylko `latin` i `latin-ext` (skip cyrillic/greek/vietnamese).

## 4. Image optimization — ffmpeg jako ImageMagick fallback

Anty: zatrzymanie gdy `magick` nieobecny.

Pattern: ffmpeg często JEST (dep innych narzędzi). `ffmpeg -i in.png -vf scale=W:H:flags=lanczos -c:v libwebp -quality 85 out.webp` = ~84% redukcja vs PNG. `scripts/optimize-logo.ps1` ma 3 paths: magick → ffmpeg → sharp.

## 5. `<picture>` z WebP + PNG fallback

Anty: sam `<img src="x.webp">` — brak fallback.

Pattern:
```html
<picture>
  <source srcset="img/logo-1024.webp" type="image/webp">
  <img src="img/logo.png" alt="" class="hero__logo">
</picture>
```
Plus `loading="lazy"` off-fold + `fetchpriority="high"` na LCP + `decoding="async"`.

## 6. Email obfuscation — 3 warstwy

Anty: literalny `mailto:foo@bar.pl` (bot food) ALBO JS-only (łamie SEO).

Pattern:
1. Human-readable "foo [at] bar [dot] pl" w HTML + `data-u`/`data-d` attrs
2. JS po DOMContentLoaded rebuduje href + textContent
3. JSON-LD email plain (Google wymaga)
4. Cloudflare Email Obfuscation jako warstwa 2 (Dashboard)

## 7. Real geographic data > hand-drawn

Anty: SVG kraju rysowany z głowy — wygląda fake.

Pattern: Natural Earth (CC0) `admin_0_countries` 110m + Python ekstrakcja MultiPolygon → Mercator (`lon_scale = cos(lat_mid)`) → SVG path. Repo: `martynafford/natural-earth-geojson`. ~5 KB SVG, real shape, public domain.

## 8. Visual verification loop

Anty: commit + push CSS/font changes bez sprawdzenia renderu.

Pattern: Playwright MCP `browser_navigate` + `browser_take_screenshot` po każdej znaczącej zmianie wizualnej. Dla `.reveal`: `browser_evaluate` z `forEach(el => el.classList.add('is-visible'))` przed screenshot (fullPage screenshot nie triggeruje IntersectionObserver).

## 9. Decisive pivot on aesthetic failure

Anty: bronienie wyboru fontu/koloru "bo competent" gdy user mówi "nudne", "brzydka".

Pattern: subjective design rejections to hard signal — wywal kierunek, nie tweakuj. Iteracja Anton→Antonio→Oswald→Bricolage→Big Shoulders była tańsza niż obrona Antonio.

## 10. Mobile responsive — viewport-specific tuning

Anty: jeden mobile breakpoint (np. 600px).

Pattern: kilka dla różnych iPhone'ów — 640px (general), 540px (compact), 440px (iPhone 14 Pro Max 430px CSS), 380px (small). Dla text-stroke na hero h1: em-units (0.018em) skalują, plus media query overrides dla problematic sizes (0.8px <768, 0.6px <480).

## 11. PR target branch verification

Anty: założenie że default = `main`.

Pattern: `git ls-remote --heads origin` lub `gh repo view --json defaultBranchRef` przed PR. Repos sprzed 2020 (jak ten) często `master`.

## 12. Galeria realizacji — placeholdery vs zdjęcia

Galeria ma 3 karty `.gal-card.placeholder` z CSS-owym patternem (3 warianty). Aby podmienić na zdjęcie:
1. Wrzucić do `img/realizacja-XX.jpg` (WebP, 800×1000px, aspect 4:5)
2. Usunąć klasę `placeholder` + opcjonalnie `placeholder-pattern-N`
3. Dodać inline `style="background-image: url('img/realizacja-XX.jpg')"`

Komentarz HTML w pliku — szukaj `=== EDYCJA GALERII ===`.

## 13. Reduced-motion completeness — każda animacja ma override

Anty: `scroll-behavior: smooth` (lub `transition`, `animation`) globalnie bez override w `@media (prefers-reduced-motion: reduce)`. WCAG fail i Copilot to wyłapuje.

Pattern: każda dyrektywa ruchowa ma zerujący odpowiednik. Audyt: grep `scroll-behavior|animation:|transition:` i sprawdź czy każde ma reduced-motion counter-rule.

```css
@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
  .hero__byline, .reveal { opacity: 1; animation: none; }
  .hero__logo { animation: none; }
}
```

## 14. Fixed nav wymaga scroll-padding-top

Anty: fixed top nav 72px + `<a href="#section">` → anchor scroll chowa nagłówek pod navem.

Pattern: `html { scroll-padding-top: calc(var(--nav-h) + 12px); }` — 12px buffer. Wszystkie anchor links respektują nav height bez per-section `scroll-margin-top`.

## 15. Skip-link target + focus visibility (WCAG 2.4.7)

Anty A: `<a class="skip-link" href="#main">` celuje w `<main>` bez `tabindex` — fokus zostaje na linku, Tab nawiguje od skip-linku zamiast w treści.
Anty B: `<main tabindex="-1">` + `outline: none` → fokus niewidoczny (WCAG fail).

Pattern: `<main id="main" tabindex="-1">` + outline zastąpiony subtelnym inset box-shadow band u góry (nie outline wokół ogromnego elementu):
```css
main[tabindex="-1"]:focus-visible {
  outline: none;
  box-shadow: inset 0 4px 0 0 var(--accent);
}
```

## 16. Touch hover prevention z feature query

Anty: `:hover { transform: scale(1.05) }` → sticky hover na touch (long-press trzyma styl do kolejnego tapa).

Pattern: każdy transform-based hover w `@media (hover: hover) and (pointer: fine) { ... }`.
```css
@media (hover: hover) and (pointer: fine) {
  .btn:hover { transform: translateY(-2px); background: var(--accent-hover); }
}
```

## 17. Symmetric safe-area-inset w landscape z notchem

Anty: `padding-inline: max(20px, env(safe-area-inset-left))` — tylko lewy notch. iPhone landscape z prawym notchem → content na okrągłym kącie.

Pattern: rozdziel start/end (logical properties, bonus dla RTL):
```css
padding-inline-start: max(20px, env(safe-area-inset-left));
padding-inline-end:   max(20px, env(safe-area-inset-right));
```

## 18. Progressive enhancement > `@supports not`

Anty: `@supports not (-webkit-text-stroke: 1px black)` — fallback nadal używa nie-wspieranej property; z `color: transparent` przeglądarki bez wsparcia renderują niewidoczny tekst.

Pattern: default rule = uniwersalnie wspierana wersja. Efekt zaawansowany w pozytywnej feature query:
```css
.hero__title .outline { color: var(--fg); }
@supports (-webkit-text-stroke: 1px black) {
  .hero__title .outline {
    color: transparent;
    -webkit-text-stroke: 0.018em var(--fg);
  }
}
```
Plus gating ≥769px dla efektów które na mobile wyglądają źle (antialiasing thin stroke).

## 19. Format-specific image library options

Anty: `sharp.$Format({ quality: 85, effort: 6 })` dynamicznie — działa dla webp, throws/ignoruje dla png (PNG nie ma `effort`).

Pattern: branch options per format:
```powershell
$opts = if ($Format -eq 'webp') { "{ quality: $Quality, effort: 6 }" }
       else { "{ compressionLevel: 9 }" }
```

## 20. ffmpeg aspect-ratio preservation

Anty: `scale=W:H` wymusza wymiary → stretching dla nie-kwadratowych źródeł.

Pattern: `scale=W:H:force_original_aspect_ratio=decrease,format=rgba,pad=W:H:(ow-iw)/2:(oh-ih)/2:color=black@0`. Zachowuje proporcje, dopaduje do kwadratu z transparentnym tłem (`format=rgba` przed `pad` — pad domyślnie bez alpha jeśli źródło RGB).

## 21. Cross-platform PowerShell temp dir

Anty: `$env:TEMP` — Windows-only. macOS/Linux pwsh: TEMP unset.

Pattern: `[System.IO.Path]::GetTempPath()` — respektuje `TMPDIR` (Unix), `$env:TEMP/$env:TMP` (Windows). Helper `Get-TempDir`.

## 22. HTML entity encoding w atrybutach

Anty: `<iframe src="...?a=1&b=2">` — surowe `&` w atrybucie. Walidator protestuje; niektóre parsery interpretują `&b` jako entity.

Pattern: zawsze `&amp;` w atrybutach (`src`, `href`, `value`):
```html
<iframe src="https://maps.google.com/maps?q=X&amp;t=&amp;z=15&amp;output=embed">
```
W JS template stringach `&` OK (to nie HTML). URL-encode wartości (`%20`, `%C3%B3`) niezależnie.

## 23. Detect every binary actually invoked

Anty: gate `sharp` na `$haveNpx`, potem wewnątrz wywołać `npm install` i `node`. Volta / nvm-windows może shimnąć jeden bez drugiego.

Pattern: wykryj każdy binary który kod realnie wywołuje. Dla sharp: `$haveNode -and $haveNpm`. W błędzie nazwij brakujący precyzyjnie:
```powershell
$missing = if (-not $haveNode) { 'node' } else { 'npm' }
Write-Host "ERROR: Brakuje: $missing"
```

## 24. PR description rotuje — sync z kodem przy pivotach

Anty: PR description pisany na branch creation, nieupdate'owany gdy implementacja pivotuje. Myli reviewerów.

Pattern: po każdym dużym pivocie `gh pr edit <N> --body "$(cat <<'EOF' ... EOF)"` z aktualnym opisem. Checkboxy "Pending" → odznaczać po ukończeniu.

## 25. Copilot review cycle workflow

Pattern (operacyjny): każdy push triggeruje review Copilota na nowym commicie (1-3 min). Reviews często powtarzają stare findings ze starymi ID — attached do nowego commitu, ale issues już naprawione.

Cykl:
1. Push commit z fixem
2. Wait for new review: `until COMMIT=$(gh pr view 1 --json reviews --jq '... .commit.oid[0:7]') && [ "$COMMIT" = "<latest>" ]; do sleep 20; done` (run_in_background, timeout 420s)
3. `gh api .../pulls/N/comments` — filtruj po najnowszych ID
4. Fix + commit + push tylko realnie nowe
5. `resolve all` przez GraphQL po fixie żeby UI był czysty
6. Repeat aż review pusty

```bash
UNRESOLVED=$(gh api graphql -f query='{ repository(owner:"X",name:"Y") { pullRequest(number:1) { reviewThreads(first:50) { nodes { id isResolved } } } } }' --jq '.data.repository.pullRequest.reviewThreads.nodes | map(select(.isResolved == false)) | .[].id')
for tid in $UNRESOLVED; do gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$tid\"}) { thread { isResolved } } }" > /dev/null; done
```

## 26. Trust but verify Copilot — hallucinated occurrences

Anty: Copilot mówi "typo na liniach X i Y" → poprawiasz ślepo oba. Czasem druga to halucynacja.

Pattern: zawsze `grep` przed fixem. Match actual count vs claimed. Fix tylko realne, ignoruj phantomy.

## 27. User aesthetic feedback = HARD PIVOT (wzmocnienie #9)

Pattern (rozszerzony): subjective rejections to NIE feedback do tweakowania, to sygnał do wywalenia kierunku.

Przykłady tej sesji:
- "wypierdek" o shorthand → drop entirely
- "tytuł brzydki" o text-stroke mobile → gate behind `min-width: 769px`
- "tak nie może być" o byline pchającym cards → relokuj entirely
- "nudne / kompetentne" o Antonio → pivot na Big Shoulders Display

Subiektywne odrzucenie = rozszerz search space, nie kompromisuj w wąskim.

## 28. Nav hierarchy pod presją szerokości — brand-first, phones-degrade

Project-specific (KFDIAMENT) hierarchia ważności nav elementów przy malejącej szerokości:
1. Brand wordmark + mark — zawsze widoczne, zawsze 26px, identity anchor.
2. Hamburger — widoczny gdy links hidden (≤1080px).
3. Phones — degradują pierwsze: 2 → 1 (≤640px) → 0 (≤460px). Hidden phones dostępne w `.mobile-menu__phones`.
4. Section links — hidden ≤1080px.

Footer brand ma osobny scoping (38-46px `.footer .brand__mark`); nav scope zachowuje stały rozmiar.

## 29. Phone digits never wrap

Anty: numer "511 478 232" pęka na 2 linie przy tight widths.

Pattern: globalna reguła `a[href^="tel:"] { white-space: nowrap; }` łapie wszystkie miejsca. Plus defensive `white-space: nowrap` na `.nav__phone` i `.mobile-menu__phone` (cyferki w `<span>` wewnątrz `<a>`).

## 30. Nav breakpoint niezależny od section grid

Pattern: projekt używa 900px jako universal mobile/desktop dla sekcji. NAV potrzebuje wyższego (1080px) — 5 linków + 2 phones + brand + maxw padding wymaga ~1100px breathing room.

Reguła: media query 1080 dla nav-only (`.nav__links display: none`, `.nav__burger display: inline-flex`, mobile-menu desktop-hide guard, JS resize-close). Sekcji nie bumpować na 1080 — tylko nav.

## 31. Anchor decorative element na max-width, nie na viewport

Anty: `right: -8vw` na slow-spin logo — na 4K (3840px) viewport `-8vw = -307px`, element drifuje daleko poza content column.

Pattern: anchor do `--maxw` container's right edge:
```css
.hero__logo {
  right: calc(max(0px, (100vw - var(--maxw)) / 2) - 8vw);
}
```
Na viewport ≤ `--maxw` zachowuje stare `-8vw`. Na szerszych ekranach prawa krawędź docisnięta do container, element zostaje w content width.

## 32. Belt-and-suspenders dla user requirements

Pattern: gdy klient mówi "X zawsze musi być w stanie Y" → enforce w >1 warstwie.

Przykład email lowercase:
1. HTML: `data-u="kontakt" data-d="kfdiament.pl"` (lowercase obfuscation)
2. CSS: `a.email-obf { text-transform: lowercase; }`
3. JS: `(el.dataset.u + '@' + el.dataset.d).toLowerCase()`

Trzy niezależne warstwy — nawet jeśli edytor wpisze "Kontakt@...", output zostaje lowercase.

## 33. Inverted CTA = section banner consistency

Project-specific: każde "Inne zapytanie" / general inquiry CTA (mailto-card, banner, button) używa inverted:
- `background: var(--fg)` (dark)
- `color: var(--bg)` (cream)
- arrow / accent: `var(--accent-2)`
- hover: `background: var(--accent-deep)`

Implementacja przez `.mailto-card--inverted` (sekcja 5) lub `.service-other` banner (sekcja 2).

## 34. Mobile hamburger menu — phones-section pattern (struktura)

Project-specific HTML/CSS dla `.mobile-menu`:
```
.mobile-menu (absolute top: 100%, slides down)
├── .mobile-menu__phones (2-col grid >420px, stack ≤420px)
│   ├── .mobile-menu__phone (gold pill, full "+48 511 478 232")
│   └── .mobile-menu__phone
├── (hairline divider via border-bottom)
└── .mobile-menu__links (ul z 5 section links)
    └── li.a → <span class="mobile-menu__num">01</span><span>O nas</span>
```

JS toggle (close, scrim click, Escape, link click, resize ≥1081 → close) — patrz #41 dla aktualnego `inert`-based wzorca + focus trap. Wcześniejsza wersja `hidden` + `setTimeout(240ms)` superseded.

## 35. JS reflow trick dla transition po `hidden`

Anty: `element.hidden = false; element.classList.add('open');` w tym samym frame — transition nie triggeruje (browser nie widzi initial state).

Pattern: force reflow między display change a state change:
```js
menu.hidden = false;
void menu.offsetWidth;
menu.setAttribute('data-open', 'true');
```

## 36. PR description sync via `gh pr edit`

Pattern (operacyjny): `gh pr edit <N> --body "$(cat <<'EOF' ... EOF)"` przy każdym pivocie. HEREDOC single-quoted (`'EOF'`) chroni przed shell expansion. Jeden source of truth w PR body.

## 37. Cloudflare _headers — semantics merge, nie first-match

Pattern: reguły z pasującymi globami są mergeowane per żądanie. Konflikt nazwy headera (np. `Cache-Control`) — wygrywa bardziej specyficzny glob (`/fonts/*` nadpisuje `/*`). Security headers z `/*` (HSTS itp.) przechodzą do `/fonts/*` i `/img/*`, bo te bardziej specyficzne ustawiają tylko Cache-Control + CORS.

Mit "first-match wins" błędny — nie kopiuj security headers do każdego bloku, wystarczą w `/*`.

## 38. iframe sandbox — minimum necessary

Pattern dla third-party iframe (Google Maps):
```html
<iframe
  src="..."
  loading="lazy"
  referrerpolicy="no-referrer-when-downgrade"
  sandbox="allow-scripts allow-same-origin allow-popups"
  title="...">
</iframe>
```
NIE `allow-popups-to-escape-sandbox` (redundant + ryzyko). NIE `allow-forms allow-top-navigation` chyba że potrzebne. `referrerpolicy` chroni privacy.

## 39. PDF/dokument od klienta = source of truth — check w obie strony

Anty: dostajesz PDF, sprawdzasz tylko "czy wszystko z PDF jest na stronie". Albo odwrotnie — bierzesz stronę i nie weryfikujesz z PDF.

Pattern: cross-check w obie strony:
1. PDF → site: czy claims/teksty/dane są reflektowane? (oczywiste)
2. Site → PDF: każdy claim na stronie bez odpowiednika w PDF jest podejrzany — mógł być wymyślony przez Claude w iteracji, zostać ze starej oferty, lub być copywritingiem do potwierdzenia.

Sprawdź: dane firmy (NIP, REGON, adres, telefony, email — exact), lista usług (nazwy i kolejność), statystyki/claims marketingowe (każda liczba ma źródło), spec sprzętu (modele, średnice), mottos/tagline'y (exact phrasing), stylistyczne wymyślenia copywritera.

Format raportu:
```
KRYTYCZNE ROZBIEŻNOŚCI — decyzja klienta
BRAKUJĄCE NA STRONIE (z PDF) — drobne
NA STRONIE — claims spoza PDF (sprawdzić u klienta)
ZGODNE
```
Z linijkami i propozycją per item. NIE wprowadzaj zmian automatycznie — klient decyduje.

Tej sesji: PDF miał "Wyburzenia" jako 3. usługę, strona "Osadzanie kotew chemicznych". PDF "3 lata", strona "wieloletnie". PDF bez "bezwibracyjne cięcie" ani "Akcesoria oryginalne Hilti". Wszystkie wyleciały po decyzji klienta.

## 40. Mailto template fields w nawiasach, nie po em-dash

Anty: "Rodzaj materiału — beton lub żelbet" w mailto body. Em-dash + przykłady wyglądają jak część nazwy pola.

Pattern: przykłady w nawiasach okrągłych, krótkie:
- "Rodzaj materiału (beton, żelbet, mur)"
- "Sposób wywozu gruzu (w naszym zakresie czy klienta)"

Nawiasy sygnalizują "podpowiedzi, nie część nazwy". Łatwiejsze do skasowania jeśli klient nie chce w final message.

## 41. `inert` zamiast `hidden` dla animowanych paneli

Anty: `hidden` toggled przez `setTimeout` po fade-out → ~240ms okienko gdzie panel jest visually invisible ale tabbable (WCAG 2.4.3 Focus Order fail).

Pattern: `inert` blokuje Tab + AT natychmiast, element nadal renderuje — animacja gra normalnie.
```js
const closeMenu = () => {
  menu.setAttribute('inert', '');
  menu.removeAttribute('data-open');
};
const openMenu = () => {
  menu.removeAttribute('inert');
  void menu.offsetWidth;
  menu.setAttribute('data-open', 'true');
};
```
Browser support: Chrome 102+, Firefox 112+, Safari 15.5+. Starsze: graceful degradation (`inert` ignored, fokus normalnie, animacja działa).

## 42. CSS RGB-triplet variable dla theme-aware rgba()

Anty: hardkodowanie `rgba(245, 241, 232, 0.92)` w komponentach gdy paleta w CSS variables. Theme switch wymaga search-replace.

Pattern: para `--bg` (hex) + `--bg-rgb` (RGB triplet), używaj `rgba(var(--bg-rgb), 0.92)`. Komentarz "MUSI być w sync" jako safety net.
```css
:root {
  --bg:     #f5f1e8;
  --bg-rgb: 245, 241, 232;
  --fg:     #1a1614;
  --fg-rgb: 26, 22, 20;
}
.nav { background: rgba(var(--bg-rgb), 0.92); }
.scrim { background: rgba(var(--fg-rgb), 0.32); }
```

Modern alt (Chrome 111+/FF 113+/Safari 16.2+): `color-mix(in srgb, var(--bg) 92%, transparent)` — bez RGB duplikatu. Wymaga `@supports` fallback dla starszych.

## 43. Unicode special chars wymagają explicit font-family chain

Anty: Unicode special char (`⌀` U+2300, math operators, arrows) bez font-family chain. Self-hosted woff2 subsety często pokrywają Basic Latin + Latin-Ext, NIE Misc Technical / Math Operators. Browser fallback → losowy default serif (Times New Roman), wygląda obco.

Pattern: chain do fontów które realnie mają glyph:
```css
.ic-diameter {
  font-family:
    'Cambria Math',        /* Windows */
    'STIX Two Math',       /* cross-platform math */
    'Lucida Sans Unicode', /* Windows legacy */
    'Segoe UI Symbol',     /* Windows */
    'DejaVu Sans',         /* Linux */
    sans-serif;
}
```

Alternative: dodać `unicode-range: U+2300-23FF` subset do self-hosted woff2 (~5-10 KB), jednolite cross-platform rendering.

## 44. Symbol z math fontu w caps context — bump font-size 1.4-1.5em

Anty: Cambria Math / STIX renderują technical symbols na x-height (jak małe litery). W ALL-CAPS lub digit-heavy ("WIERCENIE DO ⌀800MM") symbol wygląda subscripted — ~70% wysokości sąsiadów.

Pattern: `font-size: 1.4-1.5em` żeby match cap-height (stosunek x-height/cap-height ~0.7, więc 1/0.7 ≈ 1.43). Plus `line-height: 1`, `vertical-align` tweak.
```css
.ic-diameter {
  font-family: 'Cambria Math', /* ... */;
  font-size: 1.5em;
  line-height: 1;
  vertical-align: -0.05em;
  margin-inline: 0.02em;
}
```
Em-unit utrzymuje proporcję spójną przez konteksty (hero stat, marquee, mailto desc) — jedna reguła, działa wszędzie.

## 45. Grid 1fr cells dają nierówne odstępy przy różnej szerokości treści

Anty: `grid-template-columns: repeat(N, 1fr)` na liście gdzie content się waha (krótkie "PL" obok długiego "Ø800mm"). Każda komórka równa, content at start of cell — empty space różnej szerokości po prawej = wizualny chaos. `border-right` jako separator pogłębia (border at cell edge, daleko od treści).

Pattern — 2 opcje:

A. Flex-column z `align-items: center` — content wycentrowany w 1fr, optycznie spaced równo:
```css
.hero__stats { display: grid; grid-template-columns: repeat(5, 1fr); gap: 0 clamp(12px, 1.6vw, 24px); }
.stat { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 10px; }
```

B. `auto` cols + `justify-content: space-between` — komórki tight do treści, browser distributes leftover jako equal gaps:
```css
.list { display: flex; justify-content: space-between; align-items: baseline; }
```

A = symetryczne kolumny (responsive grid 5→3→2 wrap działa). B = equal gaps, kolumny różnej szerokości (flat line, no wrapping). NIE używać border-right jako separator z 1fr + variable content — gap jest lepszy.

## 46. Strukturuj kod żeby revert był łatwy

Pattern: user może zmienić zdanie po feedback rounds. Przykład:
- R1: "outline brzydki na mobile" → dodaj `@media (min-width: 769px)` gate
- R5: "daj outline wszędzie" → revert media query (3 deleted lines)

Code structured well (em-based stroke + jeden `@supports` + jeden `@media` wrapper) = one-line revert. Code structured badly (hardkodowane px, wiele media queries, per-element overrides) = godzinny refactor.

Zasady:
- em/rem/% zamiast px gdy proporcje skalują z context
- jedna `@supports`/`@media` zamiast warstw warunków
- progressive enhancement default = uniwersalnie wspierane, feature query opt-in (#18)
- mobile-specific overrides oddzielne od enhancement layer

## 47. Unicode + font fallback vs inline SVG

Saga ze znakiem ⌀:
1. Latin Ø (U+00D8) w Big Shoulders → wygląda jak przekreślone zero
2. Inline SVG per użycie → pixel-perfect, ale duplikat HTML 6×
3. SVG sprite + `<use href="#id"/>` → DRY, ale kreska wewnątrz koła (nie engineering convention)
4. Unicode ⌀ (U+2300) + font fallback → system math font renderuje prawdziwy diameter sign. ALE x-height → bump 1.5em

Final lesson: dla typografii/symboli prefer Unicode + font fallback OVER inline SVG, gdy:
- Symbol standardowy Unicode (math/technical/punctuation)
- System fonty często go mają (Cambria Math, STIX, Segoe UI Symbol)
- Wiele kontekstów o różnych font-size (Unicode skaluje jak litera)

SVG wybierz gdy:
- Symbol nie-standardowy (custom brand glyph)
- Visual MUST be pixel-perfect cross-platform
- Animacja/interakcja na symbolu

Unicode + font fallback wymaga: (1) explicit font-family chain (#43), (2) czasem font-size bump w caps context (#44).

## 48. PDF od klienta vs wcześniejsze świadome decyzje — nie regresować

Anty: dostajesz nowy PDF z treścią od klienta, traktujesz go jako pełny source of truth, regresujesz wcześniejsze decyzje klienta (które same odbiegały od starszych PDF-ów). PDF często wysyłany "dla porządku" zawiera nieaktualne fragmenty, które klient sam zmienił przy poprzedniej iteracji.

Pattern: cross-check PDF z `git log` ostatnich dni. Każda rozbieżność PDF ↔ strona ma **dwa potencjalne źródła**:
1. PDF świeższy → klient chce update (przyjmij)
2. Strona świeższa → świadoma pivot klienta, PDF stale (zostaw)

Rozpoznać po commit history: jeśli ostatnie commity dotykały tej linii, to klient zmienił świadomie → PDF stale na tym punkcie. Przykład: commity `a1cbdee`, `a3e0fb1`, `3bc3818` z 2026-05-14 zmieniły "3 lata" → "wiele lat" → drop ze stats. Nowy PDF wraca do "3 lata" — to **regresja**, nie update.

Format raportu rozbieżności (rozszerzenie #39): dodaj kolumnę **"site newer than PDF — sprawdź czy to świadomy pivot"**. Klient potwierdza per item, czy chce revert do PDF czy zostaje wersja site.

Project-specific dla KFDIAMENT (zatwierdzone 2026-05-14):
- **"wiele lat doświadczenia"** w `O nas` para 2 — NIE "3 lata" (mimo że niektóre PDF mówią 3)
- Hero stats: brak liczby lat doświadczenia (drop podczas `a1cbdee`)

## Skróty / przyspieszacze

- Lokalny preview: `python -m http.server 8000` → `http://localhost:8000`
- Walidacja schema: [validator.schema.org](https://validator.schema.org/)
- Rich results test: [search.google.com/test/rich-results](https://search.google.com/test/rich-results)
- Lighthouse: Chrome DevTools → Lighthouse → Analyze
- Playwright MCP do regression testing po zmianach
