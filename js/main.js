/* =========================================================
   Northline Home Services — interactions & animations
   Vanilla JS, no dependencies.
   ========================================================= */
(() => {
  'use strict';

  const $ = (sel, ctx = document) => ctx.querySelector(sel);
  const $$ = (sel, ctx = document) => Array.from(ctx.querySelectorAll(sel));
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------- header: scrolled state, hide on scroll down ---------- */
  const header = $('#header');
  const progress = $('.scroll-progress span');
  const toTop = $('#to-top');
  const stickyCta = $('#sticky-cta');
  const heroEl = $('#hero');
  let lastY = window.scrollY;

  const onScroll = () => {
    const y = window.scrollY;
    const max = document.documentElement.scrollHeight - window.innerHeight;
    header.classList.toggle('is-scrolled', y > 40);
    header.classList.toggle('is-hidden', y > 400 && y > lastY && !document.body.classList.contains('menu-open'));
    if (progress) progress.style.transform = `scaleX(${max > 0 ? y / max : 0})`;
    toTop.classList.toggle('is-visible', y > 700);
    if (stickyCta) stickyCta.classList.toggle('is-visible', y > (heroEl?.offsetHeight || 600) * 0.7);
    lastY = y;
  };
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
  // Hide the sticky CTA while the quote form itself is on screen
  const quoteSection = $('#quote');
  if (stickyCta && quoteSection) {
    new IntersectionObserver(entries => stickyCta.classList.toggle('is-suppressed', entries[0].isIntersecting), { threshold: .15 }).observe(quoteSection);
  }
  toTop.addEventListener('click', () => window.scrollTo({ top: 0, behavior: reduceMotion ? 'auto' : 'smooth' }));

  /* ---------- mobile nav ---------- */
  const burger = $('#burger');
  const nav = $('#nav');
  burger.addEventListener('click', () => {
    const open = nav.classList.toggle('is-open');
    burger.setAttribute('aria-expanded', String(open));
    burger.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    document.body.classList.toggle('menu-open', open);
  });
  $$('.nav__link, .megamenu__item', nav).forEach(a => a.addEventListener('click', e => {
    if (a.tagName === 'A') {
      nav.classList.remove('is-open');
      burger.setAttribute('aria-expanded', 'false');
      document.body.classList.remove('menu-open');
    }
  }));
  // Services dropdown (click toggles for keyboard + touch)
  $$('.nav__item--has-menu').forEach(item => {
    const btn = $('.nav__link', item);
    btn.addEventListener('click', () => {
      const open = item.classList.toggle('is-open');
      btn.setAttribute('aria-expanded', String(open));
    });
    document.addEventListener('click', e => {
      if (!item.contains(e.target)) { item.classList.remove('is-open'); btn.setAttribute('aria-expanded', 'false'); }
    });
  });

  /* ---------- reveal on scroll ---------- */
  const revealEls = $$('[data-reveal]');
  revealEls.forEach(el => { const d = el.dataset.delay; if (d) el.style.setProperty('--d', `${d}ms`); });
  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15, rootMargin: '0px 0px -8% 0px' });
  revealEls.forEach(el => io.observe(el));
  const steps = $('#steps');
  if (steps) new IntersectionObserver((e, o) => { if (e[0].isIntersecting) { steps.classList.add('is-visible'); o.disconnect(); } }, { threshold: .3 }).observe(steps);

  /* ---------- counters ---------- */
  const ease = t => 1 - Math.pow(1 - t, 3);
  const counters = $$('[data-counter]');
  const counterIO = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el = entry.target;
      const target = parseFloat(el.dataset.counter);
      const decimals = parseInt(el.dataset.decimals || '0', 10);
      const dur = 1800;
      let start;
      const tick = (ts) => {
        if (!start) start = ts;
        const p = Math.min((ts - start) / dur, 1);
        el.textContent = (target * ease(p)).toFixed(decimals);
        if (p < 1) requestAnimationFrame(tick);
      };
      reduceMotion ? (el.textContent = target.toFixed(decimals)) : requestAnimationFrame(tick);
      counterIO.unobserve(el);
    });
  }, { threshold: .5 });
  counters.forEach(c => counterIO.observe(c));

  /* ---------- hero parallax + cursor tilt ---------- */
  const parallaxEls = $$('[data-parallax]');
  if (!reduceMotion && parallaxEls.length) {
    let raf = null;
    const update = () => {
      const y = window.scrollY;
      parallaxEls.forEach(el => { el.style.transform = `translate3d(0, ${y * parseFloat(el.dataset.parallax)}px, 0)`; });
      raf = null;
    };
    window.addEventListener('scroll', () => { if (!raf) raf = requestAnimationFrame(update); }, { passive: true });
  }

  /* ---------- feature card spotlight ---------- */
  $$('.feature').forEach(card => {
    card.addEventListener('pointermove', e => {
      const r = card.getBoundingClientRect();
      card.style.setProperty('--mx', `${e.clientX - r.left}px`);
      card.style.setProperty('--my', `${e.clientY - r.top}px`);
    });
  });

  /* ---------- roofing system explorer ---------- */
  const layerList = $('#layer-list');
  const exploded = $('#exploded');
  const callout = $('#callout');
  const systemLabel = $('#system-label');
  if (layerList && exploded) {
    const slabs = $$('.xl', exploded);
    const GAP = 42;           // vertical spacing between exploded layers
    const BASE_SHIFT = 40;    // pushes the stack up so it sits centered
    const setActive = (n) => {
      $$('.layer', layerList).forEach(li => li.classList.toggle('is-active', li.dataset.layer === String(n)));
      slabs.forEach(s => {
        const idx = parseInt(s.dataset.xl, 10);
        const isActive = idx === n;
        // Layers above the active one lift further, the active one lifts slightly, below stays compact.
        let offset = -(idx - 1) * GAP + BASE_SHIFT;
        if (idx > n) offset -= 70;
        if (isActive) offset -= 20;
        s.style.transform = `translateY(${offset}px)`;
        s.classList.toggle('is-dim', !isActive);
        s.classList.toggle('is-hot', isActive);
      });
      // callout dot follows the active layer's right edge
      const activeOffset = -(n - 1) * GAP + BASE_SHIFT - 20;
      callout.style.transform = `translate(470px, ${480 + activeOffset}px)`;
      const li = $(`.layer[data-layer="${n}"]`, layerList);
      if (li && systemLabel) {
        systemLabel.querySelector('strong').textContent = li.querySelector('strong').textContent;
        systemLabel.querySelector('span').textContent = `Layer ${li.querySelector('.layer__num').textContent}`;
      }
    };
    $$('.layer', layerList).forEach(li => {
      li.setAttribute('tabindex', '0');
      li.setAttribute('role', 'button');
      const go = () => { setActive(parseInt(li.dataset.layer, 10)); stopAuto(); };
      li.addEventListener('click', go);
      li.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); go(); } });
    });
    // Auto-cycle until the user interacts, only while in view
    let auto = null, current = 7;
    const startAuto = () => { if (auto || reduceMotion) return; auto = setInterval(() => { current = current === 1 ? 7 : current - 1; setActive(current); }, 2600); };
    const stopAuto = () => { clearInterval(auto); auto = null; };
    new IntersectionObserver(entries => { entries[0].isIntersecting ? startAuto() : stopAuto(); }, { threshold: .4 }).observe(exploded);
    setActive(7);
  }

  /* ---------- shingle color picker ---------- */
  const swatches = $('#swatches');
  const preview = $('#house-preview');
  const colorName = $('#color-name');
  if (swatches && preview) {
    const base = $('.sh-base', preview), lines = $$('.sh-line', preview), hi = $('.sh-hi', preview);
    swatches.addEventListener('click', e => {
      const btn = e.target.closest('.swatch');
      if (!btn) return;
      $$('.swatch', swatches).forEach(s => { s.classList.remove('is-active'); s.setAttribute('aria-selected', 'false'); });
      btn.classList.add('is-active'); btn.setAttribute('aria-selected', 'true');
      base.setAttribute('fill', btn.dataset.base);
      lines.forEach(l => l.setAttribute('stroke', btn.dataset.line));
      hi.setAttribute('stroke', btn.dataset.hi);
      colorName.textContent = btn.dataset.name;
      const small = colorName.nextElementSibling;
      if (small) small.textContent = btn.dataset.name === 'Charcoal Slate' ? 'Most popular' : 'Class 4 impact rated';
    });
  }

  /* ---------- before / after compare ---------- */
  const compare = $('#compare');
  const range = $('#compare-range');
  if (compare && range) {
    const set = v => compare.style.setProperty('--pos', `${v}%`);
    range.addEventListener('input', () => set(range.value));
    // Pointer drag anywhere on the compare box
    const move = e => {
      const r = compare.getBoundingClientRect();
      const x = Math.min(Math.max(e.clientX - r.left, 0), r.width);
      const v = (x / r.width) * 100;
      range.value = v; set(v);
    };
    compare.addEventListener('pointerdown', e => { move(e); compare.setPointerCapture(e.pointerId); compare.addEventListener('pointermove', move); });
    compare.addEventListener('pointerup', () => compare.removeEventListener('pointermove', move));
    compare.addEventListener('pointercancel', () => compare.removeEventListener('pointermove', move));
    // Intro nudge when it scrolls into view
    if (!reduceMotion) {
      new IntersectionObserver((entries, o) => {
        if (!entries[0].isIntersecting) return;
        o.disconnect();
        let t0; const from = 50, to = 32, dur = 1400;
        const step = ts => { if (!t0) t0 = ts; const p = Math.min((ts - t0) / dur, 1); const v = from + (to - from) * Math.sin(p * Math.PI); set(v); range.value = v; if (p < 1) requestAnimationFrame(step); };
        setTimeout(() => requestAnimationFrame(step), 500);
      }, { threshold: .5 }).observe(compare);
    }
  }

  /* ---------- reviews carousel ---------- */
  const track = $('#carousel-track');
  if (track) {
    const slides = $$('.review', track);
    const dots = $('#dots');
    let index = 0, timer;
    const perView = () => window.innerWidth >= 1100 ? 3 : window.innerWidth >= 760 ? 2 : 1;
    const pages = () => Math.max(1, slides.length - perView() + 1);
    const render = () => {
      const gap = parseFloat(getComputedStyle(track).gap) || 0;
      const w = slides[0].getBoundingClientRect().width + gap;
      index = Math.min(index, pages() - 1);
      track.style.transform = `translateX(${-index * w}px)`;
      dots.innerHTML = '';
      for (let i = 0; i < pages(); i++) {
        const b = document.createElement('button');
        b.className = i === index ? 'is-active' : '';
        b.setAttribute('aria-label', `Go to review ${i + 1}`);
        b.addEventListener('click', () => { index = i; render(); restart(); });
        dots.appendChild(b);
      }
    };
    const next = () => { index = (index + 1) % pages(); render(); };
    const prev = () => { index = (index - 1 + pages()) % pages(); render(); };
    const restart = () => { clearInterval(timer); if (!reduceMotion) timer = setInterval(next, 5000); };
    $('#next').addEventListener('click', () => { next(); restart(); });
    $('#prev').addEventListener('click', () => { prev(); restart(); });
    track.closest('.carousel').addEventListener('pointerenter', () => clearInterval(timer));
    track.closest('.carousel').addEventListener('pointerleave', restart);
    // swipe
    let sx = null;
    track.addEventListener('pointerdown', e => sx = e.clientX);
    track.addEventListener('pointerup', e => { if (sx === null) return; const dx = e.clientX - sx; if (Math.abs(dx) > 40) { dx < 0 ? next() : prev(); restart(); } sx = null; });
    window.addEventListener('resize', render);
    render(); restart();
  }

  /* ---------- financing calculator ---------- */
  const amt = $('#calc-amount'), term = $('#calc-term');
  if (amt && term) {
    const fmt = n => '$' + Math.round(n).toLocaleString('en-US');
    const paintRange = r => r.style.setProperty('--fill', `${((r.value - r.min) / (r.max - r.min)) * 100}%`);
    const calc = () => {
      const P = +amt.value, n = +term.value * 12, r = 0.0799 / 12;
      const m = P * r / (1 - Math.pow(1 + r, -n));
      $('#calc-cost').textContent = fmt(P);
      $('#calc-term-out').textContent = `${term.value} year${term.value === '1' ? '' : 's'}`;
      $('#calc-monthly').textContent = Math.round(m).toLocaleString('en-US');
      paintRange(amt); paintRange(term);
    };
    amt.addEventListener('input', calc); term.addEventListener('input', calc); calc();
  }
  $$('input[type="range"]:not(#calc-amount):not(#calc-term):not(#compare-range)').forEach(r => r.style.setProperty('--fill', '50%'));

  /* ---------- multi-step quote form ---------- */
  const form = $('#quote-form');
  if (form) {
    const stepsEls = $$('.form__step', form);
    const bars = $$('.form__steps span', form);
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
      if (e.target.matches('[data-next]')) { if (validate(stepsEls[step - 1])) show(step + 1); }
      if (e.target.matches('[data-prev]')) show(step - 1);
    });
    // Phone auto-format
    const phone = $('input[name="phone"]', form);
    phone.addEventListener('input', () => {
      const d = phone.value.replace(/\D/g, '').slice(0, 10);
      phone.value = d.length > 6 ? `(${d.slice(0,3)}) ${d.slice(3,6)}-${d.slice(6)}` : d.length > 3 ? `(${d.slice(0,3)}) ${d.slice(3)}` : d;
    });
    form.addEventListener('submit', e => {
      e.preventDefault();
      if (!validate(stepsEls[2])) return;
      const btn = $('button[type="submit"]', form);
      btn.disabled = true; btn.textContent = 'Sending…';
      setTimeout(() => {
        stepsEls.forEach(s => s.classList.remove('is-active'));
        $('.form__steps', form).hidden = true;
        $('#success-name').textContent = $('input[name="first"]', form).value.trim() || 'friend';
        $('#form-success').hidden = false;
        btn.disabled = false; btn.textContent = 'Get My Free Quote';
      }, 900);
    });
    $('#form-reset').addEventListener('click', () => {
      form.reset();
      $('#form-success').hidden = true;
      $('.form__steps', form).hidden = false;
      $('input[value="Roofing"]', form).checked = true;
      show(1);
    });
  }

  /* ---------- misc ---------- */
  const year = $('#year'); if (year) year.textContent = new Date().getFullYear();

  // Smooth-scroll offset for sticky header on anchor clicks
  $$('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      const id = a.getAttribute('href');
      if (id.length < 2) return;
      const target = $(id);
      if (!target) return;
      e.preventDefault();
      const top = target.getBoundingClientRect().top + window.scrollY - (id === '#top' ? 200 : 70);
      window.scrollTo({ top: Math.max(top, 0), behavior: reduceMotion ? 'auto' : 'smooth' });
      history.pushState(null, '', id);
    });
  });
})();
