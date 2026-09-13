# Northline Home Services — Demo Site

A demo website for a home-services / exterior-remodeling company (roofing focus), built as a portfolio piece and designed to be re-skinned per prospect. The look is modeled on premium national remodelers: dark cinematic theme, bold condensed uppercase headlines, red accent, animated full-bleed hero, and scroll-driven interactions.

**Stack:** plain HTML, CSS and JavaScript. No build step, no frameworks, no dependencies beyond Google Fonts. Routing is hash-based (`#/services/roof-replacement`), so the whole site works as static files on any host with zero server configuration.

## Run it

Open `index.html` directly, or serve the folder:

```bash
npx http-server . -p 8080
# → http://localhost:8080
```

## Re-skin per prospect

Everything visible on the site lives in **`js/config.js`**: brand name, phone, hours, accent color, every headline and paragraph, the nav groups, all 20 sub-pages, shingle swatches, feature cards, stats, reviews, tracker steps, FAQ groups, and the quote form's service chips. Change that one file and the whole site (home page, every sub-page, nav, footer, search index) updates.

- `brand.colors.accent` recolors buttons, highlights, the logo mark and the page wipe.
- Each entry in `nav[]` becomes a landing page (`#/services`) and each of its `items[]` becomes its own page (`#/services/windows`) with hero, copy, "what's included" cards, related pages, and a quote form.
- Items flagged `home: true` also appear in the home-page services grid.

## What's in it

| Section | Features |
| --- | --- |
| Announcement bar + sticky header | Blur header that tightens on scroll and hides on scroll-down, mega-menus for every nav group, site search button, mobile drawer with expandable groups |
| Site search | Full-screen overlay indexing every page and FAQ, with top-search chips and instant results |
| Hero | Animated SVG night-storm scene (drifting clouds, rain, twinkling stars, chimney smoke), parallax, staggered headline reveal |
| Stats | Count-up counters triggered on scroll |
| Marquee | Infinite credential ticker |
| Why Northline | Six feature cards with cursor-tracking spotlight and icon hover states |
| Roofing System | Interactive exploded 7-layer roof diagram; click a layer or let it auto-cycle |
| Color visualizer | 12 shingle swatches that recolor the house preview live |
| Process | Four steps with an animated progress line |
| Before / After | Drag-to-compare slider (pointer + keyboard), auto nudge on first view |
| Reviews | Responsive carousel with dots, arrows, swipe and autoplay |
| Project tracker | Floating phone mockup with animated job status steps and progress bar |
| Financing | Live monthly-payment estimator |
| Services grid | Tinted hover cards linking to each service page |
| FAQ | Tabbed groups with an accessible `<details>` accordion |
| Quote form | Three-step form with validation, phone formatting and animated success state; reused on every sub-page |
| Sub-pages | 20 config-driven pages with page-transition wipe, breadcrumbs, sticky quote sidebar, "what's included" and related pages |
| Footer + mobile CTA | Config-driven link columns, sticky call/quote bar on phones (hides while a form is on screen), back-to-top, scroll progress bar |

Everything respects `prefers-reduced-motion`.

## Swapping in real photos

All imagery is inline SVG so the demo renders anywhere with no external image dependencies. To use photography, replace these blocks in `index.html` with `<img>` or `background-image`:

- `.hero__media` → hero photo/video
- `.colors__preview svg` → house photo (the shingle recolor works on the SVG pattern; for photos use a set of pre-rendered images per color)
- `.compare__before svg` / `.compare__after svg` → before/after photos

## Files

```
index.html        page shell + hand-drawn SVG scenes
css/styles.css    design tokens and all styles
js/config.js      per-prospect content and settings (edit this)
js/main.js        rendering, router, search, interactions
summit/           earlier light-theme variant kept for reference
```

The form is front-end only; wire the `submit` handler in `js/main.js` to your CRM or form endpoint.
