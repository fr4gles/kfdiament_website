# KFDIAMENT — strona-wizytówka

Statyczna jednoplikowa strona-wizytówka firmy **KFDIAMENT Obrębski Motyka Spółka jawna**
(cięcie i wiercenie diamentowe betonu, wyburzenia konstrukcji — cała Polska).

## Stack

- Czysty HTML5 + CSS + vanilla JS — wszystko inline w `index.html` (bez build-stepu, bez npm).
- Self-hosted variable woff2 z `/fonts/` (Big Shoulders Display, Manrope, JetBrains Mono) — same-origin, bez Google Fonts CDN.
- Hosting: GitHub + Cloudflare Pages (free tier).

## Struktura plików

```
.
├── index.html       — cała strona (HTML + CSS + JS inline)
├── _headers         — Cloudflare HTTP headers (security + cache)
├── robots.txt, sitemap.xml
├── scripts/optimize-logo.ps1   — generator wariantów WebP + favicony
├── fonts/           — self-hosted woff2 (6 plików)
└── img/             — logo + warianty WebP + og.jpg + galeria
```

## Lokalny podgląd

Najprostszy serwer (wymagane dla iframe Google Maps — `file://` nie zadziała):

```powershell
python -m http.server 8000
# albo: npx serve .
```

Otwórz [http://localhost:8000](http://localhost:8000). Alternatywnie: VS Code → rozszerzenie **Live Server** → prawym na `index.html` → Open with Live Server.

Quick check po zmianie: klikalność telefonów i maili, mapa Google się ładuje, layout nie pęka przy resize, DevTools → Lighthouse audit.

## Pierwszy deploy

### 1) Logo + skrypt optymalizacji

Zapisz źródło jako `img/logo.png` (zalecane **512×512+**, PNG z przezroczystym tłem). Uruchom:

```powershell
pwsh -File scripts/optimize-logo.ps1
```

Skrypt auto-wykrywa narzędzia w kolejności: **ImageMagick** → **ffmpeg** → **sharp** (npx/npm). Generuje `logo.webp` (512), `logo-1024.webp` (hero LCP), `logo-96.webp` (nav thumb), `favicon-32.png`, `apple-touch-icon.png` (180×180).

HTML używa `<picture>` z WebP + PNG fallback — bez skryptu strona dalej działa, tylko bez performance win.

### 2) Push do GitHuba

```bash
git add img/logo.png
git commit -m "feat: add company logo"
git push -u origin master
```

### 3) Cloudflare Pages

Dashboard → **Workers & Pages → Create → Pages → Connect to Git** → repo `fr4gles/kfdiament_website`. Konfiguracja:

| Pole | Wartość |
|---|---|
| Production branch | `master` |
| Framework preset | **None** |
| Build command | _(puste)_ |
| Build output directory | `/` |
| Environment variables | _(brak)_ |

**Save and Deploy** → po ~30s adres `https://kfdiament.pages.dev`. Każdy push do `master` = auto-deploy. Pushe na inne branche = preview URL.

`_headers` w repo jest czytany automatycznie (security headers + długi cache fontów/obrazków, krótki HTML).

## Post-deploy checklist (KRYTYCZNE — jednorazowo)

### Cloudflare Dashboard

- **Scrape Shield → Email Address Obfuscation: ON** (2. warstwa anti-spam, pokrywa też JSON-LD)
- **SSL/TLS → Full (strict)** + **Always Use HTTPS** + HSTS (już mamy w `_headers`, CF dodaje warstwę edge)
- **Analytics & Logs → Web Analytics → Add a site** — skopiuj snippet przed `</body>` (RUM Core Web Vitals, bez cookies, bez RODO bannera)
- **Speed → Optimization**: Brotli ON, Early Hints ON, 0-RTT ON. Auto Minify — opcjonalne (zachowuje czytelny `view-source` jeśli OFF).

### Custom domain `kfdiament.pl`

Pages → deployment → **Custom domains → Set up a custom domain** → `kfdiament.pl` i `www.kfdiament.pl`. Cloudflare poda rekordy DNS (CNAME na `kfdiament-website.pages.dev`). Jeśli domena nie jest jeszcze w Cloudflare DNS — przełącz nameservery lub dodaj rekordy u rejestratora. SSL Let's Encrypt generuje się 1-15 min.

### SEO

1. **Google Search Console** ([search.google.com/search-console](https://search.google.com/search-console)) — dodaj jako domain property, weryfikacja TXT w Cloudflare DNS, submit `https://kfdiament.pl/sitemap.xml`.
2. **Bing Webmaster Tools** — import z Search Console (1 klik), submit sitemap.
3. **Google Business Profile** ⭐ NAJWAŻNIEJSZE dla lokalnego biznesu — kategoria "Firma budowlana / wyburzeniowa", adres Grunwaldzka 9 33-330 Grybów, telefony, zdjęcia realizacji. Listing pojawia się w Local Pack + Knowledge Panel.
4. Walidacja: [validator.schema.org](https://validator.schema.org/) + [Rich Results Test](https://search.google.com/test/rich-results).

### Verify

- Lighthouse mobile + desktop (expected 95-100/95-100/95-100/100).
- [pagespeed.web.dev](https://pagespeed.web.dev) — real-world Core Web Vitals.
- View source (Ctrl+U) → szukaj `kontakt@kfdiament.pl` — powinno być **tylko w JSON-LD**, nie w body HTML.
- Kliknij każdą z 4 mailto-cards → każda inny temat + body.

### Maintenance (raz / miesiąc–kwartał)

- Search Console → Coverage (czy wszystko zaindeksowane).
- Cloudflare Analytics → top pages + referrers.
- Google Business Profile → odpowiadać na opinie + nowe zdjęcia realizacji.

## Edycja treści

Cała treść w `index.html`. Najczęstsze edycje:

| Co zmienić | Gdzie szukać |
|---|---|
| Numery telefonów | szukaj `tel:+48511478232` (nav, mobile menu, footer, contact, JSON-LD) |
| E-mail | `kontakt@kfdiament.pl` + obfuskowane `data-u="kontakt" data-d="kfdiament.pl"` |
| Tekst hero | `<header class="hero">` |
| O nas / Usługi / Sprzęt | sekcje `id="o-nas"`, `id="uslugi"`, `id="sprzet"` |
| Adres / NIP / REGON | footer + JSON-LD `LocalBusiness` |
| Mailto-presety | obiekt `queries` w `<script>` na końcu |

### Galeria realizacji

3 karty mają CSS-owe placeholdery. Aby podmienić na zdjęcie:

1. Wrzuć `img/realizacja-01.jpg` (zalecane **800×1000px**, aspect 4:5).
2. W `index.html` znajdź `<article class="gal-card placeholder reveal">`.
3. Usuń `placeholder` + `placeholder-pattern-N`, dodaj inline `style="background-image: url('img/realizacja-01.jpg')"`.

### Mapa Google

Darmowy embed iframe (bez API key). Aby zmienić lokalizację — zmień parametr `q=` w `iframe src="https://maps.google.com/maps?q=..."`.

## Kolory

Wszystkie kolory w CSS custom properties w `:root` (`index.html`). Paleta: **antique brass + warm cream + warm black** (dobrana pod logo).

```css
--accent:       #a8842c;   /* antique brass — primary gold */
--accent-hover: #7d5f1c;   /* deeper bronze */
--bg:           #f5f1e8;   /* warm cream paper */
--fg:           #1a1614;   /* warm near-black */
```

Pełen wariant dark theme jest w komentarzu na początku `<style>` — podmiana 11 wartości w `:root`.

## Co warto dodać dalej

- [ ] `img/og.jpg` (1200×630) — preview do social media.
- [ ] Galeria — 3+ realne zdjęcia z realizacji.
- [ ] Page rule w Cloudflare — przekierowanie `www.kfdiament.pl` ↔ `kfdiament.pl` (wybierz jedno).
- [ ] Strony usług (przyszłość): `/ciecie-betonu`, `/wiercenie`, `/wyburzenia` — SEO long-tail.

## Linki przydatne

- [Cloudflare Pages docs](https://developers.cloudflare.com/pages/)
- [Google Search Console](https://search.google.com/search-console)
- [Schema.org validator](https://validator.schema.org/) · [Rich Results Test](https://search.google.com/test/rich-results)

---

© 2026 KFDIAMENT Obrębski Motyka Spółka jawna · NIP 7343669611
