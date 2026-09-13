# Home Services Demo Sites

Two demo websites for home-services / exterior-remodeling companies (roofing focus), built as portfolio pieces. Both are plain HTML, CSS and JavaScript with no build step, no frameworks, and no dependencies beyond Google Fonts.

| Demo | Path | Direction |
| --- | --- | --- |
| **Northline Home Services** | `index.html` + `css/` + `js/` | Dark cinematic single-page site modeled on premium national remodelers: condensed uppercase headlines, red accent, animated SVG hero, scroll-driven interactions. |
| **Summit Roofing Co.** | `summit/index.html` | Light navy-and-amber multi-page site in one file. Hash-based routing (`#/services/roof-replacement`), site search, project tracker, page-transition wipe, and a `CONFIG` object at the bottom of the file to re-skin the whole site per prospect. |

## Run them

Open either `index.html` directly, or serve the folder:

```bash
npx http-server . -p 8080
# Northline → http://localhost:8080
# Summit    → http://localhost:8080/summit/
```

---

# Northline Home Services

## What's in it

| Section | Features |
| --- | --- |
| Announcement bar + sticky header | Blur header that tightens on scroll and hides on scroll-down, services mega-menu, mobile drawer nav |
| Hero | Animated SVG night-storm scene (drifting clouds, rain, twinkling stars, chimney smoke), parallax, staggered headline line-reveal |
| Stats | Count-up counters triggered on scroll |
| Marquee | Infinite credential ticker |
| Why Northline | Six feature cards with cursor-tracking spotlight and icon hover states |
| Roofing System | Interactive exploded 7-layer roof diagram; click a layer or let it auto-cycle |
| Color visualizer | 12 shingle swatches that recolor the house preview live |
| Process | Four steps with an animated progress line |
| Before / After | Drag-to-compare slider (pointer + keyboard), auto nudge on first view |
| Reviews | Responsive carousel with dots, arrows, swipe and autoplay |
| Financing | Live monthly-payment estimator |
| Services grid | Tinted hover cards for all six trades |
| FAQ | Accessible accordion using `<details>` |
| Quote form | Three-step form with validation, phone formatting and animated success state |
| Footer + mobile CTA | Sticky call/quote bar on phones, back-to-top button, scroll progress bar |

Everything respects `prefers-reduced-motion`.

## Swapping in real photos

All imagery is inline SVG so the demo renders anywhere with no external image dependencies. To use photography, replace these blocks with `<img>` or `background-image`:

- `.hero__media` → hero photo/video
- `.colors__preview svg` → house photo (the shingle recolor works on the SVG pattern; for photos use a set of pre-rendered images per color)
- `.compare__before svg` / `.compare__after svg` → before/after photos

## Customizing

Brand colors, fonts and spacing live as CSS custom properties at the top of `css/styles.css`. Company name, phone number and copy are all in `index.html`. The form is front-end only; wire the `submit` handler in `js/main.js` to your CRM or form endpoint.
