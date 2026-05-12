# Folder na grafiki

## Wymagane pliki

| Plik | Opis | Wymiary | Status |
|---|---|---|---|
| `logo.png` | Główne logo firmy (gold-on-black piła tarczowa z K&F) | min. 512×512 (kwadrat) | **wymagane przed deployem** |
| `og.jpg` | Open Graph preview do social media | dokładnie 1200×630 | wymagane (do dorobienia) |
| `realizacja-01.jpg` | Zdjęcie z realizacji #1 (placeholder w gallerii) | zalecane 800×1000 (4:5) | opcjonalne |
| `realizacja-02.jpg` | Zdjęcie z realizacji #2 | 800×1000 | opcjonalne |
| `realizacja-03.jpg` | Zdjęcie z realizacji #3 | 800×1000 | opcjonalne |

## Jak wrzucić logo

1. **W kliencie poczty / komunikatorze**: zapisz załącznik z logiem na dysk
2. Zapisz plik jako `D:\kfdiament_webiste\img\logo.png` (dokładnie ta nazwa)
3. Odśwież stronę w przeglądarce (Ctrl+F5)

## Format

- **PNG z przezroczystością** zalecany (logo jest okrągłe, kwadratowy plik z czarnym tłem PNG też zadziała, ale wtedy nie zobaczysz cieniowania w hero)
- **WebP** też zadziała — wystarczy nazwać `logo.webp` i zmienić ref w `index.html`
- **SVG** byłby najlepszy (perfect scale, mała waga) — jeśli klient ma source vector

## Jak podmienić placeholdery w galerii

Patrz `README.md` w głównym katalogu repo, sekcja "Galeria realizacji".
