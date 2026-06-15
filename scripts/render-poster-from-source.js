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

  // Hide the JS-injected sources QR globally via a stylesheet (so per-render
  // reset code that does `el.style.display = ''` on `.poster-body > *` can't
  // resurrect it). The QR has no value on a phone screen — sources live in
  // the IG bio link tree instead — and removing it gives recalcFit() more
  // vertical room so body text + photos scale larger.
  //
  // ALSO inject card-slide overrides that activate when an .poster element
  // gets data-slide-mode set. The default flow of the source layout top-
  // anchors content with no vertical centering and uses CSS columns —
  // when a card slide shows only one paragraph or one blockquote, the
  // result is a top-loaded slide with a huge empty bottom. The CSS below
  // centers the visible content vertically, kills the 2-column layout,
  // and bumps font sizes so single-element slides fill the 1080x1350 frame.
  await page.evaluate(() => {
    const style = document.createElement('style');
    style.id = 'social-renderer-overrides';
    style.textContent = `
      .poster-sources-qr { display: none !important; }

      /* Slide 2: band only — hide the body wrapper entirely (otherwise its
         padding + the gold-divider keep occupying vertical space) and
         expand the navy band to fill the entire frame as a title card
         with the kicker / title / sub vertically centered. */
      .poster[data-slide-mode="band"] .poster-body {
        display: none !important;
      }
      .poster[data-slide-mode="band"] .poster-inner {
        height: 100%;
      }
      .poster[data-slide-mode="band"] .poster-band {
        height: 100%;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        padding: 90px 70px !important;
        border-bottom: none !important;
        box-sizing: border-box;
      }
      .poster[data-slide-mode="band"] .poster-band .kicker {
        font-size: 1.6rem !important;
        letter-spacing: 7px !important;
        margin: 0 !important;
      }
      .poster[data-slide-mode="band"] .poster-band h2 {
        font-size: 5.4rem !important;
        line-height: 1.02 !important;
        margin: 0 !important;
      }
      .poster[data-slide-mode="band"] .poster-band .sub {
        font-size: 1.85rem !important;
        line-height: 1.45 !important;
        max-width: none !important;
        margin: 0 !important;
      }
      /* Gold rule pinned just below the title block as a divider between
         title and subtitle — a touch of brand color on the otherwise
         all-navy slide. */
      .poster[data-slide-mode="band"] .poster-band h2::after {
        content: '';
        display: block;
        width: 120px;
        height: 6px;
        background: var(--gold);
        margin: 24px 0 0;
      }

      /* Slides that show a single piece of body content (one para, one
         para + photo, or one blockquote): force single column, minimal
         padding (we want the renderer's post-pass scale to make the
         actual content fill the frame edge-to-edge — the body's normal
         padding would scale up into visible whitespace borders).
         Note we do NOT set height: 100% / flex-center on the body
         here — that would fake the body to always equal frame height
         and prevent the renderer's fill-frame post-pass from measuring
         the natural content height. */
      .poster[data-slide-mode="para"] .poster-body,
      .poster[data-slide-mode="para-photo"] .poster-body,
      .poster[data-slide-mode="quote"] .poster-body {
        column-count: 1 !important;
        column-rule: 0 !important;
        padding: 8px 14px !important;
      }
      /* Hide the gold-divider on card slides — it's a band-to-body
         separator that adds vertical bulk above the lone visible
         element (and reads as orphaned without the band above it). */
      .poster[data-slide-mode="para"] .poster-body > .gold-divider,
      .poster[data-slide-mode="para-photo"] .poster-body > .gold-divider,
      .poster[data-slide-mode="quote"] .poster-body > .gold-divider {
        display: none !important;
      }

      /* Paragraph-only slides — biggest possible body text. */
      .poster[data-slide-mode="para"] .poster-body p {
        font-size: 1.55rem !important;
        line-height: 1.5 !important;
        margin: 0 !important;
      }
      .poster[data-slide-mode="para"] .poster-body .lead-in {
        font-size: 1.4rem !important;
        display: block;
        margin-bottom: 10px;
      }

      /* Para + photo (slide 3) — keep both visible, vertically centered,
         photo enlarged. Photo de-floated so flex layout works. */
      .poster[data-slide-mode="para-photo"] .poster-body > .poster-photo {
        float: none !important;
        margin: 0 auto 22px !important;
        width: 100% !important;
        max-width: 720px !important;
        order: -1;  /* photo always on top of the stack */
      }
      .poster[data-slide-mode="para-photo"] .poster-body > .poster-photo img {
        max-height: 560px !important;
        max-width: 100% !important;
        width: auto !important;
        margin: 0 auto !important;
      }
      .poster[data-slide-mode="para-photo"] .poster-body p {
        font-size: 1.25rem !important;
        line-height: 1.5 !important;
        margin: 0 !important;
      }
      .poster[data-slide-mode="para-photo"] .poster-body .lead-in {
        font-size: 1.15rem !important;
        display: block;
        margin-bottom: 8px;
      }
      /* Strip any inline images out of the first paragraph during
         para-photo mode — the floating right-rail image they're meant
         to wrap around is gone, so they'd otherwise jam awkwardly into
         the centered text. The hero photo above is the visual anchor. */
      .poster[data-slide-mode="para-photo"] .poster-body p img {
        display: none !important;
      }

      /* Quote slides — large italic display, centered. */
      .poster[data-slide-mode="quote"] .poster-body blockquote {
        font-size: 1.55rem !important;
        line-height: 1.5 !important;
        margin: 0 !important;
        padding: 24px 28px !important;
        max-width: 100% !important;
      }

      /* Hide the gold divider on body-only card slides — it's a
         band-to-body separator that looks orphaned without the band. */
      .poster[data-slide-mode="para"] .poster-body .gold-divider,
      .poster[data-slide-mode="para-photo"] .poster-body .gold-divider,
      .poster[data-slide-mode="quote"] .poster-body .gold-divider {
        display: none !important;
      }
    `;
    document.head.appendChild(style);
    window.dispatchEvent(new Event('resize'));
  });


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
  // `opts.mode` (optional) sets data-slide-mode on the poster element, which
  // activates the card-slide CSS overrides in social-renderer-overrides:
  //   'full'       — slide 1 (no overrides; same as native fit)
  //   'band'       — slide 2 (vertically center the band)
  //   'para-photo' — slide 3 (single para + photo, vertically centered)
  //   'para'       — slides 4..K+2 (single para, no photo)
  //   'quote'      — slides K+3..end (single blockquote)
  async function compose(opts) {
    await page.evaluate(({ n, h, opts }) => {
      const p = document.getElementById('poster-' + n);
      const body = p.querySelector('.poster-body');

      p.style.height = h;
      if (opts.mode) p.dataset.slideMode = opts.mode;
      else delete p.dataset.slideMode;

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

      // Hide the sources block on every carousel slide (the QR is already
      // hidden globally in openSourcePage; the .sources <ul> is hidden by
      // the source's own CSS but defensively re-hide here too).
      const sources = body.querySelector(':scope > .sources');
      if (sources) sources.style.display = 'none';

      window.dispatchEvent(new Event('resize'));
    }, { n: posterNum, h: FRAME_HEIGHT, opts });
    await sleep(400);

    // POST-PASS: for card slides (anything other than 'full'), recalcFit's
    // MAX_DISTORT cap (1.18) and MIN_W floor (0.45) leave huge white space
    // when only one paragraph (or one quote / the band) is visible inside a
    // 1080x1350 frame. We replace its result with a more aggressive fit:
    //   1. Narrow the inner's layout width until the wrapped content's
    //      natural aspect ratio (h/w) is >= the frame's (h/w). At that
    //      point a uniform scale fills both axes.
    //   2. If even at the narrowest tested width (0.10 of frame) the
    //      content is still too "wide-and-short" (very little text — e.g.
    //      a single-sentence pull-quote), fall back to anisotropic scale
    //      with no distortion cap so the output still fills the frame.
    if (opts.mode && opts.mode !== 'full') {
      const debug = await page.evaluate((n) => {
        const p = document.getElementById('poster-' + n);
        if (!p) return null;
        const inner = p.querySelector(':scope > .poster-inner');
        if (!inner) return null;
        // Reset prior scale state.
        p.style.removeProperty('--fit-scale');
        p.style.removeProperty('--fit-scale-x');
        p.style.removeProperty('--fit-scale-y');
        const frameH = p.clientHeight;
        const frameW = p.clientWidth;
        if (!frameH || !frameW) return;
        const targetRatio = frameH / frameW;

        // Step 1: binary search for the layout width whose natural content
        // aspect ratio just exceeds the frame's. Search range w in
        // [0.10, 1.30] — 0.10 is narrower than recalcFit's 0.45 floor so
        // sparse cards can pack tall; 1.30 is wider for the rare case
        // where one paragraph's natural width already overflows the frame.
        function measure(w) {
          inner.style.width = (w * 100).toFixed(3) + '%';
          // Force synchronous layout.
          void inner.offsetHeight;
          return { ch: inner.scrollHeight, cw: inner.scrollWidth };
        }
        const MIN_W = 0.10, MAX_W = 1.30;
        let lo = MIN_W, hi = MAX_W;
        let bestW = MAX_W;
        // 14 iters: width precision ~ (MAX_W-MIN_W)/2^14 = 0.000073
        for (let i = 0; i < 14; i++) {
          const mid = (lo + hi) / 2;
          const m = measure(mid);
          const ratio = m.ch / m.cw;
          if (ratio >= targetRatio) {
            // Tall enough — could narrow further but this fits; remember and
            // try wider (less narrow) to find the LARGEST w that still fits.
            bestW = mid;
            lo = mid;
          } else {
            // Too wide-and-short — narrow more.
            hi = mid;
          }
        }
        // Step 2: apply the chosen width and compute scale to fill the frame.
        const finalM = measure(bestW);
        const sx = frameW / finalM.cw;
        const sy = frameH / finalM.ch;
        // If natural ratio matched target, sx ~ sy — uniform fill, no
        // distortion. If we hit the MIN_W floor (content still wider than
        // target), sy > sx — accept anisotropic stretch (no cap) so the
        // output still fills the frame edge-to-edge.
        p.style.setProperty('--fit-scale-x', sx.toFixed(4));
        p.style.setProperty('--fit-scale-y', sy.toFixed(4));
        p.style.setProperty('--fit-scale', Math.min(sx, sy).toFixed(4));
        return { frameW, frameH, bestW: bestW.toFixed(3), finalCw: finalM.cw, finalCh: finalM.ch, sx: sx.toFixed(3), sy: sy.toFixed(3) };
      }, posterNum);
      await sleep(250);
      // Re-read what the source DOM actually has after our writes.
      const verify = await page.evaluate((n) => {
        const p = document.getElementById('poster-' + n);
        return {
          fitX: p.style.getPropertyValue('--fit-scale-x'),
          fitY: p.style.getPropertyValue('--fit-scale-y'),
          innerWidth: p.querySelector(':scope > .poster-inner').style.width,
        };
      }, posterNum);
      if (process.env.DEBUG_FILL) {
        console.log(`    [fill ${opts.mode}] ${JSON.stringify(debug)} verify=${JSON.stringify(verify)}`);
      }
    }
  }

  // SLIDE 1: full poster, everything visible — same view as the 4:5 single.
  await compose({ band: true, photo: true, paras: 'all', quotes: 'all', mode: 'full' });
  await snap('full poster');

  // SLIDE 2: band only — the hero header.
  await compose({ band: true, photo: false, paras: 'none', quotes: 'none', mode: 'band' });
  await snap('band');

  // SLIDES 3..K+2: each paragraph in order. Photo rides with paragraph 1.
  for (let i = 0; i < counts.paras; i++) {
    await compose({
      band: false,
      photo: i === 0,
      paras: i,
      quotes: 'none',
      mode: i === 0 ? 'para-photo' : 'para',
    });
    await snap(i === 0 ? 'para 1 + photo' : `para ${i + 1}`);
  }

  // SLIDES K+3..end: each blockquote in order.
  for (let i = 0; i < counts.bqs; i++) {
    await compose({ band: false, photo: false, paras: 'none', quotes: i, mode: 'quote' });
    await snap(`quote ${i + 1}`);
  }

  // Restore the poster so subsequent renders see a clean DOM.
  await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    if (!p) return;
    p.style.height = '';
    delete p.dataset.slideMode;
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
