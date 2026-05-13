# CLAUDE.md — kontekst projektu dla przyszłych sesji

Ten plik jest dla **przyszłych iteracji Claude Code** pracujących nad tym repozytorium. Zawiera kluczowe decyzje, konwencje, **patterns z poprzednich sesji**, i pułapki — żeby nie odkrywać tego samego za każdym razem.

## 🎓 Samouczenie — ZAWSZE na koniec sesji (META-REGUŁA)

**Pod koniec każdej sesji rozkminić, czego można było się nauczyć**, i wpisać to do tego pliku jako nową regułę/pattern. Bez tego za miesiąc te same błędy popełnimy od nowa.

Co konkretnie wyciągać:
1. **Każdy znajdź Copilota** — co kazał poprawić, dlaczego, co była przyczyna źródłowa
2. **Własne obserwacje** — zauważone anty-patterny, decyzje projektowe, świadome wybory technologiczne
3. **UX feedback od klienta** — co kazał zmienić, dlaczego, jaki to wzorzec percepcyjny (np. "wypierdek" → drop short suffix, "brzydko wygląda" → hard pivot)
4. **Proces — co poszło źle/dobrze** — np. że Copilot powtarza stare wątki gdy nierozwiązane, że trzeba `resolve all` po fixie, że PR description rotuje

Format: nowy `## NN. Tytuł` w sekcji "Patterns & lessons learned" niżej. Lead z **anty-patternem**, potem **wzorcem**, potem **kiedy stosować**. Konkretnie i krótko — bez wody.

Po dopisaniu reguł — `commit` + `push`, żeby było w pamięci git.

---

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

## 13. Reduced-motion completeness — KAŻDA animacja ma override

**Anti-pattern**: `scroll-behavior: smooth` (lub `transition`, `animation`) ustawione globalnie, brak override'a w `@media (prefers-reduced-motion: reduce)`. To WCAG fail i Copilot to wyłapuje.

**Wzorzec**: każda dyrektywa ruchowa (`animation`, `transition`, `scroll-behavior: smooth`, `transform` na hover) ma zerujący odpowiednik w bloku `prefers-reduced-motion: reduce`. Audyt: grep `scroll-behavior|animation:|transition:` i sprawdź czy każde wystąpienie ma reduced-motion counter-rule.

```css
@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
  .hero__byline, .reveal { opacity: 1; animation: none; }
  .hero__logo { animation: none; }
}
```

## 14. Fixed nav wymaga scroll-padding-top

**Anti-pattern**: fixed top nav (`.nav { position: fixed; height: 72px }`) + `<a href="#section">` → anchor scroll przewija tak, że nagłówek sekcji chowa się pod navem. Klikalność słaba, UX zły.

**Wzorzec**: `html { scroll-padding-top: calc(var(--nav-h) + 12px); }` — buffer 12px nad nagłówkiem po skoku. Wszystkie anchor links automatycznie respektują nav height bez per-section `scroll-margin-top`.

## 15. Skip-link target + focus visibility (WCAG 2.4.7)

**Anti-pattern A**: `<a class="skip-link" href="#main">` celuje w `<main>` bez `tabindex` — fokus klawiatury zostaje na linku, scroll się zmienia ale Tab dalej nawiguje od zaraz po skip-linku zamiast w treści.

**Anti-pattern B**: `<main tabindex="-1">` + `outline: none` na focus → fokus niewidoczny = WCAG 2.4.7 fail.

**Wzorzec**: `<main id="main" tabindex="-1">` + outline zastąpiony subtelnym indykatorem (inset box-shadow band u góry, nie outline wokół ogromnego elementu):

```css
main[tabindex="-1"]:focus-visible {
  outline: none;
  box-shadow: inset 0 4px 0 0 var(--accent);  /* 4px gold band u gory main */
}
```

## 16. Touch hover prevention z feature query

**Anti-pattern**: `:hover { transform: scale(1.05) }` triggeruje sticky hover na touch devices — long-press = trzymanie stylu hover do kolejnego tapa.

**Wzorzec**: każdy transform-based hover owinięty w `@media (hover: hover) and (pointer: fine) { ... }`. Mouse users dostają hover affordances, touch users nie mają sticky.

```css
@media (hover: hover) and (pointer: fine) {
  .btn:hover { transform: translateY(-2px); background: var(--accent-hover); }
}
```

## 17. Symmetric safe-area-inset w landscape z notchem

**Anti-pattern**: `padding-inline: max(20px, env(safe-area-inset-left))` — tylko lewy notch honored. iPhone w landscape z prawym notchem nakłada content na okrągły kąt ekranu.

**Wzorzec**: rozdzielić start/end:
```css
padding-inline-start: max(20px, env(safe-area-inset-left));
padding-inline-end:   max(20px, env(safe-area-inset-right));
```

Działa też dla RTL languages w przyszłości (logical properties).

## 18. Progressive enhancement > `@supports not`

**Anti-pattern**: `@supports not (-webkit-text-stroke: 1px black) { /* tylko re-set text-stroke */ }` — fallback nadal używa nie-wspieranej property. Z `color: transparent` dla stroke text, przeglądarki bez wsparcia renderują niewidoczny tekst.

**Wzorzec**: default rule = uniwersalnie wspierana wersja. Efekt zaawansowany w POZYTYWNEJ feature query:

```css
.hero__title .outline {
  color: var(--fg);  /* default visible */
}
@supports (-webkit-text-stroke: 1px black) {
  .hero__title .outline {
    color: transparent;
    -webkit-text-stroke: 0.018em var(--fg);
  }
}
```

Plus gating na ekrany ≥769px dla efektów które na mobile wyglądają źle (artefakty antialiasingu thin stroke przy małych font-size).

## 19. Format-specific image library options

**Anti-pattern**: `sharp.$Format({ quality: 85, effort: 6 })` dynamicznie — działa dla webp, throws/ignoruje dla png (PNG nie ma `effort`).

**Wzorzec**: branch options per format:
```powershell
$opts = if ($Format -eq 'webp') {
  "{ quality: $Quality, effort: 6 }"
} else {
  "{ compressionLevel: 9 }"  # PNG lossless
}
```

## 20. ffmpeg aspect-ratio preservation

**Anti-pattern**: `scale=W:H` wymusza dokładne wymiary → stretching dla nie-kwadratowych źródeł.

**Wzorzec**: `scale=W:H:force_original_aspect_ratio=decrease,format=rgba,pad=W:H:(ow-iw)/2:(oh-ih)/2:color=black@0`. Zachowuje proporcje, dopaduje do kwadratu z transparentnym tłem (format=rgba przed pad — pad domyślnie nie ma alpha jeśli źródło jest RGB).

## 21. Cross-platform PowerShell temp dir

**Anti-pattern**: `$env:TEMP` — Windows-only. macOS/Linux pwsh: `TEMP` jest unset, `Join-Path` daje śmieci.

**Wzorzec**: `[System.IO.Path]::GetTempPath()` — respektuje `TMPDIR` (Unix), `$env:TEMP/$env:TMP` (Windows). Helper `Get-TempDir` w skrypcie.

## 22. HTML entity encoding w atrybutach

**Anti-pattern**: `<iframe src="...?a=1&b=2">` — surowe `&` w wartości atrybutu. Walidator HTML protestuje; niektóre parsery interpretują `&b` jako entity reference.

**Wzorzec**: zawsze `&amp;` w atrybutach (`src`, `href`, `value`):
```html
<iframe src="https://maps.google.com/maps?q=X&amp;t=&amp;z=15&amp;output=embed">
```

W JS template stringach `&` jest OK (to nie HTML), tylko w atrybutach. URL-encode wartości (`%20`, `%C3%B3`) niezależnie.

## 23. Detect every binary actually invoked

**Anti-pattern**: gate `sharp` ścieżki na `$haveNpx`, potem w środku wywołać `npm install` i `node script.js`. Volta / nvm-windows mogą shimnąć jeden bez drugiego.

**Wzorzec**: wykryj każdy binary który kod naprawdę wywołuje. Dla sharp: `$haveNode -and $haveNpm`. W komunikacie błędu **nazwij** brakujący binary precyzyjnie:

```powershell
$missing = if (-not $haveNode) { 'node' } else { 'npm' }
Write-Host "ERROR: Brakuje: $missing"
```

## 24. PR description rotuje — sync z kodem przy pivotach

**Anti-pattern**: PR description pisany na branch creation, nieupdate'owany gdy implementacja pivotuje (font, paleta, architektura). Mylące dla reviewerów.

**Wzorzec**: po każdym dużym pivocie — `gh pr edit <N> --body "$(cat <<'EOF' ... EOF)"` z aktualnym opisem. Lista checkboxów "Pending" → odznaczać po ukończeniu.

## 25. Copilot review cycle workflow

**Pattern (operacyjny)**: każdy push triggeruje review Copilota na nowym commicie (1-3 min). Reviews często powtarzają stare findings ZE STAREMI ID — są attached do nowego commitu, ale underlying issues już naprawione.

Cykl pracy:
1. Push commit z fixem
2. Wait for new review: `until COMMIT=$(gh pr view 1 --json reviews --jq '... .commit.oid[0:7]') && [ "$COMMIT" = "<latest>" ]; do sleep 20; done` (Bash run_in_background z timeout 420s)
3. `gh api .../pulls/N/comments` — filtruj po **najnowszych ID** (numerycznie wyższe = nowe) vs powtórki starych
4. Fix + commit + push **tylko realnie nowe**
5. **`resolve all` przez GraphQL** po fixie żeby UI był czysty (one-liner: query + foreach `resolveReviewThread`)
6. Repeat aż review jest pusty

```bash
UNRESOLVED=$(gh api graphql -f query='{ repository(owner:"X",name:"Y") { pullRequest(number:1) { reviewThreads(first:50) { nodes { id isResolved } } } } }' --jq '.data.repository.pullRequest.reviewThreads.nodes | map(select(.isResolved == false)) | .[].id')
for tid in $UNRESOLVED; do gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$tid\"}) { thread { isResolved } } }" > /dev/null; done
```

## 26. Trust but verify Copilot — hallucinated occurrences

**Anti-pattern**: Copilot mówi "ten typo pojawia się na linii X i Y" → ślepo poprawiasz oba. Czasem druga lokalizacja to halucynacja.

**Wzorzec**: zawsze `grep` przed fixem. Match actual count vs claimed count. Jeśli się nie zgadza — fix tylko realne, ignoruj phantomy. Przykład tej sesji: Copilot twierdził że "głowny" jest w 2 miejscach, było 1.

## 27. User aesthetic feedback = HARD PIVOT (wzmocnienie #9)

**Wzorzec (rozszerzony)**: subjective rejections to NIE feedback do tweakowania, to sygnał do wywalenia kierunku w całości.

Konkretne przykłady z tej sesji:
- "wypierdek" o `·232/·182` shorthand → drop entirely, nie próbuj go upiększyć
- "tytuł brzydki" o text-stroke na mobile → gate całkowicie behind `min-width: 769px`
- "tak nie może być" o byline pchającym cards w dół → relokuj entirely, nie tweakuj marginów
- "nudne / kompetentne" o Antonio fonts → pivot to Big Shoulders Display

Cena iteracji "Anton→Antonio→Oswald→Bricolage→Big Shoulders" była niższa niż obrona Antonio. Subiektywne odrzucenie = ROZSZERZ SEARCH SPACE, nie kompromisuj w wąskim.

## 28. Nav hierarchy pod presją szerokości — brand-first, phones-degrade

**Project-specific rule (KFDIAMENT)**: w tym site'cie hierarchia ważności nav elementów przy szerokości malejącej:

1. **Brand wordmark + mark** — ZAWSZE widoczne, ZAWSZE 26px (default), nigdy nie shrinkowane w nav scope. To identity anchor.
2. **Hamburger** — zawsze widoczny gdy links hidden (≤1080px).
3. **Phones** — degradują pierwsze: 2 → 1 (≤640px) → 0 (≤460px). Hidden phones zostają dostępne w `.mobile-menu__phones` na górze panelu.
4. **Section links** — hidden ≤1080px (replaced by hamburger).

Footer brand ma osobny scoping (38-46px `.footer .brand__mark`); nav scope zachowuje stały rozmiar.

## 29. Phone digits never wrap

**Anti-pattern**: numer "511 478 232" pęka na 2 linie ("511 478" / "232") przy tight widths.

**Wzorzec**: globalna reguła `a[href^="tel:"] { white-space: nowrap; }` łapie wszystkie miejsca jednym fixem. Plus defensive `white-space: nowrap` na `.nav__phone` i `.mobile-menu__phone` — cyferki siedzą w `<span>` wewnątrz `<a>`, reguła globalna łapie parent, defensive na child gdyby style się przemieszały.

## 30. Nav breakpoint niezależny od section grid

**Wzorzec**: ten projekt używa 900px jako universal mobile/desktop dla sekcji (hero stats, about, gallery, contact grid, footer). NAV potrzebuje **wyższego** breakpointa (1080px) — desktop nav z 5 linkami + 2 phones + brand + maxw padding wymaga ~1100px breathing room.

Reguła: media query 1080 dla rzeczy nav-only (`.nav__links display: none`, `.nav__burger display: inline-flex`, mobile-menu desktop-hide guard, JS resize-close logic). Sekcji NIE bumpować na 1080 — tylko nav.

## 31. Anchor decorative element na max-width, nie na viewport

**Anti-pattern**: `right: -8vw` na decorative element (slow-spin logo) — na 4K (3840px) viewport `-8vw = -307px`, element drifuje w no-man's-land daleko poza content column.

**Wzorzec**: anchor right edge do `--maxw` container's right edge:
```css
.hero__logo {
  right: calc(max(0px, (100vw - var(--maxw)) / 2) - 8vw);
}
```

Na viewport ≤ `--maxw` zachowuje stare `-8vw` (element extending poza viewport). Na szerszych ekranach prawa krawędź docisnięta do prawej krawędzi container, element zostaje w obrebie content width.

## 32. Belt-and-suspenders dla user requirements

**Wzorzec**: gdy klient mówi "X ZAWSZE musi być w stanie Y" → enforce go w >1 warstwie żeby nie złamało się przez accidentalną edycję.

Przykład email lowercase (z tej sesji):
1. **HTML**: `data-u="kontakt" data-d="kfdiament.pl"` (lowercase obfuscation)
2. **CSS**: `a.email-obf { text-transform: lowercase; }`
3. **JS**: `(el.dataset.u + '@' + el.dataset.d).toLowerCase()`

Trzy niezależne warstwy. Nawet jeśli przyszły edytor wpisze "Kontakt@..." w data attrs, output zostaje lowercase.

## 33. Inverted CTA = section 2 banner consistency

**Project-specific rule**: każde "Inne zapytanie" / general inquiry CTA na stronie (mailto-card, banner, button) używa inverted treatment:
- `background: var(--fg)` (dark)
- `color: var(--bg)` (cream)
- arrow / accent: `var(--accent-2)` (jasny gold, kontrast na ciemnym)
- hover: `background: var(--accent-deep)`

Spójność wizualna: gdziekolwiek "inne zapytanie" pojawia się, ma ten sam dark+gold akcent. Implementacja przez `.mailto-card--inverted` modifier (sekcja 5) lub `.service-other` banner (sekcja 2).

## 34. Mobile hamburger menu — phones-section pattern

**Project-specific HTML/CSS structure** dla `.mobile-menu`:

```
.mobile-menu (absolute top: 100%, slides down)
├── .mobile-menu__phones (sekcja telefonow u gory, 2-col grid >420px, stack ≤420px)
│   ├── .mobile-menu__phone (gold pill button, full number "+48 511 478 232")
│   └── .mobile-menu__phone
├── (hairline divider via border-bottom na __phones)
└── .mobile-menu__links (ul z 5 section links)
    └── li.a → <span class="mobile-menu__num">01</span><span>O nas</span>
```

JS toggle pattern:
- `aria-expanded` na burger
- `data-open` attribute na panel + scrim (CSS transition opacity/translateY)
- `hidden` attribute removed BEFORE animating + `void el.offsetWidth` żeby transition zalapal
- Close on: Escape (+ refocus burger), scrim click, link click, resize >=1081
- `setTimeout(240ms)` przed `hidden = true` żeby fade-out animation dograł

## 35. JS reflow trick dla transition po `hidden`

**Anti-pattern**: `element.hidden = false; element.classList.add('open');` — `hidden=false` i klasa stosowane w tym samym frame, transition nie triggeruje (browser nie widzi initial state).

**Wzorzec**: force reflow między display change a state change:
```js
menu.hidden = false;
void menu.offsetWidth;  // reflow — czyta layout, force commit
menu.setAttribute('data-open', 'true');
```

## 36. PR description sync via `gh pr edit`

**Wzorzec (operacyjny)**: `gh pr edit <N> --body "$(cat <<'EOF' ... EOF)"` przy każdym pivocie. HEREDOC single-quoted (`'EOF'`) chroni przed expansion zmiennych shell w opisie. Zostawia jeden "source of truth" w PR body.

## 37. Cloudflare _headers — semantics merge, nie first-match

**Wzorzec (dokumentacyjny)**: w `_headers` reguły z pasującymi globami są **mergeowane** dla danego żądania. Konflikt nazwy header (np. `Cache-Control`) — wygrywa **bardziej specyficzny glob** (`/fonts/*` nadpisuje `/*`). Security headers z `/*` (HSTS itp.) **przechodzą** do `/fonts/*` i `/img/*`, bo te bardziej specyficzne reguły ustawiają tylko Cache-Control + CORS, nie security.

Mit "first-match wins" jest błędny — nie kopiuj security headers do każdego bloku, wystarczą w `/*`.

## 38. iframe sandbox — minimum necessary

**Wzorzec**: dla third-party iframe (Google Maps embed):
```html
<iframe
  src="..."
  loading="lazy"
  referrerpolicy="no-referrer-when-downgrade"
  sandbox="allow-scripts allow-same-origin allow-popups"
  title="...">
</iframe>
```

NIE dodawać `allow-popups-to-escape-sandbox` (redundant + ryzyko). NIE używać `allow-forms allow-top-navigation` chyba że konkretnie potrzebne. `referrerpolicy` chroni privacy.

## Skróty / przyspieszacze pracy

- Lokalny preview: `python -m http.server 8000` → `http://localhost:8000`
- Walidacja schema: [validator.schema.org](https://validator.schema.org/)
- Rich results test: [search.google.com/test/rich-results](https://search.google.com/test/rich-results)
- Lighthouse: Chrome DevTools → Lighthouse → Analyze
- Playwright MCP (jeśli dostępne) do regression testing po zmianach
