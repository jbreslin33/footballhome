#!/usr/bin/env node
/**
 * render-poster-from-source.js
 *
 * Renders Instagram + print artefacts DIRECTLY from
 *   frontend/exhibit/lighthouse-history.html
 *
 * No intermediate JSON. The printed museum poster IS the source.
 * Whatever the printed poster says, the IG slides say. Same words,
 * same typography, same colours.
 *
 * Three outputs per poster N:
 *   1. exhibit-pNN-longposter.png  1080 x 2160   (native 2:4 portrait)
 *   2. exhibit-pNN-poster.png      1080 x 1350   (IG 4:5 single tile)
 *   3. exhibit-pNN-1.png ..-K.png  1080 x 1080   (IG carousel,
 *                                                  one slide per source
 *                                                  paragraph + each
 *                                                  blockquote)
 *
 * The source's own recalcFit() auto-scales content to whichever frame
 * we hand it, so we just resize the .poster element with inline CSS
 * and let the page do its thing. Resize events trigger the source's
 * debounced recalc.
 *
 * CLI:
 *   node scripts/render-poster-from-source.js <N>           # all 3 outputs
 *   node scripts/render-poster-from-source.js <N> long      # only longposter
 *   node scripts/render-poster-from-source.js <N> single    # only 4:5
 *   node scripts/render-poster-from-source.js <N> slides    # only carousel
 */

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const ROOT = path.resolve(__dirname, '..');
const SOURCE_PATH = path.join(ROOT, 'frontend/exhibit/lighthouse-history.html');
const SOURCE_URL = 'file://' + SOURCE_PATH;
const POSTS_DIR = path.join(ROOT, 'frontend/images/posts');

// 24 print-inches wide, 48 tall -> 1080 x 2160 at 45px/inch.
const PRINT_SCALE = 45;

// ---------------------------------------------------------------------------
// Puppeteer prep
// ---------------------------------------------------------------------------

async function openSourcePage(browser) {
  const page = await browser.newPage();
  // Viewport tall enough to host a full 1080x2160 poster without scrolling.
  await page.setViewport({ width: 1400, height: 2400, deviceScaleFactor: 1 });

  // The source pulls Google Fonts. networkidle0 hangs in this env, so do
  // domcontentloaded + explicit fonts.ready + a short settle.
  await page.goto(SOURCE_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
  try { await page.evaluate(() => document.fonts && document.fonts.ready); } catch {}

  // Force final-print mode (no diagnostic chrome, white poster on gray bg).
  // Click the button so the source's setMode() runs the proper RAF + recalc.
  await page.evaluate(() => {
    const btn = document.querySelector('button[data-mode="final"]');
    if (btn) btn.click();
    else document.body.dataset.mode = 'final';
  });

  // Pin the print scale so every poster's native 24 x 48 inches = 1080 x 2160 px.
  // The source has `body[data-scale="medium"] { --print-scale: 16px }`, so we need
  // !important to beat it, and we clear data-scale to neutralise the source's toggle.
  await page.evaluate((scale) => {
    document.body.removeAttribute('data-scale');
    document.documentElement.style.setProperty('--print-scale', scale + 'px', 'important');
    document.body.style.setProperty('--print-scale', scale + 'px', 'important');
    // Re-fit after CSS change.
    window.dispatchEvent(new Event('resize'));
  }, PRINT_SCALE);

  // Wait for poster images to finish loading.
  try {
    await page.waitForFunction(() => {
      const imgs = Array.from(document.querySelectorAll('.poster img'));
      if (!imgs.length) return false;
      return imgs.every(img => img.complete && img.naturalWidth > 0);
    }, { timeout: 20000 });
  } catch (e) {
    console.warn('⚠️  Some poster images did not finish loading; proceeding anyway.');
  }

  // Settle for the source's 100ms resize-debounce + RAF chain.
  await sleep(600);
  return page;
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

// ---------------------------------------------------------------------------
// Output 1: native 2:4 long poster — straight screenshot of #poster-N.
// ---------------------------------------------------------------------------

async function renderLongPoster(page, posterNum, outPath) {
  const el = await page.$(`#poster-${posterNum}`);
  if (!el) throw new Error(`#poster-${posterNum} not found in source HTML`);
  // Make sure no leftover inline overrides from a previous render are still on this element.
  await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    if (p) p.style.height = '';
    p.querySelectorAll('.poster-body > *').forEach(el => { el.style.display = ''; });
    const photo = p.querySelector('.poster-inner > .poster-photo, .poster-body > .poster-photo');
    if (photo) photo.style.display = '';
    window.dispatchEvent(new Event('resize'));
  }, posterNum);
  await sleep(400);
  await el.screenshot({ path: outPath, type: 'png' });
  console.log(`  ✓ longposter -> ${path.basename(outPath)} (1080x2160)`);
}

// ---------------------------------------------------------------------------
// Output 2: IG 4:5 single tile — override poster height to 30 print-inches
// so recalcFit() shrinks the existing content to fit a 1080 x 1350 frame.
// ---------------------------------------------------------------------------

async function renderSingleTile(page, posterNum, outPath) {
  await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    if (!p) return;
    // Show all body content (in case it was hidden by a previous carousel pass).
    p.querySelectorAll('.poster-body > *').forEach(el => { el.style.display = ''; });
    p.style.height = 'calc(30 * var(--print-scale))';
    window.dispatchEvent(new Event('resize'));
  }, posterNum);
  await sleep(500);
  const el = await page.$(`#poster-${posterNum}`);
  await el.screenshot({ path: outPath, type: 'png' });
  // Restore.
  await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    if (p) p.style.height = '';
    window.dispatchEvent(new Event('resize'));
  }, posterNum);
  await sleep(300);
  console.log(`  ✓ single    -> ${path.basename(outPath)} (1080x1350)`);
}

// ---------------------------------------------------------------------------
// Output 3: IG carousel — 1080 x 1350 (4:5) slides. IG requires every slide
// in a carousel to share an aspect ratio, so we use 4:5 across the board so
// slide 1 can be the full poster (same image as the single-tile output).
//
// Slide order:
//   1.        Full poster, nothing hidden    (= same view as the 4:5 single)
//   2.        Band only (header / kicker / title / sub)
//   3..K+2.   Each paragraph in turn. The photo rides with paragraph 1
//             (the source moves it next to the first <p> during init).
//   K+3..end. Each blockquote in turn.
// ---------------------------------------------------------------------------

async function renderCarouselSlides(page, posterNum, pad) {
  // Discover paragraph and blockquote count from the live DOM.
  const counts = await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    const body = p.querySelector('.poster-body');
    const paras = Array.from(body.querySelectorAll(':scope > p'));
    const bqs   = Array.from(body.querySelectorAll(':scope > blockquote'));
    return { paras: paras.length, bqs: bqs.length };
  }, posterNum);

  // 4:5 frame: 30 print-inches tall = 1080 x 1350 at scale 45.
  const FRAME_HEIGHT = 'calc(30 * var(--print-scale))';
  const slides = [];
  let slideIdx = 0;

  // Helper: write current state of #poster-N to disk as the next slide.
  async function snap(label) {
    slideIdx += 1;
    const outPath = path.join(POSTS_DIR, `exhibit-p${pad}-${slideIdx}.png`);
    const el = await page.$(`#poster-${posterNum}`);
    await el.screenshot({ path: outPath, type: 'png' });
    slides.push(outPath);
    console.log(`  ✓ slide ${slideIdx} (${label}) -> ${path.basename(outPath)} (1080x1350)`);
  }

  // Helper: apply a per-slide visibility pass and trigger the source's recalc.
  async function compose(opts) {
    await page.evaluate(({ n, h, opts }) => {
      const p = document.getElementById('poster-' + n);
      const body = p.querySelector('.poster-body');

      p.style.height = h;

      // Band on/off.
      p.querySelectorAll('.poster-band').forEach(el => {
        el.style.display = opts.band ? '' : 'none';
      });

      // Photo on/off.
      p.querySelectorAll('.poster-photo').forEach(el => {
        el.style.display = opts.photo ? '' : 'none';
      });

      // Paragraph visibility: 'all' | 'none' | <0-based index>.
      const paras = Array.from(body.querySelectorAll(':scope > p'));
      paras.forEach((para, i) => {
        if (opts.paras === 'all') para.style.display = '';
        else if (opts.paras === 'none') para.style.display = 'none';
        else para.style.display = (i === opts.paras) ? '' : 'none';
      });

      // Blockquote visibility: 'all' | 'none' | <0-based index>.
      const bqs = Array.from(body.querySelectorAll(':scope > blockquote'));
      bqs.forEach((bq, i) => {
        if (opts.quotes === 'all') bq.style.display = '';
        else if (opts.quotes === 'none') bq.style.display = 'none';
        else bq.style.display = (i === opts.quotes) ? '' : 'none';
      });

      // Hide sources block + injected QR on every carousel slide (they look
      // out of place at IG sizes; users tap through to the museum URL instead).
      const sources = body.querySelector(':scope > .sources');
      if (sources) sources.style.display = 'none';
      const qr = body.querySelector(':scope > .poster-sources-qr');
      if (qr) qr.style.display = opts.qr ? '' : 'none';

      window.dispatchEvent(new Event('resize'));
    }, { n: posterNum, h: FRAME_HEIGHT, opts });
    await sleep(400);
  }

  // SLIDE 1: full poster, everything visible — same view as the 4:5 single.
  await compose({ band: true, photo: true, paras: 'all', quotes: 'all', qr: true });
  await snap('full poster');

  // SLIDE 2: band only — the hero header.
  await compose({ band: true, photo: false, paras: 'none', quotes: 'none', qr: false });
  await snap('band');

  // SLIDES 3..K+2: each paragraph in order. Photo rides with paragraph 1.
  for (let i = 0; i < counts.paras; i++) {
    await compose({ band: false, photo: i === 0, paras: i, quotes: 'none', qr: false });
    await snap(i === 0 ? 'para 1 + photo' : `para ${i + 1}`);
  }

  // SLIDES K+3..end: each blockquote in order.
  for (let i = 0; i < counts.bqs; i++) {
    await compose({ band: false, photo: false, paras: 'none', quotes: i, qr: false });
    await snap(`quote ${i + 1}`);
  }

  // Restore the poster so subsequent renders see a clean DOM.
  await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    if (!p) return;
    p.style.height = '';
    p.querySelectorAll('.poster-band').forEach(el => { el.style.display = ''; });
    p.querySelectorAll('.poster-photo').forEach(el => { el.style.display = ''; });
    p.querySelectorAll('.poster-body > *').forEach(el => { el.style.display = ''; });
    window.dispatchEvent(new Event('resize'));
  }, posterNum);
  await sleep(300);

  return slides;
}

// ---------------------------------------------------------------------------
// Source metadata reader — exposes title/sub/first-paragraph so callers can
// build a caption without inventing anything.
// ---------------------------------------------------------------------------

async function readPosterMeta(page, posterNum) {
  return await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    if (!p) return null;
    const txt = el => el ? el.textContent.replace(/\s+/g, ' ').trim() : '';
    return {
      n,
      kicker:    txt(p.querySelector('.poster-band .kicker')),
      title:     txt(p.querySelector('.poster-band h2')),
      sub:       txt(p.querySelector('.poster-band .sub')),
      firstPara: txt(p.querySelector('.poster-body > p')),
    };
  }, posterNum);
}

// ---------------------------------------------------------------------------
// Public entry point: render one or all output kinds for poster N.
// ---------------------------------------------------------------------------

async function renderPoster(posterNum, kinds) {
  await ensureDir(POSTS_DIR);
  const pad = String(posterNum).padStart(2, '0');

  // Clean any prior outputs for this poster so stale slides don't linger.
  const prior = fs.readdirSync(POSTS_DIR)
    .filter(f => f.startsWith(`exhibit-p${pad}-`) && f.endsWith('.png'));
  prior.forEach(f => fs.unlinkSync(path.join(POSTS_DIR, f)));
  if (prior.length) console.log(`  · cleared ${prior.length} prior file(s) for p${pad}`);

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  try {
    const page = await openSourcePage(browser);

    // Sanity check: target poster exists.
    const exists = await page.$(`#poster-${posterNum}`);
    if (!exists) throw new Error(`Poster #${posterNum} not present in source HTML.`);

    const meta = await readPosterMeta(page, posterNum);
    console.log(`\n📰  Poster ${pad} — ${meta.title || '(untitled)'}`);

    let slideCount = 0;

    if (kinds.has('long')) {
      const out = path.join(POSTS_DIR, `exhibit-p${pad}-longposter.png`);
      await renderLongPoster(page, posterNum, out);
    }
    if (kinds.has('single')) {
      const out = path.join(POSTS_DIR, `exhibit-p${pad}-poster.png`);
      await renderSingleTile(page, posterNum, out);
    }
    if (kinds.has('slides')) {
      const slides = await renderCarouselSlides(page, posterNum, pad);
      slideCount = slides.length;
    }

    return { meta, slideCount };
  } finally {
    await browser.close();
  }
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

async function main() {
  const args = process.argv.slice(2);
  const posterNum = parseInt(args[0], 10);
  const mode = (args[1] || 'all').toLowerCase();

  if (!posterNum) {
    console.error('Usage: node scripts/render-poster-from-source.js <N> [long|single|slides|all]');
    process.exit(1);
  }

  const ALL = new Set(['long', 'single', 'slides']);
  let kinds;
  if (mode === 'all') kinds = ALL;
  else if (ALL.has(mode)) kinds = new Set([mode]);
  else { console.error(`Unknown mode "${mode}". Expected: long | single | slides | all`); process.exit(1); }

  const { slideCount } = await renderPoster(posterNum, kinds);
  if (kinds.has('slides')) console.log(`\n🖼  Carousel: ${slideCount} slide(s) rendered.`);
  console.log('\n✓ done.');
}

if (require.main === module) {
  main().catch(err => { console.error(err); process.exit(1); });
}

module.exports = { renderPoster, readPosterMeta };
