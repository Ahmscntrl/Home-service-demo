# Northline Home Services — Demo Site

A single-page demo website for a home-services / exterior-remodeling company (roofing focus), built as a portfolio piece. The look and structure are modeled on premium national remodelers: dark cinematic theme, bold condensed headlines, red accent, full-bleed hero, and scroll-driven animations.

**Stack:** plain HTML, CSS and JavaScript. No build step, no frameworks, no dependencies beyond Google Fonts.

## Run it

Open `index.html` directly, or serve the folder:

```bash
npx http-server . -p 8080
# → http://localhost:8080
```

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
