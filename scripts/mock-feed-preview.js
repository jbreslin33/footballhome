#!/usr/bin/env node
// scripts/mock-feed-preview.js
// Renders a realistic Instagram feed mockup for the youth-signup ad
// (faithful approximation — not Meta's official preview, but pixel-close)
//
// Usage:
//   node scripts/mock-feed-preview.js

const puppeteer = require('puppeteer');
const path      = require('path');
const fs        = require('fs');

const ROOT       = path.resolve(__dirname, '..');
const CARD_PATH  = path.join(ROOT, 'frontend', 'images', 'posts', 'youth-signup-ad.png');
const AVATAR     = path.join(ROOT, 'frontend', 'images', 'teams', 'logos', 'lighthouse-1893.png');
const OUT_FILE   = path.join(ROOT, 'frontend', 'images', 'posts', 'previews', 'youth-signup-instagram-mockup.png');

const CAPTION = `⚽ LIGHTHOUSE YOUTH SOCCER — NOW ENROLLING

Open to all boys & girls entering 1st through 6th grade.
Travel & In-House Leagues.

Summer training + fall season · all skill levels welcome.

📍 Lighthouse Sports & Entertainment Complex
199 East Erie Avenue, Philadelphia, PA 19140

#Lighthouse1893 #PhillySoccer #YouthSoccer`;

function dataUri(p) {
  const ext = path.extname(p).toLowerCase();
  const mime = ext === '.png' ? 'image/png' : 'image/jpeg';
  return `data:${mime};base64,${fs.readFileSync(p).toString('base64')}`;
}

const cardImg = dataUri(CARD_PATH);
const avatar  = dataUri(AVATAR);

// Truncate caption to first ~125 chars for IG feed display, with "...more"
const captionPreview = CAPTION.length > 125
  ? CAPTION.substring(0, 125) + '...'
  : CAPTION;

const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  body { background:#000; font-family: -apple-system, 'Segoe UI', Roboto, sans-serif; }
  .ig-post {
    width:540px; background:#000; color:#fff;
    font-size:14px;
  }
  .ig-header {
    display:flex; align-items:center; padding:12px 16px;
    border-bottom:1px solid #262626;
  }
  .ig-header .avatar {
    width:34px; height:34px; border-radius:50%;
    background:#fff; padding:2px; margin-right:12px;
    object-fit:contain;
  }
  .ig-header .meta { flex:1; }
  .ig-header .username { font-weight:600; font-size:14px; line-height:1.2; }
  .ig-header .sponsored {
    font-size:12px; color:#a8a8a8; line-height:1.2; margin-top:2px;
    display:flex; align-items:center; gap:3px;
  }
  .ig-header .more {
    color:#fff; font-size:20px; font-weight:bold;
  }

  .ig-image { width:540px; height:540px; display:block; }

  .ig-cta-bar {
    background:#1a1a1a;
    padding:10px 16px;
    display:flex; align-items:center; justify-content:space-between;
    border-bottom:1px solid #262626;
  }
  .ig-cta-bar .cta-text { font-size:13px; color:#fff; }
  .ig-cta-bar .cta-text .small { color:#a8a8a8; font-size:12px; display:block; }
  .ig-cta-bar .cta-btn {
    background:#0095f6; color:#fff; font-weight:600;
    padding:8px 14px; border-radius:6px;
    font-size:13px; cursor:pointer;
  }
  .ig-cta-bar .chev { color:#fff; }

  .ig-actions {
    padding:10px 16px;
    display:flex; gap:16px;
  }
  .ig-actions svg { width:24px; height:24px; fill:none; stroke:#fff; stroke-width:2; }

  .ig-caption {
    padding:4px 16px 12px;
    font-size:14px; line-height:1.35;
    color:#fff;
    white-space:pre-wrap;
    word-wrap:break-word;
  }
  .ig-caption .username { font-weight:600; margin-right:6px; }
  .ig-caption .more-link { color:#a8a8a8; cursor:pointer; }

  .ig-time {
    padding:0 16px 12px;
    font-size:11px; color:#a8a8a8; text-transform:uppercase;
  }

  /* Label */
  .label {
    color:#fff; font-size:18px; font-weight:600;
    text-align:center; padding:20px 0;
    background:#000;
  }
</style></head>
<body>
  <div class="label">📱 Instagram Feed Preview</div>
  <div class="ig-post">
    <div class="ig-header">
      <img class="avatar" src="${avatar}" alt="">
      <div class="meta">
        <div class="username">lighthouse1893soccerclub</div>
        <div class="sponsored">Sponsored · Philadelphia, PA</div>
      </div>
      <div class="more">⋯</div>
    </div>

    <img class="ig-image" src="${cardImg}" alt="">

    <div class="ig-cta-bar">
      <div class="cta-text">
        Lighthouse Youth Soccer
        <span class="small">linktr.ee · Now enrolling</span>
      </div>
      <div class="cta-btn">Sign Up</div>
    </div>

    <div class="ig-actions">
      <svg viewBox="0 0 24 24"><path d="M16.7 5.4c-1.7 0-3.3 1-4.7 2.7C10.6 6.4 9 5.4 7.3 5.4c-3 0-5.3 2.4-5.3 5.4 0 5.1 9.3 11.2 9.7 11.5.3.2.7.2 1 0 .4-.3 9.7-6.4 9.7-11.5 0-3-2.3-5.4-5.3-5.4z"/></svg>
      <svg viewBox="0 0 24 24"><path d="M20.6 3.4H3.4c-.5 0-.9.4-.9.9v17.4l3.7-3h14.4c.5 0 .9-.4.9-.9V4.3c0-.5-.4-.9-.9-.9z"/></svg>
      <svg viewBox="0 0 24 24"><path d="M22 3L9.2 14.4 2 11l20-8zM22 3l-7 17-3.8-7.7L22 3z"/></svg>
    </div>

    <div class="ig-caption">
      <span class="username">lighthouse1893soccerclub</span>${captionPreview}<span class="more-link"> more</span>
    </div>

    <div class="ig-time">Just now</div>
  </div>
</body></html>`;

(async () => {
  if (!fs.existsSync(path.dirname(OUT_FILE))) fs.mkdirSync(path.dirname(OUT_FILE), { recursive: true });

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 540, height: 900, deviceScaleFactor: 2 });
    await page.setContent(html, { waitUntil: 'networkidle0' });
    const h = await page.evaluate(() => document.body.scrollHeight);
    await page.setViewport({ width: 540, height: h, deviceScaleFactor: 2 });
    await page.screenshot({ path: OUT_FILE, type: 'png', fullPage: true });
  } finally {
    await browser.close();
  }

  console.log('✅ Wrote', OUT_FILE);
})().catch(err => {
  console.error('❌ Failed:', err);
  process.exit(1);
});
