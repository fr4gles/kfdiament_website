# CLAUDE.md — kontekst projektu dla przyszłych sesji

Ten plik jest dla **przyszłych iteracji Claude Code** pracujących nad tym repozytorium. Zawiera kluczowe decyzje, konwencje i pułapki — żeby nie odkrywać tego samego za każdym razem.

## Czym jest projekt

Statyczna **strona-wizytówka** firmy **KFDIAMENT Obrębski Motyka Spółka jawna** (cięcie i wiercenie diamentowe betonu, osadzanie kotew chemicznych — działają na terenie całej Polski, siedziba: Grybów, Grunwaldzka 9).

Hostowana na **Cloudflare Pages** (free tier), domena docelowa: **kfdiament.pl**. GitHub remote: `fr4gles/kfdiament_website`.

## Stack — świadome ograniczenia

To **NIE jest** projekt JS-framework. Świadomie:

- **Jeden plik** `index.html` (HTML + CSS + JS inline). Nie rozbijać na osobne pliki bez bardzo dobrego powodu.
- **Vanilla JS** — bez React, Vue, frameworków. Skrypt ma <100 linii.
- **Bez build-stepu** — `package.json` nie ma i nie powinno się pojawić.
- **Bez npm/yarn/pnpm**.
- **Google Fonts przez `<link>`** — Big Shoulders (display, variable wght 500-900 + opsz 10-72), Manrope (body), JetBrains Mono (etykiety techniczne).
- **Bez CSS frameworków** (Tailwind, Bootstrap, etc.).
- **Bez bibliotek JS** (lightbox, slider, animation library — wszystko vanilla).

**Powód:** Cloudflare Pages preset = `None`, build command pusty, output `/`. Cała wartość tego setupu pochodzi z prostoty.

## Struktura plików

```
.
├── index.html       — cała strona (jeden plik, ~62 KB)
├── README.md        — dokumentacja dla człowieka (deploy, lokalny preview, SEO)
├── COMPARISON.md    — raport porównawczy vs diamtar.pl (konkurencja)
├── CLAUDE.md        — TEN PLIK (kontekst dla przyszłego Claude)
├── robots.txt       — pozwala indeksować, wskazuje sitemapę
├── sitemap.xml      — jeden URL (strona główna)
├── .gitignore       — system files, edytory, Cloudflare local
└── img/             — assety (poza repo do momentu wrzucenia loga)
    ├── logo.png     — gold-on-black okrągłe logo z K&F monogramem
    └── og.jpg       — Open Graph preview 1200×630 (do dorobienia)
```

## Branch strategy

- **Główny branch nazywa się `master`** (NIE `main`). Nie zmieniać.
- Praca na branchach `feat/...`, `fix/...`, PR-y do `master`.
- Pierwszy branch: `feat/landing-page`.

## Paleta kolorów — i CZEMU taka

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

**Kluczowa decyzja:** **NIE jest to Hilti red.** Wcześniejsza wersja była, ale klient pokazał logo (gold-on-black) i paleta została zpivotowana pod **brand identity logo**. Antique brass `#a8842c` był wybrany świadomie zamiast `#ffd700` (disco) lub `#b8923a` (zbyt żółty) — to "antique brass / aged bronze", daje premium feel bez krzykliwości.

Dark theme variant siedzi w komentarzu na początku `<style>` w `index.html` — wystarczy podmienić wartości w `:root`.

## Typografia

- **Big Shoulders** (Display, variable) — display sans, weight 500-900 + optical size axis 10-72. Industrial DNA: zaprojektowany przez Patric King z odwołaniem do Chicago "city of big shoulders" (Carl Sandburg) — fabryczne szyldy, railway signage, hot-rolled steel. **Dobrany świadomie** po analizie 3 alternatyw (Bricolage Grotesque, Hanken Grotesk): wygrywa scoringiem 53/60 vs 44 i 35 — perfect contrast z humanist Manrope body, autentyczne PL diakrytyki (Latin Extended-A coverage), industrial premium feel. Domyślnie `font-weight: 600` na display elementach, `700-800` na hero/brand, `900` na akcentach. **Brak italic w rodzinie** — używa się `color: var(--accent)` + heavier weight zamiast italic na `<em>`.
- **Manrope** — body. Geometryczny humanist sans, świetne PL znaki, idealny kontrast z condensed Big Shoulders display.
- **JetBrains Mono** — etykiety techniczne (`/ 01`, `01 — O nas`), spec lines, tagi mono. NIE używać do długich akapitów.

**Hero h1**: trzy-linijkowy, `clamp(2.8rem, 9.5vw, 8.2rem)`, środkowe słowo `outline` (text-stroke 2px), trzecie `accent` (gold weight 900, BEZ italic — brutalist purity). Letter-spacing minimalnie dodatnie (`0.005em`) bo Big Shoulders jest naturalnie condensed. Wszystkie display elementy używają `font-variation-settings: 'opsz' N` gdzie N matches actual font-size (72 dla hero, 48 dla section titles, 24 dla card titles).

## Struktura sekcji (nie zmieniać kolejności bez powodu)

1. Nav (fixed, blur, height=72px)
2. Hero (full vh, slow-spin logo absolute top-right)
3. `#o-nas` (bg-2, 5 akapitów + corner-card "Dlaczego my?")
4. `#uslugi` (3 service cards — Cięcie, Wiercenie, **Osadzanie kotew**)
5. `#realizacje` (bg-2, 3 gal-card z placeholderami)
6. `#sprzet` (bg-3 gradient, ogromny "HILTI" w tle)
7. `#kontakt` (4 contact-blocks + 4 mailto-cards + map iframe)
8. Footer (bg-2, brand+dane+kontakt)

## Mailto-cards — pattern

Sekcja kontakt **NIE ma `<form>`**. Zamiast tego 4 karty `<a class="mailto-card" data-mailto="KEY">`. JS na końcu pliku:

1. Patrzy na `data-mailto`
2. Bierze obiekt `queries[key]` z subject + intro + fields
3. Generuje `mailto:kontakt@kfdiament.pl?subject=...&body=...` z `encodeURIComponent`
4. Ustawia `href` na link

**Klucze obecnie:** `ciecie`, `wiercenie`, `kotwy`, `ogolne`. **Service card 3 to "Osadzanie kotew"** — wcześniej było "Wyburzenia" i kluczem był `wyburzenia`. **Nie pomylić**.

Subjecty są **bez nawiasów/symboli technicznych** — biuro czyta inbox, klient pisze maila, oba powinny czytać się naturalnie:
- `Wycena - Cięcie betonu - zapytanie ze strony`
- `Wycena - Wiercenie otworów - zapytanie ze strony`
- `Wycena - Osadzanie kotew - zapytanie ze strony`
- `Kontakt ze strony - zapytanie ogólne`

Body kończy się stopką `Wiadomość wysłana ze strony kfdiament.pl` — żeby biuro wiedziało skąd przyszło.

## Dane firmy (hardkodowane — NIE zmieniać bez prośby klienta)

- Nazwa: KFDIAMENT Obrębski Motyka Spółka jawna
- NIP: `7343669611`
- REGON: `54455908000000`
- Adres: Grunwaldzka 9, 33-330 Grybów
- Telefony: `+48 511 478 232`, `+48 511 478 182`
- E-mail: `kontakt@kfdiament.pl` (**zawsze małą literą** — w UI, mailto, schema.org, footerze)

Te dane są w **wielu miejscach**: nav CTA, footer, contact-blocks, JSON-LD `LocalBusiness`, hero stats, opisy. Gdy klient prosi o zmianę — `grep` po starej wartości i podmieniaj **wszędzie**.

## SEO — co zostało zrobione

- 3 schematy JSON-LD: `LocalBusiness` (z `hasOfferCatalog` zawierającym 3 `Service`), `Organization`, `WebSite`
- Open Graph + Twitter Card (z `og:image` 1200×630 — plik do dorobienia)
- `<title>` + `<meta description>` + canonical + hreflang `pl` + `x-default`
- `robots.txt` + `sitemap.xml`
- Semantic HTML5 (`<nav>`, `<header>`, `<section>`, `<article>`, `<aside>`, `<footer>`)
- Alt texts WCAG-compliant (puste dla dekoracyjnych logo, bo wordmark dubluje)
- `prefers-reduced-motion` obsługiwane

## Performance — micro-optymalizacje na miejscu

- **CSS inline** (0 zewnętrznych stylesheets)
- **JS inline na końcu body** (nie blokuje render)
- **Google Fonts preconnect** + `display=swap`
- **`<link rel="preload" as="image">` na logo** (LCP candidate)
- **`fetchpriority="high"` + `decoding="async"`** na hero logu
- **`loading="lazy"`** na footer img + map iframe
- **`prefers-reduced-motion`** wycina animacje
- **SVG noise** jako data URI (zero requestów na grain texture)

**Po deployu spodziewany Lighthouse**: 95-100 / 95-100 / 95-100 / 100.

## Galeria realizacji — placeholdery vs zdjęcia

Galeria ma 3 karty `.gal-card.placeholder` z CSS-owym patternem industrialnym (3 warianty: domyślny, `placeholder-pattern-2`, `placeholder-pattern-3`).

**Aby podmienić na zdjęcie:**

1. Wrzucić plik do `img/realizacja-XX.jpg` (zalecane WebP, 800×1000px, aspect 4:5)
2. Usunąć klasę `placeholder` + opcjonalnie `placeholder-pattern-N`
3. Dodać inline `style="background-image: url('img/realizacja-XX.jpg')"`

Komentarz HTML w pliku zawiera instrukcję — szukaj `=== EDYCJA GALERII ===`.

## Czego NIE robić

- **NIE dodawać `<form>` kontaktowego** — świadoma decyzja: mailto-cards są szybsze (klient od razu ma pre-fill), tańsze (zero backendu), bezpieczniejsze (brak XSS/spam vector).
- **NIE dodawać Google Maps JavaScript API** — używamy **darmowego embed iframe** (`maps.google.com/maps?q=...&output=embed`). Bez API key, bez kosztów.
- **NIE dodawać emoji jako ikon** — wszystkie ikony to SVG inline (Lucide-style, stroke style).
- **NIE dodawać stockowych obrazków** — placeholdery CSS na razie, klient daje swoje zdjęcia.
- **NIE dodawać cookies bannera ani Google Analytics** — to wizytówka. Jeśli klient zechce statystyk → **Cloudflare Web Analytics** (bez cookies, bez RODO bannera).
- **NIE używać czerni `#000` i bieli `#fff`** — używać `var(--fg)` i `var(--bg)` (warm tones).
- **NIE rozbijać `index.html` na komponenty** — to świadoma decyzja architektoniczna.

## Pułapki / lessons learned

- **`@keyframes slow-spin`** na hero logu obraca CAŁE logo wraz z napisem "K&F" — to świadome (logo to piła tarczowa). Ale uważać przy mikrointerakcjach żeby nie dodawać dodatkowych obrotów konfliktujących.
- **Polish characters w URL-encode**: Grybów → `Gryb%C3%B3w` w iframe Google Maps src.
- **`text-stroke`** na hero h1 `outline` wymaga `-webkit-` prefix (Firefox też go obsługuje).
- **`mailto:` body** musi być `encodeURIComponent`-owane — newlines `\n` zamieniają się na `%0A`, ale Outlook/Gmail dekodują OK.
- **Cloudflare Pages** trzeba podłączyć przez GitHub (nie wgrywać ZIP-em) — wtedy każdy push do `master` triggeruje deploy.
- **GitHub default branch to `master`**, nie `main` (decyzja klienta).
- **Logo plik `img/logo.png`** — musi być wrzucony PRZED pierwszym pushem, inaczej widać złamane obrazki na pierwszej wersji deploya.

## Roadmap (priorytety do dorobienia)

1. **`img/logo.png`** — konieczne przed pierwszym pushem
2. **`img/og.jpg`** — preview social media (1200×630)
3. **3-9 zdjęć realizacji** — podmienić placeholdery
4. **Google Business Profile** — kluczowe dla lokalnego SEO
5. **Cloudflare Web Analytics** — darmowe statystyki bez RODO
6. **Osobne podstrony usług** (`/ciecie-betonu`, `/wiercenie-otworow`, `/osadzanie-kotew`) — DIAMTAR ma, my nie mamy
7. **FAQ sekcja** — bezpośredni ranking signal w Google
8. **Strona z opiniami klientów** — DIAMTAR ma 4 testimoniale
9. **Favicon set** — `realfavicongenerator.net` wygeneruje pakiet (apple-touch, icon-192, icon-512, manifest)
10. **Logo SVG** zamiast PNG (mniejsze + perfect scale)

## Skróty / przyspieszacze pracy

- Lokalny preview: `python -m http.server 8000` → `http://localhost:8000`
- Walidacja schema: [validator.schema.org](https://validator.schema.org/)
- Rich results test: [search.google.com/test/rich-results](https://search.google.com/test/rich-results)
- Lighthouse: Chrome DevTools → Lighthouse → Analyze
