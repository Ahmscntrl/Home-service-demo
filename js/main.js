/* =========================================================
   Northline Home Services — app
   Renders everything from window.CONFIG (js/config.js), then wires
   interactions, the site search, and the hash router for sub-pages.
   Vanilla JS, no dependencies.
   ========================================================= */
(() => {
  'use strict';
  const C = window.CONFIG;
  const $ = (sel, ctx = document) => ctx.querySelector(sel);
  const $$ = (sel, ctx = document) => Array.from(ctx.querySelectorAll(sel));
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const canHover = window.matchMedia('(hover: hover)').matches;
  const tel = 'tel:' + C.brand.phone.replace(/[^\d+]/g, '');
  const esc = s => String(s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const get = path => path.split('.').reduce((o, k) => (o == null ? o : o[k]), C);

  /* ---------- brand colors ---------- */
  const root = document.documentElement.style;
  if (C.brand.colors?.accent) {
    root.setProperty('--red', C.brand.colors.accent);
    root.setProperty('--red-dark', C.brand.colors.accentDark || C.brand.colors.accent);
    const h = C.brand.colors.accent.replace('#', '');
    const [r, g, b] = [0, 2, 4].map(i => parseInt(h.slice(i, i + 2), 16));
    root.setProperty('--red-glow', `rgba(${r},${g},${b},.35)`);
  }

  /* ---------- icons (48x48 stroke) ---------- */
  const ICONS = {
    home: '<path d="M8 26 24 10l16 16" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linejoin="round"/><path d="M12 24v14h24V24" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M18 32h12" stroke="currentColor" stroke-width="2.5"/>',
    drop: '<path d="M24 6c8 8 12 14 12 20a12 12 0 0 1-24 0c0-6 4-12 12-20Z" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M24 22c3 3 5 5 5 8a5 5 0 0 1-10 0c0-3 2-5 5-8Z" fill="currentColor"/>',
    vent: '<path d="M8 30h32M8 22h32M8 14h32" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/><path d="M16 38h16" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>',
    shield: '<path d="M24 6 8 12v12c0 9 7 15 16 18 9-3 16-9 16-18V12L24 6Z" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M17 24l5 5 9-10" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>',
    crew: '<circle cx="24" cy="18" r="8" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M8 42c2-8 8-12 16-12s14 4 16 12" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>',
    calendar: '<rect x="8" y="10" width="32" height="28" rx="3" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M8 18h32M16 6v8M32 6v8" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/><path d="M16 28l4 4 8-8" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>',
    window: '<rect x="10" y="8" width="28" height="32" rx="2" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M24 8v32M10 24h28" stroke="currentColor" stroke-width="2.5"/>',
    siding: '<path d="M8 12h32M8 20h32M8 28h32M8 36h32" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/><path d="M16 12v8M28 20v8M20 28v8" stroke="currentColor" stroke-width="2.5"/>',
    door: '<rect x="14" y="6" width="20" height="36" rx="2" fill="none" stroke="currentColor" stroke-width="2.5"/><circle cx="29" cy="25" r="2" fill="currentColor"/>',
    solar: '<rect x="8" y="14" width="32" height="20" rx="2" transform="skewX(-10)" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M16 14v20M24 14v20M32 14v20M8 24h32" transform="skewX(-10)" stroke="currentColor" stroke-width="1.8"/>',
    gutter: '<path d="M6 16h36v6a5 5 0 0 1-5 5H11a5 5 0 0 1-5-5Z" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M34 27v15" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>',
    wind: '<path d="M6 16h20a5 5 0 1 0-5-5M6 26h26a5 5 0 1 1-5 5M6 21h14" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>',
    tools: '<path d="M8 40l10-10M30 8l10 10M18 30l12-12M14 34l-2-2M36 16l-4-4" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/><path d="M28 18a6 6 0 1 0 8-8l-4 4-2-2 4-4a6 6 0 0 0-8 8Z" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linejoin="round"/>',
    flag: '<path d="M10 42V6" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/><path d="M10 8h26l-6 8 6 8H10" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linejoin="round"/>',
    heart: '<path d="M24 40S8 30 8 18a8 8 0 0 1 16-2 8 8 0 0 1 16 2c0 12-16 22-16 22Z" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linejoin="round"/>',
    star: '<path d="m24 6 5.5 11.5L42 19l-9 8.5L35.5 40 24 33.5 12.5 40 15 27.5 6 19l12.5-1.5Z" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linejoin="round"/>',
    briefcase: '<rect x="6" y="14" width="36" height="26" rx="3" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M18 14V9h12v5M6 26h36" stroke="currentColor" stroke-width="2.5"/>',
    phone: '<rect x="14" y="4" width="20" height="40" rx="4" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M21 38h6" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>',
    doc: '<path d="M12 6h16l10 10v26H12Z" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linejoin="round"/><path d="M28 6v10h10M18 26h12M18 33h12" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/>',
    check: '<circle cx="24" cy="24" r="17" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="m15 24 6 6 12-13" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>',
    clock: '<circle cx="24" cy="24" r="17" fill="none" stroke="currentColor" stroke-width="2.5"/><path d="M24 13v11l7 5" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>',
    photo: '<rect x="6" y="10" width="36" height="28" rx="3" fill="none" stroke="currentColor" stroke-width="2.5"/><circle cx="18" cy="20" r="3" fill="currentColor"/><path d="m8 36 11-10 7 6 6-5 8 8" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linejoin="round"/>'
  };
  const icon = (k, cls = '') => `<svg class="${cls}" viewBox="0 0 48 48" aria-hidden="true">${ICONS[k] || ICONS.home}</svg>`;
  const ARROW = '<svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg>';
  const CHEV = '<svg width="12" height="12" viewBox="0 0 12 12" aria-hidden="true"><path d="M2 4l4 4 4-4" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>';

  /* ---------- fill static [data-c] slots ---------- */
  const fill = (scope = document) => $$('[data-c]', scope).forEach(el => {
    const k = el.dataset.c;
    if (k === 'brand.phoneLink') { el.href = tel; return; }
    const v = get(k);
    if (v == null) return;
    if (el.hasAttribute('data-html')) el.innerHTML = v; else el.textContent = v;
  });
  fill();
  document.title = `${C.brand.legalName} | Roofing Built to Outlast the Weather`;
  $('#year').textContent = new Date().getFullYear();

  /* ---------- templates ---------- */
  const serviceCard = (g, it, delay = 0) => `
    <a href="#/${g.slug}/${it.s}" class="service reveal" data-reveal data-delay="${delay}" style="--tint:${it.tint || 'var(--red)'}">
      <div class="service__art">${icon(it.icon)}</div>
      <h3>${esc(it.t)}</h3><p>${esc(it.d)}</p><span class="service__arrow">→</span>
    </a>`;
  const featureCard = (f, delay = 0) => `
    <article class="feature reveal" data-reveal data-delay="${delay}">
      <div class="feature__icon">${icon(f.icon)}</div>
      <h3>${esc(f.t)}</h3><p>${esc(f.d)}</p>
    </article>`;
  const chip = (s, checked) => `<label class="chip"><input type="checkbox" name="service" value="${esc(s)}"${checked ? ' checked' : ''}><span>${esc(s)}</span></label>`;

  const quoteHTML = (title = C.quote.head, lede = C.quote.lede) => `
  <section class="section quote" id="quote">
    <div class="container quote__grid">
      <div class="quote__copy reveal" data-reveal>
        <p class="eyebrow">${esc(C.quote.eyebrow)}</p>
        <h2>${title}</h2>
        <p class="lede">${esc(lede)}</p>
        <ul class="checklist checklist--light">${C.quote.list.map(l => `<li>${esc(l)}</li>`).join('')}</ul>
        <div class="quote__phone"><small>Prefer to talk?</small><a href="${tel}">${esc(C.brand.phone)}</a></div>
      </div>
      <form class="form reveal" data-reveal data-delay="120" novalidate>
        <div class="form__steps" aria-hidden="true"><span class="is-active"></span><span></span><span></span></div>
        <fieldset class="form__step is-active" data-step="1">
          <legend>What are you interested in?</legend>
          <div class="chips">${C.quote.services.map((s, i) => chip(s, i === 0)).join('')}</div>
          <label class="field"><span>ZIP code</span><input type="text" name="zip" inputmode="numeric" maxlength="5" placeholder="20001" required><em class="field__err">Enter a 5-digit ZIP code</em></label>
          <button type="button" class="btn btn--primary btn--block" data-next>Continue</button>
        </fieldset>
        <fieldset class="form__step" data-step="2">
          <legend>Tell us about your home</legend>
          <div class="field-row">
            <label class="field"><span>Home type</span><select name="home"><option>Single family</option><option>Townhome</option><option>Multi-family</option><option>Condo</option></select></label>
            <label class="field"><span>Roof age</span><select name="age"><option>Not sure</option><option>Under 10 years</option><option>10–20 years</option><option>20+ years</option></select></label>
          </div>
          <label class="field"><span>Anything we should know? <small>(optional)</small></span><textarea name="notes" rows="3" placeholder="Leak near the chimney, missing shingles after last storm…"></textarea></label>
          <div class="form__nav"><button type="button" class="btn btn--ghost" data-prev>Back</button><button type="button" class="btn btn--primary" data-next>Continue</button></div>
        </fieldset>
        <fieldset class="form__step" data-step="3">
          <legend>Where should we send your quote?</legend>
          <div class="field-row">
            <label class="field"><span>First name</span><input type="text" name="first" required autocomplete="given-name"><em class="field__err">Required</em></label>
            <label class="field"><span>Last name</span><input type="text" name="last" required autocomplete="family-name"><em class="field__err">Required</em></label>
          </div>
          <label class="field"><span>Email</span><input type="email" name="email" required autocomplete="email"><em class="field__err">Enter a valid email</em></label>
          <label class="field"><span>Phone</span><input type="tel" name="phone" required autocomplete="tel" placeholder="(555) 555-0199"><em class="field__err">Enter a valid phone number</em></label>
          <div class="form__nav"><button type="button" class="btn btn--ghost" data-prev>Back</button><button type="submit" class="btn btn--primary">Get My Free Quote</button></div>
          <p class="form__fine">${esc(C.quote.fine)}</p>
        </fieldset>
        <div class="form__success" hidden>
          <div class="form__check"><svg viewBox="0 0 52 52"><circle cx="26" cy="26" r="24" fill="none" stroke="currentColor" stroke-width="3"/><path d="M15 27l8 8 14-16" fill="none" stroke="currentColor" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
          <h3>You're all set, <span class="form__success-name">friend</span>.</h3>
          <p>A project specialist will call you shortly to schedule your free inspection. Keep an eye on your inbox for a confirmation.</p>
          <button type="button" class="btn btn--ghost form__reset">Submit another request</button>
        </div>
      </form>
    </div>
  </section>`;

  /* ---------- multi-step quote form ---------- */
  const bindQuote = scope => $$('.form', scope).forEach(form => {
    const stepsEls = $$('.form__step', form), bars = $$('.form__steps span', form);
    let step = 1;
    const show = n => {
      step = n;
      stepsEls.forEach(s => s.classList.toggle('is-active', +s.dataset.step === n));
      bars.forEach((b, i) => b.classList.toggle('is-active', i < n));
      const first = $('input, select, textarea', stepsEls[n - 1]);
      if (first && window.innerWidth > 900) first.focus({ preventScroll: true });
    };
    const validate = fs => {
      let ok = true;
      $$('.field', fs).forEach(f => {
        const input = $('input, select, textarea', f);
        if (!input || !input.required) return;
        let valid = input.checkValidity();
        if (input.name === 'phone') valid = input.value.replace(/\D/g, '').length >= 10;
        if (input.name === 'zip') valid = /^\d{5}$/.test(input.value.trim());
        f.classList.toggle('is-invalid', !valid);
        if (!valid) ok = false;
      });
      return ok;
    };
    form.addEventListener('input', e => { const f = e.target.closest('.field'); if (f) f.classList.remove('is-invalid'); });
    form.addEventListener('click', e => {
      if (e.target.matches('[data-next]') && validate(stepsEls[step - 1])) show(step + 1);
      if (e.target.matches('[data-prev]')) show(step - 1);
    });
    const phone = $('input[name="phone"]', form);
    phone.addEventListener('input', () => {
      const d = phone.value.replace(/\D/g, '').slice(0, 10);
      phone.value = d.length > 6 ? `(${d.slice(0, 3)}) ${d.slice(3, 6)}-${d.slice(6)}` : d.length > 3 ? `(${d.slice(0, 3)}) ${d.slice(3)}` : d;
    });
    form.addEventListener('submit', e => {
      e.preventDefault();
      if (!validate(stepsEls[2])) return;
      const btn = $('button[type="submit"]', form);
      btn.disabled = true; btn.textContent = 'Sending…';
      setTimeout(() => {
        stepsEls.forEach(s => s.classList.remove('is-active'));
        $('.form__steps', form).hidden = true;
        $('.form__success-name', form).textContent = $('input[name="first"]', form).value.trim() || 'friend';
        $('.form__success', form).hidden = false;
        btn.disabled = false; btn.textContent = 'Get My Free Quote';
      }, 900);
    });
    $('.form__reset', form).addEventListener('click', () => {
      form.reset();
      $('.form__success', form).hidden = true;
      $('.form__steps', form).hidden = false;
      const firstChip = $('.chip input', form); if (firstChip) firstChip.checked = true;
      show(1);
    });
  });

  /* ---------- render home content ---------- */
  $('#hero-title').innerHTML = C.hero.lines.map(l => `<span class="line"><span>${l}</span></span>`).join('');
  $('#hero-trust').innerHTML = C.hero.trust.map(t => `<li>${t}</li>`).join('');
  $('#stats-grid').innerHTML = C.stats.map((s, i) => `<div class="stat reveal" data-reveal data-delay="${i * 80}"><div class="stat__num"><span data-counter="${s.v}" data-decimals="${s.dec || 0}">0</span>${s.suffix || ''}</div><p class="stat__label">${esc(s.label)}</p></div>`).join('');
  $('#marquee').innerHTML = [...C.marquee, ...C.marquee].map(t => `<span>${esc(t)}</span><span class="dot"></span>`).join('');
  $('#features').innerHTML = C.why.features.map((f, i) => featureCard(f, i * 80)).join('');
  $('#layer-list').innerHTML = C.system.layers.map((l, i) => `<li class="layer${i === 0 ? ' is-active' : ''}" data-layer="${7 - i}" tabindex="0" role="button"><span class="layer__num">${String(i + 1).padStart(2, '0')}</span><span><strong>${esc(l.t)}</strong><small>${esc(l.d)}</small></span></li>`).join('');
  $('#swatches').innerHTML = C.colors.swatches.map((s, i) => `<button class="swatch${i === 0 ? ' is-active' : ''}" role="option" aria-selected="${i === 0}" data-name="${esc(s.n)}" data-base="${s.base}" data-line="${s.line}" data-hi="${s.hi}" data-tag="${esc(s.tag || 'Class 4 impact rated')}" style="--c:${s.base}"><span></span>${esc(s.n)}</button>`).join('');
  $('#color-specs').innerHTML = C.colors.specs.map(([v, l]) => `<div><strong>${esc(v)}</strong><span>${esc(l)}</span></div>`).join('');
  $('#steps').insertAdjacentHTML('beforeend', C.process.steps.map((s, i) => `<article class="step reveal" data-reveal data-delay="${i * 100}"><div class="step__num">${i + 1}</div><h3>${esc(s.t)}</h3><p>${esc(s.d)}</p><span class="step__time">${esc(s.time)}</span></article>`).join(''));
  $('#carousel-track').innerHTML = C.reviews.items.map(r => `<blockquote class="review"><div class="review__stars">★★★★★</div><p>“${esc(r.t)}”</p><footer><span class="review__avatar" style="--a:${r.color}">${esc(r.name.split(/\s|&/).filter(Boolean).map(w => w[0]).join('').slice(0, 2).toUpperCase())}</span><div><strong>${esc(r.name)}</strong><small>${esc(r.meta)}</small></div></footer></blockquote>`).join('');
  $('#ratings').innerHTML = C.reviews.ratings.map(([v, l]) => `<div class="rating"><strong>${esc(v)}</strong><span>${esc(l)}</span></div>`).join('');
  $('#tracker-list').innerHTML = C.tracker.list.map(l => `<li>${esc(l)}</li>`).join('');
  $('#phone-pct').textContent = `${C.tracker.progress}%`;
  $('#phone-steps').innerHTML = C.tracker.steps.map((s, i) => `<div class="phone__step${s.state ? ' is-' + s.state : ''}"><i>${s.state === 'done' ? '✓' : i + 1}</i>${esc(s.t)}</div>`).join('');
  $('#phone').style.setProperty('--p', `${C.tracker.progress}%`);
  $('#financing-list').innerHTML = C.financing.list.map(l => `<li>${esc(l)}</li>`).join('');
  $('#calc-fine').textContent = `Based on a ${C.financing.apr}% fixed APR. For illustration only, not an offer of credit.`;
  const servicesGroup = C.nav.find(g => g.slug === 'services') || C.nav[0];
  $('#services-grid').innerHTML = servicesGroup.items.filter(it => it.home).map((it, i) => serviceCard(servicesGroup, it, i * 60)).join('');
  const faqGroups = Object.keys(C.faq.groups);
  $('#faq-tabs').innerHTML = faqGroups.map((g, i) => `<button class="tab${i === 0 ? ' is-active' : ''}" role="tab" aria-selected="${i === 0}" data-g="${i}">${esc(g)}</button>`).join('');
  $('#faq-groups').innerHTML = faqGroups.map((g, i) => `<div class="accordion faq-group${i === 0 ? ' is-active' : ''}" data-g="${i}">${C.faq.groups[g].map(([q, a], k) => `<details class="acc"${k === 0 ? ' open' : ''}><summary>${esc(q)}<span class="acc__icon"></span></summary><div class="acc__body"><p>${esc(a)}</p></div></details>`).join('')}</div>`).join('');
  $('#home-quote').innerHTML = quoteHTML();
  bindQuote($('#home-quote'));
  $('#awards').innerHTML = C.awards.map(a => `<span>${icon('check')}${esc(a)}</span>`).join('');

  /* ---------- nav + footer ---------- */
  $('#nav-list').innerHTML = C.nav.map(g => `
    <li class="nav__item nav__item--has-menu" data-slug="${g.slug}">
      <a class="nav__link" href="#/${g.slug}" aria-expanded="false">${esc(g.label)} ${CHEV}</a>
      <div class="megamenu${g.wide ? ' megamenu--wide' : ''}">
        ${g.items.map(it => `<a href="#/${g.slug}/${it.s}" class="megamenu__item" data-page="${g.slug}/${it.s}"><span class="megamenu__icon">${icon(it.icon)}</span><span><strong>${esc(it.t)}</strong><small>${esc(it.d)}</small></span></a>`).join('')}
        <a href="#/${g.slug}" class="megamenu__item megamenu__item--all">All ${esc(g.label.toLowerCase())} ${ARROW}</a>
      </div>
    </li>`).join('');
  $('#footer-grid').innerHTML = `
    <div class="footer__brand">
      <a href="#/" class="logo" aria-label="Home"><svg class="logo__mark" viewBox="0 0 40 40" aria-hidden="true"><path d="M4 22 20 6l16 16h-5v12H9V22Z" fill="currentColor"/><path d="M20 6 4 22h5l11-11 11 11h5L20 6Z" fill="var(--red)"/></svg><span class="logo__text">${esc(C.brand.name)}<span>${esc(C.brand.tagline)}</span></span></a>
      <p>${esc(servicesGroup.items.filter(i => i.home).map(i => i.t).join(', '))} for homeowners who want it done once, done right.</p>
    </div>
    ${C.nav.map(g => `<div><h4>${esc(g.label)}</h4><ul>${g.items.map(it => `<li><a href="#/${g.slug}/${it.s}">${esc(it.t)}</a></li>`).join('')}</ul></div>`).join('')}
    <div class="footer__contact"><h4>Talk to us</h4><a class="footer__phone" href="${tel}">${esc(C.brand.phone)}</a><p>${C.brand.hours.map(esc).join('<br>')}</p><p>${C.brand.address.map(esc).join('<br>')}</p><p><a href="mailto:${esc(C.brand.email)}">${esc(C.brand.email)}</a></p></div>`;

  /* ---------- header: scrolled state, hide on scroll down ---------- */
  const header = $('#header'), progress = $('.scroll-progress span'), toTop = $('#to-top'), stickyCta = $('#sticky-cta'), heroEl = $('#hero');
  let lastY = window.scrollY;
  const onScroll = () => {
    const y = window.scrollY, max = document.documentElement.scrollHeight - window.innerHeight;
    header.classList.toggle('is-scrolled', y > 40);
    header.classList.toggle('is-hidden', y > 400 && y > lastY && !document.body.classList.contains('menu-open'));
    progress.style.transform = `scaleX(${max > 0 ? y / max : 0})`;
    toTop.classList.toggle('is-visible', y > 700);
    stickyCta.classList.toggle('is-visible', y > (heroEl.offsetHeight || 600) * 0.7);
    lastY = y;
  };
  window.addEventListener('scroll', onScroll, { passive: true });
  toTop.addEventListener('click', () => window.scrollTo({ top: 0, behavior: reduceMotion ? 'auto' : 'smooth' }));
  // hide sticky CTA while a quote form is on screen
  const quotesInView = new Set();
  const quoteIO = new IntersectionObserver(entries => {
    entries.forEach(en => en.isIntersecting ? quotesInView.add(en.target) : quotesInView.delete(en.target));
    stickyCta.classList.toggle('is-suppressed', quotesInView.size > 0);
  }, { threshold: .15 });

  /* ---------- mobile nav + dropdowns ---------- */
  const burger = $('#burger'), nav = $('#nav');
  const setMenu = open => {
    nav.classList.toggle('is-open', open);
    burger.setAttribute('aria-expanded', String(open));
    burger.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    document.body.classList.toggle('menu-open', open);
  };
  burger.addEventListener('click', () => setMenu(!nav.classList.contains('is-open')));
  const navItems = $$('.nav__item--has-menu');
  const closeAll = () => navItems.forEach(it => { it.classList.remove('is-open'); $('.nav__link', it).setAttribute('aria-expanded', 'false'); });
  navItems.forEach(it => {
    const link = $('.nav__link', it);
    link.addEventListener('click', e => {
      // On touch devices (or in the mobile drawer) the first tap opens the menu instead of navigating
      if (!canHover || nav.classList.contains('is-open')) {
        e.preventDefault();
        const was = it.classList.contains('is-open');
        closeAll();
        if (!was) { it.classList.add('is-open'); link.setAttribute('aria-expanded', 'true'); }
      }
    });
  });
  document.addEventListener('click', e => { if (!e.target.closest('.nav__item--has-menu')) closeAll(); });

  /* ---------- site search ---------- */
  const search = $('#search'), searchInput = $('#search-input'), results = $('#search-results');
  const index = [
    ...C.nav.flatMap(g => g.items.map(it => ({ t: it.t, h: `#/${g.slug}/${it.s}`, d: it.d, g: g.label }))),
    { t: 'Get a free quote', h: '#/quote', d: 'Written, guaranteed price on the spot', g: 'Quote' },
    { t: 'Shingle colors', h: '#colors', d: 'Preview twelve shades on your home', g: 'Design' },
    { t: 'Payment estimator', h: '#financing', d: 'See your monthly payment', g: 'Financing' },
    ...faqGroups.flatMap(g => C.faq.groups[g].map(([q]) => ({ t: q, h: '#faq', d: 'FAQ', g })))
  ];
  const openSearch = () => { setMenu(false); search.classList.add('is-open'); search.setAttribute('aria-hidden', 'false'); document.body.classList.add('menu-open'); setTimeout(() => searchInput.focus(), 80); };
  const closeSearch = () => { if (!search.classList.contains('is-open')) return; search.classList.remove('is-open'); search.setAttribute('aria-hidden', 'true'); document.body.classList.remove('menu-open'); searchInput.value = ''; renderResults(''); };
  const renderResults = q => {
    q = q.trim().toLowerCase();
    $('#search-top').hidden = !!q; $('#search-results-wrap').hidden = !q;
    if (!q) return;
    const hits = index.filter(x => `${x.t} ${x.d} ${x.g}`.toLowerCase().includes(q));
    results.innerHTML = hits.length
      ? hits.map((x, i) => `<a href="${x.h}" style="animation-delay:${i * 40}ms"><div><b>${esc(x.t)}</b><small>${esc(x.d)}</small></div><span>${esc(x.g)}</span></a>`).join('')
      : '<div class="search__none">No matches. Try "quote" or "warranty".</div>';
  };
  $('#search-chips').innerHTML = C.topSearches.map(t => `<button type="button" class="search__chip" data-q="${esc(t)}">${esc(t)}</button>`).join('');
  $('#search-chips').addEventListener('click', e => { const c = e.target.closest('.search__chip'); if (!c) return; searchInput.value = c.dataset.q; renderResults(c.dataset.q); searchInput.focus(); });
  $('#search-btn').addEventListener('click', openSearch);
  $('#nav-search').addEventListener('click', openSearch);
  $('#search-close').addEventListener('click', closeSearch);
  searchInput.addEventListener('input', () => renderResults(searchInput.value));
  results.addEventListener('click', e => { if (e.target.closest('a')) closeSearch(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape') { closeSearch(); setMenu(false); closeAll(); } });

  /* ---------- reveal on scroll ---------- */
  const revealIO = new IntersectionObserver(entries => entries.forEach(en => {
    if (!en.isIntersecting) return;
    en.target.classList.add('is-visible');
    revealIO.unobserve(en.target);
  }), { threshold: 0.12, rootMargin: '0px 0px -6% 0px' });
  const observe = (scope = document) => {
    $$('[data-reveal]', scope).forEach(el => { const d = el.dataset.delay; if (d) el.style.setProperty('--d', `${d}ms`); revealIO.observe(el); });
    $$('.quote', scope).forEach(q => quoteIO.observe(q));
  };

  /* ---------- counters ---------- */
  const ease = t => 1 - Math.pow(1 - t, 3);
  const counterIO = new IntersectionObserver(entries => entries.forEach(en => {
    if (!en.isIntersecting) return;
    const el = en.target, target = parseFloat(el.dataset.counter), decimals = parseInt(el.dataset.decimals || '0', 10);
    let start;
    const tick = ts => { if (!start) start = ts; const p = Math.min((ts - start) / 1800, 1); el.textContent = (target * ease(p)).toFixed(decimals); if (p < 1) requestAnimationFrame(tick); };
    reduceMotion ? (el.textContent = target.toFixed(decimals)) : requestAnimationFrame(tick);
    counterIO.unobserve(el);
  }), { threshold: .5 });
  $$('[data-counter]').forEach(c => counterIO.observe(c));
  const steps = $('#steps');
  new IntersectionObserver((e, o) => { if (e[0].isIntersecting) { steps.classList.add('is-visible'); o.disconnect(); } }, { threshold: .3 }).observe(steps);

  /* ---------- hero parallax ---------- */
  const parallaxEls = $$('[data-parallax]');
  if (!reduceMotion && parallaxEls.length) {
    let raf = null;
    const update = () => { const y = window.scrollY; parallaxEls.forEach(el => { el.style.transform = `translate3d(0, ${y * parseFloat(el.dataset.parallax)}px, 0)`; }); raf = null; };
    window.addEventListener('scroll', () => { if (!raf) raf = requestAnimationFrame(update); }, { passive: true });
  }

  /* ---------- feature card spotlight (delegated so sub-pages work) ---------- */
  document.addEventListener('pointermove', e => {
    const card = e.target.closest('.feature'); if (!card) return;
    const r = card.getBoundingClientRect();
    card.style.setProperty('--mx', `${e.clientX - r.left}px`); card.style.setProperty('--my', `${e.clientY - r.top}px`);
  });

  /* ---------- roofing system explorer ---------- */
  {
    const layerList = $('#layer-list'), exploded = $('#exploded'), callout = $('#callout'), label = $('#system-label');
    const slabs = $$('.xl', exploded);
    const GAP = 42, BASE_SHIFT = 40;
    const setActive = n => {
      $$('.layer', layerList).forEach(li => li.classList.toggle('is-active', li.dataset.layer === String(n)));
      slabs.forEach(s => {
        const idx = parseInt(s.dataset.xl, 10), isActive = idx === n;
        let offset = -(idx - 1) * GAP + BASE_SHIFT;
        if (idx > n) offset -= 70;
        if (isActive) offset -= 20;
        s.style.transform = `translateY(${offset}px)`;
        s.classList.toggle('is-dim', !isActive); s.classList.toggle('is-hot', isActive);
      });
      callout.style.transform = `translate(470px, ${480 - (n - 1) * GAP + BASE_SHIFT - 20}px)`;
      const li = $(`.layer[data-layer="${n}"]`, layerList);
      $('strong', label).textContent = $('strong', li).textContent;
      $('span', label).textContent = `Layer ${$('.layer__num', li).textContent}`;
    };
    let auto = null, current = 7;
    const startAuto = () => { if (auto || reduceMotion) return; auto = setInterval(() => { current = current === 1 ? 7 : current - 1; setActive(current); }, 2600); };
    const stopAuto = () => { clearInterval(auto); auto = null; };
    $$('.layer', layerList).forEach(li => {
      const go = () => { current = parseInt(li.dataset.layer, 10); setActive(current); stopAuto(); };
      li.addEventListener('click', go);
      li.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); go(); } });
    });
    new IntersectionObserver(entries => entries[0].isIntersecting ? startAuto() : stopAuto(), { threshold: .4 }).observe(exploded);
    setActive(7);
  }

  /* ---------- shingle color picker ---------- */
  {
    const swatches = $('#swatches'), preview = $('#house-preview');
    const base = $('.sh-base', preview), lines = $$('.sh-line', preview), hi = $('.sh-hi', preview);
    const paint = btn => {
      $$('.swatch', swatches).forEach(s => { s.classList.toggle('is-active', s === btn); s.setAttribute('aria-selected', String(s === btn)); });
      base.setAttribute('fill', btn.dataset.base); lines.forEach(l => l.setAttribute('stroke', btn.dataset.line)); hi.setAttribute('stroke', btn.dataset.hi);
      $('#color-name').textContent = btn.dataset.name; $('#color-tag').textContent = btn.dataset.tag;
    };
    swatches.addEventListener('click', e => { const btn = e.target.closest('.swatch'); if (btn) paint(btn); });
    paint($('.swatch', swatches));
  }

  /* ---------- before / after compare ---------- */
  {
    const compare = $('#compare'), range = $('#compare-range');
    const set = v => compare.style.setProperty('--pos', `${v}%`);
    range.addEventListener('input', () => set(range.value));
    const move = e => { const r = compare.getBoundingClientRect(); const v = Math.min(Math.max(e.clientX - r.left, 0), r.width) / r.width * 100; range.value = v; set(v); };
    compare.addEventListener('pointerdown', e => { move(e); compare.setPointerCapture(e.pointerId); compare.addEventListener('pointermove', move); });
    ['pointerup', 'pointercancel'].forEach(ev => compare.addEventListener(ev, () => compare.removeEventListener('pointermove', move)));
    if (!reduceMotion) new IntersectionObserver((entries, o) => {
      if (!entries[0].isIntersecting) return; o.disconnect();
      let t0; const step = ts => { if (!t0) t0 = ts; const p = Math.min((ts - t0) / 1400, 1); const v = 50 - 18 * Math.sin(p * Math.PI); set(v); range.value = v; if (p < 1) requestAnimationFrame(step); };
      setTimeout(() => requestAnimationFrame(step), 500);
    }, { threshold: .5 }).observe(compare);
  }

  /* ---------- reviews carousel ---------- */
  {
    const track = $('#carousel-track'), slides = $$('.review', track), dots = $('#dots');
    let index = 0, timer;
    const perView = () => window.innerWidth >= 1100 ? 3 : window.innerWidth >= 760 ? 2 : 1;
    const pages = () => Math.max(1, slides.length - perView() + 1);
    const render = () => {
      const gap = parseFloat(getComputedStyle(track).gap) || 0, w = slides[0].getBoundingClientRect().width + gap;
      index = Math.min(index, pages() - 1);
      track.style.transform = `translateX(${-index * w}px)`;
      dots.innerHTML = '';
      for (let i = 0; i < pages(); i++) {
        const b = document.createElement('button'); b.className = i === index ? 'is-active' : ''; b.setAttribute('aria-label', `Go to review ${i + 1}`);
        b.addEventListener('click', () => { index = i; render(); restart(); }); dots.appendChild(b);
      }
    };
    const next = () => { index = (index + 1) % pages(); render(); }, prev = () => { index = (index - 1 + pages()) % pages(); render(); };
    const restart = () => { clearInterval(timer); if (!reduceMotion) timer = setInterval(next, 5000); };
    $('#next').addEventListener('click', () => { next(); restart(); }); $('#prev').addEventListener('click', () => { prev(); restart(); });
    const car = $('#carousel'); car.addEventListener('pointerenter', () => clearInterval(timer)); car.addEventListener('pointerleave', restart);
    let sx = null;
    track.addEventListener('pointerdown', e => sx = e.clientX);
    track.addEventListener('pointerup', e => { if (sx === null) return; const dx = e.clientX - sx; if (Math.abs(dx) > 40) { dx < 0 ? next() : prev(); restart(); } sx = null; });
    window.addEventListener('resize', render);
    render(); restart();
  }

  /* ---------- financing calculator ---------- */
  {
    const amt = $('#calc-amount'), term = $('#calc-term');
    amt.value = C.financing.defaultAmount; term.value = C.financing.defaultTerm;
    const fmt = n => '$' + Math.round(n).toLocaleString('en-US');
    const paint = r => r.style.setProperty('--fill', `${((r.value - r.min) / (r.max - r.min)) * 100}%`);
    const calc = () => {
      const P = +amt.value, n = +term.value * 12, r = C.financing.apr / 100 / 12, m = P * r / (1 - Math.pow(1 + r, -n));
      $('#calc-cost').textContent = fmt(P); $('#calc-term-out').textContent = `${term.value} year${term.value === '1' ? '' : 's'}`;
      $('#calc-monthly').textContent = Math.round(m).toLocaleString('en-US'); paint(amt); paint(term);
    };
    amt.addEventListener('input', calc); term.addEventListener('input', calc); calc();
  }

  /* ---------- FAQ tabs ---------- */
  $('#faq-tabs').addEventListener('click', e => {
    const t = e.target.closest('.tab'); if (!t) return;
    $$('.tab').forEach(x => { x.classList.toggle('is-active', x === t); x.setAttribute('aria-selected', String(x === t)); });
    $$('.faq-group').forEach(x => x.classList.toggle('is-active', x.dataset.g === t.dataset.g));
  });

  /* ---------- tracker phone ---------- */
  new IntersectionObserver((e, o) => { if (e[0].isIntersecting) { $('#phone').classList.add('is-live'); o.disconnect(); } }, { threshold: .4 }).observe($('#phone'));

  /* ---------- router ---------- */
  const home = $('#home'), page = $('#page'), wipe = $('#wipe'), wipeLabel = $('#wipe-label');
  const firstSentence = s => s.split('. ')[0].replace(/\.$/, '') + '.';
  const pageHero = (crumbs, eyebrow, title, lede, num) => `
    <header class="page-hero" data-num="${esc(num)}">
      <div class="page-hero__bg"></div>
      <div class="container page-hero__inner">
        <nav class="crumbs" aria-label="Breadcrumb">${crumbs}</nav>
        <p class="eyebrow reveal" data-reveal>${esc(eyebrow)}</p>
        <h1 class="page-hero__title reveal" data-reveal data-delay="80"><span class="line"><span>${esc(title)}</span></span></h1>
        <p class="lede reveal" data-reveal data-delay="160">${esc(lede)}</p>
        <div class="hero__cta reveal" data-reveal data-delay="240"><a class="btn btn--primary" href="#quote">Get a free quote</a><a class="btn btn--ghost" href="${tel}">${esc(C.brand.phone)}</a></div>
      </div>
    </header>`;
  const pageHTML = (g, it) => {
    const num = String(g.items.indexOf(it) + 1).padStart(2, '0');
    const others = g.items.filter(x => x !== it).slice(0, 3);
    return pageHero(`<a href="#/">Home</a><span>/</span><a href="#/${g.slug}">${esc(g.label)}</a>`, g.label, it.t, `${it.d}. ${firstSentence(it.body[0])}`, num) + `
    <section class="section page-body"><div class="container page-body__grid">
      <div class="prose reveal" data-reveal>${it.body.map(p => `<p>${esc(p)}</p>`).join('')}<h3>Why homeowners choose ${esc(C.brand.name)}</h3><p>Employee crews, written pricing, and a warranty we actually honor. Ask for references and we'll give you addresses of recent jobs so you can drive by.</p></div>
      <aside class="side reveal" data-reveal data-delay="100"><div class="side__card">
        <p class="eyebrow">Free consultation</p><h3>Talk to a project specialist</h3><p>Written, guaranteed price the same day we visit. No pressure, no surprises.</p>
        <a class="btn btn--primary btn--block" href="#quote">Get a free quote</a><a class="btn btn--ghost btn--block" href="${tel}">${esc(C.brand.phone)}</a>
        <small>${C.brand.hours.map(esc).join(' · ')}</small>
      </div></aside>
    </div></section>
    <section class="section hl"><div class="container">
      <div class="section__head reveal" data-reveal><p class="eyebrow">${esc(it.t)}</p><h2>What's <em>included.</em></h2></div>
      <div class="features features--3">${it.hl.map(([t, d], i) => featureCard({ icon: ['check', 'clock', 'shield'][i % 3], t, d }, i * 80)).join('')}</div>
    </div></section>
    <section class="section more"><div class="container">
      <div class="section__head reveal" data-reveal><p class="eyebrow">More ${esc(g.label.toLowerCase())}</p><h2>Keep <em>exploring.</em></h2></div>
      <div class="services__grid">${others.map((x, i) => serviceCard(g, x, i * 60)).join('')}</div>
    </div></section>
    ${quoteHTML(`Ready to talk <em>${esc(it.t.toLowerCase())}?</em>`, 'Tell us a little about your home and a project specialist will call within 15 minutes during business hours.')}`;
  };
  const landingHTML = g => pageHero(`<a href="#/">Home</a><span>/</span><span>${esc(g.label)}</span>`, `${g.items.length} pages`, g.label, g.lede, g.label.slice(0, 2).toUpperCase()) + `
    <section class="section"><div class="container"><div class="services__grid">${g.items.map((it, i) => serviceCard(g, it, (i % 3) * 60)).join('')}</div></div></section>
    ${quoteHTML()}`;

  let currentKey = '', busy = false;
  const scrollToIn = (view, hash) => { const el = view.querySelector(hash); if (el) el.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth' }); return !!el; };
  const render = (hash, first) => {
    const parts = (hash || '#/').replace(/^#\/?/, '').split('/').filter(Boolean);
    const isHome = parts.length === 0 || parts[0] === 'quote';
    let html = null, label = '', title = `${C.brand.legalName} | Roofing Built to Outlast the Weather`;
    if (!isHome) {
      const g = C.nav.find(x => x.slug === parts[0]);
      if (!g) return render('#/', first);
      const it = parts[1] && g.items.find(x => x.s === parts[1]);
      if (parts[1] && !it) return render(`#/${g.slug}`, first);
      html = it ? pageHTML(g, it) : landingHTML(g);
      label = it ? it.t : g.label;
      title = `${label} | ${C.brand.legalName}`;
    }
    const key = isHome ? 'home' : parts.join('/');
    const swap = () => {
      home.classList.toggle('is-active', isHome); page.classList.toggle('is-active', !isHome);
      if (!isHome) { page.innerHTML = html; fill(page); bindQuote(page); observe(page); }
      document.title = title;
      navItems.forEach(it => it.classList.toggle('is-current', !isHome && it.dataset.slug === parts[0]));
      $$('.megamenu__item').forEach(a => a.classList.toggle('is-active', a.dataset.page === key));
      if (parts[0] === 'quote') scrollToIn(home, '#quote'); else window.scrollTo(0, 0);
      currentKey = key; onScroll();
    };
    setMenu(false); closeSearch(); closeAll();
    if (first) { swap(); return; }
    if (key === currentKey) { if (parts[0] === 'quote') scrollToIn(home, '#quote'); return; }
    if (busy) return;
    if (reduceMotion) { swap(); return; }
    busy = true; wipeLabel.textContent = label || C.brand.name;
    wipe.className = 'wipe is-in';
    wipe.addEventListener('animationend', function a() {
      wipe.removeEventListener('animationend', a); swap(); wipe.className = 'wipe is-out';
      wipe.addEventListener('animationend', () => { wipe.className = 'wipe'; busy = false; }, { once: true });
    }, { once: true });
  };
  const onHash = () => {
    const h = location.hash;
    if (h === '' || h === '#' || h.startsWith('#/')) { render(h); return; }
    // Plain #anchor: scroll within the active view (sub-pages have their own #quote)
    const view = $('.view.is-active');
    setMenu(false); closeAll(); closeSearch();
    if (!scrollToIn(view, h) && !scrollToIn(document, h)) render('#/');
  };
  window.addEventListener('hashchange', onHash);
  observe(home);
  render(location.hash.startsWith('#/') ? location.hash : '#/', true);
  if (location.hash && !location.hash.startsWith('#/')) setTimeout(() => scrollToIn(home, location.hash), 400);
  onScroll();
})();
