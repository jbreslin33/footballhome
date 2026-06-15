#!/usr/bin/env node
// generate-exhibit-card.js — Render social-media cards for the Lighthouse history exhibit.
//
// Content source: frontend/exhibit/posters-social.json (one entry per poster, with
// a `slides[]` array — one slide per prose paragraph of the printed poster).
//
// Output:
//   frontend/images/posts/exhibit-pNN-1.png    (1080x1080 IG square, slide 1)
//   frontend/images/posts/exhibit-pNN-2.png    (1080x1080 IG square, slide 2)
//   ...
//   frontend/images/posts/exhibit-pNN-fb.png   (1200x630  FB landscape)
//
// Usage:
//   node scripts/generate-exhibit-card.js 1         # all IG slides + FB
//   node scripts/generate-exhibit-card.js 1 3       # just slide 3
//   node scripts/generate-exhibit-card.js 1 fb      # just the FB landscape

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const ROOT = path.resolve(__dirname, '..');
const DATA_FILE = path.join(ROOT, 'frontend', 'exhibit', 'posters-social.json');
const POSTS_DIR = path.join(ROOT, 'frontend', 'images', 'posts');
if (!fs.existsSync(POSTS_DIR)) fs.mkdirSync(POSTS_DIR, { recursive: true });

// --- Brand tokens (mirror the printed exhibit palette) -------------------
const NAVY     = '#0F2C59';
const NAVY_2   = '#0a1f42';
const GOLD     = '#C5A880';
const GOLD_HI  = '#d8bd95';
const PAPER    = '#FAFAFA';
const INK      = '#2B2B2B';

const FOOTER = 'LIGHTHOUSE 1893 SC  ·  EST. 1897  ·  KENSINGTON, PHILADELPHIA';

// --- Image helpers --------------------------------------------------------
function imgToDataUri(relOrAbs) {
  if (!relOrAbs) return null;
  const abs = path.isAbsolute(relOrAbs) ? relOrAbs : path.join(ROOT, relOrAbs);
  if (!fs.existsSync(abs)) {
    console.warn(`  ! image not found: ${relOrAbs}`);
    return null;
  }
  const ext = path.extname(abs).toLowerCase();
  const mime = { '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
                 '.webp': 'image/webp', '.svg': 'image/svg+xml', '.gif': 'image/gif' }[ext] || 'image/png';
  return `data:${mime};base64,${fs.readFileSync(abs).toString('base64')}`;
}

// --- Shared CSS -----------------------------------------------------------
function baseStyles(W, H) {
  return `
  *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
  @import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Montserrat:wght@400;600;700;800;900&family=Open+Sans:wght@400;600;700;700i&display=swap');
  html, body { width: ${W}px; height: ${H}px; overflow: hidden; }
  body { font-family: 'Open Sans', 'Segoe UI', Arial, sans-serif; color: ${PAPER}; background: ${NAVY}; }
  .card { width: ${W}px; height: ${H}px; position: relative; background: ${NAVY}; overflow: hidden; }
  .gold-bar { position: absolute; top: 0; left: 0; right: 0; height: 10px; background: linear-gradient(90deg, ${GOLD}, ${GOLD_HI}, ${GOLD}); z-index: 5; }
  .gold-bar-bottom { position: absolute; bottom: 0; left: 0; right: 0; height: 6px; background: ${GOLD}; z-index: 5; }
  .footer { position: absolute; bottom: 22px; left: 0; right: 0; text-align: center; font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: 14px; letter-spacing: 4px; color: ${GOLD}; z-index: 4; }
  .slide-dot-row { position: absolute; bottom: 56px; left: 0; right: 0; display: flex; justify-content: center; gap: 8px; z-index: 4; }
  .slide-dot-row .dot { width: 8px; height: 8px; border-radius: 50%; background: rgba(197,168,128,0.30); }
  .slide-dot-row .dot.active { background: ${GOLD}; width: 22px; border-radius: 4px; }
  `;
}

// =========================================================================
// PARAGRAPH SLIDE  (single template for all IG slides)
//   - Optional top photo (45% of canvas) when slide.photo is set
//   - Optional pull-quote treatment when slide.type === 'quote'
//   - Optional footnote line under body (slide.footnote, e.g. stat strip)
// =========================================================================
function slideParagraph(p, slide, idx, total, W = 1080, H = 1080) {
  const isQuote = slide.type === 'quote';
  const photo = slide.photo ? imgToDataUri(slide.photo) : null;
  const PHOTO_H = photo ? 480 : 0;

  const dots = Array.from({ length: total }, (_, i) =>
    `<span class="dot${i === idx ? ' active' : ''}"></span>`).join('');

  // --- Quote variant -----------------------------------------------------
  if (isQuote) {
    return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>
    ${baseStyles(W, H)}
    .quote-card { padding: 120px 90px 130px; height: 100%; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; }
    .quote-mark { font-family: 'Bebas Neue', Georgia, serif; font-size: 220px; line-height: 0.8; color: ${GOLD}; opacity: 0.55; margin-bottom: 10px; }
    .kicker { font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: 18px; letter-spacing: 5px; color: ${GOLD}; margin-bottom: 22px; }
    .quote-body { font-family: 'Open Sans', Georgia, serif; font-style: italic; font-weight: 600; font-size: 36px; line-height: 1.38; color: ${PAPER}; max-width: 880px; }
    .quote-attr { margin-top: 32px; font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: 18px; letter-spacing: 3px; color: ${GOLD}; text-transform: uppercase; }
    .quote-rule { width: 70px; height: 3px; background: ${GOLD}; margin: 26px auto 0; }
    </style></head><body>
      <div class="card">
        <div class="gold-bar"></div>
        <div class="quote-card">
          <div class="quote-mark">“</div>
          ${slide.kicker ? `<div class="kicker">${slide.kicker}</div>` : ''}
          <div class="quote-body">${slide.body || ''}</div>
          <div class="quote-rule"></div>
          ${slide.attribution ? `<div class="quote-attr">${slide.attribution}</div>` : ''}
        </div>
        <div class="slide-dot-row">${dots}</div>
        <div class="footer">${FOOTER}</div>
        <div class="gold-bar-bottom"></div>
      </div></body></html>`;
  }

  // --- Standard paragraph variant ---------------------------------------
  // When a photo is present, body area shrinks; when not, body fills the canvas
  // and is vertically centered.
  const bodyTop = photo ? PHOTO_H + 56 : 110;
  const bodyMaxH = H - bodyTop - 110; /* leave room for footer + dot row */

  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>
  ${baseStyles(W, H)}
  ${photo ? `
    .photo { position: absolute; top: 10px; left: 0; right: 0; height: ${PHOTO_H}px; background: #000 center/cover no-repeat; background-image: url('${photo}'); }
    .photo::after { content: ''; position: absolute; inset: 0; background: linear-gradient(180deg, rgba(15,44,89,0) 70%, rgba(15,44,89,0.85) 100%); }
    .photo-credit { position: absolute; bottom: 8px; right: 14px; font-size: 11px; color: rgba(255,255,255,0.75); font-style: italic; max-width: 60%; text-align: right; z-index: 2; }
    .body-block { position: absolute; left: 70px; right: 70px; top: ${bodyTop}px; max-height: ${bodyMaxH}px; }
  ` : `
    .body-block { position: absolute; left: 80px; right: 80px; top: 70px; bottom: 110px; display: flex; flex-direction: column; justify-content: center; }
  `}
  .kicker { font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: 18px; letter-spacing: 5px; color: ${GOLD}; margin-bottom: 12px; }
  .headline { font-family: 'Bebas Neue', 'Montserrat', sans-serif; font-size: ${photo ? '52px' : '64px'}; line-height: 0.98; letter-spacing: 1.5px; color: ${PAPER}; margin-bottom: ${photo ? '18px' : '26px'}; }
  .body { font-family: 'Open Sans', sans-serif; font-weight: 400; font-size: ${photo ? '22px' : '26px'}; line-height: 1.48; color: ${PAPER}; opacity: 0.96; }
  .body strong { color: ${GOLD_HI}; font-weight: 700; }
  .body em { font-style: italic; }
  .footnote { margin-top: 22px; padding-top: 16px; border-top: 1px solid rgba(197,168,128,0.35); font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: 15px; letter-spacing: 1.5px; color: ${GOLD}; text-transform: uppercase; }
  </style></head><body>
    <div class="card">
      <div class="gold-bar"></div>
      ${photo ? `<div class="photo">${slide.photo_credit ? `<div class="photo-credit">${slide.photo_credit}</div>` : ''}</div>` : ''}
      <div class="body-block">
        ${slide.kicker ? `<div class="kicker">${slide.kicker}</div>` : ''}
        ${slide.headline ? `<div class="headline">${slide.headline}</div>` : ''}
        ${slide.body ? `<div class="body">${slide.body}</div>` : ''}
        ${slide.footnote ? `<div class="footnote">${slide.footnote}</div>` : ''}
      </div>
      <div class="slide-dot-row">${dots}</div>
      <div class="footer">${FOOTER}</div>
      <div class="gold-bar-bottom"></div>
    </div></body></html>`;
}

// =========================================================================
// SMASHED POSTER  (whole poster on a single canvas — every slide flattened)
//   H drives the typography scale:
//     H = 1350 (1080x1350, IG 4:5)  → "smashed" mode: tiny but fits IG feed
//     H = 2160 (1080x2160, 1:2)     → "long poster" mode: native print aspect,
//                                      legible on mobile, posts on Stories /
//                                      X / web / FB (NOT IG feed — 4:5 cap).
//   Reads the same poster.slides[] as the carousel. Slide 0 = hero (kicker +
//   title + sub + photo). Slides 1..N-1 = paragraphs (lead-in + body). Final
//   `type:'quote'` slide(s) = pull-quote with attribution.
// =========================================================================
function slidePoster(poster, W = 1080, H = 1350) {
  const long = H >= 1800;
  const heroSlide = (poster.slides && poster.slides[0]) || {};
  const bodySlides = (poster.slides || []).slice(1);
  const photo = imgToDataUri(heroSlide.photo);

  // Typography scale — picked so the dense P1 (640w body + 6 lead-ins +
  // 1 blockquote) fills the canvas; a measure-and-fit pass at render time
  // scales the body-region down (never up) if a poster overflows.
  const T = long
    ? { kicker: 20, title: 78, sub: 26, photoW: 420, photoH: 420, leadIn: 24, body: 24, lh: 1.45, gap: 18, quote: 30, attr: 16, pad: 64, footer: 14, gapFooter: 70 }
    : { kicker: 16, title: 52, sub: 19, photoW: 360, photoH: 360, leadIn: 18, body: 18, lh: 1.42, gap: 11, quote: 21, attr: 13, pad: 50, footer: 11, gapFooter: 50 };

  // Paragraph slides → inline rendering: bold-gold lead-in + body, separated
  // by a tight gap. Quote slides → italic pull-quote with gold rule + attr.
  const paragraphsHtml = bodySlides.map(s => {
    if (s.type === 'quote') {
      return `<div class="pq">
        <div class="pq-mark">“</div>
        <div class="pq-body">${s.body || ''}</div>
        <div class="pq-rule"></div>
        ${s.attribution ? `<div class="pq-attr">${s.attribution}</div>` : ''}
      </div>`;
    }
    return `<p class="para"><span class="lead">${s.headline || ''}</span> ${s.body || ''}</p>`;
  }).join('');

  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>
  ${baseStyles(W, H)}
  .card { display: flex; flex-direction: column; }
  /* The fit-stack wraps the band + body-region so a measure-and-shrink pass
     (post-render JS in renderHtmlToPng) can scale it down to fit between
     the top gold bar and the footer if a denser poster overflows. */
  .fit-stack { position: absolute; top: 10px; left: 0; right: 0; transform-origin: top center; width: ${W}px; }
  /* Header band — matches the printed poster's .poster-band */
  .band { background: ${NAVY_2}; border-bottom: 4px solid ${GOLD}; padding: ${T.pad * 0.55}px ${T.pad}px ${T.pad * 0.5}px; flex-shrink: 0; margin-top: 0; }
  .band .kicker { font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: ${T.kicker}px; letter-spacing: ${long ? 4 : 3}px; color: ${GOLD}; text-transform: uppercase; margin-bottom: ${long ? 8 : 5}px; }
  .band .title { font-family: 'Bebas Neue', 'Montserrat', sans-serif; font-size: ${T.title}px; line-height: 0.95; letter-spacing: 1.5px; color: ${PAPER}; margin-bottom: ${long ? 10 : 6}px; }
  .band .sub { font-family: 'Open Sans', sans-serif; font-style: italic; font-weight: 600; font-size: ${T.sub}px; line-height: 1.38; color: ${PAPER}; opacity: 0.92; max-width: 900px; }
  /* Body region: small floated photo + flowing paragraphs */
  .body-region { padding: ${T.pad * 0.45}px ${T.pad}px ${T.pad * 0.45}px; position: relative; }
  ${photo ? `
    .hero-photo { float: left; width: ${T.photoW}px; height: ${T.photoH}px; margin: 0 ${T.pad * 0.4}px ${T.pad * 0.3}px 0; background: #000 center/cover no-repeat; background-image: url('${photo}'); box-shadow: 0 6px 18px rgba(0,0,0,0.5); border-radius: 3px; position: relative; }
    .hero-photo::after { content: ''; position: absolute; inset: 0; box-shadow: inset 0 0 0 1px rgba(197,168,128,0.35); }
    ${heroSlide.photo_credit ? `.hero-photo .credit { position: absolute; bottom: 4px; right: 6px; left: 6px; font-size: ${long ? 9 : 7}px; color: rgba(255,255,255,0.78); font-style: italic; text-align: right; line-height: 1.2; text-shadow: 0 1px 2px rgba(0,0,0,0.7); z-index: 2; }` : ''}
  ` : ''}
  .para { font-family: 'Open Sans', sans-serif; font-size: ${T.body}px; line-height: ${T.lh}; color: ${PAPER}; opacity: 0.95; margin-bottom: ${T.gap}px; text-align: justify; hyphens: auto; }
  .para .lead { font-family: 'Open Sans', sans-serif; font-weight: 700; font-size: ${T.leadIn}px; color: ${GOLD_HI}; letter-spacing: 0.2px; }
  .para strong { color: ${GOLD_HI}; font-weight: 700; }
  .para em { font-style: italic; }
  /* Pull-quote — sits inline at the bottom of the prose */
  .pq { margin: ${T.gap * 1.4}px 0 ${T.gap}px; padding: ${long ? 18 : 10}px ${long ? 28 : 16}px ${long ? 20 : 12}px; border-left: 3px solid ${GOLD}; background: rgba(197,168,128,0.06); position: relative; }
  .pq-mark { position: absolute; top: ${long ? -8 : -4}px; left: ${long ? 14 : 8}px; font-family: 'Bebas Neue', Georgia, serif; font-size: ${long ? 70 : 42}px; line-height: 0.8; color: ${GOLD}; opacity: 0.5; }
  .pq-body { font-family: 'Open Sans', Georgia, serif; font-style: italic; font-weight: 600; font-size: ${T.quote}px; line-height: 1.4; color: ${PAPER}; padding-left: ${long ? 32 : 18}px; }
  .pq-rule { width: 50px; height: 2px; background: ${GOLD}; margin: ${long ? 12 : 6}px 0 0 ${long ? 32 : 18}px; }
  .pq-attr { margin-top: ${long ? 8 : 4}px; margin-left: ${long ? 32 : 18}px; font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: ${T.attr}px; letter-spacing: 2px; color: ${GOLD}; text-transform: uppercase; }
  .footer { font-size: ${T.footer}px; letter-spacing: ${long ? 4 : 3}px; bottom: ${long ? 18 : 14}px; }
  </style></head><body>
    <div class="card">
      <div class="gold-bar"></div>
      <div class="fit-stack" data-fit-stack="1" data-fit-max="${H - 10 - 6 - T.gapFooter}">
        <div class="band">
          ${poster.kicker ? `<div class="kicker">${poster.kicker}</div>` : ''}
          <div class="title">${poster.title || ''}</div>
          ${poster.sub ? `<div class="sub">${poster.sub}</div>` : ''}
        </div>
        <div class="body-region">
          ${photo ? `<div class="hero-photo">${heroSlide.photo_credit ? `<div class="credit">${heroSlide.photo_credit}</div>` : ''}</div>` : ''}
          ${paragraphsHtml}
        </div>
      </div>
      <div class="footer">${FOOTER}</div>
      <div class="gold-bar-bottom"></div>
    </div></body></html>`;
}

// =========================================================================
// FACEBOOK LANDSCAPE  (1200x630 hero treatment — single image post)
function slideFb(p, W = 1200, H = 630) {
  const hero = (p.slides && p.slides[0]) || {};
  const photoPath = hero.photo || p.hero_image; /* hero_image kept as fallback for legacy posters */
  const photoCredit = hero.photo_credit || p.hero_image_credit || '';
  const photo = imgToDataUri(photoPath);
  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>
  ${baseStyles(W, H)}
  .photo { position: absolute; top: 10px; left: 0; width: 540px; bottom: 6px; background: #000 center/cover no-repeat; ${photo ? `background-image: url('${photo}');` : ''} }
  .photo::after { content: ''; position: absolute; inset: 0; background: linear-gradient(90deg, rgba(15,44,89,0) 60%, rgba(15,44,89,0.95) 100%); }
  .text-pane { position: absolute; top: 10px; left: 540px; right: 0; bottom: 6px; padding: 60px 60px 60px 50px; display: flex; flex-direction: column; justify-content: center; }
  .kicker { font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: 16px; letter-spacing: 4px; color: ${GOLD}; margin-bottom: 14px; text-transform: uppercase; }
  .title { font-family: 'Bebas Neue', 'Montserrat', sans-serif; font-size: 60px; line-height: 0.95; letter-spacing: 1.5px; color: ${PAPER}; margin-bottom: 18px; }
  .sub { font-family: 'Open Sans', sans-serif; font-style: italic; font-weight: 600; font-size: 20px; line-height: 1.4; color: ${PAPER}; opacity: 0.95; }
  .photo-credit { position: absolute; bottom: 14px; left: 14px; font-size: 10px; color: rgba(255,255,255,0.65); font-style: italic; z-index: 2; }
  </style></head><body>
    <div class="card">
      <div class="gold-bar"></div>
      <div class="photo">${photoCredit ? `<div class="photo-credit">${photoCredit}</div>` : ''}</div>
      <div class="text-pane">
        ${p.kicker ? `<div class="kicker">${p.kicker}</div>` : ''}
        <div class="title">${p.title || ''}</div>
        <div class="sub">${p.sub || ''}</div>
      </div>
      <div class="footer">${FOOTER}</div>
      <div class="gold-bar-bottom"></div>
    </div></body></html>`;
}

// --- Renderer -------------------------------------------------------------
async function renderHtmlToPng(browser, html, outPath, W, H) {
  const page = await browser.newPage();
  await page.setViewport({ width: W, height: H, deviceScaleFactor: 1 });
  // Use domcontentloaded + explicit font wait — networkidle0 can hang when
  // fonts.googleapis.com is slow or blocked in the local env.
  await page.setContent(html, { waitUntil: 'domcontentloaded', timeout: 15000 });
  try {
    await page.evaluate(() => document.fonts && document.fonts.ready);
  } catch { /* fonts API may be unavailable; fall back to system fonts */ }
  await new Promise(r => setTimeout(r, 400));
  // Auto-fit pass: if a [data-fit-stack] element is taller than its
  // data-fit-max, scale-shrink it (origin top-left) to fit. Never upscale —
  // sparse posters keep their natural typography and leave breathing room
  // at the bottom (the footer's still anchored independently).
  await page.evaluate(() => {
    document.querySelectorAll('[data-fit-stack]').forEach(stack => {
      const maxH = parseFloat(stack.dataset.fitMax || '0');
      if (!maxH) return;
      const actual = stack.scrollHeight;
      if (actual > maxH) {
        const scale = maxH / actual;
        stack.style.transformOrigin = 'top left';
        stack.style.transform = `scale(${scale})`;
        stack.style.width = `${100 / scale}%`;
      }
    });
  });
  await new Promise(r => setTimeout(r, 150));
  await page.screenshot({ path: outPath, type: 'png', omitBackground: false });
  await page.close();
  const stats = fs.statSync(outPath);
  console.log(`  ✓ ${path.relative(ROOT, outPath)}  (${(stats.size/1024).toFixed(1)} KB)`);
}

// --- CLI ------------------------------------------------------------------
async function main() {
  const data = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
  const posterNum = parseInt(process.argv[2] || '1', 10);
  const onlyKey = process.argv[3]; // optional: a slide index ('1'..'10') or 'fb'

  const poster = data.posters.find(p => p.n === posterNum);
  if (!poster) {
    console.error(`Poster ${posterNum} not found in ${path.relative(ROOT, DATA_FILE)}`);
    process.exit(1);
  }

  const pad = String(posterNum).padStart(2, '0');
  const slides = poster.slides || [];
  if (!slides.length) {
    console.error(`Poster ${posterNum} has no slides[] entries.`);
    process.exit(1);
  }

  console.log(`Rendering poster ${posterNum} — ${poster.title} (${slides.length} IG slides + FB)`);
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    // IG square slides
    for (let i = 0; i < slides.length; i++) {
      const slideIdx = i + 1;
      if (onlyKey && !['fb', 'poster', 'longposter'].includes(onlyKey) && String(slideIdx) !== onlyKey) continue;
      if (['fb', 'poster', 'longposter'].includes(onlyKey || '')) continue;
      const outPath = path.join(POSTS_DIR, `exhibit-p${pad}-${slideIdx}.png`);
      const html = slideParagraph(poster, slides[i], i, slides.length, 1080, 1080);
      await renderHtmlToPng(browser, html, outPath, 1080, 1080);
    }

    // FB landscape (1200x630)
    if (!onlyKey || onlyKey === 'fb') {
      const outPath = path.join(POSTS_DIR, `exhibit-p${pad}-fb.png`);
      const html = slideFb(poster, 1200, 630);
      await renderHtmlToPng(browser, html, outPath, 1200, 630);
    }

    // Smashed-into-one IG portrait (1080x1350) — whole poster on one card
    if (!onlyKey || onlyKey === 'poster') {
      const outPath = path.join(POSTS_DIR, `exhibit-p${pad}-poster.png`);
      const html = slidePoster(poster, 1080, 1350);
      await renderHtmlToPng(browser, html, outPath, 1080, 1350);
    }

    // Long poster (1080x2160) — native 1:2 print aspect, for Stories / X / web
    if (!onlyKey || onlyKey === 'longposter') {
      const outPath = path.join(POSTS_DIR, `exhibit-p${pad}-longposter.png`);
      const html = slidePoster(poster, 1080, 2160);
      await renderHtmlToPng(browser, html, outPath, 1080, 2160);
    }
  } finally {
    await browser.close();
  }

  console.log(`Done.  Rendered: ${onlyKey || 'all (IG slides + FB + smashed poster + long poster)'}`);
  console.log(`Preview locally:  file://${path.join(ROOT, 'frontend/exhibit/slideshow.html')}?p=${posterNum}`);
}

main().catch(err => { console.error(err); process.exit(1); });
