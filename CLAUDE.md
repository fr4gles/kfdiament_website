# CLAUDE.md — kontekst projektu dla przyszłych sesji

Plik dla przyszłych iteracji Claude Code w tym repo. Kluczowe decyzje, konwencje, patterns z poprzednich sesji.

## Samouczenie — meta-reguła

Pod koniec każdej sesji wyciągnij wnioski i dopisz jako nowy `## NN. Tytuł` w sekcji Patterns niżej. Co wyciągać: findy Copilota, własne obserwacje, UX feedback klienta, observations o procesie. Format: anty-pattern → wzorzec → kiedy. Po dopisaniu commit + push. Numeracja patternów jest **stabilna** (cross-refy w pliku) — przy mergowaniu zostaw stub `## NN. [MERGED → #M]`.

---

## Czym jest projekt

Statyczna strona-wizytówka firmy KFDIAMENT Obrębski Motyka Spółka jawna (cięcie i wiercenie diamentowe betonu, wyburzenia konstrukcji, cała Polska, siedziba: Grybów, Grunwaldzka 9). Hosting: Cloudflare Pages (free tier), domena: kfdiament.pl. Remote: `fr4gles/kfdiament_website`.

## Stack — świadome ograniczenia

NIE jest to JS-framework. Świadomie:

- Jeden plik `index.html` (HTML+CSS+JS inline, ~4500 linii). Nie rozbijać bez dobrego powodu.
- Vanilla JS: mailto generator, email obfuscation, hamburger z focus trap (inert), scroll progress, IntersectionObserver, theme switcher (data-theme + data-mode).
- Bez build-stepu, bez `package.json`, bez npm/yarn/pnpm, bez CSS frameworków, bez bibliotek JS.
- Self-hosted woff2 w `/fonts/` (6 plików ~186 KB, variable, latin + latin-ext). NIE Google Fonts CDN (perf + GDPR).

Powód: Cloudflare Pages preset = `None`, build pusty, output `/`. Wartość setupu = prostota.

## Struktura plików

```
.
├── index.html                — cała strona (HTML+CSS+JS inline)
├── _headers                  — Cloudflare HTTP headers (security + cache)
├── README.md, COMPARISON.md, CLAUDE.md
├── robots.txt, sitemap.xml, .gitignore
├── scripts/optimize-logo.ps1 — PNG → WebP (magick → ffmpeg → sharp fallback)
├── fonts/                    — self-hosted variable woff2 (~186 KB total)
│   ├── big-shoulders-{latin,latin-ext}.woff2     (57 + 44 KB)
│   ├── manrope-{latin,latin-ext}.woff2           (24 + 15 KB)
│   └── jetbrains-mono-{latin,latin-ext}.woff2    (31 + 11 KB)
└── img/
    ├── README.md             — workflow assetów
    ├── logo.png              — master
    ├── logo.webp / logo-1024.webp / logo-96.webp — nav, hero LCP, thumb
    ├── favicon-32.png, apple-touch-icon.png (180×180)
    ├── og.jpg                — 1200×630 social
    └── original.jpeg         — backup źródłowy
```

## Branch strategy

Główny branch to `master` (NIE `main`). Praca na `feat/...`, `fix/...`, PR-y do `master`.

## Paleta kolorów i motywy

System motywów: dwa atrybuty na `<html>` (`data-theme="<slug>"` paleta + `data-mode="light|dark"` tryb) + dwa wpisy w localStorage (`kfd_theme` family + `kfd_mode`). Patrz pattern #49. Theme toggle (sun/moon button w nav) flipuje tylko mode. Anti-FOUC: `THEME_PAIRS` inline w `<head>` ORAZ w głównym JS — celowa duplikacja.

Domyślny motyw (light, "warm cream paper" — antique brass na kremie):

| zmienna | hex | rola |
|---|---|---|
| `--bg` | `#f5f1e8` | tło główne |
| `--bg-2` | `#ebe5d6` | sekcje alternujące (kraft) |
| `--bg-3` | `#ddd4bf` | inset / głębsze surfaces |
| `--fg` | `#1a1614` | warm near-black |
| `--muted` | `#5c5346` | warm graphite |
| `--line` | `#c9bfa6` | hairline border |
| `--line-strong` | `#8a7d5e` | strong divider, stroke ikon |
| `--accent` | `#a8842c` | antique brass — primary gold (AA 4.6:1) |
| `--accent-hover` | `#7d5f1c` | deeper bronze hover |
| `--accent-2` | `#c9a85a` | jaśniejszy gold (borders, highlights) |
| `--accent-deep` | `#5d4416` | darkest bronze (stamps) |

Para RGB-triplet do rgba(): `--bg-rgb`, `--fg-rgb` (musi być w sync — patrz #42). Inne palety: `logo-metallic`, `logo-metallic-light`, `brass-midnight`, `parchment-amber`, `navy-evening`, `nordic-mist`, `solar-bright`, `hivis-engineer`, `moss-brass` (pary light/dark w `:root[data-theme="..."]`). Nie hardkodować hex — używać `var(--accent)`.

Decyzja: NIE Hilti red. Klient pokazał logo (gold-on-black piła z K&F monogramem), paleta zpivotowana pod brand identity.

## Typografia (self-hosted)

CSS variables: `--font-display` (Big Shoulders + BigShouldersFallback z metric-matched local Arial Narrow), `--font-body` (Manrope), `--font-mono` (JetBrains Mono).

- **Big Shoulders Display** — variable wght 100-900, display sans z industrial DNA. Latin Extended-A z polskimi ogonkami. BRAK italic — `color: var(--accent)` + heavier weight na `<em>`.
- **Manrope** — variable wght 200-800, body, geometryczny humanist sans.
- **JetBrains Mono** — variable wght 100-800, etykiety techniczne (`/ 01`, spec lines). NIE do długich akapitów.

Hero h1: trzy-linijkowy, `clamp(2.8rem, 9.5vw, 8.2rem)`. Środkowe słowo `outline` (text-stroke jako em-units `0.018em` — skaluje proporcjonalnie). Trzecie `accent` (gold weight 900).

Hero brand byline: `.hero__byline` z `.hero__byline-{key,brand,sub}` spans i 4px gold gradient bar `::before` — architektoniczna tabliczka znamionowa.

## Struktura sekcji

1. **Nav** — fixed top, blur, 72px wysokości. `.nav__phones > .nav__phone × 2` + `.nav__email` + `.nav__theme-toggle` (sun/moon, #52) + `.nav__burger`. Breakpointy nav-specific:
   - ≤1280px: email staje się icon-only
   - ≤1080px: section links znikają, hamburger się pokazuje
   - ≤820px: padding tighter, `.nav__email` hidden (pełna wersja w mobile menu)
   - ≤720px: 2. phone button znika
   - ≤540px: oba phones znikają z nav, hamburger+toggle 40×40, toggle `margin-left:auto` (#51)
   - ≤380px: brand mark 76px

   Mobile menu (≤1080px): slide-down z `.mobile-menu__phones` (2 gold pill buttons) + `.mobile-menu__email` + 5 section links. `inert` (nie `hidden`) blokuje fokus/AT natychmiast (#41). Focus trap: gdy menu open, `<main>` dostaje `inert`. Easter egg pulse ring USUNIĘTY (commit 0af5cd6).
2. **Hero** — full vh, slow-spin logo absolute `clamp(360px, 52vw, 720px)`, anchor do `--maxw` (#31), opacity 0.18. h1 3-spanowy: "Specjaliści w cięciu i wierceniu" / **"techniką diamentową"** (accent) / "betonu i żelbetu." + brand byline + sub + 2 CTA + 4 stats (Ø800mm / PL / 2. gen. DST 20-CA / Beton+Żelbet).
3. **Marquee ticker** — czarny pas, gold-accented (5 items + duplikat dla seamless loop). 38s linear infinite, pauza on hover.
4. **`#o-nas`** — bg-2 + background "01", 5 akapitów + corner-card "Dlaczego my?". Para 2 mówi **"wiele lat doświadczenia"** — świadoma decyzja klienta (2026-05-14), NIE "3 lata". Patrz #48.
5. **`#uslugi`** — bg + "02", 4 service cards (Cięcie / Wiercenie / Wyburzenia / Kotwy chemiczne) + banner "Inne zapytanie" /05 (full-width dark CTA, `ogolne`). Grid `repeat(auto-fit, minmax(320px, 1fr))`.
6. **`#realizacje`** — bg-2 + "03", 3 gal-card z placeholderami.
7. **`#sprzet`** — bg-3 gradient, "HILTI" w tle, 2 spec-items (DST 20-CA piła ścienna, DD500-CA wiertnica do ⌀800mm).
8. **`#kontakt`** — bg + "05". 2-kolumnowy grid (h2 + brand byline static). 4 contact-blocks (Telefon, E-mail, Siedziba z pill "Otwórz w Mapach Google", Zasięg) + 5 mailto-cards (5. = `mailto-card--inverted` dla `ogolne`) + iframe Google Maps. Blok Zasięg: 4-kolumnowy grid `52px auto auto 1fr` z mini-mapą Polski (Natural Earth, niżej), `clamp(78px, 14vw, 110px)`, hidden ≤380px.
9. **Footer** — bg-2, brand+dane+kontakt.

Persistent UI: scroll progress bar (`#scrollProgress`, 3px gold gradient, rAF passive). Klikalne `.section-label` (`01 — Nazwa`).

## Mailto-cards — pattern

Sekcja kontakt NIE ma `<form>`. Karty `<a class="mailto-card" data-mailto="KEY">`. Fallback `href="#kontakt"` (NIE literalny `mailto:`) — JS replace'uje na `mailto:?subject=...&body=...` z `encodeURIComponent`.

Klucze (5): `ciecie`, `wiercenie`, `wyburzenia`, `kotwy`, `ogolne`. Subjects:
- `Wycena - Cięcie betonu - zapytanie ze strony`
- `Wycena - Wiercenie otworów - zapytanie ze strony`
- `Wycena - Wyburzenia - zapytanie ze strony`
- `Wycena - Kotwy chemiczne - zapytanie ze strony`
- `Kontakt ze strony - zapytanie ogólne`

Body kończy się stopką `Wiadomość wysłana ze strony kfdiament.pl`. W sekcji Usługi `ogolne` triggeruje banner "Skontaktuj się z nami / Niestandardowy zakres prac".

## Email obfuscation — pattern

Maile NIE w plain text w HTML. Pattern w wielu miejscach (nav, mobile-menu, contact-block, mailto note, footer):

```html
<a class="email-obf" data-u="kontakt" data-d="kfdiament.pl"
   href="#kontakt" rel="nofollow">kontakt [at] kfdiament [dot] pl</a>
```

JS rebuduje href + textContent (chyba że `data-keep-text="1"`, np. nav/mobile-menu gdzie chcemy zachować "kontakt@kfdiament.pl" jako label). CSS `text-transform: lowercase` jako belt-and-suspenders (#32). JSON-LD email plain (SEO LocalBusiness wymaga). Cloudflare Email Obfuscation (Dashboard → Scrape Shield) jako warstwa 2.

## `_headers` (Cloudflare Pages)

Plik w root automatycznie czytany. Definiuje:
- Security (`/*`): HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy (blokuje camera/mic/geolocation + FLoC opt-out)
- Long cache 1 rok immutable: `/fonts/*` (z CORS `*`), `/img/*`
- Short cache 600s must-revalidate: `/` + `*.html`
- Medium cache 3600s: `robots.txt`, `sitemap.xml`

Semantyka: reguły mergeowane per żądanie, nie first-match (#37). Security headers z `/*` przechodzą do `/fonts/*` i `/img/*`.

## Dane firmy (hardkodowane — NIE zmieniać bez prośby klienta)

- Nazwa: KFDIAMENT Obrębski Motyka Spółka jawna
- NIP: `7343669611` | REGON: `54455908000000`
- Adres: Grunwaldzka 9, 33-330 Grybów
- Telefony: `+48 511 478 232`, `+48 511 478 182`
- E-mail: `kontakt@kfdiament.pl` (zawsze małą literą — #32)

Dane w wielu miejscach: nav 2 phone buttons + email, mobile menu, footer, contact-blocks, JSON-LD `LocalBusiness`. Przy zmianie — `grep` po starej wartości i podmieniaj wszędzie.

## Mapa Polski (Zasięg block)

Real outline z Natural Earth 110m admin_0_countries (CC0, [martynafford/natural-earth-geojson](https://github.com/martynafford/natural-earth-geojson)). 45 punktów, Mercator-projected (`lon_scale = cos(lat_mid)` dla ~52°N). ViewBox 0 0 24 24, stroke-width 0.55. Path inline w `index.html`. NIE rysować ręcznie — Polak rozpozna fake.

## SEO setup

- 3 schematy JSON-LD: `LocalBusiness` z `hasOfferCatalog`, `Organization`, `WebSite`
- Open Graph + Twitter Card (`og:image` 1200×630 → `img/og.jpg`)
- `<title>` + `<meta description>` + canonical + hreflang `pl` + `x-default`
- `robots.txt` + `sitemap.xml`
- Semantic HTML5, hierarchia h1 → h2 → h3, alt texts WCAG
- `prefers-reduced-motion` obsługiwane (#13)
- `<meta name="color-scheme" content="light dark">` + `<meta name="theme-color">` per `prefers-color-scheme` (#50)

## Performance — micro-optymalizacje

- CSS + JS inline (0 external stylesheets, JS na końcu body)
- Self-hosted fonts + preload (`big-shoulders-{latin,latin-ext}`, `manrope-{latin,latin-ext}`, `jetbrains-mono-latin`)
- `<link rel="preload" as="image">` + `fetchpriority="high"` + `decoding="async"` na hero `logo-1024.webp` (LCP)
- `loading="lazy"` na footer img + map iframe + off-fold
- `<picture>` WebP + PNG fallback
- `prefers-reduced-motion` wycina animacje
- SVG noise jako data URI (zero requestów na grain)

Po deployu spodziewany Lighthouse: 95-100 / 95-100 / 95-100 / 100.

## Czego NIE robić

- NIE `<form>` kontaktowego — mailto-cards są szybsze (pre-fill), tańsze (zero backendu), bezpieczniejsze.
- NIE Google Maps JS API — używamy darmowego embed iframe.
- NIE emoji jako ikony — wszystkie ikony to SVG inline (Lucide-style, stroke).
- NIE stockowe obrazki — placeholdery CSS.
- NIE cookies banner / Google Analytics — Cloudflare Web Analytics (bez cookies, bez RODO).
- NIE `#000`/`#fff` ani hardkodowane hex — `var(--fg)`, `var(--bg)`, `var(--accent)` (kolory zmieniają się per motyw).
- NIE rozbijać `index.html` na komponenty.
- NIE Google Fonts CDN — self-hosting świadomy (perf + GDPR).
- NIE rysować mapy Polski ręcznie — Natural Earth path.

---

# Patterns & lessons learned

## 1. CSS Cascade Order — same-specificity pułapka

Anty: override `.foo--variant` zdefiniowany PRZED base `.foo` (same specificity → later wins → base nadpisuje modifier).

Pattern: w CSS > 500 linii umieszczaj `.block--modifier` PO `.block`. Alternatywa: bumpuj specificity (`.foo.foo--variant` = 2 klasy).

## 2. Font self-hosting — anti-FOUT

Anty: Google CDN — `font-display: optional` daje permanent fallback (100ms cross-origin za mało), `swap` daje widoczny FOUT.

Pattern: self-host woff2 same-origin + `<link rel="preload">` + `font-display: swap` + fallback `@font-face` z `size-adjust` / `ascent-override` (BigShouldersFallback z Arial Narrow / Bahnschrift Condensed). Variable woff2: jeden plik per `unicode-range`, `font-weight: 100 900`.

## 3. Pobieranie woff2 z Google Fonts

Anty: `curl fonts.googleapis.com/css2?...` bez headerów → TTF.

Pattern:
```bash
curl -H "User-Agent: Mozilla/5.0 ... Chrome/120" -H "Accept: text/css" \
  "https://fonts.googleapis.com/css2?family=..." | grep woff2
```
Pobierz tylko `latin` + `latin-ext` (skip cyrillic/greek/vietnamese).

## 4. Image optimization — ffmpeg jako ImageMagick fallback

3-tier fallback chain w `scripts/optimize-logo.ps1`: magick → ffmpeg → sharp. `ffmpeg -i in.png -vf scale=W:H:flags=lanczos -c:v libwebp -quality 85 out.webp` daje ~84% redukcję vs PNG.

## 5. `<picture>` z WebP + PNG fallback

Używane w nav/hero/footer (3 lokacje):
```html
<picture>
  <source srcset="img/logo-1024.webp" type="image/webp">
  <img src="img/logo.png" alt="" class="hero__logo">
</picture>
```
+ `loading="lazy"` off-fold, `fetchpriority="high"` na LCP, `decoding="async"`.

## 6. Email obfuscation — 3 warstwy

Anty: literalny `mailto:foo@bar.pl` (bot food) ALBO JS-only (łamie SEO/JSON-LD).

Pattern:
1. HTML: `data-u`/`data-d` attrs + human-readable "foo [at] bar [dot] pl", `href="#kontakt"`
2. JS po starcie rebuilduje href + textContent (z guard na missing attrs i `data-keep-text="1"` dla button labels)
3. JSON-LD email plain (Google wymaga)
4. Cloudflare Email Obfuscation (Dashboard) jako warstwa 2

```js
document.querySelectorAll('a.email-obf').forEach(function (el) {
  const u = el.dataset.u, d = el.dataset.d;
  if (!u || !d) { console.error('[email-obf] missing data-u/data-d', el); return; }
  const addr = (u + '@' + d).toLowerCase();
  el.setAttribute('href', 'mailto:' + addr);
  if (!el.dataset.keepText) el.textContent = addr;
  el.removeAttribute('rel');
});
```

## 7. Real geographic data > hand-drawn

Anty: SVG kraju rysowany ręcznie — Polak rozpozna fake.

Pattern: Natural Earth (CC0) `admin_0_countries` 110m → Python ekstrakcja MultiPolygon → Mercator (`lon_scale = cos(lat_mid)`) → SVG path inline. Repo: `martynafford/natural-earth-geojson`. ~5 KB, real shape, public domain.

## 8. Visual verification loop

Anty: commit + push wizualnych zmian bez sprawdzenia renderu.

Pattern: Playwright MCP `browser_navigate` + `browser_take_screenshot` po każdej znaczącej zmianie. Dla `.reveal`: `browser_evaluate` z `forEach(el => el.classList.add('is-visible'))` przed screenshot (fullPage nie triggeruje IntersectionObserver).

## 9. Decisive pivot on aesthetic failure

Anty: bronienie wyboru "bo competent" gdy user mówi "nudne"/"brzydka".

Pattern: subjective rejection = wywal kierunek, nie tweakuj. Iteracja Anton→Antonio→Oswald→Bricolage→Big Shoulders tańsza niż obrona Antonio. Wzmocnione w #27.

## 10. Mobile responsive — viewport-specific tuning

Anty: jeden mobile breakpoint (np. 600px).

Pattern: kilka — 640px (general), 540px (compact), 440px (iPhone 14 Pro Max 430px CSS), 380px (small). Dla efektów jak text-stroke: em-units (`0.018em`) skalują, plus media query overrides dla problematic sizes.

## 11. PR target branch verification

Anty: założenie że default = `main`. Pattern: `gh repo view --json defaultBranchRef` (lub `git ls-remote --heads origin`) przed PR. Repos sprzed 2020 (jak ten) często `master`.

## 12. Galeria realizacji — placeholdery vs zdjęcia

Galeria: 3 karty `.gal-card.placeholder` z CSS-owym patternem (3 warianty). Podmiana na zdjęcie:
1. `img/realizacja-XX.jpg` (WebP, 800×1000, aspect 4:5)
2. Usuń klasę `placeholder` (+ `placeholder-pattern-N`)
3. `style="background-image: url('img/realizacja-XX.jpg')"`

Komentarz HTML `=== EDYCJA GALERII ===` w `index.html` jako landmark.

## 13. Reduced-motion completeness — każda animacja ma override

Anty: `scroll-behavior: smooth` / `transition` / `animation` bez `@media (prefers-reduced-motion: reduce)` override. WCAG fail, Copilot wyłapuje.

Pattern: każda dyrektywa ruchowa ma zerujący odpowiednik. Audyt: grep `scroll-behavior|animation:|transition:` i sprawdź czy każde ma counter-rule. Plus JS guard `if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;`.

```css
@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
  .hero__byline, .reveal { opacity: 1; animation: none; }
  .hero__logo { animation: none; }
}
```

## 14. Fixed nav wymaga scroll-padding-top

Anty: fixed nav 72px + `<a href="#section">` → anchor scroll chowa nagłówek pod navem.

Pattern: `html { scroll-padding-top: calc(var(--nav-h) + var(--theme-panel-h, 0px) + 12px); }` — uwzględnia też theme-panel jeśli widoczny. 12px buffer.

## 15. Skip-link target + focus visibility (WCAG 2.4.7)

Anty A: `href="#main"` → `<main>` bez `tabindex` — fokus zostaje na linku.
Anty B: `<main tabindex="-1">` + `outline: none` → fokus niewidoczny.

Pattern: `<main id="main" tabindex="-1">` + inset box-shadow band zamiast outline wokół ogromnego elementu. Aplikowane na `:focus` ORAZ `:focus-visible` (niektóre browsery nie matchują `:focus-visible` po programmatic focus z anchor).
```css
main[tabindex="-1"]:focus,
main[tabindex="-1"]:focus-visible {
  outline: none;
  box-shadow: inset 0 4px 0 0 var(--accent);
}
```

## 16. Touch hover prevention z feature query

Anty: `:hover { transform: scale(1.05) }` → sticky hover na touch (long-press trzyma styl).

Pattern: każdy transform-based hover w `@media (hover: hover) and (pointer: fine)`.

## 17. Symmetric safe-area-inset w landscape z notchem

Anty: `padding-inline: max(20px, env(safe-area-inset-left))` — tylko lewy notch. iPhone landscape z prawym notchem → content na rounded corner.

Pattern: rozdziel start/end (logical properties, bonus RTL):
```css
padding-inline-start: max(20px, env(safe-area-inset-left));
padding-inline-end:   max(20px, env(safe-area-inset-right));
```

## 18. Progressive enhancement > `@supports not`

Anty: `@supports not (-webkit-text-stroke)` z `color: transparent` — przeglądarki bez wsparcia renderują niewidoczny tekst.

Pattern: default rule = wspierana wersja, efekt w pozytywnej feature query.
```css
.hero__title .outline { color: var(--fg); }
@supports (-webkit-text-stroke: 1px black) {
  .hero__title .outline { color: transparent; -webkit-text-stroke: 0.018em var(--fg); }
}
```

## 19. Format-specific image library options

Sharp option object różni się per format (`effort` jest webp-only, PNG ma `compressionLevel`).
```powershell
$opts = if ($Format -eq 'webp') { "{ quality: $Quality, effort: 6 }" }
       else { "{ compressionLevel: 9 }" }
```

## 20. ffmpeg aspect-ratio preservation

`scale=W:H` stretchuje. Use `scale=W:H:force_original_aspect_ratio=decrease,format=rgba,pad=W:H:(ow-iw)/2:(oh-ih)/2:color=black@0` — proporcje + transparent pad (`format=rgba` MUSI być przed `pad`).

## 21. Cross-platform PowerShell temp dir

`$env:TEMP` jest Windows-only. Użyj `[System.IO.Path]::GetTempPath()` — respektuje `TMPDIR` (Unix) i `$env:TEMP/TMP` (Windows).

## 22. HTML entity encoding w atrybutach

Surowy `&` w atrybucie — walidator protestuje, parser interpretuje `&b` jako entity. Zawsze `&amp;` w `src`/`href`/`value`. W JS template strings `&` OK. URL-encode wartości (`%20`, `%C3%B3`) niezależnie.

## 23. Detect every binary actually invoked

Wykryj **każdy** binary który skrypt realnie wywołuje (Volta/nvm shim mogą rozdzielić node/npm). Dla sharp: `$haveNode -and $haveNpm`. W błędzie nazwij brakujący precyzyjnie:
```powershell
$missing = if (-not $haveNode) { 'node' } else { 'npm' }
```

## 24. PR description rotuje — sync z kodem przy pivotach

Po każdym pivocie: `gh pr edit <N> --body "$(cat <<'EOF' ... EOF)"`. Jeden source of truth w PR body, checkboxy odznaczać.

## 25. Copilot review cycle workflow

Każdy push triggeruje nowy review (1-3 min), często z powtórzonymi findings ze starymi ID. Cykl: push → wait for new review SHA → filter nowe ID → fix tylko realne → `resolveReviewThread` GraphQL → repeat.

## 26. Trust but verify Copilot — hallucinated occurrences

Copilot mówi "typo na liniach X i Y" → zawsze `grep` przed fixem. Match actual count vs claimed; ignoruj phantomy.

## 27. User aesthetic feedback = HARD PIVOT (wzmocnienie #9)

Subjective rejections ("brzydkie", "nudne", "tak nie może być") = sygnał do wywalenia kierunku, NIE do tweakowania. Rozszerz search space zamiast kompromisować w wąskim.

## 28. Nav hierarchy pod presją szerokości — brand-first, phones-degrade

Project-specific (KFDIAMENT), aktualne breakpointy (po commits faaa56e..e451883):

| szerokość | brand | links | email | phones |
|---|---|---|---|---|
| ≥1281 | 86px | visible | full (text+icon) | 2 widoczne |
| ≤1280 | 86px | visible | **icon-only 44×44** | 2 widoczne |
| ≤1080 | 86px | **hidden** (→ hamburger) | icon-only | 2 widoczne |
| ≤820 | 86px | hidden | **hidden** (→ mobile menu) | 2 (compact) |
| ≤720 | 86px | hidden | hidden | **1 widoczny** |
| ≤540 | 86px | hidden | hidden | **0**; burger+toggle 40px, `margin-left:auto` na toggle |
| ≤380 | **76px** | — | — | — |

Hierarchia ważności: **brand (zawsze) > hamburger (gdy links hidden) > toggle > phones (degradują) > email (icon→hidden)**. Footer brand niezależny scoping (110-200px).

## 29. Phone digits never wrap

Globalna `a[href^="tel:"] { white-space: nowrap; }` + defensive na `.nav__phone`/`.mobile-menu__phone`.

## 30. Nav breakpoint niezależny od section grid

Sekcje używają 900px jako mobile/desktop boundary. Nav potrzebuje **1080px** (5 linków + 2 phones + brand + maxw padding ≈ 1100px breathing room). Plus 1280px (email icon-only) jako stage przed hamburgerem.

## 31. Anchor decorative element na max-width, nie na viewport

Na 4K (3840px) `-8vw = -307px` driftuje element poza content. Anchor do `--maxw`:
```css
.hero__logo {
  right: calc(max(0px, (100vw - var(--maxw)) / 2) - 8vw);
}
```
Na viewport ≤ `--maxw` zachowuje `-8vw`. Na szerszych — prawa krawędź docisnięta do containera.

## 32. Belt-and-suspenders dla user requirements

Klient mówi "X zawsze w stanie Y" → enforce w >1 warstwie. Email lowercase: HTML lowercase attrs + CSS `text-transform: lowercase` + JS `.toLowerCase()`. Trzy niezależne warstwy.

## 33. Inverted CTA = section banner consistency

Project-specific: każde "Inne zapytanie" CTA używa inverted scheme: `background: var(--fg)`, `color: var(--bg)`, accent `var(--accent-2)`, hover `var(--accent-deep)`. Implementacja: `.mailto-card--inverted` (sekcja 5) lub `.service-other` banner (sekcja 2).

## 34. Mobile hamburger menu — phones-section struktura

```
.mobile-menu (absolute top: 100%, slides down, has `inert` when closed)
├── .mobile-menu__phones (2-col grid >420px, stack ≤420px)
│   └── 2× .mobile-menu__phone (gold pill, full "+48 511 478 232")
├── (hairline divider via border-bottom)
└── .mobile-menu__links (ul z 5 section links)
    └── li.a → <span class="mobile-menu__num">01</span><span>O nas</span>
```

JS: toggle przez `inert` + focus trap (`<main>` dostaje `inert` gdy menu open). Close triggers: scrim click, Escape, link click, resize ≥1081. Pełny wzorzec — #41.

## 35. JS reflow trick dla state-change po inert/display

`element.removeAttribute('inert'); element.setAttribute('data-open','true');` w jednym frame → browser coalesce'uje, transition nie triggeruje. Force reflow:
```js
menu.removeAttribute('inert');
void menu.offsetWidth;  // force reflow
menu.setAttribute('data-open', 'true');
```

## 36. PR description sync via `gh pr edit`

Po każdym pivocie: `gh pr edit <N> --body "$(cat <<'EOF' ... EOF)"`. Single-quoted HEREDOC chroni przed shell expansion.

## 37. Cloudflare _headers — semantics merge, nie first-match

Reguły z pasującymi globami są mergeowane per request. Konflikt nazwy headera → wygrywa bardziej specyficzny glob (`/fonts/*` nadpisuje `/*`). Security headers w `/*` przechodzą do `/fonts/*` i `/img/*`, bo te ustawiają tylko `Cache-Control` + CORS. NIE kopiować security headers do każdego bloku.

## 38. iframe sandbox — minimum necessary

Dla third-party iframe (Google Maps):
```html
<iframe src="..." loading="lazy" referrerpolicy="no-referrer-when-downgrade"
  sandbox="allow-scripts allow-same-origin allow-popups" title="..."></iframe>
```
NIE `allow-popups-to-escape-sandbox` / `allow-forms` / `allow-top-navigation` chyba że potrzebne. `referrerpolicy` chroni privacy.

## 39. PDF od klienta = source of truth — cross-check w obie strony

Anty: PDF → site only ("czy wszystko z PDF jest"). Pattern: także site → PDF — każdy claim na stronie bez odpowiednika w PDF jest podejrzany.

Audytuj: dane firmy, nazwy/kolejność usług, statystyki, spec sprzętu, mottos, claims marketingowe.

Raport: `KRYTYCZNE / BRAKUJĄCE / CLAIMS SPOZA PDF / ZGODNE`. NIE zmieniaj automatycznie — klient decyduje per item. Zobacz #48 dla regresji vs świadome pivoty.

## 40. Mailto template fields w nawiasach, nie po em-dash

Anty: "Rodzaj materiału — beton lub żelbet" (em-dash wygląda jak część nazwy pola).

Pattern: przykłady w nawiasach okrągłych — "Rodzaj materiału (beton, żelbet, mur)". Łatwiejsze do skasowania w final message.

## 41. `inert` zamiast `hidden` dla animowanych paneli

Anty: `hidden` toggled przez `setTimeout` po fade-out → ~240ms okno gdzie panel jest niewidoczny ale tabbable (WCAG 2.4.3 fail).

Pattern: `inert` blokuje Tab + AT natychmiast, element nadal renderuje. Plus focus trap przez `inert` na `<main>` gdy menu otwarte.
```js
const closeMenu = () => { menu.setAttribute('inert', ''); main?.removeAttribute('inert'); menu.removeAttribute('data-open'); };
const openMenu  = () => { menu.removeAttribute('inert'); main?.setAttribute('inert', ''); void menu.offsetWidth; menu.setAttribute('data-open', 'true'); };
```
Support: Chrome 102+/FF 112+/Safari 15.5+.

## 42. CSS RGB-triplet variable dla theme-aware rgba()

Para `--bg`/`--bg-rgb` (oraz `--fg`/`--fg-rgb`) — `rgba(var(--bg-rgb), 0.92)`. RGB triplet MUSI być w sync z hex. Replikowane per theme palette.

```css
:root { --bg: #f5f1e8; --bg-rgb: 245, 241, 232; --fg: #1a1614; --fg-rgb: 26, 22, 20; }
.nav { background: rgba(var(--bg-rgb), 0.92); }
```

Modern alt: `color-mix(in srgb, var(--bg) 92%, transparent)` (Chrome 111+/FF 113+/Safari 16.2+). NIE adoptowane — multi-theme map już zbudowana z RGB-triplets.

## 43. Unicode special chars saga (⌀) — font chain + size bump + Unicode-vs-SVG

Saga: Latin Ø wygląda jak przekreślone zero → inline SVG (duplikat 6×) → SVG sprite (kreska wewnątrz koła, anti-engineering) → **Unicode U+2300 `⌀` + font fallback chain** ✓

**(a) Explicit font-family chain** — woff2 subsety pokrywają Latin/Latin-Ext, NIE Misc Technical / Math Operators. Browser fallback → losowy serif. Chain musi celować w fonty które realnie mają glyph:
```css
.ic-diameter {
  font-family: 'Cambria Math', 'STIX Two Math', 'Lucida Sans Unicode',
               'Segoe UI Symbol', 'DejaVu Sans', sans-serif;
  font-style: normal;
  font-size: 1.5em;        /* (b) bump */
  line-height: 1;
  vertical-align: -0.05em;
  margin-inline: 0.02em;
}
```

**(b) Font-size bump 1.4-1.5em w caps/digit context** — math fonty renderują symbole na x-height (~70% cap-height), więc obok WIELKICH LITER wyglądają subscripted. `1/0.7 ≈ 1.43`. Em-unit skaluje przez konteksty — jedna reguła wszędzie.

**(c) Kiedy Unicode + font fallback vs inline SVG:**
- **Unicode**: symbol standardowy (math/technical/punctuation), system fonty go mają, wiele kontekstów o różnym font-size.
- **SVG**: custom brand glyph, pixel-perfect cross-platform, lub animacja na symbolu.

Alt: dodać `unicode-range: U+2300-23FF` subset do self-hosted woff2 (~5-10 KB).

## 44. [MERGED → #43]

## 45. Grid 1fr cells = nierówne wizualne odstępy przy variable content

Anty: `grid-template-columns: repeat(N, 1fr)` z content variable width (`PL` obok `Ø800mm`). Content at cell start, empty space różny po prawej → wizualny chaos. `border-right` jako separator pogłębia.

**A. Flex-column z `align-items: center`** — content wycentrowany w 1fr, optycznie spaced równo. Wybrane dla `.hero__stats` (4 staty, responsive 4→2×2 ≤1080 i ≤600px):
```css
.hero__stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 0 clamp(12px, 1.6vw, 24px); }
.stat { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 10px; }
```

**B. `auto` cols + `justify-content: space-between`** — tight do treści, browser daje equal gaps:
```css
.list { display: flex; justify-content: space-between; align-items: baseline; }
```

A = symetryczne kolumny + responsive wrap. B = equal gaps, kolumny różnej szerokości. NIE używać `border-right` z 1fr + variable content.

## 46. Strukturuj kod żeby revert był łatwy (meta)

User zmieni zdanie po feedback rounds. Code structured well (em-based + jeden `@supports` + jeden `@media` wrapper) = one-line revert. Hardcoded px + warstwy media queries = godzinny refactor.

Zasady: em/rem/% gdy proporcje skalują z context; jedna `@supports`/`@media` zamiast warstw; progressive enhancement default = uniwersalnie wspierane (#18); mobile overrides oddzielne od enhancement layer.

## 47. [MERGED → #43]

## 48. PDF od klienta vs wcześniejsze świadome decyzje — nie regresować

Anty: traktować nowy PDF jako pełny source of truth i regresować wcześniejsze decyzje klienta. PDF wysyłany "dla porządku" często zawiera nieaktualne fragmenty.

Pattern: cross-check PDF z `git log`. Każda rozbieżność PDF ↔ strona ma dwa źródła:
1. PDF świeższy → klient chce update (przyjmij)
2. Strona świeższa → świadomy pivot, PDF stale (zostaw)

Rozpoznać po commit history. Format raportu (rozszerzenie #39): dodaj kolumnę **"site newer than PDF — sprawdź czy świadomy pivot"**.

Project-specific dla KFDIAMENT (zatwierdzone 2026-05-14): **"wiele lat doświadczenia"** w `O nas` para 2 (NIE "3 lata"), hero stats bez liczby lat doświadczenia.

## 49. Theme system: rozdziel family od mode (data-theme + data-mode)

Anty: jeden atrybut `data-theme="logo-metallic-dark"` mieszający paletę z trybem — każda paleta = 2 wpisy, switching palety w dark mode wymaga ręcznych mapowań.

Pattern: dwa niezależne atrybuty na `<html>`:
- `data-theme="<slug>"` — aktywny slug palety (light lub dark variant)
- `data-mode="light"|"dark"` — gate dla `color-scheme`, ikon toggle, Dark Reader

Plus localStorage: `kfd_theme` (palette family, canonical light slug) + `kfd_mode`. JS lookup `THEME_PAIRS[family] → { light, dark }` daje aktywny slug. Toggle flipuje tylko mode — paleta zostaje; switching palety zachowuje obecny mode.

Anti-FOUC: ten sam `THEME_PAIRS` duplikowany inline w `<head>` bootstrap script ORAZ w głównym JS. Akceptujemy duplikację. Naming: dark slug = light slug + `-dark`. REVERSE_MIGRATE dla starych slugów (np. `logo-metallic` → family + `mode=dark`).

## 50. Dark Reader signal: color-scheme CSS + meta

Pattern dla "I have native dark mode, nie inwertuj":
1. `<meta name="color-scheme" content="light dark">` w `<head>`
2. `:root { color-scheme: light }` + `:root[data-mode="dark"] { color-scheme: dark }` — Dark Reader wyłącza auto-darkening
3. `<meta name="theme-color">` z `media="(prefers-color-scheme: light|dark)"` dla mobile address bar

Bez tego Dark Reader na dark mode robi double-invert.

## 51. flex space-between z 3 itemami push środek do dead-center

Anty: `[brand] [middle] [last]` z `justify-content: space-between` — z 3 itemami space-between rozkłada przestrzeń **między nimi równo**, middle ląduje w idealnym środku zamiast obok last.

Pattern: gdy chcesz "first left, last 2 grouped right", użyj `margin-left: auto` na drugim itemie. Pushuje go i wszystko po nim do prawej.

```css
@media (max-width: 540px) {
  .nav__theme-toggle { margin-left: auto; }
}
```

Case: na ≤540px zostają brand|toggle|burger; bez margin-left:auto toggle w dead center, z nim — toggle+burger pushed right group.

## 52. Toggle icon convention — show TARGET, nie current state

Anty: w light mode pokazuj sun (current state) — klik daje niejasny efekt.

Pattern: pokazuj TARGET — w light mode moon ("klik = pójdziesz w dark"), w dark mode sun ("klik = pójdziesz w light").

aria-label dynamicznie + `aria-pressed`:
- light: `aria-label="Przełącz motyw na ciemny"` + `aria-pressed="false"`
- dark: `aria-label="Przełącz motyw na jasny"` + `aria-pressed="true"`

## 53. Global attribute selector + JS href rewriter = retroaktywne capture

Anty: globalny `a[href^="mailto:"] { white-space: nowrap }` (dla obfuskowanych emaili w nav/footer) łapie też duże komponenty po tym jak JS na starcie podmienia ich `href="#kontakt"` → `href="mailto:..."`. Case KFDIAMENT: `.mailto-card` na 412px viewport (OnePlus 12) — tytuł/desc nie zawijały, min-content forsował grid track do ~492px, `overflow: hidden` na sekcji ucinał strzałki.

Pattern: zawęź selektor — `:not(.specific-class)` exclusion **albo** precyzyjniejszy scope (np. `.contact-block a[href^="mailto:"]`).

```css
a[href^="mailto:"]:not(.mailto-card) { white-space: nowrap; }
```

Kiedy: każdy globalny `a[href^=...]` / `a[target=...]` — przed merge'em sprawdź czy istnieje JS rewriter atrybutu który może retroaktywnie wciągnąć komponenty nieprzeznaczone. Case: commit 7426b83.

## 54. Nav breakpoint per realny pomiar widths, nie per common phone sizes

Anty: dobierz breakpoint na 460px bo "to mały telefon" / "iPhone SE". Realnie nie wiesz czy wszystko mieści się — wybór po nazwie urządzenia, nie po sumie szerokości elementów.

Pattern: zmierz sumę widths nav + paddingi + gaps + bufor 40-60px. Jeśli brand 86 + 1 phone (~140px) + 2× icon 44 + gaps 3×10 + padding 2×20 ≈ ~440-470px bez phones, to phones-hidden musi być **>470 z buforem** (np. 540).

Kiedy: każda nav z multiple buttons gdzie kolejność degradacji ma sense (#28). Case: commit e451883 — 486px (OnePlus 12) burger wypadał, bump 460 → 540.

## 55. Performance-first — scroll MUSI być lagfree (mandat klienta)

**Mandat klienta (zatwierdzony 2026-05-15, niepodważalny): strona musi być lagfree. Laggy scroll = niedopuszczalne. Performance-first przy KAŻDEJ zmianie wizualnej.** Przed dodaniem dowolnego efektu (cień, blur, blend, filtr, animacja) zadaj pytanie: "czy to jest przerysowywane podczas scrolla?". Jeśli tak — uzasadnij koszt albo nie dodawaj.

Anty (katalog scroll-jank wykryty 2026-05-15, potwierdzony empirycznie Chrome DevTools — A/B na żywo: wyłączenie tych efektów podniosło dark z ~55 do stabilnych 60 FPS = poziom light):

1. **`backdrop-filter: blur()` na `position: fixed` elemencie pełnej szerokości** (nav, mobile-menu) → blur re-liczony co klatkę scrolla nad zmienną treścią. Koszt rośnie ~kwadratowo z promieniem.
2. **Scroll-driven RAF loop piszący custom property na `:root`, która karmi `filter`/`drop-shadow`** (easter egg piły `initSawBlade`) → invalidacja filtra 60×/s. W dark mode 5-warstwowy `drop-shadow` blur do 280px na logo nav = ~10× paint vs light. **To była główna przyczyna „dark gorszy niż light".**
3. **`mix-blend-mode` na `position: fixed` full-viewport overlay** (`body::before` noise) → kompozytor re-miesza całą klatkę z przewijaną treścią. `multiply` na ciemnym tle droższy → kontrybucja do różnicy dark/light. Przy `opacity ≤ 0.05` efekt niewidoczny, koszt pełny.
4. **Odczyt geometrii (`scrollHeight`/`getBoundingClientRect`) w rAF-callbacku scrolla** (`updateProgress`) → forced synchronous layout co klatkę. Trace insight 80→111 ms / 5 s. Cache poza pętlą, odśwież na `resize`/`load`.
5. **Animacja `width`/`top`/`box-shadow`/`filter` zamiast `transform`/`opacity`** (scroll-progress `transition: width`) → layout/paint zamiast composite.

Wzorzec: rotacja/przesunięcie tylko przez `transform`; glow przez `opacity` osobnej composited warstwy (nie pulsujący promień blur w `filter`); fixed elementy → `contain: paint`; sekcje poniżej fold → `content-visibility: auto`; `will-change: transform` TYLKO na realnie animowanym elemencie (nigdy `filter`); efekt-gadżet podczas scrolla → rozważ on-hover-only lub usuń. Każdy nowy `drop-shadow`/`blur`/`blend` na fixed/animowanym elemencie = czerwona flaga do uzasadnienia.

Diagnostyka: 3 niezależne audyty kodu + 1 empiryczny profiling (Chrome DevTools MCP, CPU 4×, A/B na żywo) zbiegły się na tych samych przyczynach — triangulacja > pojedynczy audyt (#8 rozszerzenie). Wykluczone z dowodem: Dark Reader double-invert (sygnał `color-scheme` poprawny dla wszystkich palet), 404 ścieżek (wszystkie względne, 200), ciężki JS (0 long tasków). Pełna analiza: sesja 2026-05-15, tag `stable-2026-05-15-przed-perf` = stan przed naprawami.

Kiedy: każda zmiana dotykająca CSS efektów wizualnych lub JS na ścieżce scrolla. Audyt: grep `backdrop-filter|mix-blend-mode|drop-shadow|will-change|transition:\s*(width|top|left|height)` i sprawdź czy element jest fixed/animowany/w viewport podczas scrolla.

Zastosowane (commit „perf #55", saw-blade nav, zweryfikowane Chrome DevTools — dark 54→**60 FPS**, p95 22→17 ms, 0 zgubionych klatek):
- **`--saw-glow` (mnożnik promienia `drop-shadow` w `filter`) USUNIĘTY** z CSS+JS. `--saw-angle` (rotacja, `transform`) ZOSTAJE — transform jest kompozytowany, tani.
- **Statyczna wartość `filter` na elemencie animowanym `transform` JEST OK** — rasteryzowana raz, potem tylko composite. Zabójcza była tylko *zmienna* wartość filtra co klatkę (`calc(... * var(--saw-glow))`).
- **Halo dark = statyczny `radial-gradient` na `::before`**, odpięty od rotacji (malowany raz). Pułapka: `z-index:-1` wpadłby za półprzezroczyste tło `.nav`; fix = `isolation: isolate` na `<picture>` → lokalny kontekst stackingu (halo za logo, ale nad tłem nav).
- **Custom property sterujące co klatkę → pisz na lokalnym elemencie, NIE `:root`** (`navBrand.style.setProperty('--saw-angle')`) — zawęża zakres inwalidacji stylu; konsument musi być potomkiem.

## Skróty / przyspieszacze

- Lokalny preview: `python -m http.server 8000` → `http://localhost:8000`
- Walidacja schema: validator.schema.org
- Rich results: search.google.com/test/rich-results
- Lighthouse: Chrome DevTools → Lighthouse → Analyze
- Playwright MCP do regression testing po zmianach
