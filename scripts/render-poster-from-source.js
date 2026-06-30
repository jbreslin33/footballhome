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
         render the navy band as a tight, centered title card. Do NOT
         force height:100% on the band/inner — let it have its NATURAL
         stacked height so the renderer's post-pass binary-search can
         narrow the layout width (forcing the title + sub to wrap onto
         more lines) and then scale-to-fill the 1080x1350 frame. With
         the old height:100% + justify-content:space-between setup the
         band always reported scrollHeight === frame height, so the
         post-pass found nothing to do and left huge vertical gaps. */
      .poster[data-slide-mode="band"] .poster-body {
        display: none !important;
      }
      .poster[data-slide-mode="band"] .poster-band {
        display: block !important;
        padding: 70px 70px !important;
        border-bottom: none !important;
        box-sizing: border-box;
      }
      .poster[data-slide-mode="band"] .poster-band .kicker {
        font-size: 1.6rem !important;
        letter-spacing: 7px !important;
        margin: 0 0 36px 0 !important;
      }
      .poster[data-slide-mode="band"] .poster-band h2 {
        font-size: 5.4rem !important;
        line-height: 1.05 !important;
        margin: 0 !important;
      }
      .poster[data-slide-mode="band"] .poster-band .sub {
        font-size: 1.85rem !important;
        line-height: 1.45 !important;
        max-width: none !important;
        margin: 36px 0 0 0 !important;
      }
      /* Gold rule pinned just below the title as a brand-color divider
         between title and subtitle. */
      .poster[data-slide-mode="band"] .poster-band h2::after {
        content: '';
        display: block;
        width: 120px;
        height: 6px;
        background: var(--gold);
        margin: 28px 0 0;
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

      /* Hide inline decorative figures on card slides. These are the
         right-floated / left-floated portrait <figure>s embedded inside
         .poster-body (e.g. poster 16's "Walter Bahr in his US kit"
         portrait, poster 18's Hollywood-film and book figures). They
         belong with their attached paragraph in the printed museum
         layout, but without explicit per-slide pairing they leak onto
         every card slide. The dedicated hero <figure class="poster-photo">
         is excluded so it still rides slide 3 (the para-photo slide).
         JS sets display:none too but the static .two-col rule wins on
         specificity; this !important rule is the actual enforcement. */
      .poster[data-slide-mode="para"] .poster-body > figure:not(.poster-photo),
      .poster[data-slide-mode="para-photo"] .poster-body > figure:not(.poster-photo),
      .poster[data-slide-mode="quote"] .poster-body > figure:not(.poster-photo) {
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

      /* Slide 1 (full poster squashed to 4:5): the article paragraphs use
         inline style="clear:right" / "clear:left" / "clear:both" to give
         the long 24x48 print poster a clean visual rhythm — but at the
         squashed 1080x1350 frame those clears leave big empty bands
         below floated photos because the next paragraph won't begin
         until the float is past. Strip the clears in full mode so text
         flows naturally around the floats and packs the frame edge-to-
         edge. Inline style wins normally, so this rule needs !important. */
      .poster[data-slide-mode="full"] .poster-body > p,
      .poster[data-slide-mode="full"] .poster-body > blockquote,
      .poster[data-slide-mode="full"] .poster-body > ul,
      .poster[data-slide-mode="full"] .poster-body > ol {
        clear: none !important;
      }
      /* Tighten paragraph spacing in full mode for the same reason —
         the source's natural margin-bottom is generous for the long
         poster, but at 4:5 every saved px lets recalcFit/post-pass
         scale text up. */
      .poster[data-slide-mode="full"] .poster-body > p {
        margin-top: 0 !important;
        margin-bottom: 8px !important;
      }
      /* Cap the width of inline floated photos in full mode. The source
         uses 200-260px widths tuned for the 24-inch print poster, which
         at the squashed 4:5 frame creates tall floats whose tails extend
         below the text — leaving an L-shaped white gap in the corner
         next to the float. A smaller width gives a shorter float tail
         (height scales with width since each image is height:auto), so
         text catches up to the float bottom and there's no orphan
         column.
         NOTE: matching specificity of the source's own .two-col rules
         (lighthouse-history.html ~line 305) which set width:auto +
         max-width:35% with !important — without matching those exact
         selectors our cap loses on specificity tie-break. */
      .poster[data-slide-mode="full"] .poster-body p > img[style*="float:right"],
      .poster[data-slide-mode="full"] .poster-body p > img[style*="float:left"],
      .poster[data-slide-mode="full"] .poster-body.two-col p > img[style*="float:right"],
      .poster[data-slide-mode="full"] .poster-body.two-col p > img[style*="float:left"] {
        width: 150px !important;
        max-width: 150px !important;
        height: auto !important;
        max-height: none !important;
        margin-top: 2px !important;
        margin-bottom: 6px !important;
      }
      /* Belt-and-suspenders: any remaining gap below the last float
         gets eaten by a flow-root on the body so the inner's
         scrollHeight reflects ONLY visible content, plus min-height to
         force the body to fill the frame. The post-pass then scales
         the actually-visible content uniformly with no trailing dead
         space at the bottom. */
      .poster[data-slide-mode="full"] .poster-body {
        display: flow-root !important;
      }

      /* Opt-in: 2-column slide 1. The default full-mode rule collapses
         to 1 column because floats don't wrap across column boxes —
         text-heavy posters with no floated images (or where the dead-
         band tradeoff is acceptable) can re-enable 2-col by adding
         class="full-two-col" to the article element. Higher specificity
         than the source's [data-slide-mode=full] .poster-body.two-col
         rule via the extra class. */
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col {
        column-count: 2 !important;
        -webkit-column-count: 2 !important;
        column-gap: 24px !important;
        column-rule: 1px solid rgba(15,44,89,0.12) !important;
        display: block !important;  /* flow-root above kills columns */
        /* column-fill: balance (default) equalises column heights — the
           post-pass then scales the body so both columns reach the
           bottom. break-inside: avoid below keeps the blockquote /
           callout intact so the balancer has clean break points. */
      }
      /* Keep blockquotes / callouts intact across the column break. */
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col blockquote,
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col p[style*="border-left"] {
        break-inside: avoid !important;
        -webkit-column-break-inside: avoid !important;
      }
      /* Span the blockquote across both columns as a horizontal feature
         band. This removes the single tallest indivisible element from
         the balanced-column flow, letting the remaining paragraphs
         distribute much more evenly between col 1 and col 2 — no
         leftover dead bands at the bottom of either column. */
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col > blockquote {
        column-span: all !important;
        -webkit-column-span: all !important;
        margin: 14px 0 !important;
      }
      /* Pump up body text in 2-col full mode — the balanced columns
         naturally leave bottom dead-space when total content is
         smaller than 2*frame-height, so growing the type makes the
         columns balance taller and squeeze that gap shut. The post-
         pass scaler then clamps both columns at exactly frame height. */
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col p,
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col li {
        font-size: 1.15rem !important;
        line-height: 1.45 !important;
      }
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col blockquote {
        font-size: 1.1rem !important;
        line-height: 1.45 !important;
      }
      /* The closing callout (last .poster-body > p with the inline
         border-left styling) anchors the poster — span it across both
         columns so it sits as a wide footer band and absorbs the
         column-balance dead space at the bottom of column 2. */
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col > p:last-child[style*="border-left"] {
        column-span: all !important;
        -webkit-column-span: all !important;
        margin-top: 16px !important;
      }
      /* In 2-col full mode, keep images floated INSIDE their column so
         the surrounding text wraps around them — no blank side bands.
         Width is capped to ~45% of column so there's room for 2-3
         words per line beside the image. The source's inline
         clear:left/right/both on following paragraphs is stripped
         (see the full-mode clear:none rule above) so float-wrap works
         clean. Floats are constrained to their own column by the
         column algorithm, so they can't bleed into the neighbor. */
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col p > img[style*="float:right"] {
        float: right !important;
        display: inline !important;
        width: 42% !important;
        max-width: 42% !important;
        height: auto !important;
        max-height: none !important;
        object-fit: initial !important;
        margin: 2px 0 6px 10px !important;
      }
      .poster.full-two-col[data-slide-mode="full"] .poster-body.two-col p > img[style*="float:left"] {
        float: left !important;
        display: inline !important;
        width: 42% !important;
        max-width: 42% !important;
        height: auto !important;
        max-height: none !important;
        object-fit: initial !important;
        margin: 2px 10px 6px 0 !important;
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
    // Mark as a compact 4:5 "full" view so the source's
    // [data-slide-mode="full"] CSS hooks (height caps on body images,
    // etc.) apply — same flag the carousel slide 1 uses.
    p.dataset.slideMode = 'full';
    window.dispatchEvent(new Event('resize'));
  }, posterNum);
  await sleep(500);
  const el = await page.$(`#poster-${posterNum}`);
  await el.screenshot({ path: outPath, type: 'png' });
  // Restore.
  await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    if (p) {
      p.style.height = '';
      delete p.dataset.slideMode;
    }
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
//   3..K+2.   Each paragraph in turn. The photo rides with the paragraph
//             indicated by data-photo-with-para on <article class="poster">
//             (1-based, defaults to 1).
//   K+3..end. Each blockquote in turn.
// ---------------------------------------------------------------------------

async function renderCarouselSlides(page, posterNum, pad) {
  // Discover paragraph and blockquote count from the live DOM, plus which
  // paragraph the .poster-photo should ride with on its own slide.
  const counts = await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    const body = p.querySelector('.poster-body');
    const paras = Array.from(body.querySelectorAll(':scope > p'));
    const bqs   = Array.from(body.querySelectorAll(':scope > blockquote'));
    // Does this poster have a dedicated .poster-photo <figure>? Some
    // posters (P6, P7) embed images inline inside paragraphs instead and
    // have no separate hero figure — for those we must NOT switch to
    // 'para-photo' mode (which would hide the inline <img> tags assuming
    // a real figure is available) and should just render every paragraph
    // in 'para' mode so the inline images stay visible.
    const hasPhotoFigure = !!p.querySelector(':scope > .poster-inner > .poster-photo, :scope > .poster-photo');
    // 1-based in source for readability ("3rd paragraph"); convert to
    // 0-based here. Default: paragraph 1.
    const raw = parseInt(p.dataset.photoWithPara || '1', 10);
    const photoParaIdx = Math.max(0, Math.min(paras.length - 1, (isNaN(raw) ? 1 : raw) - 1));
    return { paras: paras.length, bqs: bqs.length, photoParaIdx, hasPhotoFigure };
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

      // For card slides (single-paragraph / single-quote modes), also hide
      // every other direct body child that isn't a <p>, <blockquote>, or
      // <figure class="poster-photo"> — i.e. side-rail decorations like
      // .note (staff-only display instructions), .badge-list, stray <ul>,
      // <div class="note">, etc. Without this they'd pile onto every card
      // and break the "one paragraph per slide" rhythm. Full / band slides
      // keep them visible so the long poster still reads as the printed
      // exhibit panel does.
      const isCard = opts.mode === 'para' || opts.mode === 'para-photo' || opts.mode === 'quote';
      if (isCard) {
        Array.from(body.children).forEach(child => {
          const tag = child.tagName.toLowerCase();
          // Keep the chosen para / quote and (for para-photo) the figure.
          if (tag === 'p' || tag === 'blockquote') return; // visibility set above
          // Only the dedicated hero <figure class="poster-photo"> is
          // toggled by the photo on/off pass above. Other inline figures
          // (e.g. the right-floated "Walter Bahr in his US kit" portrait
          // inside poster 16's body) are paragraph-attached decorations
          // that would otherwise float onto every card slide. The actual
          // enforcement is the !important CSS rule in social-renderer-
          // overrides (the static .two-col stylesheet overrides this
          // inline style on specificity) — the inline set here is just
          // defense-in-depth.
          if (tag === 'figure') {
            if (child.classList.contains('poster-photo')) return;
            child.style.display = 'none';
            return;
          }
          // gold-divider is already hidden by social-renderer-overrides CSS
          // for card slides; hiding it inline too is harmless and avoids
          // any specificity surprises.
          child.style.display = 'none';
        });
      }

      window.dispatchEvent(new Event('resize'));
    }, { n: posterNum, h: FRAME_HEIGHT, opts });
    await sleep(400);

    // POST-PASS: replace recalcFit's result with a more aggressive fit so
    // every slide fills the 1080x1350 frame edge-to-edge. recalcFit's
    // MAX_DISTORT cap (1.18) and MIN_W floor (0.45) leave huge white
    // space when only a single paragraph (or the band, or a wide-and-
    // short full-poster squashed from 2:4 to 4:5) is visible.
    //   1. Narrow the inner's layout width until the wrapped content's
    //      natural aspect ratio (h/w) is >= the frame's (h/w). At that
    //      point a uniform scale fills both axes.
    //   2. If even at the narrowest tested width (0.10 of frame) the
    //      content is still too "wide-and-short" (very little text — e.g.
    //      a single-sentence pull-quote, or a band with a 3-word title),
    //      fall back to anisotropic scale with no distortion cap so the
    //      output still fills the frame.
    // Applied to ALL modes including 'full' — without it, slide 1 of
    // image-heavy posters left ~30% blank at the bottom because
    // recalcFit only scales DOWN, never up, and was hitting the
    // "sparse poster" branch on the squashed 4:5 frame.
    if (opts.mode) {
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

  // SLIDES 3..K+2: each paragraph in order. If this poster has a
  // dedicated .poster-photo figure, ride it with the paragraph chosen by
  // data-photo-with-para (default: paragraph 1) in 'para-photo' mode.
  // If the poster has NO dedicated figure (P6/P7 style — inline images
  // inside the paragraph), render every paragraph in plain 'para' mode
  // so the inline <img> tags stay visible (para-photo mode hides them).
  for (let i = 0; i < counts.paras; i++) {
    const withPhoto = counts.hasPhotoFigure && (i === counts.photoParaIdx);
    await compose({
      band: false,
      photo: withPhoto,
      paras: i,
      quotes: 'none',
      mode: withPhoto ? 'para-photo' : 'para',
    });
    await snap(withPhoto ? `para ${i + 1} + photo` : `para ${i + 1}`);
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
