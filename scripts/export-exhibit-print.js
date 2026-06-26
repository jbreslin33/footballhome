#!/usr/bin/env node
/**
 * export-exhibit-print.js
 *
 * Renders print-ready artefacts from frontend/exhibit/lighthouse-history.html
 * for every poster, so we can hand a single download page to a print shop
 * (Fireball Printing) and let them grab whatever format they need.
 *
 * Per poster N, produces three files in frontend/exhibit/print/:
 *   exhibit-pNN.pdf          — vector PDF at exact physical size
 *                              (24"×48" portrait, 48"×24" landscape, 24"×24" half)
 *   exhibit-pNN-hi-res.png   — ~150 DPI raster (e.g. 3600×7200 for portrait)
 *   exhibit-pNN-preview.png  — small ~67 DPI preview (1600×3200 for portrait)
 *
 * Also writes a manifest (print-manifest.json) consumed by print.html.
 *
 * CLI:
 *   node scripts/export-exhibit-print.js          # all posters, all formats
 *   node scripts/export-exhibit-print.js 3        # only poster 3
 *   node scripts/export-exhibit-print.js 3 5 7    # multiple specific posters
 */

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const ROOT = path.resolve(__dirname, '..');
const SOURCE_PATH = path.join(ROOT, 'frontend/exhibit/lighthouse-history.html');
const SOURCE_URL = 'file://' + SOURCE_PATH;
const OUT_DIR = path.join(ROOT, 'frontend/exhibit/print');
const MANIFEST_PATH = path.join(OUT_DIR, 'print-manifest.json');

// Layout scale for screen — keeps puppeteer DOM rendering reasonable.
// Final output PNG resolution is controlled separately via deviceScaleFactor.
const LAYOUT_SCALE = 30;          // px per print-inch (DOM size)
const HIRES_SCALE_FACTOR = 5;     // deviceScaleFactor for hi-res PNG → 150 DPI effective
const PREVIEW_SCALE_FACTOR = 2.2; // for preview PNG → ~67 DPI effective

const ORIENTATIONS = {
  portrait:  { wIn: 24, hIn: 48 },
  landscape: { wIn: 48, hIn: 24 },
  half:      { wIn: 24, hIn: 24 },
};

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

async function openSourcePage(browser, deviceScaleFactor) {
  const page = await browser.newPage();
  await page.setViewport({
    // Width = widest orientation (48in × LAYOUT_SCALE) + margin for layout chrome
    width: Math.ceil(48 * LAYOUT_SCALE) + 200,
    // Height: tall enough for portrait 48in × LAYOUT_SCALE + padding for body
    height: Math.ceil(48 * LAYOUT_SCALE) + 400,
    deviceScaleFactor: deviceScaleFactor,
  });
  await page.goto(SOURCE_URL, { waitUntil: 'domcontentloaded', timeout: 30000 });
  try { await page.evaluate(() => document.fonts && document.fonts.ready); } catch {}

  await page.evaluate((scale) => {
    // Force final-print mode (no chrome, white poster background)
    const btn = document.querySelector('button[data-mode="final"]');
    if (btn) btn.click();
    else document.body.dataset.mode = 'final';
    document.body.removeAttribute('data-scale');
    document.documentElement.style.setProperty('--print-scale', scale + 'px', 'important');
    document.body.style.setProperty('--print-scale', scale + 'px', 'important');
    window.dispatchEvent(new Event('resize'));
  }, LAYOUT_SCALE);

  // Strip chrome we don't want in print output
  await page.addStyleTag({
    content: `
      .poster-sources-qr { display: none !important; }
      .layout-toggle, .poster-fit-toggle, .intro, .footer, .toc { display: none !important; }
      body[data-mode="final"] {
        background: #fff !important;
        padding: 0 !important;
      }
      body[data-mode="final"] .poster {
        box-shadow: none !important;
        outline: none !important;
        margin: 0 !important;
      }
      body[data-mode="final"] .poster-list {
        gap: 0 !important;
        align-items: flex-start !important;
      }
    `,
  });

  // Wait for all poster images to load (silently swallow stragglers)
  try {
    await page.waitForFunction(() => {
      const imgs = Array.from(document.querySelectorAll('.poster img'));
      if (!imgs.length) return false;
      return imgs.every(img => img.complete && img.naturalWidth > 0);
    }, { timeout: 20000 });
  } catch {
    console.warn('  ⚠  Some poster images did not load fully; continuing.');
  }

  await sleep(600);
  return page;
}

async function getPosterMeta(page) {
  return page.evaluate(() => {
    const posters = Array.from(document.querySelectorAll('article.poster'));
    return posters.map((p, idx) => {
      const num = idx + 1;
      const orientation = p.dataset.orientation || 'portrait';
      const header = p.querySelector('.poster-band h2, .poster-band h1');
      const kicker = p.querySelector('.poster-band .kicker');
      return {
        num,
        id: p.id || ('poster-' + num),
        orientation,
        kicker: kicker ? kicker.textContent.trim() : '',
        title: header ? header.textContent.trim() : ('Poster ' + num),
      };
    });
  });
}

/**
 * Hide every poster except the target, then return target bounding box.
 */
async function isolatePoster(page, posterNum) {
  return page.evaluate((n) => {
    const posters = Array.from(document.querySelectorAll('article.poster'));
    posters.forEach((p, idx) => {
      p.style.display = (idx + 1 === n) ? '' : 'none';
    });
    // Also strip any wrapping diptychs that might affect layout
    document.querySelectorAll('.diptych').forEach(d => {
      const hasTarget = d.querySelector(`article.poster:nth-of-type(${n})`);
      // Always show diptych — its children visibility is what matters
      d.style.background = 'transparent';
      d.style.padding = '0';
      d.style.gap = '0';
      d.style.border = '0';
    });
    window.scrollTo(0, 0);
    window.dispatchEvent(new Event('resize'));
  }, posterNum);
}

async function renderHiResPNG(page, posterNum, outPath) {
  const el = await page.$(`#poster-${posterNum}`);
  if (!el) throw new Error(`#poster-${posterNum} not found`);
  await page.evaluate((n) => {
    const p = document.getElementById('poster-' + n);
    if (p) p.style.height = '';
    if (p) p.querySelectorAll('.poster-body > *').forEach(el => { el.style.display = ''; });
    window.dispatchEvent(new Event('resize'));
  }, posterNum);
  await sleep(400);
  await el.screenshot({ path: outPath, type: 'png' });
}

async function renderPDF(page, poster, outPath) {
  const dims = ORIENTATIONS[poster.orientation] || ORIENTATIONS.portrait;
  // Use Puppeteer's PDF mode with exact physical paper size.
  await page.pdf({
    path: outPath,
    width: dims.wIn + 'in',
    height: dims.hIn + 'in',
    printBackground: true,
    margin: { top: 0, right: 0, bottom: 0, left: 0 },
    preferCSSPageSize: false,
    pageRanges: '1',
  });
}

async function exportPoster(browser, poster, kinds) {
  console.log(`\n📜 Poster ${poster.num} (${poster.orientation}) — ${poster.title}`);
  const pad = String(poster.num).padStart(2, '0');

  if (kinds.has('hires')) {
    const page = await openSourcePage(browser, HIRES_SCALE_FACTOR);
    await isolatePoster(page, poster.num);
    const out = path.join(OUT_DIR, `exhibit-p${pad}-hi-res.png`);
    await renderHiResPNG(page, poster.num, out);
    const stat = fs.statSync(out);
    console.log(`  ✓ hi-res PNG   → ${path.basename(out)}  (${(stat.size / 1e6).toFixed(1)} MB)`);
    await page.close();
  }

  if (kinds.has('preview')) {
    const page = await openSourcePage(browser, PREVIEW_SCALE_FACTOR);
    await isolatePoster(page, poster.num);
    const out = path.join(OUT_DIR, `exhibit-p${pad}-preview.png`);
    await renderHiResPNG(page, poster.num, out);
    const stat = fs.statSync(out);
    console.log(`  ✓ preview PNG  → ${path.basename(out)}  (${(stat.size / 1e6).toFixed(1)} MB)`);
    await page.close();
  }

  if (kinds.has('pdf')) {
    const page = await openSourcePage(browser, 1);
    await isolatePoster(page, poster.num);
    const out = path.join(OUT_DIR, `exhibit-p${pad}.pdf`);
    await renderPDF(page, poster, out);
    const stat = fs.statSync(out);
    console.log(`  ✓ PDF          → ${path.basename(out)}  (${(stat.size / 1e6).toFixed(1)} MB)`);
    await page.close();
  }
}

function writeManifest(posters) {
  const manifest = posters.map(p => {
    const pad = String(p.num).padStart(2, '0');
    const dims = ORIENTATIONS[p.orientation] || ORIENTATIONS.portrait;
    const files = {};
    const pdf = `exhibit-p${pad}.pdf`;
    const hires = `exhibit-p${pad}-hi-res.png`;
    const preview = `exhibit-p${pad}-preview.png`;
    if (fs.existsSync(path.join(OUT_DIR, pdf)))    files.pdf = pdf;
    if (fs.existsSync(path.join(OUT_DIR, hires)))  files.hires = hires;
    if (fs.existsSync(path.join(OUT_DIR, preview))) files.preview = preview;
    return {
      num: p.num,
      pad,
      orientation: p.orientation,
      dimensions: `${dims.wIn}″ × ${dims.hIn}″`,
      kicker: p.kicker,
      title: p.title,
      files,
    };
  });
  fs.writeFileSync(MANIFEST_PATH, JSON.stringify({
    generatedAt: new Date().toISOString(),
    posters: manifest,
  }, null, 2));
  console.log(`\n📋 Wrote manifest → ${path.relative(ROOT, MANIFEST_PATH)}`);
}

async function main() {
  ensureDir(OUT_DIR);
  const argv = process.argv.slice(2);
  // Optional kinds filter via env or first arg "--kinds=pdf,hires,preview"
  // Default: hi-res PNGs only — that's the format Fireball Printing uses
  // and the only one we sync to the shared Drive folder.
  let kinds = new Set(['hires']);
  const kindArg = argv.find(a => a.startsWith('--kinds='));
  if (kindArg) {
    kinds = new Set(kindArg.split('=')[1].split(',').map(s => s.trim()));
  }
  const posterNums = argv.filter(a => /^\d+$/.test(a)).map(Number);

  console.log('🖨  Exporting exhibit posters for print …');
  console.log(`   Output: ${path.relative(ROOT, OUT_DIR)}/`);
  console.log(`   Kinds:  ${Array.from(kinds).join(', ')}`);

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    // First, enumerate posters once (using a discardable page).
    const tmp = await openSourcePage(browser, 1);
    const allPosters = await getPosterMeta(tmp);
    await tmp.close();
    console.log(`   Found ${allPosters.length} posters in source.\n`);

    const targets = posterNums.length
      ? allPosters.filter(p => posterNums.includes(p.num))
      : allPosters;

    for (const poster of targets) {
      await exportPoster(browser, poster, kinds);
    }

    writeManifest(allPosters);
  } finally {
    await browser.close();
  }

  console.log('\n✅ Done.');
}

if (require.main === module) {
  main().catch(err => {
    console.error('❌ export-exhibit-print failed:', err);
    process.exit(1);
  });
}

module.exports = { main };
