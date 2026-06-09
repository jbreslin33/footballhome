// scripts/generate-youth-signup-card.js
// Generates a 1080x1080 promo card for Lighthouse Youth Soccer signups
// and writes it to frontend/images/posts/youth-signup-ad.png.
//
// Optionally takes a promoId to also save as promo_<id>.jpg and update DB.
//
// Usage:
//   node scripts/generate-youth-signup-card.js               # writes youth-signup-ad.png only
//   node scripts/generate-youth-signup-card.js <promoId>     # also updates promo row

const puppeteer = require('puppeteer');
const path      = require('path');
const fs        = require('fs');
const { Client } = require('pg');

const promoId = process.argv[2] || null;

const ROOT       = path.resolve(__dirname, '..');
const POSTS_DIR  = path.join(ROOT, 'frontend', 'images', 'posts');
const STATIC_OUT = path.join(POSTS_DIR, 'youth-signup-ad.png');
const STATIC_URL = 'https://footballhome.org/images/posts/youth-signup-ad.png';

const LH_1893   = path.join(ROOT, 'frontend', 'images', 'teams', 'logos', 'lighthouse-1893.png');
const LH_CPLX   = path.join(ROOT, 'frontend', 'images', 'lighthouse-complex.png');
const LH_ORG    = path.join(ROOT, 'frontend', 'images', 'lighthouse-org.png');
const PPR       = path.join(ROOT, 'frontend', 'images', 'leagues', 'phila-parks-rec.jpg');
const EPYSA     = path.join(ROOT, 'frontend', 'images', 'leagues', 'epysa.png');
const USYS      = path.join(ROOT, 'frontend', 'images', 'leagues', 'usys.png');
const USSOCCER  = path.join(ROOT, 'frontend', 'images', 'leagues', 'ussoccer.png');
const FIFA      = path.join(ROOT, 'frontend', 'images', 'leagues', 'fifa.png');

function dataUri(p) {
  if (!fs.existsSync(p)) { console.warn('⚠️  missing:', p); return ''; }
  const ext = path.extname(p).toLowerCase();
  const mime = ext === '.png' ? 'image/png' : ext === '.jpg' || ext === '.jpeg' ? 'image/jpeg' : 'image/png';
  return `data:${mime};base64,${fs.readFileSync(p).toString('base64')}`;
}

const lh1893   = dataUri(LH_1893);
const lhCplx   = dataUri(LH_CPLX);
const lhOrg    = dataUri(LH_ORG);
const ppr      = dataUri(PPR);
const epysa    = dataUri(EPYSA);
const usys     = dataUri(USYS);
const ussoccer = dataUri(USSOCCER);
const fifa     = dataUri(FIFA);

const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  body { width:1080px; height:1080px; overflow:hidden;
         font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif; color:#fff; }
  .card {
    width:1080px; height:1080px; position:relative;
    background: radial-gradient(ellipse at 30% 20%, #1a3a8a 0%, #0d2247 45%, #060f25 100%);
    padding:60px;
  }
  .pattern {
    position:absolute; inset:0; opacity:0.06; pointer-events:none;
    background-image: radial-gradient(#ffffff 1px, transparent 1px);
    background-size: 22px 22px;
  }
  .gold-bar  { position:absolute; top:0; left:0; right:0; height:12px; background:#f5d442; }
  .gold-bar2 { position:absolute; bottom:0; left:0; right:0; height:12px; background:#f5d442; }

  .header {
    display:flex; align-items:center; gap:24px;
    margin-top:8px;
  }
  .header img { height:130px; width:auto; }
  .header .text { display:flex; flex-direction:column; line-height:1.05; }
  .header .text .club { font-size:30px; font-weight:900; letter-spacing:2px; }
  .header .text .since { font-size:18px; color:#f5d442; font-weight:700; letter-spacing:4px; }

  .hero {
    margin-top:60px;
    text-align:center;
  }
  .hero .kicker {
    font-size:28px; letter-spacing:16px; color:#f5d442; font-weight:800;
    text-transform:uppercase; opacity:0.95;
  }
  .hero h1 {
    font-size:150px; font-weight:900; letter-spacing:2px;
    line-height:0.95; margin-top:14px;
    text-shadow: 0 6px 24px rgba(0,0,0,0.55);
  }
  .hero h1 .accent { color:#f5d442; }
  .hero .sub {
    font-size:42px; font-weight:700; margin-top:30px; opacity:0.95;
  }
  .hero .sub strong { color:#f5d442; }
  .hero .leagues {
    font-size:30px; font-weight:800; margin-top:18px; color:#f5d442;
    letter-spacing:3px; text-transform:uppercase;
  }

  .pills {
    display:flex; justify-content:center; gap:14px; margin-top:24px; flex-wrap:wrap;
  }
  .pills .pill {
    background: rgba(245,212,66,0.18);
    border:2px solid rgba(245,212,66,0.55);
    color:#f5d442;
    padding:12px 22px;
    border-radius:999px;
    font-size:20px; font-weight:800;
    letter-spacing:1px;
  }

  .ages-block {
    margin-top:26px;
    display:flex; justify-content:center; align-items:center; gap:18px;
  }
  .ages-block .age-card {
    background: rgba(255,255,255,0.08);
    border:1px solid rgba(255,255,255,0.18);
    border-radius:16px;
    padding:20px 28px;
    text-align:center;
    min-width:170px;
  }
  .ages-block .age-card .label { font-size:14px; letter-spacing:3px; opacity:0.7; font-weight:700; }
  .ages-block .age-card .val { font-size:48px; font-weight:900; color:#f5d442; line-height:1; margin-top:4px; }
  .ages-block .age-card .small { font-size:14px; opacity:0.8; margin-top:6px; font-weight:600; }

  .perks {
    margin-top:34px;
    display:grid;
    grid-template-columns: repeat(3, 1fr);
    gap:16px;
  }
  .perks .perk {
    background: rgba(255,255,255,0.06);
    border:1px solid rgba(255,255,255,0.14);
    border-radius:14px;
    padding:18px;
    text-align:center;
  }
  .perks .perk .icon { font-size:34px; }
  .perks .perk .title { font-size:18px; font-weight:800; margin-top:6px; }
  .perks .perk .body { font-size:14px; opacity:0.8; margin-top:4px; line-height:1.3; }

  .cta-banner {
    margin-top:50px;
    background: #f5d442;
    color:#0a1628;
    border-radius:16px;
    padding:20px 24px;
    text-align:center;
  }
  .cta-banner .top { font-size:18px; font-weight:800; letter-spacing:3px; }
  .cta-banner .bottom { font-size:28px; font-weight:900; margin-top:4px; }

  .footer {
    position:absolute; bottom:30px; left:60px; right:60px;
    display:flex; flex-direction:column; align-items:center; gap:10px;
  }
  .footer .venue { text-align:center; }
  .footer .venue .name { font-size:16px; font-weight:800; }
  .footer .venue .addr { font-size:12px; opacity:0.8; margin-top:2px; }
  .footer .affiliations {
    display:flex; justify-content:center; align-items:center; gap:14px;
    margin-top:6px;
  }
  .footer .affiliations .label {
    font-size:10px; font-weight:800; letter-spacing:3px;
    color:#f5d442; opacity:0.85; text-transform:uppercase;
    writing-mode:vertical-rl; transform:rotate(180deg);
  }
  .footer .affiliations img {
    height:54px; width:auto; object-fit:contain;
    background:#fff; border-radius:8px; padding:5px; flex-shrink:0;
  }
</style>
</head>
<body>
  <div class="card">
    <div class="pattern"></div>
    <div class="gold-bar"></div>

    <div class="header">
      <img src="${lh1893}" alt="Lighthouse 1893">
      <div class="text">
        <div class="club">LIGHTHOUSE 1893 SC</div>
        <div class="since">EST. 1893 · PHILADELPHIA</div>
      </div>
    </div>

    <div class="hero">
      <div class="kicker">Now Enrolling</div>
      <h1>YOUTH<br><span class="accent">SOCCER</span></h1>
      <div class="sub">Boys &amp; Girls · <strong>1st – 6th Grade</strong></div>
      <div class="leagues">Travel &amp; In-House Leagues</div>
    </div>

    <div class="cta-banner">
      <div class="top">SUMMER TRAINING + FALL SEASON</div>
      <div class="bottom">All skill levels welcome</div>
    </div>

    <div class="footer">
      <div class="venue">
        <div class="name">📍 Lighthouse Sports &amp; Entertainment Complex · 199 East Erie Avenue, Philadelphia, PA 19140</div>
      </div>
    </div>

    <div class="gold-bar2"></div>
  </div>
</body></html>`;

(async () => {
  if (!fs.existsSync(POSTS_DIR)) fs.mkdirSync(POSTS_DIR, { recursive: true });

  console.log('🚀 Launching headless browser...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1080, height: 1080, deviceScaleFactor: 1 });
    await page.setContent(html, { waitUntil: 'networkidle0', timeout: 60000 });

    // Always write the canonical PNG used by the ad
    console.log('📸 Writing', STATIC_OUT);
    await page.screenshot({ path: STATIC_OUT, type: 'png', fullPage: false });

    // If promoId given, also save promo_<id>.jpg
    if (promoId) {
      const promoOut = path.join(POSTS_DIR, `promo_${promoId}.jpg`);
      console.log('📸 Writing', promoOut);
      await page.screenshot({ path: promoOut, type: 'jpeg', quality: 92, fullPage: false });
    }
  } finally {
    await browser.close();
  }

  console.log('✅ Wrote', STATIC_OUT);
  console.log('   URL: ' + STATIC_URL);

  if (promoId) {
    const url = `https://footballhome.org/images/posts/promo_${promoId}.jpg`;
    const client = new Client({
      host: process.env.PGHOST || 'localhost',
      port: process.env.PGPORT || 5432,
      user: process.env.PGUSER || 'footballhome_user',
      password: process.env.PGPASSWORD || 'footballhome_pass',
      database: process.env.PGDATABASE || 'footballhome',
    });
    await client.connect();
    try {
      const res = await client.query(
        `UPDATE promotional_posts
            SET image_path = $1, image_url = $2, updated_at = NOW()
          WHERE id = $3
          RETURNING id, title, status, image_url`,
        [`promo_${promoId}.jpg`, url, promoId]
      );
      console.log('✅ DB updated:', res.rows[0]);
    } finally {
      await client.end();
    }
  }
})().catch(err => {
  console.error('❌ Failed:', err);
  process.exit(1);
});
