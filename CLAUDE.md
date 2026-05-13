# CLAUDE.md — kontekst projektu dla przyszłych sesji

Ten plik jest dla **przyszłych iteracji Claude Code** pracujących nad tym repozytorium. Zawiera kluczowe decyzje, konwencje, **patterns z poprzednich sesji**, i pułapki — żeby nie odkrywać tego samego za każdym razem.

## Czym jest projekt

Statyczna **strona-wizytówka** firmy **KFDIAMENT Obrębski Motyka Spółka jawna** (cięcie i wiercenie diamentowe betonu, osadzanie kotew chemicznych — działają na terenie całej Polski, siedziba: Grybów, Grunwaldzka 9).

Hostowana na **Cloudflare Pages** (free tier), domena docelowa: **kfdiament.pl**. GitHub remote: `fr4gles/kfdiament_website`.

## Stack — świadome ograniczenia

To **NIE jest** projekt JS-framework. Świadomie:

- **Jeden plik** `index.html` (HTML + CSS + JS inline, ~2400 linii, ~80 KB). Nie rozbijać na osobne pliki bez bardzo dobrego powodu.
- **Vanilla JS** — bez React, Vue, frameworków. Skrypt ma <150 linii.
- **Bez build-stepu** — `package.json` nie ma i nie powinno się pojawić.
- **Bez npm/yarn/pnpm**.
- **Self-hosted fonty (woff2)** w `/fonts/` — Big Shoulders + Manrope + JetBrains Mono (variable, latin + latin-ext, 6 plików, ~180 KB total). **NIE używamy Google Fonts CDN** — wszystko same-origin dla performance i GDPR.
- **Bez CSS frameworków** (Tailwind, Bootstrap, etc.).
- **Bez bibliotek JS** (lightbox, slider, animation library — wszystko vanilla).

**Powód:** Cloudflare Pages preset = `None`, build command pusty, output `/`. Cała wartość tego setupu pochodzi z prostoty.

## Struktura plików

```
.
├── index.html                — cała strona (jeden plik, ~80 KB)
├── _headers                  — Cloudflare HTTP headers (security + cache)
├── README.md                 — dokumentacja dla człowieka (deploy, post-deploy, edycja)
├── COMPARISON.md             — raport porównawczy vs diamtar.pl
├── CLAUDE.md                 — TEN PLIK (kontekst dla przyszłego Claude)
├── robots.txt                — pozwala indeksować + sitemap reference
├── sitemap.xml               — jeden URL (strona główna)
├── .gitignore
├── scripts/
│   └── optimize-logo.ps1     — PowerShell: PNG → WebP w 3 rozmiarach + favicony
│                                (auto-detect: magick → ffmpeg → sharp)
├── fonts/                    — self-hosted variable woff2
│   ├── big-shoulders-latin.woff2          57 KB
│   ├── big-shoulders-latin-ext.woff2      44 KB
│   ├── manrope-latin.woff2                24 KB
│   ├── manrope-latin-ext.woff2            15 KB
│   ├── jetbrains-mono-latin.woff2         31 KB
│   └── jetbrains-mono-latin-ext.woff2     11 KB
└── img/
    ├── README.md             — instrukcja workflow assetów
    ├── logo.png              — ŹRÓDŁO master (obecnie 500×500, zalecane min. 512×512 dla nowych źródeł)
    ├── logo.webp             — 512×512 WebP (nav/footer via <picture> WebP source)
    ├── logo-1024.webp        — 1024×1024 (hero LCP, preload)
    ├── logo-96.webp          — 96×96 (nav/footer thumbnail)
    ├── favicon-32.png        — favicon
    ├── apple-touch-icon.png  — 180×180 (iOS bookmark)
    ├── og.jpg                — 1200×630 social preview (wygenerowane przez ffmpeg)
    └── realizacja-XX.jpg     — opcjonalne: galeria
```

## Branch strategy

- **Główny branch nazywa się `master`** (NIE `main`). Nie zmieniać.
- Praca na branchach `feat/...`, `fix/...`, PR-y do `master`.
- Pierwszy branch: `feat/landing-page`.

## Paleta kolorów

**Wszystkie kolory siedzą w CSS custom properties w `:root`** w `<style>` w `index.html`. **Nigdy nie hardkodować hex codes w komponentach** — używać `var(--accent)` itd.

| zmienna | hex | rola |
|---|---|---|
| `--bg` | `#f5f1e8` | warm cream paper (główne tło, klimat betonu/papieru) |
| `--bg-2` | `#ebe5d6` | sekcje alternujące (kraft) |
| `--bg-3` | `#ddd4bf` | inset / głębsze surfaces |
| `--fg` | `#1a1614` | warm near-black (honoruje czerń logo) |
| `--muted` | `#5c5346` | warm graphite — drugorzędny tekst |
| `--line` | `#c9bfa6` | hairline border |
| `--line-strong` | `#8a7d5e` | strong divider, stroke SVG ikon |
| `--accent` | `#a8842c` | **antique brass** — primary gold (kontrast 4.6:1 na bg = AA) |
| `--accent-hover` | `#7d5f1c` | deeper bronze, hover/active |
| `--accent-2` | `#c9a85a` | jaśniejszy gold (borders, highlights) |
| `--accent-deep` | `#5d4416` | darkest bronze (stamps, embossed) |

**Kluczowa decyzja:** **NIE jest to Hilti red.** Wcześniejsza wersja była, ale klient pokazał logo (gold-on-black piła z K&F monogramem) i paleta została zpivotowana pod **brand identity logo**.

Dark theme variant siedzi w komentarzu na początku `<style>` w `index.html`.

## Typografia (self-hosted)

- **Big Shoulders Display** (variable wght 500-900 + opsz 10-72) — display sans, industrial DNA (Chicago "city of big shoulders"). Dobrany świadomie po porównaniu 3 alternatyw (Bricolage Grotesque, Hanken Grotesk). Latin Extended-A coverage z naturalnymi polskimi ogonkami (ą, ę, ł, ń, ó, ś, ź, ż). **BRAK italic w rodzinie** — używamy `color: var(--accent)` + heavier weight zamiast italic na `<em>`.
- **Manrope** — body. Geometryczny humanist sans, perfect contrast z condensed Big Shoulders display.
- **JetBrains Mono** — etykiety techniczne (`/ 01`, `01 — O nas`, spec lines). NIE używać do długich akapitów.

**Hero h1**: trzy-linijkowy, `clamp(2.8rem, 9.5vw, 8.2rem)`. Środkowe słowo `outline` (text-stroke jako **em-units** `0.018em` — skaluje z font-size, mobile breakpointy 0.8px/0.6px żeby na iPhone nie wyglądało zbyt grubo). Trzecie `accent` (gold weight 900, BEZ italic — brutalist purity).

**Hero brand byline** (między h1 a sub):
```html
<p class="hero__byline">
  <span class="hero__byline-text">
    <span class="hero__byline-key">Realizuje</span>           <!-- mono small -->
    <span class="hero__byline-brand">KFDIAMENT</span>          <!-- Big Shoulders 800, gold, big -->
    <span class="hero__byline-sub">Obrębski · Motyka Sp. j.</span>  <!-- Big Shoulders 600 -->
  </span>
</p>
```
Z 4px gold gradient bar `::before`. Architektoniczna tabliczka znamionowa.

## Struktura sekcji

1. **Nav** — fixed top, blur, 72px wysokości. **2 osobne klikalne przyciski telefonów obok siebie** (`.nav__phones > .nav__phone × 2`), nie jeden CTA. Responsive z 4 breakpointami (640/540/440/380px) żeby się mieściło na iPhone 14 Pro Max bez overflow.
2. **Hero** — full vh, slow-spin logo absolute (~52vw, opacity 0.18, blend mode multiply). Brand byline + 4 stats + 2 CTA + engraved h1.
3. **Marquee ticker** — czarny pas między hero a o-nas, gold-accented scrolling text "CIĘCIE · WIERCENIE · KOTWY · CAŁA POLSKA · BEZ KUCIA". 38s linear infinite, pauza on hover.
4. `#o-nas` — bg-2 + background "01" numeral, 5 akapitów + corner-card "Dlaczego my?"
5. `#uslugi` — bg + "02" numeral, 3 service cards + **banner "Inne zapytanie"** (full-width dark CTA pod kartami, mailto query `ogolne`)
6. `#realizacje` — bg-2 + "03" numeral, 3 gal-card z placeholderami
7. `#sprzet` — bg-3 gradient, ogromny "HILTI" w tle
8. `#kontakt` — bg + "05" numeral, 4 contact-blocks + 4 mailto-cards + iframe Google Maps. **Blok Zasięg** ma 3-kolumnowy grid: ikona | 2 pary label/value (Zasięg/Cała Polska + Baza/Grybów, Małopolska) | **mini-mapa Polski** (real outline z Natural Earth 110m, 45 punktów, CC0).
9. **Footer** — bg-2, brand+dane+kontakt

**Persistent UI**:
- **Scroll progress bar** — `<div id="scrollProgress">` na samej górze, 3px gold gradient, JS animuje width na scroll (requestAnimationFrame, passive)
- **Klikalne section labels** — `<a class="section-label" href="#sekcja">01 — Nazwa</a>` — każda etykieta to anchor link do swojej sekcji (URL hash updates, shareable deep-links). Hover: indicator line rozszerza się 36→56px + accent-hover color.

## Mailto-cards — pattern

Sekcja kontakt **NIE ma `<form>`**. Zamiast tego 4 karty `<a class="mailto-card" data-mailto="KEY">`.

**Kluczowy detal**: fallback `href="#kontakt"` (NIE `mailto:...`) — żeby HTML nie zawierał literalnego mailto: dla botów. JS na końcu pliku replace'uje href na pełny `mailto:?subject=...&body=...` z `encodeURIComponent`.

**Klucze obecnie:** `ciecie`, `wiercenie`, `kotwy`, `ogolne`. Karta `ogolne` ma tytuł **"Inne zapytanie"** w kontekście Kontakt, ale w sekcji Usługi ten sam klucz triggeruje banner "Skontaktuj się z nami / Niestandardowy zakres prac".

**Subjects** — bez nawiasów/symboli technicznych:
- `Wycena - Cięcie betonu - zapytanie ze strony`
- `Wycena - Wiercenie otworów - zapytanie ze strony`
- `Wycena - Osadzanie kotew - zapytanie ze strony`
- `Kontakt ze strony - zapytanie ogólne`

Body kończy się stopką `Wiadomość wysłana ze strony kfdiament.pl`.

## Email obfuscation — pattern

Maile NIE są w plain text w body HTML. Pattern w 3 miejscach (contact-block, mailto note, footer):

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

**JSON-LD email zostaje plain** (SEO LocalBusiness wymaga). Cloudflare Email Obfuscation (włączane w Dashboard → Scrape Shield) to dodatkowa warstwa 2 — pokrywa też JSON-LD.

## `_headers` (Cloudflare Pages)

Plik w root repo automatycznie czytany przez Cloudflare Pages. Definiuje:
- **Security**: HSTS, X-Frame-Options, Referrer-Policy, Permissions-Policy (blokuje camera/mic/geolocation + FLoC opt-out)
- **Long cache 1 rok immutable**: `/fonts/*`, `/img/*` (CORS allow-origin też dla fontów)
- **Short cache 600s must-revalidate**: HTML root + `*.html`
- **Medium cache 3600s**: `robots.txt`, `sitemap.xml`

Reguły aplikowane od góry — **pierwsza pasująca wygrywa**. Specific paths PRZED `/*` wildcard.

## Dane firmy (hardkodowane — NIE zmieniać bez prośby klienta)

- Nazwa: KFDIAMENT Obrębski Motyka Spółka jawna
- NIP: `7343669611`
- REGON: `54455908000000`
- Adres: Grunwaldzka 9, 33-330 Grybów
- Telefony: `+48 511 478 232`, `+48 511 478 182`
- E-mail: `kontakt@kfdiament.pl` (**zawsze małą literą**)

Te dane są w **wielu miejscach**: nav 2 phone buttons, footer, contact-blocks, JSON-LD `LocalBusiness`, hero stats, opisy. Gdy klient prosi o zmianę — `grep` po starej wartości i podmieniaj **wszędzie**.

## Mapa Polski (Zasięg block)

Real outline kartograficzny z **Natural Earth 110m admin_0_countries** (CC0, public domain). Source: `github.com/martynafford/natural-earth-geojson`. 45 punktów, Mercator-projected (lon_scale = cos(lat_mid) dla ~52°N Poland). ViewBox 0 0 24 24, stroke-width 0.55. Path zaczyna się od `M 21.35 5.25 L 21.44 6.76 ...`. **NIE rysować ręcznie** — Polak rozpozna fake'a.

Generator (jeśli trzeba update): Python script z `ne_110m_admin_0_countries.json`, w komentarzu w README dla `scripts/`.

## SEO setup

- 3 schematy JSON-LD: `LocalBusiness` z `hasOfferCatalog` (3 `Service`), `Organization`, `WebSite`
- Open Graph + Twitter Card (z `og:image` 1200×630 — plik DO DOROBIENIA)
- `<title>` + `<meta description>` + canonical + hreflang `pl` + `x-default`
- `robots.txt` + `sitemap.xml`
- Semantic HTML5, hierarchia h1 → h2 → h3, alt texts WCAG
- `prefers-reduced-motion` obsługiwane (animacje hero, marquee, slow-spin logo)

## Performance — micro-optymalizacje na miejscu

- **CSS inline** (0 zewnętrznych stylesheets)
- **JS inline na końcu body** (nie blokuje render)
- **Self-hosted fonts** + preload (`big-shoulders-latin`, `big-shoulders-latin-ext`, `manrope-latin`)
- **`<link rel="preload" as="image">` na logo-1024.webp** (LCP candidate)
- **`fetchpriority="high"` + `decoding="async"`** na hero logu
- **`loading="lazy"`** na footer img + map iframe + off-fold images
- **`<picture>` z WebP + PNG fallback** w 3 miejscach (nav, hero, footer)
- **`prefers-reduced-motion`** wycina animacje (marquee, slow-spin, fade-ins)
- **SVG noise** jako data URI (zero requestów na grain texture)
- **`_headers` długi cache** dla fontów/images, krótki dla HTML

**Po deployu spodziewany Lighthouse**: 95-100 / 95-100 / 95-100 / 100.

## Czego NIE robić

- **NIE dodawać `<form>` kontaktowego** — świadoma decyzja: mailto-cards są szybsze (pre-fill), tańsze (zero backendu), bezpieczniejsze (brak XSS/spam vector).
- **NIE dodawać Google Maps JavaScript API** — używamy **darmowego embed iframe** (`maps.google.com/maps?q=...&output=embed`).
- **NIE używać emoji jako ikon** — wszystkie ikony to SVG inline (Lucide-style, stroke style).
- **NIE dodawać stockowych obrazków** — placeholdery CSS na razie.
- **NIE dodawać cookies bannera ani Google Analytics** — Cloudflare Web Analytics (bez cookies, bez RODO).
- **NIE używać czerni `#000` i bieli `#fff`** — używać `var(--fg)` i `var(--bg)` (warm tones).
- **NIE rozbijać `index.html` na komponenty**.
- **NIE wracać do Google Fonts CDN** — self-hosting jest świadomy (performance + GDPR).
- **NIE rysować mapy Polski ręcznie** — używać Natural Earth path z `index.html`.

---

# Patterns & lessons learned (z sesji)

## 1. CSS Cascade Order — pułapka same-specificity

**Anti-pattern**: pisanie override `.foo--variant` z założeniem że "to override więc zadziała", bez sprawdzenia gdzie w pliku jest base `.foo`. W tym projekcie zdarzyło się: `.contact-block--zasieg { grid-template-columns: 3 cols }` był w linii 754, base `.contact-block { 2 cols }` w 1428. **Same specificity (1 klasa), later wins** → base nadpisywał override.

**Wzorzec**:
- Sprawdź gdzie jest base CSS (Grep), umieszczaj override PO base
- Albo bumpuj specificity (`.foo.foo--variant` = 2 klasy = wygrywa)

**Kiedy stosować**: każdy `.block--modifier` w pliku CSS > 500 linii.

## 2. Font self-hosting — strategia anti-FOUT

**Anti-pattern**:
- `font-display: optional` z Google CDN — 100ms za mało dla cross-origin, fallback PERMANENT
- `font-display: swap` z Google CDN — visible flash (FOUT)

**Wzorzec**:
- Self-host woff2 (`<link rel="preload">` + same-origin)
- `font-display: swap` w @font-face
- Plus fallback @font-face z `size-adjust` + `ascent-override` (BigShouldersFallback z Arial Narrow / Bahnschrift Condensed)

Variable woff2 = jeden plik per `unicode-range`, wszystkie wagi w środku, `font-weight: 100 900` w @font-face.

## 3. Pobieranie woff2 z Google Fonts

**Anti-pattern**: `curl fonts.googleapis.com/css2?...` → domyślnie dostajesz TTF URLs.

**Wzorzec**:
```bash
curl -H "User-Agent: Mozilla/5.0 ... Chrome/120" -H "Accept: text/css" \
  "https://fonts.googleapis.com/css2?family=..." | grep woff2
```

Z headerami Chrome dostajesz woff2 URLs + osobne pliki per unicode-range. Pobierz tylko `latin` i `latin-ext` (skip cyrillic/greek/vietnamese — Polski to ę/ą/ł).

## 4. Image optimization — ffmpeg jako ImageMagick fallback

**Anti-pattern**: zatrzymanie się gdy `magick` nie zainstalowany.

**Wzorzec**: check co JEST dostępne — ffmpeg często jest (jako dep innych narzędzi). `ffmpeg -i in.png -vf scale=W:H:flags=lanczos -c:v libwebp -quality 85 out.webp` = 84% redukcja vs PNG. Skrypt `scripts/optimize-logo.ps1` ma 3 paths: magick → ffmpeg → sharp.

## 5. `<picture>` z WebP + PNG fallback

**Anti-pattern**: sam `<img src="x.webp">` — brak fallback dla starych browserów.

**Wzorzec**:
```html
<picture>
  <source srcset="img/logo-1024.webp" type="image/webp">
  <img src="img/logo.png" alt="" class="hero__logo">
</picture>
```

Plus `loading="lazy"` off-fold + `fetchpriority="high"` na LCP candidate + `decoding="async"`.

## 6. Email obfuscation — 3 warstwy

**Anti-pattern**: literalny `mailto:foo@bar.pl` w HTML (bot food) ALBO JS-only obfuscation (łamie SEO).

**Wzorzec**:
1. Human-readable "foo [at] bar [dot] pl" w HTML body, `data-u`/`data-d` attrs
2. JS po DOMContentLoaded rebuduje href + textContent
3. JSON-LD email zostaje plain (Google wymaga)
4. Cloudflare Email Obfuscation jako warstwa 2 (włączana w Dashboard)

## 7. Real geographic data > hand-drawn

**Anti-pattern**: SVG kraju rysowany z głowy / aproksymowany — wygląda fake.

**Wzorzec**: Natural Earth (CC0) `admin_0_countries` 110m + Python ekstrakcja MultiPolygon → Mercator projection (`lon_scale = cos(lat_mid)`) → SVG path. Repo: `martynafford/natural-earth-geojson`. ~5 KB SVG, real shape, public domain.

## 8. Visual verification loop

**Anti-pattern**: commit + push CSS/font changes bez sprawdzenia że faktycznie renderuje się dobrze.

**Wzorzec**: Playwright MCP `browser_navigate` + `browser_take_screenshot` po każdej znaczącej zmianie wizualnej. Szczególnie dla font swaps, layout changes, image replacements. Dla `.reveal` elementów: `browser_evaluate` z `forEach(el => el.classList.add('is-visible'))` przed screenshot (fullPage screenshot nie triggeruje IntersectionObserver).

## 9. Decisive pivot on aesthetic failure

**Anti-pattern**: bronienie wyboru fontu/koloru "bo jest competent" gdy user mówi "nudne", "brzydka", "wystaje".

**Wzorzec**: subjective design rejections to **hard signal** — wywal cały kierunek, nie tweakuj. Iteracja Anton→Antonio→Oswald→Bricolage→Big Shoulders była tańsza niż obrona Antonio. Jeśli klient pisze "kompetentne ale nudne" — natychmiast pivot.

## 10. Mobile responsive — viewport-specific tuning

**Anti-pattern**: jeden mobile breakpoint (np. 600px).

**Wzorzec**: kilka breakpointów dla różnych iPhone'ów:
- 640px (general mobile)
- 540px (compact)
- 440px (iPhone 14 Pro Max 430px CSS width)
- 380px (small phones)

Specifically dla `text-stroke` na hero h1: em-units (0.018em) skalują się, plus media query overrides dla problematic sizes (0.8px <768, 0.6px <480).

## 11. PR target branch verification

**Anti-pattern**: założenie że default branch = `main`.

**Wzorzec**: `git ls-remote --heads origin` lub `gh repo view --json defaultBranchRef` przed PR. Repos sprzed 2020 (jak ten) często `master`.

## 12. Galeria realizacji — placeholdery vs zdjęcia

Galeria ma 3 karty `.gal-card.placeholder` z CSS-owym patternem industrialnym (3 warianty). **Aby podmienić na zdjęcie:**
1. Wrzucić plik do `img/realizacja-XX.jpg` (zalecane WebP, 800×1000px, aspect 4:5)
2. Usunąć klasę `placeholder` + opcjonalnie `placeholder-pattern-N`
3. Dodać inline `style="background-image: url('img/realizacja-XX.jpg')"`

Komentarz HTML w pliku zawiera instrukcję — szukaj `=== EDYCJA GALERII ===`.

## Skróty / przyspieszacze pracy

- Lokalny preview: `python -m http.server 8000` → `http://localhost:8000`
- Walidacja schema: [validator.schema.org](https://validator.schema.org/)
- Rich results test: [search.google.com/test/rich-results](https://search.google.com/test/rich-results)
- Lighthouse: Chrome DevTools → Lighthouse → Analyze
- Playwright MCP (jeśli dostępne) do regression testing po zmianach
